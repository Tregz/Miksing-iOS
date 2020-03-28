//
//  Song+CoreDataClass.swift
//  Miksing
//
//  Created by Jerome Robbins on 2020-03-28.
//  Copyright © 2020 Tregz. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Song)
public class Song: NSManagedObject {
    
    // Derived values for table sections
    @objc var alpha: String? { if (name ?? "").isEmpty { return "" }
        return String(name!.prefix(1)).uppercased() } // Alphabetic
    
    @objc var fresh: String? { let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy" //-MM-dd HH:mm:ss
        return dateFormatter.string(from: releasedAt!) } // Released date

}
