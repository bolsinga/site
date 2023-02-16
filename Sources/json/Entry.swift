//
//  Entry.swift
//  site
//
//  Created by Greg Bolsinga on 12/6/20.
//

import Foundation

public struct Entry: Codable {
  public let timestamp: Date
  public let title: String?
  public let id: String
  public let comment: String

  public init(timestamp: Date, title: String? = nil, id: String, comment: String) {
    self.timestamp = timestamp
    self.title = title
    self.id = id
    self.comment = comment
  }
}
