//
//  StatsSummary.swift
//  site
//
//  Created by Greg Bolsinga on 9/23/24.
//

import SwiftUI

struct StatsSummary: View {
  @Environment(VaultModel.self) var model

  let displayArchiveCategoryCounts: Bool

  var body: some View {
    List {
      StatsGrouping(
        concerts: model.vault.concerts, displayArchiveCategoryCounts: displayArchiveCategoryCounts)
    }
  }
}

#Preview {
  StatsSummary(displayArchiveCategoryCounts: false)
    .environment(VaultModel(vaultPreviewData, executeAsynchronousTasks: false))
}

#Preview {
  StatsSummary(displayArchiveCategoryCounts: true)
    .environment(VaultModel(vaultPreviewData, executeAsynchronousTasks: false))
}
