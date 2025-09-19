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
        concerts: model.vault.concerts, displayArchiveCategoryCounts: true,
        weekdaysTitleLocalizedString: "\(ArchiveCategory.shows.localizedString) Weekdays",
        monthsTitleLocalizedString: "\(ArchiveCategory.shows.localizedString) Months")
    }
    .navigationTitle(Text(ArchiveCategory.stats.localizedString))
  }
}

#Preview(traits: .modifier(VaultPreviewModifier())) {
  StatsSummary()
}
