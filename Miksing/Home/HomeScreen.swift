//
//  HomeScreen.swift
//  Miksing
//
//  Created by Jerome Robbins on 2020-03-28.
//  Copyright © 2020 Tregz. All rights reserved.
//

import UIKit

class HomeScreen : UIViewController {
    
    static let COMPARATOR = "Comparator"
    private var sorting: Int = 0
    
    let sortIcon:[String]! = ["SF_textformat_abc", "SF_calendar_badge_plus"]
    
    @IBAction func comparator(_ sender: UIBarButtonItem) {
        if (sorting < 1) { sorting += 1 } else { sorting = 0 }
        let info: [String: Int] = [HomeScreen.COMPARATOR: sorting]
        let name = Notification.Name(HomeScreen.COMPARATOR)
        NotificationCenter.default.post(name: name, object: nil, userInfo: info)
        sender.image = UIImage(named: sortIcon![sorting])
    }
}
