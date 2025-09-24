//
//  DaysShowsSummary.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 8/6/25.
//

import SwiftUI

struct DaysShowsSummary: View {
  @Binding var mode: ShowsMode

  var body: some View {
    Picker(selection: $mode) {
      ForEach(ShowsMode.allCases, id: \.self) {
        Image(systemName: $0.systemImage)
      }
    } label: {
    }
    .pickerStyle(.segmented)

    switch mode {
    case .ordinal:
      TodaySummary()
    case .grouped:
      ShowsSummary()
    }
  }
}

#Preview("Ordinal", traits: .vaultModel, .nearbyModel) {
  DaysShowsSummary(mode: .constant(.ordinal))
}

#Preview("Grouped", traits: .vaultModel, .nearbyModel) {
  DaysShowsSummary(mode: .constant(.grouped))
}
