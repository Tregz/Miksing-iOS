//
//  DataRealtime.swift
//  Miksing
//
//  Created by Jerome Robbins on 2020-03-23.
//  Copyright © 2020 Tregz. All rights reserved.
//

import CoreData
import Firebase
import UIKit

class DataRealtime {
    
    static let shared: DataRealtime = DataRealtime()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var ref: DatabaseReference! = Database.database().reference()
    var songIds: Array<String> = Array()
    var tubeIds: Array<String> = Array()
    
    private init() {}
    
    func sync(userId: String) {
        //deleteAllData(entity: "Song")
        DispatchQueue.global(qos: .background).async {
            self.retrieveUser(userId: userId) {
                for tubeId in self.tubeIds {
                    self.retrieveTube(tubeId: tubeId) {
                        for songId in self.songIds {
                            self.retrieveSong(songId: songId) {}
                        }
                    }
                }
            }
        }
    }
    
    func retrieveSong(songId: String, finished: @escaping () -> ()) {
        ref.database.reference(withPath: "song/" + songId + "/").observeSingleEvent(of: .value, with: { snapshot in
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Song")
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: DataNotation.ID + " = %@", songId)
            var song: Song? = nil
            do {
                let result = try self.context.fetch(request)
                if (result.count >= 1) {
                    song = result[0] as? Song
                } else {
                    song = Song(context: self.context)
                    song?.id = snapshot.key
                }
            } catch {
                // do nothing
            }
            
            let dictionary = snapshot.value as! [String: AnyObject]
            if (dictionary[DataNotation.RD] != nil) { song?.releasedAt = self.toDate(long: dictionary[DataNotation.RD] as! Double) }
            if (dictionary[DataNotation.CD] != nil) { song?.createdAt = self.toDate(long: dictionary[DataNotation.CD] as! Double) }
            if (dictionary[DataNotation.DD] != nil) { song?.deletedAt = self.toDate(long: dictionary[DataNotation.DD] as! Double) }
            if (dictionary[DataNotation.UD] != nil) { song?.updatedAt = self.toDate(long: dictionary[DataNotation.UD] as! Double) }
            if (dictionary[DataNotation.FS] != nil) { song?.featuring = dictionary[DataNotation.FS] as? String }
            if (dictionary[DataNotation.GS] != nil) { song?.genre = dictionary[DataNotation.GS] as? String }
            if (dictionary[DataNotation.MS] != nil) { song?.mixedBy = dictionary[DataNotation.MS] as? String }
            if (dictionary[DataNotation.AS] != nil) { song?.artist = dictionary[DataNotation.AS] as? String }
            if (dictionary[DataNotation.NS] != nil) { song?.name = dictionary[DataNotation.NS] as? String }
            if (dictionary[DataNotation.VI] != nil) { song?.version = (dictionary[DataNotation.VI] as? Int16)! }
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            finished()
        })
    }
    
    private func toDate(long: Double) -> Date {
        return Date(timeIntervalSince1970: (long / 1000.0))
    }
    
    func retrieveTube(tubeId: String, finished: @escaping () -> ()) {
        ref.database.reference(withPath: "tube/" + tubeId + "/data/").observeSingleEvent(of: .value, with: { snapshot in
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Tube")
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: DataNotation.ID + " = %@", tubeId)
            var tube: Tube? = nil
            do {
                let result = try self.context.fetch(request)
                if (result.count >= 1) {
                    tube = result[0] as? Tube
                } else {
                    tube = Tube(context: self.context)
                    tube?.id = tubeId
                }
            } catch {
                // do nothing
            }
            
            let dictionary = snapshot.value as! [String: AnyObject]
            if (dictionary[DataNotation.NS] != nil) { tube?.name = dictionary[DataNotation.NS] as? String }
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            finished()
        })
    }
    
    func retrieveUser(userId: String, finished: @escaping () -> ()) {
        ref.database.reference(withPath: "user/" + userId + "/tube/").observeSingleEvent(of: .value, with: { snapshot in
            for child in snapshot.children { self.tubeIds.append((child as! DataSnapshot).key) }
            self.ref.database.reference(withPath: "user/" + userId + "/song/").observeSingleEvent(of: .value, with: { snapshot in
                for child in snapshot.children { self.songIds.append((child as! DataSnapshot).key) }
                finished()
            })
        })
    }
    
    func deleteAllData(entity: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false

        do {
            let results = try context.fetch(fetchRequest)
            for managedObject in results { context.delete(managedObject as! NSManagedObject) }
        } catch let error as NSError {
            print("Delete all data in \(entity) error : \(error) \(error.userInfo)")
        }
    }
    
}
