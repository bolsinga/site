//
//  DayChangedModifer.swift
//
//
//  Created by Greg Bolsinga on 5/17/23.
//

import SwiftUI

extension View {
  func onDayChanged(
    action: @escaping () -> Void
  ) -> some View {
    self.onNotification(name: .NSCalendarDayChanged, action: action)
  }
}
