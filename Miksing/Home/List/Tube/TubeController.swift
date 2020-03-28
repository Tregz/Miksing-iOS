//
//  TubeController.swift
//  Miksing
//
//  Created by Jerome Robbins on 2020-03-28.
//  Copyright © 2020 Tregz. All rights reserved.
//

import UIKit
import CoreData

class TubeController : ListController<Tube> {
    
    override var descriptors:[String]! { return [DataNotation.NS] }
    override var sortSection:[String]! { return ["alpha"] }
    override var isAscending:[Bool]! { return [true] }
    
    override func configureCell(_ cell: ListHolder, withEvent tube: Tube, indexPath: IndexPath) {
        cell.title.text = NSLocalizedString(tube.name ??  "", tableName: "TubeLocalizable", comment: "")
        let songs = tube.songs
        if (songs != nil) {
            for song in songs! { print((song as! Song).name ?? "") }
        }
        
        cell.subtitle.text = "" //tube... ?? ""
        if (self.cache.object(forKey: tube.id as AnyObject) != nil) {
            cell.thumbnail.image = self.cache.object(forKey: tube.id as AnyObject) as? UIImage
        } else if (tube.id != nil) {
            // TODO
        }
    }
    
}
