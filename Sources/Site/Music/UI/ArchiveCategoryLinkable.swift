//
//  ArchiveCategoryLinkable.swift
//  site
//
//  Created by Greg Bolsinga on 10/5/24.
//

import SwiftUI

struct ArchiveCategoryLinkable: ArchiveSharable {
  let vault: Vault
  let category: ArchiveCategory

  var subject: String { category.title }
  var message: String { subject }
  var url: URL? { vault.categoryURLMap[category] }
}
