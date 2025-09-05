//
//  ArchiveCategoryLinkable.swift
//  site
//
//  Created by Greg Bolsinga on 10/5/24.
//

import Foundation
import MusicData

struct ArchiveCategoryLinkable: ArchiveSharable {
  let category: ArchiveCategory
  let url: URL?

  var subject: String { category.title }
  var message: String { subject }
}
