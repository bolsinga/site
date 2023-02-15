//
//  Location.swift
//  site
//
//  Created by Greg Bolsinga on 12/18/20.
//

import Foundation

public struct Location : Codable {
    public var city : String
    public var web : URL?
    public var street : String?
    public var state : String
}
