//
//  HomePager.swift
//  Miksing
//
//  Created by Jerome Robbins on 2020-03-29.
//  Copyright © 2020 Tregz. All rights reserved.
//

import UIKit

class HomePager : UITabBarController {
    
    static let notificationPaging = "Paging"
    @IBOutlet weak var bottomNavigationBar: UITabBar!
    
    override func viewDidLoad() {
        bottomNavigationBar.unselectedItemTintColor = BaseColor.secondaryDarkish
        let name = Notification.Name(HomePager.notificationPaging)
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { notification in
            self.selectedIndex = notification.userInfo?[HomePager.notificationPaging] as! Int
        }
    }
    
}
