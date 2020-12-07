//
//  Song.swift
//  site
//
//  Created by Greg Bolsinga on 12/17/20.
//

import Foundation

struct Song : Codable {
    var artist: String
    var digitized: Bool
    var genre: String?
    var id: String
    var lastPlayed: Date?
    var playCount: Int?
    var release: PartialDate?
    var title: String
    var track: Int?
}
