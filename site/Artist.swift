//
//  Artist.swift
//  site
//
//  Created by Greg Bolsinga on 12/17/20.
//

import Foundation

struct Artist : Codable {
    var albums: [String]?
    var id : String
    var name : String
    var sortname : String?
}
