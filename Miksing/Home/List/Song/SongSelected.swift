//
//  SongPrepare.swift
//  Miksing
//
//  Created by Jerome Robbins on 2020-03-23.
//  Copyright © 2020 Tregz. All rights reserved.
//

import CoreData
import UIKit

class SongSelected : SongController {
    
    static var selectedRelationEntityId: String? = nil
    static var shouldUpdate: Bool = false
    
    override var predicateRelationEntityId: String? {
        return SongSelected.selectedRelationEntityId
    }
    
    override var predicateRelationQuery: String? {
        return "ANY tubes.id =[cd] %@"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let name = Notification.Name(HomePager.notificationPaging)
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { notification in
            self.fetchController()
            if SongSelected.shouldUpdate {
                SongSelected.shouldUpdate = false
                self.updateYouTubePlayerPlaylist()
            }
        }
    }
    
}
