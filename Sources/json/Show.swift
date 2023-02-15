//
//  Show.swift
//  site
//
//  Created by Greg Bolsinga on 12/17/20.
//

import Foundation

public struct Show : Codable {
    public var artists: [String]
    public var comment : String?
    public var date : PartialDate
    public var id : String
    public var venue : String
}
