//
//  TubeController.swift
//  Miksing
//
//  Created by Jerome Robbins on 2020-03-28.
//  Copyright © 2020 Tregz. All rights reserved.
//

import UIKit
import CoreData

class TubeController : ListController<Tube> {
    
    override var descriptors:[String]! { return [DataNotation.ID] }
    override var sortSection:[String]! { return ["alpha"] }
    override var isAscending:[Bool]! { return [true] }
    override var searchQuery: String {
        if (NSLocale.current.languageCode == "fr") { return "(langs.fr contains [cd] %@)" }
        else { return "(langs.en contains [cd] %@)" }
    }
    
    override func configureCell(_ cell: ListHolder, withEvent tube: Tube, indexPath: IndexPath) {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let action = #selector(setDisplayModeToPrimaryHidden(_:))
        let stop = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: action)
        navigationController?.topViewController!.navigationItem.rightBarButtonItem = stop
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
    
    private func showDetailView(appDelegate: AppDelegate, splitViewController: UISplitViewController) {
        let info: [String: Int] = [HomePager.notificationPaging: 1]
        let name = Notification.Name(HomePager.notificationPaging)
        NotificationCenter.default.post(name: name, object: nil, userInfo: info)
        splitViewController.showDetailViewController(appDelegate.homeScreen!, sender: self)
    }
    
    @objc func setDisplayModeToPrimaryHidden(_ sender: Any?) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let splitViewController = appDelegate.window!.rootViewController as! UISplitViewController
        if viewIfLoaded?.window != nil { splitViewController.preferredDisplayMode = .primaryHidden }
    }
}
