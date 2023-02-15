//
//  Album.swift
//  site
//
//  Created by Greg Bolsinga on 12/17/20.
//

import Foundation

struct Album : Codable {
    var id : String
    var performer: String?
    var release: PartialDate?
    var songs: [String]
}
