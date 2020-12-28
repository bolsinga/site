//
//  Relation.swift
//  site
//
//  Created by Greg Bolsinga on 12/17/20.
//

import Foundation

struct Relation : Codable {
    var id : String
    var members: [String]
    var reason: String?
}
