//
//  Tube+CoreDataClass.swift
//  Miksing
//
//  Created by Jerome Robbins on 2020-03-28.
//  Copyright © 2020 Tregz. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Tube)
public class Tube: NSManagedObject {
    
    // Derived values for table sections
    @objc var alpha: String? {
        if (name ?? "").isEmpty { return "" }
        let localizedName = NSLocalizedString(name ?? "", tableName: "TubeLocalizable", comment: "")
        return String(localizedName.prefix(1)).uppercased() // Alphabetic
    }
    
}
