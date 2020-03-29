//
//  ListController.swift
//  Miksing
//
//  Created by Jerome Robbins on 2020-03-28.
//  Copyright © 2020 Tregz. All rights reserved.
//

import UIKit
import CoreData

class ListController<T> : UITableViewController, NSFetchedResultsControllerDelegate where T: NSManagedObject {
    
    let cache:NSCache<AnyObject, AnyObject>! = NSCache()
    var context: NSManagedObjectContext? = nil
    var descriptors:[String]! { return [] }
    var filters:[Int?]? = []
    var isAscending:[Bool]! { return [] }
    var searching:String! = ""
    var searchQuery: String { return "" }
    var sorting: Int! = 0
    var sortSection:[String]! { return [] }
    
    var predicateRelationQuery: String? { return nil }
    var predicateRelationEntityId: String? { return nil }

    func getCacheName() -> String {
        return "Playlist"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.rowHeight = 43.5;
        let appDelegate  = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        clearsSelectionOnViewWillAppear = false // preserve selection between tabs
    }
    
    // MARK: - Fetched results controller
    
    var _fetchedResultsController: NSFetchedResultsController<T>? = nil
    var fetchedResultsController: NSFetchedResultsController<T> {
        if _fetchedResultsController != nil { return _fetchedResultsController! }
        fetchController()
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
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest:request, managedObjectContext:context!, sectionNameKeyPath:sortSection![sorting!], cacheName: getCacheName())
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        fetchUpdate()
    }
    
    func fetchPredicates() -> NSCompoundPredicate {
        var predicates: [NSPredicate] = []
        if (predicateRelationEntityId != nil) {
            predicates.append(NSPredicate(format: predicateRelationQuery!, predicateRelationEntityId!))
        }
        if (searching != "") { predicates.append(NSPredicate(format: searchQuery, searching, searching)) }
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
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: getCacheName())
        fetchedResultsController.fetchRequest.predicate = fetchPredicates()
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Fetch")
            print("\(fetchError), \(fetchError.localizedDescription)") }
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ListHolder
        let song = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withEvent: song, indexPath: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView,
        titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController.sections { return sections[section].name }
        return nil
    }
    
    override func tableView(_ tableView: UITableView,
        viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionLabel")
        cell?.textLabel?.text = fetchedResultsController.sections?[section].name
        return cell
    }
    
    func configureCell(_ cell: ListHolder, withEvent data: T, indexPath: IndexPath) {}
    
}
