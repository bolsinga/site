//
//  Show.swift
//  site
//
//  Created by Greg Bolsinga on 12/17/20.
//

import Foundation

struct Show : Codable {
    var artists: [String]
    var comment : String?
    var date : PartialDate
    var id : String
    var venue : String
}
