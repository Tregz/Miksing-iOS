//
//  TubeController.swift
//  Miksing
//
//  Created by Jerome Robbins on 2020-03-28.
//  Copyright © 2020 Tregz. All rights reserved.
//

import UIKit
import CoreData

class TubeController : ListController<Tube>,
    UICollectionViewDataSource,
    UITabBarDelegate {
    
    override var descriptors:[String]! { return [DataNotation.ID] }
    override var sortSection:[String]! { return ["alpha"] }
    override var isAscending:[Bool]! { return [true] }
    override var searchCancelButtonColor: UIColor { return UIColor.black }
    override var searchQuery: String {
        if (NSLocale.current.languageCode == "fr") { return "(langs.fr contains [cd] %@)" }
        else { return "(langs.en contains [cd] %@)" }
    }
    
    private var tabs: UITabBar?
    private let filterCell = "FilterCell"
    @IBOutlet weak var filterView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /* let expand = #selector(tabsVisibility(_:))
        let tag = UIImage(named: "SF_tag_fill")
        let options = UIBarButtonItem(image: tag, style: .done, target: self, action: expand)
        options.tintColor = TintColor.secondaryDark
        navigationItem.leftBarButtonItem = options */
        
        let button =  UIButton(type: .custom)
        button.setTitle(navigationItem.title, for: .normal)
        button.setTitleColor(TintColor.secondaryDark, for: .normal)
        button.addTarget(self, action: #selector(headerVisibility(_:)), for: .touchUpInside)
        navigationItem.titleView = button
        
        let hide = #selector(setDisplayModeToPrimaryHidden(_:))
        let stop = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: hide)
        stop.tintColor = TintColor.secondaryDark
        navigationItem.rightBarButtonItem = stop
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Set navigation views for screen size
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let splitViewController = appDelegate.window!.rootViewController as! UISplitViewController
        if splitViewController.preferredDisplayMode == .primaryHidden {
            splitViewController.preferredDisplayMode = .automatic
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showDetailView(appDelegate: appDelegate, splitViewController: splitViewController)
            }
        }
        // Load header menu
        guard let header = tableView.tableHeaderView else { return }
        let height = header.frame.height
        let width = header.frame.width
        filterView.collectionViewLayout = ViewCollection.layout(columns: 3, width: width, height: height)
        filterView.backgroundColor = TintColor.primaryLight
        filterView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: filterCell)
        filterView.dataSource = self
    }

    
    override func viewDidLayoutSubviews() {
        /* if tabs == nil {
            tabs = UITabBar()
            // Tabs data
            tabs!.delegate = self
            let apero = UITabBarItem(title: "Apero", image: UIImage(named: "cocktail"), tag: 0)
            let bistro = UITabBarItem(title: "Bistro", image: UIImage(named: "charge"), tag: 0)
            let club = UITabBarItem(title: "Club", image: UIImage(named: "funk"), tag: 0)
            tabs!.setItems([apero, bistro, club], animated: false)
            tabs!.selectedItem = apero
            // Tabs look
            tabs!.barTintColor = TintColor.primaryOrange
            tabs!.isTranslucent = false
            tabs!.tintColor = TintColor.secondaryDarkish
            // Tabs layout
            header.addSubview(tabs!)
            tabs!.leadingAnchor.constraint(equalTo: header.leadingAnchor).isActive = true
            tabs!.trailingAnchor.constraint(equalTo: header.trailingAnchor).isActive = true
            tabs!.translatesAutoresizingMaskIntoConstraints = false
        } */
    }
    
    @objc func setDisplayModeToPrimaryHidden(_ sender: Any?) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let splitViewController = appDelegate.window!.rootViewController as! UISplitViewController
        if viewIfLoaded?.window != nil { splitViewController.preferredDisplayMode = .primaryHidden }
    }
    
    @objc func headerVisibility(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        guard let header = tableView.tableHeaderView else { return }
        if sender.isSelected { header.frame.size.height = 0 }
        else { header.frame.size.height = CGFloat(44) }
        tableView.tableHeaderView = header
        UIView.animate(withDuration: 0.1, animations: {
            self.tableView.layoutIfNeeded()
        })
    }
    
    private func showDetailView(appDelegate: AppDelegate, splitViewController: UISplitViewController) {
        let info: [String: Int] = [HomePager.notificationPaging: 1]
        let name = Notification.Name(HomePager.notificationPaging)
        NotificationCenter.default.post(name: name, object: nil, userInfo: info)
        splitViewController.showDetailViewController(appDelegate.homeScreen!, sender: self)
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    
    }
    
    // MARK: - Collection view
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: filterCell, for:indexPath)
        let button = UIButton(frame:CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height))
        button.setImage(UIImage(named: TubeAtmosphere.allCases[indexPath.row].icon), for: .normal)
        button.setTitle(TubeAtmosphere.allCases[indexPath.row].name, for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.tintColor = UIColor.darkGray
        button.tag = indexPath.row
        button.addTarget(self, action: #selector(selectItemAt(_:)), for: .touchUpInside)
        cell.addSubview(button)
        return cell
    }
    
    @objc func selectItemAt(_ sender: UIButton) {
        print("button selected \(sender.tag)")
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
                //filters!.append(idea)
                sender.tintColor = TintColor.secondaryDarkish
                sender.setTitleColor(TintColor.secondaryDark, for: .normal)
            } else {
                //filters!.remove(at:filters!.index(of:idea)!)
                sender.setTitleColor(UIColor.darkGray, for: .normal)
                sender.tintColor = UIColor.darkGray
            }
        //}
        fetchUpdate()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TubeAtmosphere.allCases.count
    }
    
    // MARK: - Table view
    
    override func configureCell(_ cell: ListRow, withEvent tube: Tube, indexPath: IndexPath) {
        cell.title.text = tube.name ?? ""
        cell.prefix.text = NSLocalizedString("by", tableName: "TubeLocalizable", comment: "") + " "
        cell.subtitle.text = tube.user?.name ?? ""
        if (self.cache.object(forKey: tube.id as AnyObject) != nil) {
            cell.thumbnail.image = self.cache.object(forKey: tube.id as AnyObject) as? UIImage
        } else if (tube.id != nil) {
            // do something
        }
    }
    
    override func tableView(_ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath) {
        print("tableView didSelect \(indexPath.row)")
        if (tableView.cellForRow(at:indexPath) != nil) {
            let tubeId: String = fetchedResultsController?.object(at: indexPath).id ?? ""
            SongSelected.selectedRelationEntityId = tubeId
            SongSelected.shouldUpdate = true
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let splitViewController = appDelegate.window!.rootViewController as! UISplitViewController
            self.showDetailView(appDelegate: appDelegate, splitViewController: splitViewController)
        }
    }
    
    override func tableView(_ tableView: UITableView,
        titleForHeaderInSection section: Int) -> String? {
        if section > 0, let sections = fetchedResultsController?.sections { return sections[section].name }
        return nil
    }
    
    override func tableView(_ tableView: UITableView,
        viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let id = ListSection.reuseIdentifier
            guard let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: id) as? ListSection
            else { return nil }
            return cell
        } else { return tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionLabel") }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if section == 0, let header = view as? ListSection {
            header.title.text = fetchedResultsController?.sections?[section].name
        }
        view.tintColor = TintColor.primaryOrange
    }
}
