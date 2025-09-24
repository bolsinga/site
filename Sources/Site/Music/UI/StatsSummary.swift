//
//  StatsSummary.swift
//  site
//
//  Created by Greg Bolsinga on 9/23/24.
//

import SwiftUI

struct StatsSummary: View {
  @Environment(VaultModel.self) var model

  var body: some View {
    List {
      StatsGrouping(stats: Stats(concerts: model.vault.concerts))
    }
    .navigationTitle(Text(ArchiveCategory.stats.localizedString))
  }
}

#Preview(traits: .vaultModel) {
  StatsSummary()
}
