//
//  PartialDate.swift
//  site
//
//  Created by Greg Bolsinga on 12/18/20.
//

import Foundation

public struct PartialDate: Codable {
  public let year: Int?
  public let month: Int?
  public let day: Int?
  public let unknown: Bool?

  public init(year: Int? = nil, month: Int? = nil, day: Int? = nil, unknown: Bool? = nil) {
    self.year = year
    self.month = month
    self.day = day
    self.unknown = unknown
  }
}
