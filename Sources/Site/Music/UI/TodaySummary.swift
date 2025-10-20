//
//  TodaySummary.swift
//  site
//
//  Created by Greg Bolsinga on 9/23/24.
//

import SwiftUI

struct TodaySummary: View {
  @Environment(VaultModel.self) var model

  var body: some View {
    DayList(concerts: model.todayConcerts, date: .now)
  }
}

#Preview(traits: .vaultModel) {
  NavigationStack {
    TodaySummary()
  }
}
