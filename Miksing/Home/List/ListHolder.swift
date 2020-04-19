//
//  SongCell.swift
//  Miksing
//
//  Created by Jerome Robbins on 2020-03-23.
//  Copyright © 2020 Tregz. All rights reserved.
//
import UIKit

class ListHolder : UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var prefix: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
                
    var expanded: Bool = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = TintColor.primaryPage
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.white
        selectedBackgroundView = selectedView
    }
                
}
