//
//  ViewCollection.swift
//  Miksing
//
//  Created by Jerome Robbins on 2020-04-19.
//  Copyright © 2020 Tregz. All rights reserved.
//

import UIKit

struct ViewCollection {
    
    static func collection(top: CGFloat, width: CGFloat, height: CGFloat) -> UICollectionView {
        let view : UICollectionView!
        let innerWidth = width - 28
        let innerHeight = height - 14
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.itemSize = CGSize(width: innerWidth / 7, height: innerHeight / 3)
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 3
        let frame = CGRect(x: 0, y: top, width: width, height: 0)
        view = UICollectionView(frame: frame, collectionViewLayout: layout)
        view.backgroundColor = nil
        return view
    }
}
