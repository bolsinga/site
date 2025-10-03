//
//  StatsTitles.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/3/25.
//

import Foundation

struct StatsTitles {
  let weekday: LocalizedStringResource
  let month: LocalizedStringResource
  let state: LocalizedStringResource

  static let generic = StatsTitles(
    weekday: "Weekdays", month: "Months", state: "States")
}
