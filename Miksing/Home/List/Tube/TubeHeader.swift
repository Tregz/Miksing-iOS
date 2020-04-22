//
//  TubeHeader.swift
//  Miksing
//
//  Created by Jerome Robbins on 2020-04-21.
//  Copyright © 2020 Tregz. All rights reserved.
//

import UIKit

class TubeHeader: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
    
    
    //weak var cellDelegate: CustomCollectionCellDelegate? // define delegate
    @IBOutlet weak var myCollectionView: UICollectionView!
    //var aCategory: ImageCategory?
    let cellReuseId = "CollectionViewCell"
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)// as? CustomCollectionViewCell
        //self.cellDelegate?.collectionView(collectioncell: cell, didTappedInTableview: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0 //<#code#>
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell() //<#code#>
    }
    
}
