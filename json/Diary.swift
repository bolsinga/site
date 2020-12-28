//
//  Diary.swift
//  site
//
//  Created by Greg Bolsinga on 12/6/20.
//

import Foundation

struct Diary : Codable {
    var timestamp: Date
    var colophon: [String]
    var header: [String]
    var title: String
    var statics: [String]
    var friends: [String]
    var entries: [Entry]
}
