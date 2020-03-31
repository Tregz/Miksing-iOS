//
//  HomeController.swift
//  Miksing
//
//  Created by Jerome Robbins on 2020-03-30.
//  Copyright © 2020 Tregz. All rights reserved.
//

import UIKit

class HomeController : UIViewController {
    
    @IBOutlet weak var avPanoramicHeight: NSLayoutConstraint!
    static let notificationPanoramicAspect = "PanoramicAspect"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let name = Notification.Name(HomeController.notificationPanoramicAspect)
        NotificationCenter.default.addObserver(self, selector: #selector(collapse), name: name, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.barStyle = .black
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func collapse(notification: NSNotification) {
        let panoramic = notification.userInfo?[HomeController.notificationPanoramicAspect] as? Bool ?? true
        if panoramic { avPanoramicHeight.priority = UILayoutPriority(rawValue: 998.0) }
        else { avPanoramicHeight.priority = UILayoutPriority(rawValue: 1000.0) }
        UIView.animate(withDuration: 1.0, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
}
