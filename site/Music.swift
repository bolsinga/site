//
//  Music.swift
//  site
//
//  Created by Greg Bolsinga on 12/17/20.
//

import Foundation

struct Music : Codable {
    var albums: [Album]
    var artists: [Artist]
    var relations: [Relation]
    var shows: [Show]
    var songs: [Song]
    var timestamp: Date
    var venues: [Venue]
}
