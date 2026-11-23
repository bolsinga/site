//
//  StatsTitles.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/3/25.
//

import Foundation
import SiteCore

struct StatsTitles {
  let weekday: LocalizedStringResource
  let month: LocalizedStringResource
  let state: LocalizedStringResource

  static let generic = StatsTitles(
    weekday: LocalizedStringResource("Weekdays", bundle: #bundle),
    month: LocalizedStringResource("Months", bundle: #bundle),
    state: LocalizedStringResource("States", bundle: #bundle))
}
