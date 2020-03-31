//
//  Tube+CoreDataClass.swift
//  Miksing
//
//  Created by Jerome Robbins on 2020-03-31.
//  Copyright © 2020 Tregz. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Tube)
public class Tube: NSManagedObject {

    // Localized transient values
    @objc var name: String? {
        if (NSLocale.current.languageCode == "fr") { return langs?.fr ?? "Indéfini" }
        else { return langs?.en ?? "Undefined" }
    }
       
    // Transient values for table sections
    @objc var alpha: String? {
        return String(name!.prefix(1)).uppercased()
    }
    
}
