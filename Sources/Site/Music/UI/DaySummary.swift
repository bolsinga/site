//
//  DaySummary.swift
//  site
//
//  Created by Greg Bolsinga on 9/23/24.
//

import SwiftUI

extension DayList {
  fileprivate init(model: VaultModel, dayOfLeapYear: Int) {
    self.init(concerts: model.concerts(on: dayOfLeapYear), dayOfLeapYear: dayOfLeapYear)
  }
}

struct DaySummary: View {
  @Environment(VaultModel.self) var model

  var body: some View {
    #if os(macOS)
      DayList(model: model, dayOfLeapYear: Date.now.dayOfLeapYear)
    #else
      DayBrowser()
    #endif
  }
}

#Preview(traits: .vaultModel) {
  NavigationStack {
    DaySummary()
  }
}
