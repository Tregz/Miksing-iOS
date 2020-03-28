//
//  SongTable.swift
//  Miksing
//
//  Created by Jerome Robbins on 2020-03-23.
//  Copyright © 2020 Tregz. All rights reserved.
//

import UIKit
import CoreData

class SongPlaylist : UITableViewController, NSFetchedResultsControllerDelegate {

    let cache:NSCache<AnyObject, AnyObject>! = NSCache()
    let session = URLSession.shared
    var context: NSManagedObjectContext? = nil
    var filters:[Int?]? = []

    var searching:String! = ""
    var sorting: Int! = 0
    
    func getCurrentTabPosition() -> Int {
        return 0
    }
    
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
    
    var _fetchedResultsController: NSFetchedResultsController<Song>? = nil
    var fetchedResultsController: NSFetchedResultsController<Song> {
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
            let cell =  tableView.cellForRow(at: indexPath!)! as! SongCell
            configureCell(cell, withEvent: anObject as! Song, indexPath: indexPath!)
        }
        case .move: if (tableView.cellForRow(at: indexPath!) != nil) {
            let cell =  tableView.cellForRow(at: indexPath!)! as! SongCell
            configureCell(cell, withEvent: anObject as! Song, indexPath: indexPath!)
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
        let descriptors:[String]! = ["name"]
        let sortSection:[String]! = ["alpha", "fresh"]
        let request: NSFetchRequest<Song> = Song.fetchRequest()
        request.fetchBatchSize = 20 // Set the batch size to a suitable number.
        let sortDescriptor = NSSortDescriptor(key: descriptors![sorting!], ascending: true)
        request.sortDescriptors = [sortDescriptor]
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest:request, managedObjectContext:context!, sectionNameKeyPath:sortSection![sorting!], cacheName: getCacheName())
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        fetchUpdate()
    }
    
    func fetchPredicates() -> NSCompoundPredicate {
        var predicates: [NSPredicate] = []
        if (searching != "") {
            let format = "(name contains [cd] %@) || (mark contains [cd] %@)"
            predicates.append(NSPredicate(format:format, searching, searching)) }
        if filters!.count > 0 { var format = "genre == " + String(filters![0]!)
            for i in 1..<filters!.count { format += " || genre == " + String(filters![i]!) }
            predicates.append(NSPredicate(format:"(" + format + ")")) }
        return NSCompoundPredicate(andPredicateWithSubpredicates:predicates)
    }
    
    func fetchUpdate() {
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: getCacheName())
        fetchedResultsController.fetchRequest.predicate = fetchPredicates()
        do { try self.fetchedResultsController.performFetch()
        } catch { let fetchError = error as NSError
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SongCell
        let song = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withEvent: song, indexPath: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath) {
        if (tableView.cellForRow(at:indexPath) != nil) {
            let songId: [String: String] = ["id": fetchedResultsController.object(at: indexPath).id ?? ""]
            NotificationCenter.default.post(name: Notification.Name("YouTubePlay"), object: nil, userInfo: songId)
        }
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
                
    private func configureCell(_ cell: SongCell, withEvent song: Song, indexPath: IndexPath) {
        cell.name.text = song.name ?? ""
        cell.artist.text = song.artist ?? ""
        if (self.cache.object(forKey: song.id as AnyObject) != nil) {
            cell.icon.image = self.cache.object(forKey: song.id as AnyObject) as? UIImage }
        else if (song.id != nil) {
            let url:URL! = URL(string: "https://img.youtube.com/vi/" + song.id! + "/0.jpg")
            var task: URLSessionDownloadTask!
            task = session.downloadTask(with: url, completionHandler: { (location, response, error) -> Void in
                if let data = try? Data(contentsOf: url) { DispatchQueue.main.async(execute: { () -> Void in
                        let img:UIImage! = UIImage(data: data)
                        cell.icon.image = img
                        self.cache.setObject(img, forKey: song.id as AnyObject) }) } })
            task.resume() }
    }
                
}
