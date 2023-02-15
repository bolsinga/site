//
//  PartialDate.swift
//  site
//
//  Created by Greg Bolsinga on 12/18/20.
//

import Foundation

public struct PartialDate : Codable {
    public var year : Int?
    public var month : Int?
    public var day : Int?
    public var unknown : Bool?
}
