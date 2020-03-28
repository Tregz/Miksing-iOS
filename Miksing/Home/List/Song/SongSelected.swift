//
//  SongPrepare.swift
//  Miksing
//
//  Created by Jerome Robbins on 2020-03-23.
//  Copyright © 2020 Tregz. All rights reserved.
//

import CoreData

class SongSelected : SongController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let name = Notification.Name("Songs")
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { notification in
            let songs = notification.userInfo?["Songs"] as? [String] ?? []
            for songId in songs { print("SongId:" + songId) }
            self.fetchController()
        }
    }
    
    override func getCurrentTabPosition() -> Int {
        return 1
    }
    
    override func getCacheName() -> String {
        return "Prepare"
    }
    
}
