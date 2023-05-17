//
//  DeterminateTimerModifier.swift
//
//
//  Created by Greg Bolsinga on 5/17/23.
//

import Combine
import SwiftUI

struct DeterminateTimerModifier: ViewModifier {
  let action: (Timer.TimerPublisher.Output) -> Void

  func body(content: Content) -> some View {
    let now = Date.now
    let timer = Deferred { Just(now) }  // This will send/received Date.now when connected.
      .append(
        Timer.publish(every: now.timeIntervalUntilMidnight, on: .main, in: .default).autoconnect())

    content
      .onReceive(timer) { date in
        // This Task / @MainActor seems to accomplish a similar DispatchQueue.main.async feel.
        // Still not clear to me why this is necessary in SwiftUI.
        Task { @MainActor in
          action(date)
        }
      }
  }
}

extension View {
  func determinateTimer(action: @escaping (Timer.TimerPublisher.Output) -> Void) -> some View {
    modifier(DeterminateTimerModifier(action: action))
  }
}
