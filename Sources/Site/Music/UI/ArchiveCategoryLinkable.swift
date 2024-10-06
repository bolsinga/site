//
//  ArchiveCategoryLinkable.swift
//  site
//
//  Created by Greg Bolsinga on 10/5/24.
//

import SwiftUI

struct ArchiveCategoryLinkable: ArchiveSharable, Linkable {
  let vault: Vault
  let category: ArchiveCategory

  var subject: Text { Text(category.title) }
  var message: Text { subject }
  var url: URL? { vault.categoryURLMap[category] }
}
