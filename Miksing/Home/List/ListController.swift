//
//  ListController.swift
//  Miksing
//
//  Created by Jerome Robbins on 2020-03-28.
//  Copyright © 2020 Tregz. All rights reserved.
//

import UIKit
import CoreData

class ListController<T> : UITableViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating where T: NSManagedObject {
    
    let cache:NSCache<AnyObject, AnyObject>! = NSCache()
    var context: NSManagedObjectContext? {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    var descriptors:[String]! { return [] }
    var filters:[Int?]? = []
    var isAscending:[Bool]! { return [] }
    var searchCancelButtonColor: UIColor { return UIColor.white }
    let sortIcon:[String]! = ["SF_textformat_abc", "SF_calendar_badge_plus"]
    var sorting: Int! = 0
    var sortSection:[String]! { return [] }
    
    var predicateRelationQuery: String? { return nil }
    var predicateRelationEntityId: String? { return nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.rowHeight = 43.5;
        tableView.backgroundColor = TintColor.primaryLight
        setSearchBar()
    }
    
    // MARK: - Search controller
    
    let searchController = UISearchController(searchResultsController: nil)
    var searching:String! = ""
    var searchQuery: String { return "" }
    var searchCancelButtonShows = false
    
    func setSearchBar() {
        searchController.searchBar.placeholder = "Search"
        if #available(iOS 13.0, *) {
            searchController.searchBar.searchTextField.backgroundColor = TintColor.primaryPage
        } else {
            let searchField = searchController.searchBar.value(forKey: "searchField") as? UITextField
            searchField?.backgroundColor = TintColor.primaryPage
        }
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        if #available(iOS 11.0, *) { navigationItem.searchController = searchController }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        setSearchCancelButtonColor()
        setAVPanoramicAspect(isPanoramic: false)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        setAVPanoramicAspect(isPanoramic: true)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        searching = searchController.searchBar.text!
        fetchUpdate()
    }
    
    private func setAVPanoramicAspect(isPanoramic: Bool) {
        let name = Notification.Name(HomeController.notificationPanoramicAspect)
        let info = [HomeController.notificationPanoramicAspect: isPanoramic]
        NotificationCenter.default.post(name: name, object: nil, userInfo: info)
    }
    
    private func setSearchCancelButtonColor() {
        // Cancel button is not yet available on first load
        if !searchCancelButtonShows {
            guard searchController.searchBar.showsCancelButton else {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { self.setSearchCancelButtonColor() }
                return
            }
            searchCancelButtonShows = true
            let button = searchController.searchBar.value(forKey: "cancelButton") as? UIButton
            button?.setTitleColor(searchCancelButtonColor, for: .normal)
        }
    }
    
    // MARK: - Fetched results controller
    
    var _fetchedResultsController: NSFetchedResultsController<T>? = nil
    var fetchedResultsController: NSFetchedResultsController<T>? {
        if _fetchedResultsController != nil { return _fetchedResultsController! }
        fetchController()
        if _fetchedResultsController == nil { return nil }
        return _fetchedResultsController!
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert: tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete: tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update: if (tableView.cellForRow(at: indexPath!) != nil) {
            let cell =  tableView.cellForRow(at: indexPath!)! as! ListHolder
            configureCell(cell, withEvent: anObject as! T, indexPath: indexPath!)
        }
        case .move: if (tableView.cellForRow(at: indexPath!) != nil) {
            let cell =  tableView.cellForRow(at: indexPath!)! as! ListHolder
            configureCell(cell, withEvent: anObject as! T, indexPath: indexPath!)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
        @unknown default: return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange sectionInfo: NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType
    ) {
        switch type {
        case .insert: tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete: tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default: return
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func fetchController() {
        guard let request: NSFetchRequest<T> = T.fetchRequest() as? NSFetchRequest<T> else {
            fatalError("Can't set up NSFetchRequest")
        }
        request.fetchBatchSize = 20 // Set the batch size to a suitable number.
        let sortDescriptor = NSSortDescriptor(key: descriptors![sorting!], ascending: isAscending![sorting!])
        request.sortDescriptors = [sortDescriptor]
        if (context != nil) {
            let aFetchedResultsController = NSFetchedResultsController(fetchRequest:request, managedObjectContext:context!, sectionNameKeyPath:sortSection![sorting!], cacheName: "ListCache")
            aFetchedResultsController.delegate = self
            _fetchedResultsController = aFetchedResultsController
            fetchUpdate()
        }
    }
    
    func fetchPredicates() -> NSCompoundPredicate {
        var predicates: [NSPredicate] = []
        if (predicateRelationEntityId != nil) {
            predicates.append(NSPredicate(format: predicateRelationQuery!, predicateRelationEntityId!))
        }
        /* if (searching != "") { predicates.append(NSPredicate(format: searchQuery, searching, searching)) } */
        if (searching != "" && searchQuery != "") {
            predicates.append(NSPredicate(format: searchQuery, searching))
        }
        if filters!.count > 0 {
            var format = DataNotation.GS + "  == " + String(filters![0]!)
            for i in 1..<filters!.count {
                format += " || " + DataNotation.GS + " == " + String(filters![i]!)
            }
            predicates.append(NSPredicate(format:"(" + format + ")"))
        }
        return NSCompoundPredicate(andPredicateWithSubpredicates:predicates)
    }
    
    func fetchUpdate() {
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: "ListCache")
        fetchedResultsController?.fetchRequest.predicate = fetchPredicates()
        do {
            try self.fetchedResultsController?.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Fetch")
            print("\(fetchError), \(fetchError.localizedDescription)") }
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ListHolder
        let song = fetchedResultsController?.object(at: indexPath)
        if song != nil { configureCell(cell, withEvent: song!, indexPath: indexPath) }
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView,
        titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController?.sections { return sections[section].name }
        return nil
    }
    
    override func tableView(_ tableView: UITableView,
        viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionLabel")
        cell?.textLabel?.text = fetchedResultsController?.sections?[section].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = TintColor.primaryLight
    }
    
    func configureCell(_ cell: ListHolder, withEvent data: T, indexPath: IndexPath) {}
    
}
