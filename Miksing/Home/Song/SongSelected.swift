//
//  SongPrepare.swift
//  Miksing
//
//  Created by Jerome Robbins on 2020-03-23.
//  Copyright © 2020 Tregz. All rights reserved.
//

import CoreData

class SongPrepare : SongTable {
    
    override func getCurrentTabPosition() -> Int {
        return 1
    }
    
    override func getCacheName() -> String {
        return "Prepare"
    }
    
}
