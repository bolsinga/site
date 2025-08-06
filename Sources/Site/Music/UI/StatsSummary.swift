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
      StatsGrouping(
        concerts: model.vault.concerts, displayArchiveCategoryCounts: true)
    }
  }
}

#Preview(traits: .modifier(VaultPreviewModifier())) {
  StatsSummary()
}
