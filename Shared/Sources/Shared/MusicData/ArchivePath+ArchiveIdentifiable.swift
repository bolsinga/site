//
//  ArchivePath+ArchiveIdentifiable.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 2/5/26.
//

import Foundation

extension ArchivePath: ArchiveIdentifiable {
  public var description: String {
    formatted(.rawID)
  }
}
