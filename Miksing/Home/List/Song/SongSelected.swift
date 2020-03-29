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
    
    override var predicateRelationEntityId: String? {
        return SongSelected.selectedRelationEntityId
    }
    
    override var predicateRelationQuery: String? {
        return "ANY tubes.id =[cd] %@"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let name = Notification.Name(HomePager.notificationPaging)
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { notification in
            self.fetchController()
        }
    }
    
}
