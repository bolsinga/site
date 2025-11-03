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

  @Binding var dayOfLeapYear: Int

  var body: some View {
    #if os(macOS)
      DayList(model: model, dayOfLeapYear: dayOfLeapYear)
    #else
      DayBrowser(dayOfLeapYear: $dayOfLeapYear)
    #endif
  }
}

#Preview(traits: .vaultModel) {
  @Previewable @State var dayOfLeapYear = Date.now.dayOfLeapYear

  NavigationStack {
    DaySummary(dayOfLeapYear: $dayOfLeapYear)
  }
}
