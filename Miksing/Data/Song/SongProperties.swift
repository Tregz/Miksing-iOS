//
//  Song+CoreDataProperties.swift
//  Miksing
//
//  Created by Jerome Robbins on 2020-03-28.
//  Copyright © 2020 Tregz. All rights reserved.
//
//

import Foundation
import CoreData


extension Song {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Song> {
        return NSFetchRequest<Song>(entityName: "Song")
    }

    @NSManaged public var id: String?
    @NSManaged public var artist: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var deletedAt: Date?
    @NSManaged public var featuring: String?
    @NSManaged public var genre: String?
    @NSManaged public var mixedBy: String?
    @NSManaged public var name: String?
    @NSManaged public var releasedAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var version: Int16
    @NSManaged public var user: User?

}
