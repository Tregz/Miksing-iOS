//
//  MenuFilters.swift
//  Miksing
//
//  Created by Jerome Robbins on 2020-04-19.
//  Copyright © 2020 Tregz. All rights reserved.
//

import UIKit

class MenuFilters : UIViewController,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout,
    UITabBarDelegate {
    
    @IBOutlet weak var cvFilters: UIView!
    
    var expanded = false
    let filterCell = "CollectionViewCell"
    var filtersHeightConstraint: NSLayoutConstraint?
    var filterView: UICollectionView?
    var navMinHeight:CGFloat?
    var navMaxHeight:CGFloat?
    //var tab:Int = 0
    var tabs:UITabBar?
    
    override func viewDidLoad() {
        
        
        let drain = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action:#selector(filter(_:)))//(image: "SF_play_rectangle", style: .done, target:self, action:#selector(filter(_:)))
        navigationItem.leftBarButtonItem = drain
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    @objc func filter(_ sender:Any) { var top:CGFloat?, frame:CGRect?
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let homeScreen = appDelegate.homeScreen as! HomeController
        if expanded {
            //top = CGFloat(0)
            //if mainView.collapsed { homeScreen.collapsing(self) }
            //frame = CGRect(x: 0, y: 0, width: view.frame.width, height: navMinHeight!)
            //filterView?.frame.size.height = CGFloat(0)
            
            //cvFilters.frame.size.height = 0
            filtersHeightConstraint?.isActive = false
        } else {
            //top = navMaxHeight! - navMinHeight!
            //if !mainView.collapsed { mainView.collapsing(self) }
            //frame = CGRect(x: 0, y: 0, width: view.frame.width, height: navMaxHeight!)
            //filterView?.frame.size.width = navigationController!.navigationBar.bounds.width
            //filterView?.frame.size.height = navMaxHeight! - navMinHeight!
            print("Filters should expand \(navMinHeight)")
            //cvFilters.frame.size.height = navMinHeight!
            filtersHeightConstraint = cvFilters.heightAnchor.constraint(equalToConstant: 250)
            filtersHeightConstraint?.priority = UILayoutPriority(rawValue: 998.0)
            filtersHeightConstraint?.isActive = true
        
        }
        //tableView.contentInset = UIEdgeInsets(top: top!, left: 0, bottom: 0, right: 0)
        //tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        //navigationController?.navigationBar.frame = frame!
        //tableView.layoutIfNeeded()
        self.view.layoutIfNeeded()
        expanded = !expanded
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: filterCell, for: indexPath)
        return cell
    }
    
}
