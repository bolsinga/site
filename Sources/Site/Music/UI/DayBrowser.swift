//
//  DayBrowser.swift
//  site
//
//  Created by Greg Bolsinga on 9/23/24.
//

import SwiftUI

struct DayBrowser: View {
  @Environment(VaultModel.self) var model

  enum DayTab: Int {
    case yesterday
    case today
    case tomorrow
  }

  @State private var dayOfLeapYear: Int = 1
  @State private var selection: DayTab = .today

  @ViewBuilder private func dayList(_ dayOfLeapYear: Int) -> some View {
    DayList(concerts: model.concerts(on: dayOfLeapYear), dayOfLeapYear: dayOfLeapYear)
  }

  var body: some View {
    TabView(selection: $selection) {
      Tab(value: DayTab.yesterday) {
        dayList(dayOfLeapYear.previousDayOfLeapYear)
      }

      Tab(value: DayTab.today) {
        dayList(dayOfLeapYear)
          .onDisappear {
            switch selection {
            case .yesterday:
              dayOfLeapYear = dayOfLeapYear.previousDayOfLeapYear
            case .today:
              break
            case .tomorrow:
              dayOfLeapYear = dayOfLeapYear.nextDayOfLeapYear
            }

            selection = .today
          }
      }

      Tab(value: DayTab.tomorrow) {
        dayList(dayOfLeapYear.nextDayOfLeapYear)
      }
    }
    .navigationTitle(dayOfLeapYear.relativeTitle)  // need this here for ipad
    .onAppear {
      self.dayOfLeapYear = model.todayDayOfLeapYear
    }
    #if !os(macOS)
      .indexViewStyle(.page(backgroundDisplayMode: .always))
      .tabViewStyle(.page(indexDisplayMode: .automatic))
    #endif
  }
}

#Preview(traits: .vaultModel) {
  NavigationStack {
    DayBrowser()
  }
}
