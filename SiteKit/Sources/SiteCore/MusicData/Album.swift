//
//  Album.swift
//  site
//
//  Created by Greg Bolsinga on 12/17/20.
//

import Foundation

package struct Album: Codable, Equatable, Identifiable, Sendable {
  package let id: String
  package let performer: String?
  package let release: PartialDate?
  package let songs: [String]
  public let title: String
  package let compilation: Bool?

  package init(
    id: String, performer: String? = nil, release: PartialDate? = nil, songs: [String],
    title: String, compilation: Bool? = false
  ) {
    self.id = id
    self.performer = performer
    self.release = release
    self.songs = songs
    self.title = title
    self.compilation = compilation
  }
}
