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
    
    private init() {
    }
    
    func sync(userId: String) {
        DispatchQueue.global(qos: .background).async {
            self.retrieveUser(userId: userId) {
                self.retrieveTube() {
                    for songId in self.songIds {
                        self.retrieveSong(songId: songId) {}
                    }
                }
            }
        }
    }
    
    func retrieveSong(songId: String, finished: @escaping () -> ()) {
        ref.database.reference(withPath: "song/" + songId + "/").observeSingleEvent(of: .value, with: { snapshot in
            let dictionary = snapshot.value as! [String: AnyObject]
            let song = Song(context: self.context)
            if (dictionary["name"] != nil) { song.name = dictionary["name"] as? String }
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            finished() })
    }
    
    func retrieveTube(finished: @escaping () -> ()) {
        finished()
    }
    
    func retrieveUser(userId: String, finished: @escaping () -> ()) {
        ref.database.reference(withPath: "user/" + userId + "/song/").observeSingleEvent(of: .value, with: { snapshot in
            for child in snapshot.children { self.songIds.append((child as! DataSnapshot).key) }
            finished() })
    }
    
}
