//
//  Card.swift
//  Hearthbase
//
//  Created by Paulo José on 17/10/18.
//  Copyright © 2018 Paulo José. All rights reserved.
//

import Foundation
import UIKit

struct CardModel: Codable {
    let id: String!
    let name: String!
    let attack: Int!
    let defense: Int!
    let image: String!
    let info: String!
    
    enum CodingKeys: String, CodingKey {
        case id = "cardId"
        case name
        case attack
        case defense = "health"
        case image = "img"
        case info = "text"
    }
}
