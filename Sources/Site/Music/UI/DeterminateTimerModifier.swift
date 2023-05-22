//
//  DeterminateTimerModifier.swift
//
//
//  Created by Greg Bolsinga on 5/17/23.
//

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

  let trigger: DeterminateTimerModifier.Trigger
  let action: () -> Void

  private func mainDeferredAction() {
    // This Task / @MainActor seems to accomplish a similar DispatchQueue.main.async feel.
    // Still not clear to me why this is necessary in SwiftUI.
    Task { @MainActor in
      action()
    }
  }

  func body(content: Content) -> some View {
    content
      .onAppear {
        mainDeferredAction()
      }.task {
        do {
          repeat {
            try await Task.sleep(
              until: .now + .seconds(Date.now.timeInterval(until: trigger)), clock: .continuous)
            mainDeferredAction()
          } while true
        } catch {}
      }
  }
}

extension View {
  func determinateTimer(
    trigger: DeterminateTimerModifier.Trigger,
    action: @escaping () -> Void
  ) -> some View {
    modifier(DeterminateTimerModifier(trigger: trigger, action: action))
  }
}
