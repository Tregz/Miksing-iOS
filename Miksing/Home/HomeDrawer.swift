//
//  HomeDrawer.swift
//  Miksing
//
//  Created by Jerome Robbins on 2020-03-30.
//  Copyright © 2020 Tregz. All rights reserved.
//

import UIKit

class HomeDrawer: UINavigationController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.barStyle = .black
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
