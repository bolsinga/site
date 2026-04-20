//
//  ArchiveItem.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 12/30/25.
//

import Foundation

public struct ArchiveItem: Codable, Equatable, Hashable, Identifiable, Nameable, Sendable {
  public let id: ArchivePath
  let name: String
}
