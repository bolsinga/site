//
//  Artist+SearchResult.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 1/31/26.
//

import Foundation

extension Artist: ArchiveSearchResult {
  var displayName: String { name }
}
