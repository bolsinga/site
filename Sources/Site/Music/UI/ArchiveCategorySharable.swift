//
//  ArchiveCategorySharable.swift
//  site
//
//  Created by Greg Bolsinga on 10/5/24.
//

import Foundation

struct ArchiveCategorySharable: ArchiveSharable {
  let category: ArchiveCategory

  var subject: String { category.title }
  var message: String { subject }
}
