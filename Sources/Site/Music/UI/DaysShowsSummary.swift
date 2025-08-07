//
//  DaysShowsSummary.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 8/6/25.
//

import SwiftUI

struct DaysShowsSummary: View {
  private enum Mode: CaseIterable {
    case ordinal
    case grouped

    var systemImage: String {
      switch self {
      case .ordinal:
        "calendar"
      case .grouped:
        "list.bullet"
      }
    }
  }

  @State private var mode = Self.Mode.ordinal

  var body: some View {
    Picker(selection: $mode) {
      ForEach(Mode.allCases, id: \.self) {
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

#Preview(traits: .modifier(VaultPreviewModifier()), .modifier(NearbyPreviewModifer())) {
  DaysShowsSummary()
}
