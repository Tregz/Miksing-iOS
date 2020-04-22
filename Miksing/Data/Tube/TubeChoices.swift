//
//  TubeChoices.swift
//  Miksing
//
//  Created by Jerome Robbins on 2020-04-21.
//  Copyright © 2020 Tregz. All rights reserved.
//

import Foundation

enum TubeAtmosphere: Int, CaseIterable {
    case apero
    case bistro
    case club
    
    var icon: String {
        switch self {
        case .apero: return "cocktail"
        case .bistro: return "charge"
        case .club: return "funk"
        }
    }
    
    var name: String {
        switch self {
        case .apero: return "Apero"
        case .bistro: return "Bistro"
        case .club: return "Club"
        }
    }
}
