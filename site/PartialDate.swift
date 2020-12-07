//
//  PartialDate.swift
//  site
//
//  Created by Greg Bolsinga on 12/18/20.
//

import Foundation

struct PartialDate : Codable {
    var year : Int?
    var month : Int?
    var day : Int?
    var unknown : Bool?
}
