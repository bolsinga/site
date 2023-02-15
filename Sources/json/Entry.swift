//
//  Entry.swift
//  site
//
//  Created by Greg Bolsinga on 12/6/20.
//

import Foundation

public struct Entry : Codable {
    public var timestamp: Date
    public var title: String?
    public var id: String
    public var comment: String
}
