//
//  Entry.swift
//  site
//
//  Created by Greg Bolsinga on 12/6/20.
//

import Foundation

struct Entry : Codable {
    var timestamp: Date
    var title: String?
    var id: String
    var comment: String
}
