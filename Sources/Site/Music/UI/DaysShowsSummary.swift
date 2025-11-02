//
//  DaysShowsSummary.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 8/6/25.
//

import SwiftUI

struct DaysShowsSummary: View {
  @Binding var mode: ShowsMode
  @Binding var dayOfLeapYear: Int

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
      DaySummary(dayOfLeapYear: $dayOfLeapYear)
    case .grouped:
      ShowsSummary()
    }
  }
}

#Preview(traits: .vaultModel, .nearbyModel) {
  @Previewable @State var showsMode = ShowsMode.ordinal
  @Previewable @State var dayOfLeapYear = Date.now.dayOfLeapYear

  NavigationStack {
    DaysShowsSummary(mode: $showsMode, dayOfLeapYear: $dayOfLeapYear)
  }
}
