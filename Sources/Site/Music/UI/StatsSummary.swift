//
//  StatsSummary.swift
//  site
//
//  Created by Greg Bolsinga on 9/23/24.
//

import SwiftUI

struct StatsSummary: View {
  let vault: Vault
  let displayArchiveCategoryCounts: Bool

  var body: some View {
    List {
      StatsGrouping(
        concerts: vault.concerts, displayArchiveCategoryCounts: displayArchiveCategoryCounts)
    }
    .navigationTitle(Text(ArchiveCategory.stats.localizedString))
  }
}

#Preview {
  StatsSummary(
    vault: VaultModel(vaultPreviewData, executeAsynchronousTasks: false).vault,
    displayArchiveCategoryCounts: false)
}

#Preview {
  StatsSummary(
    vault: VaultModel(vaultPreviewData, executeAsynchronousTasks: false).vault,
    displayArchiveCategoryCounts: true)
}
