//
//  ChartBarStyle.swift
//
//
//  Created by Greg Bolsinga on 10/21/26.
//

import Charts
import SwiftUI

extension ChartContent {
  /// The tint, with the bar for the current weekday, month or state a little brighter.
  func chartBarStyle(isCurrent: Bool) -> some ChartContent {
    foregroundStyle(
      isCurrent ? AnyShapeStyle(Color.accentColor.mix(with: .white, by: 0.35)) : AnyShapeStyle(.tint)
    )
  }
}
