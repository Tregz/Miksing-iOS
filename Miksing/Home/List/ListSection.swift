//
//  ListSection.swift
//  Miksing
//
//  Created by Jerome Robbins on 2020-04-01.
//  Copyright © 2020 Tregz. All rights reserved.
//

import UIKit

class ListSection : UITableViewHeaderFooterView {
    static let reuseIdentifier: String = String(describing: self)
    
    var stVertical: UIStackView! = UIStackView()
    var cvFilters: UIView = UIView()
    var title: UILabel! = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.heightAnchor.constraint(equalToConstant: 28.0).isActive = true
        contentView.addSubview(stVertical)
        stVertical.axis = .vertical
        stVertical.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        stVertical.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        stVertical.translatesAutoresizingMaskIntoConstraints = false
        
        stVertical.addArrangedSubview(cvFilters)
        cvFilters.backgroundColor = UIColor.green
        cvFilters.heightAnchor.constraint(equalToConstant: 0.0).isActive = true
        cvFilters.leadingAnchor.constraint(equalTo: stVertical.leadingAnchor).isActive = true
        cvFilters.trailingAnchor.constraint(equalTo: stVertical.trailingAnchor).isActive = true
        cvFilters.translatesAutoresizingMaskIntoConstraints = false
        
        stVertical.addArrangedSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.leadingAnchor.constraint(equalTo: stVertical.leadingAnchor).isActive = true
        title.trailingAnchor.constraint(equalTo: stVertical.trailingAnchor).isActive = true
        title.heightAnchor.constraint(equalToConstant: 28.0).isActive = true
        title.font = UIFont.boldSystemFont(ofSize: 17)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
