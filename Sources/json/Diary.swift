//
//  Diary.swift
//  site
//
//  Created by Greg Bolsinga on 12/6/20.
//

import Foundation

public struct Diary: Codable {
  public let timestamp: Date
  public let colophon: [String]
  public let header: [String]
  public let title: String
  public let statics: [String]
  public let friends: [String]
  public let entries: [Entry]

  public init(
    timestamp: Date, colophon: [String], header: [String], title: String, statics: [String],
    friends: [String], entries: [Entry]
  ) {
    self.timestamp = timestamp
    self.colophon = colophon
    self.header = header
    self.title = title
    self.statics = statics
    self.friends = friends
    self.entries = entries
  }
}
