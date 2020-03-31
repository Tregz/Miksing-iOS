//
//  UserDic.swift
//  Miksing
//
//  Created by Jerome Robbins on 2020-03-31.
//  Copyright © 2020 Tregz. All rights reserved.
//

import Foundation
import CoreData

class UserHelper {
    
    static var instance: UserHelper = {
        return UserHelper()
    }()
    
    var currentUser: User? = nil
    
    func save(delegate: AppDelegate, dictionary: [String: AnyObject], userId: String, isCurrentUser: Bool) {
        let context = delegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: DataNotation.ID + " = %@", userId)
        var user: User? = nil
        do {
            let result = try context.fetch(request)
            if (result.count >= 1) {
                user = result[0] as? User
            } else {
                user = User(context: context)
                user?.id = userId
            }
        } catch {
            // do nothing
        }
        if (dictionary[DataNotation.NS] != nil) { user?.name = dictionary[DataNotation.NS] as? String }
        if isCurrentUser { currentUser = user }
        delegate.saveContext()
    }
}
