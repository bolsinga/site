//
//  StatsSummary.swift
//  site
//
//  Created by Greg Bolsinga on 9/23/24.
//

import Shared
import SwiftUI

struct StatsSummary: View {
  @Environment(VaultModel.self) var model

  var body: some View {
    List {
      // The category totals and charts now live with their lists.
      StatsGrouping(vault: model.vault, including: [])
    }
    .navigationTitle(Text(ArchiveCategory.stats.localizedString))
  }
}

#Preview(traits: .vaultModel) {
  StatsSummary()
}
