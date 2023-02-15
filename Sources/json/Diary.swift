//
//  Diary.swift
//  site
//
//  Created by Greg Bolsinga on 12/6/20.
//

import Foundation

public struct Diary: Codable {
  public var timestamp: Date
  public var colophon: [String]
  public var header: [String]
  public var title: String
  public var statics: [String]
  public var friends: [String]
  public var entries: [Entry]
}
