//
//  Tube+CoreDataProperties.swift
//  Miksing
//
//  Created by Jerome Robbins on 2020-03-28.
//  Copyright © 2020 Tregz. All rights reserved.
//
//

import Foundation
import CoreData


extension Tube {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tube> {
        return NSFetchRequest<Tube>(entityName: "Tube")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?

}
