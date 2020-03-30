//
//  SongPrepare.swift
//  Miksing
//
//  Created by Jerome Robbins on 2020-03-23.
//  Copyright © 2020 Tregz. All rights reserved.
//

import CoreData

class SongSelected : SongController {
    
    static var selectedRelationEntityId: String? = nil
    static var shouldUpdate: Bool = false
    
    override var predicateRelationEntityId: String? {
        return SongSelected.selectedRelationEntityId
    }
    
    override var predicateRelationQuery: String? {
        return "ANY tubes.id =[cd] %@"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateYouTubePlayerPlaylist()
        let name = Notification.Name(HomePager.notificationPaging)
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { notification in
            self.fetchController()
            if SongSelected.shouldUpdate {
                SongSelected.shouldUpdate = false
                self.updateYouTubePlayerPlaylist()
            }
        }
    }
    
    private func updateYouTubePlayerPlaylist() {
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
