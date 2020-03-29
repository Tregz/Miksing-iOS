//
//  SongTable.swift
//  Miksing
//
//  Created by Jerome Robbins on 2020-03-23.
//  Copyright © 2020 Tregz. All rights reserved.
//

import UIKit
import CoreData

class SongController : ListController<Song> {

    let session = URLSession.shared
    
    override var descriptors:[String]! { return [DataNotation.NS, DataNotation.RD] }
    override var sortSection:[String]! { return ["alpha", "fresh"] }
    override var isAscending:[Bool]! { return [true, false] }
    override var searchQuery: String {
        return "(" + DataNotation.NS + " contains [cd] %@) || (" + DataNotation.AS + " contains [cd] %@)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        let name = Notification.Name(HomeScreen.COMPARATOR)
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { notification in
            self.sorting = notification.userInfo?["Comparator"] as? Int ?? 0
            self.fetchController()
        }
    }
    
    // MARK: - Table view data source
                
    override func configureCell(_ cell: ListHolder, withEvent song: Song, indexPath: IndexPath) {
        cell.title.text = song.name ?? ""
        cell.subtitle.text = song.artist ?? ""
        if (self.cache.object(forKey: song.id as AnyObject) != nil) {
            cell.thumbnail.image = self.cache.object(forKey: song.id as AnyObject) as? UIImage }
        else if (song.id != nil) {
            let url:URL! = URL(string: "https://img.youtube.com/vi/" + song.id! + "/0.jpg")
            var task: URLSessionDownloadTask!
            task = session.downloadTask(with: url, completionHandler: { (location, response, error) -> Void in
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async(execute: { () -> Void in
                        let img:UIImage! = UIImage(data: data)
                        cell.thumbnail.image = img
                        self.cache.setObject(img, forKey: song.id as AnyObject)
                    })
                }
            })
            task.resume()
        }
    }
    
    override func tableView(_ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath) {
        if (tableView.cellForRow(at:indexPath) != nil) {
            let songId: [String: String] = [DataNotation.ID: fetchedResultsController?.object(at: indexPath).id ?? ""]
            NotificationCenter.default.post(name: Notification.Name("YouTubePlay"), object: nil, userInfo: songId)
        }
    }
                
}
