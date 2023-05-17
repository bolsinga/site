//
//  DeterminateTimerModifier.swift
//
//
//  Created by Greg Bolsinga on 5/17/23.
//

import Combine
import SwiftUI

extension Date {
  fileprivate func timeInterval(until trigger: DeterminateTimerModifier.Trigger) -> TimeInterval {
    switch trigger {
    case .inFiveSeconds:
      return 5
    case .atMidnight:
      return self.timeIntervalUntilMidnight
    }
  }
}

struct DeterminateTimerModifier: ViewModifier {
  enum Trigger {
    case inFiveSeconds
    case atMidnight
  }

  let trigger: Trigger
  let action: (Timer.TimerPublisher.Output) -> Void

  func mainDeferredAction(date: Date) {
    // This Task / @MainActor seems to accomplish a similar DispatchQueue.main.async feel.
    // Still not clear to me why this is necessary in SwiftUI.
    Task { @MainActor in
      action(date)
    }
  }

  func body(content: Content) -> some View {
    let now = Date.now
    let timer = Timer.publish(every: now.timeInterval(until: trigger), on: .main, in: .default)
      .autoconnect()
    content
      .onAppear {
        mainDeferredAction(date: now)
      }
      .onReceive(timer) { date in
        mainDeferredAction(date: date)
      }
  }
}

extension View {
  func determinateTimer(
    trigger: DeterminateTimerModifier.Trigger,
    action: @escaping (Timer.TimerPublisher.Output) -> Void
  ) -> some View {
    modifier(DeterminateTimerModifier(trigger: trigger, action: action))
  }
}
