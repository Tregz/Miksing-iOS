//
//  SongCell.swift
//  Miksing
//
//  Created by Jerome Robbins on 2020-03-23.
//  Copyright © 2020 Tregz. All rights reserved.
//
import UIKit

class SongCell : UITableViewCell {
    
    @IBOutlet weak var name: UILabel! // Title
    @IBOutlet weak var artist: UILabel! // Subtitle
    @IBOutlet weak var icon: UIImageView! // Thumbnail
                
    var expanded: Bool = false
                
}
