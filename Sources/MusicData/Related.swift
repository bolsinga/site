//
//  Related.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 12/30/25.
//

import Foundation

public struct Related: Codable, Equatable, Hashable, Identifiable, Sendable {
  public let id: ArchivePath
  let name: String
}
