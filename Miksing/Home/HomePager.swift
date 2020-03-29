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
    
    override func viewDidLoad() {
        let name = Notification.Name(HomePager.notificationPaging)
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { notification in
            self.selectedIndex = notification.userInfo?[HomePager.notificationPaging] as! Int
        }
    }
    
}
