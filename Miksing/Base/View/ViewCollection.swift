//
//  ViewCollection.swift
//  Miksing
//
//  Created by Jerome Robbins on 2020-04-19.
//  Copyright © 2020 Tregz. All rights reserved.
//

import UIKit

struct ViewCollection {
    
    static func flow3lines7rows(top: CGFloat, width: CGFloat, height: CGFloat) -> UICollectionView {
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
    
    static func flow(columns: Int, width: CGFloat, height: CGFloat) -> UICollectionView {
        let view : UICollectionView!
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        let collectionViewLayout = layout(columns: columns, width: width, height: height)
        view = UICollectionView(frame: frame, collectionViewLayout: collectionViewLayout)
        view.backgroundColor = nil
        return view
    }
    
    static func layout(columns: Int, width: CGFloat, height: CGFloat) -> UICollectionViewFlowLayout {
        let spacing = 3
        let innerWidth = width - CGFloat((spacing + 1) * (columns + 1)) //- CGFloat(5)
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.itemSize = CGSize(width: innerWidth / CGFloat(columns), height: height)
        layout.minimumInteritemSpacing = CGFloat(spacing)
        layout.minimumLineSpacing = CGFloat(spacing)
        return layout
    }
}
