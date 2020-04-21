//
//  TubeController.swift
//  Miksing
//
//  Created by Jerome Robbins on 2020-03-28.
//  Copyright © 2020 Tregz. All rights reserved.
//

import UIKit
import CoreData

class TubeController : ListController<Tube>, UITabBarDelegate {
    
    override var descriptors:[String]! { return [DataNotation.ID] }
    override var sortSection:[String]! { return ["alpha"] }
    override var isAscending:[Bool]! { return [true] }
    override var searchCancelButtonColor: UIColor { return UIColor.black }
    override var searchQuery: String {
        if (NSLocale.current.languageCode == "fr") { return "(langs.fr contains [cd] %@)" }
        else { return "(langs.en contains [cd] %@)" }
    }
    
    var tabs: UITabBar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let action = #selector(setDisplayModeToPrimaryHidden(_:))
        let stop = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: action)
        stop.tintColor = TintColor.secondaryDark
        navigationItem.rightBarButtonItem = stop
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let splitViewController = appDelegate.window!.rootViewController as! UISplitViewController
        if splitViewController.preferredDisplayMode == .primaryHidden {
            splitViewController.preferredDisplayMode = .automatic
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showDetailView(appDelegate: appDelegate, splitViewController: splitViewController)
            }
        }
    }
    
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
            if tabs == nil {
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
                header.cvFilters.addSubview(tabs!)
                tabs!.leadingAnchor.constraint(equalTo: header.cvFilters.leadingAnchor).isActive = true
                tabs!.trailingAnchor.constraint(equalTo: header.cvFilters.trailingAnchor).isActive = true
                tabs!.translatesAutoresizingMaskIntoConstraints = false
            }
        }
        view.tintColor = TintColor.primaryOrange
    }
    
    @objc func setDisplayModeToPrimaryHidden(_ sender: Any?) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let splitViewController = appDelegate.window!.rootViewController as! UISplitViewController
        if viewIfLoaded?.window != nil { splitViewController.preferredDisplayMode = .primaryHidden }
    }
    
    private func showDetailView(appDelegate: AppDelegate, splitViewController: UISplitViewController) {
        let info: [String: Int] = [HomePager.notificationPaging: 1]
        let name = Notification.Name(HomePager.notificationPaging)
        NotificationCenter.default.post(name: name, object: nil, userInfo: info)
        splitViewController.showDetailViewController(appDelegate.homeScreen!, sender: self)
    }
}
