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
    
    @IBAction func btSort(_ sender: UIButton) {
        if sorting < 1 { sorting += 1 } else { sorting = 0 }
        sender.setImage(UIImage(named: sortIcon![sorting]), for: UIControl.State.normal)
        self.fetchController()
    }
    
    let session = URLSession.shared
    
    override var descriptors:[String]! { return [DataNotation.NS, DataNotation.RD] }
    override var sortSection:[String]! { return ["alpha", "fresh"] }
    override var isAscending:[Bool]! { return [true, false] }
    
    override var searchQuery: String {
        //return "(" + DataNotation.NS + " contains [cd] %@) || (" + DataNotation.AS + " contains [cd] %@)"
        return "(" + DataNotation.NS + " contains [cd] %@)"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateYouTubePlayerPlaylist()
    }
    
    // MARK: - Table view data source
                
    override func configureCell(_ cell: ListRow, withEvent song: Song, indexPath: IndexPath) {
        let text = NSMutableAttributedString()
        let font1 = UIFont.systemFont(ofSize: 17)
        let attribute1:[NSAttributedString.Key: Any] = [.font : font1]
        let text1 = NSAttributedString(string: song.name ?? "", attributes: attribute1)
        text.append(text1)
        let mixedBy = song.mixedBy
        if mixedBy != nil {
            let font2 = UIFont.boldSystemFont(ofSize: 15)
            let attribute2 = [.font : font2, NSAttributedString.Key.foregroundColor: UIColor.purple]
            let text2 = NSAttributedString(string: " (" + mixedBy! + ")", attributes: attribute2)
            text.append(text2)
        }
        cell.title.attributedText = text
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
            let notificationLoadById =  Notification.Name(PlayWeb.notificationYouTubeLoadById)
            NotificationCenter.default.post(name: notificationLoadById, object: nil, userInfo: songId)
        }
    }
    
    func updateYouTubePlayerPlaylist() {
        let clearIds = Notification.Name(PlayWeb.notificationYouTubeClearIds)
        NotificationCenter.default.post(name: clearIds, object: nil, userInfo: nil)
        let songs = self.fetchedResultsController?.fetchedObjects
        if songs != nil {
            for song in songs! {
                let userInfo: [String: String] = [DataNotation.ID: song.id ?? ""]
                let insertId = Notification.Name(PlayWeb.notificationYouTubeInsertId)
                NotificationCenter.default.post(name: insertId, object: nil, userInfo: userInfo)
            }
        }
    }
                
}
