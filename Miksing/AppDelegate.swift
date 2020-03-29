//
//  AppDelegate.swift
//  Miksing
//
//  Created by Jerome Robbins on 2020-03-22.
//  Copyright © 2020 Tregz. All rights reserved.
//

import UIKit
import CoreData
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var homeScreen:HomeScreen? = nil
    
    func application(_ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        let defaultUser = "Zdh2ZOt9AOMKih2cNv00XSwk3fh1"
        DataRealtime.shared.sync(userId: defaultUser)
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        homeScreen = splitViewController.viewControllers[1] as? HomeScreen
        return true
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // FIXME: remove fatalError in production
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                // FIXME: remove fatalError in production
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
