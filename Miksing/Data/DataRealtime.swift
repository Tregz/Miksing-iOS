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
    var user: User? = nil
    var songIds: Array<String> = Array()
    var tubeIds: Array<String> = Array()
    
    private init() {}
    
    func sync(userId: String) {
        //deleteAllData(entity: "Song")
        DispatchQueue.global(qos: .background).async {
            self.retrieveUser(userId: userId) {
                for songId in self.songIds {
                    self.retrieveSong(songId: songId) {
                        for tubeId in self.tubeIds {
                            self.retrieveTube(tubeId: tubeId) {}
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
            song?.user = UserHelper.instance.currentUser
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
            if (dictionary[DataNotation.CD] != nil) { tube?.createdAt = self.toDate(long: dictionary[DataNotation.CD] as! Double) }
            self.ref.database.reference(withPath: "tube/" + tubeId + "/data/name/").observeSingleEvent(of: .value, with: { snapshot in
                let langId = "tube-" + tubeId
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Lang")
                request.fetchLimit = 1
                request.predicate = NSPredicate(format: DataNotation.ID + " = %@", langId)
                var lang: Lang? = nil
                do {
                    let result = try self.context.fetch(request)
                    if (result.count >= 1) {
                        lang = result[0] as? Lang
                    } else {
                        lang = Lang(context: self.context)
                        lang?.id = langId
                    }
                } catch {
                    // do nothing
                }
                let langDictionary = snapshot.value as! [String: AnyObject]
                if (langDictionary["en"] != nil) { lang?.en = langDictionary["en"] as? String }
                if (langDictionary["fr"] != nil) { lang?.fr = langDictionary["fr"] as? String }
                tube?.langs = lang
                tube?.user = UserHelper.instance.currentUser
            })
            
            self.ref.database.reference(withPath: "tube/" + tubeId + "/song/").observeSingleEvent(of: .value, with: { snapshot in
                for child in snapshot.children {
                    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Song")
                    request.fetchLimit = 1
                    request.predicate = NSPredicate(format: DataNotation.ID + " = %@", (child as! DataSnapshot).key)
                    do {
                        let result = try self.context.fetch(request)
                        if (result.count >= 1) {
                            let song = result[0] as? Song
                            if (song != nil) { tube?.addToSongs(song!) }
                        }
                    } catch {
                        // do nothing
                    }
                }
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                finished()
            })
        })
    }
    
    func retrieveUser(userId: String, finished: @escaping () -> ()) {
        let pathUserData = "user/" + userId + "/data/"
        self.ref.database.reference(withPath: pathUserData).observeSingleEvent(of: .value, with: { snapshot in
            let delegate = (UIApplication.shared.delegate as! AppDelegate)
            let dictionary = snapshot.value as! [String: AnyObject]
            UserHelper.instance.save(delegate: delegate, dictionary: dictionary, userId: userId, isCurrentUser: true)
            let pathUserTube = "user/" + userId + "/tube/"
            self.ref.database.reference(withPath: pathUserTube).observeSingleEvent(of: .value, with: { snapshot in
                for child in snapshot.children { self.tubeIds.append((child as! DataSnapshot).key) }
                let pathUserSong = "user/" + userId + "/song/"
                self.ref.database.reference(withPath: pathUserSong).observeSingleEvent(of: .value, with: { snapshot in
                    for child in snapshot.children { self.songIds.append((child as! DataSnapshot).key) }
                    finished()
                })
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
