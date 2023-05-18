//
//  DeterminateTimerModifier.swift
//
//
//  Created by Greg Bolsinga on 5/17/23.
//

import Combine
import SwiftUI

extension Date {
  fileprivate func date(at trigger: DeterminateTimerModifier.Trigger) -> Date {
    switch trigger {
    case .inFiveSeconds:
      let date = Calendar.autoupdatingCurrent.date(byAdding: .second, value: 5, to: self)
      guard let date else { return self }
      return date
    case .atMidnight:
      return self.midnightTonight
    }
  }
}

struct DeterminateTimerModifier: ViewModifier {
  enum Trigger {
    case inFiveSeconds
    case atMidnight
  }

  @State var startDate: Date = Date.now

  let triggerDate: Date
  let action: () -> Void

  internal init(triggerDate: Date, action: @escaping () -> Void) {
    self.triggerDate = triggerDate
    self.action = action
  }

  public init(
    trigger: DeterminateTimerModifier.Trigger,
    action: @escaping () -> Void
  ) {
    self.init(triggerDate: Date.now.date(at: trigger), action: action)
  }

  func mainDeferredAction() {
    // This Task / @MainActor seems to accomplish a similar DispatchQueue.main.async feel.
    // Still not clear to me why this is necessary in SwiftUI.
    Task { @MainActor in
      action()
    }
  }

  func body(content: Content) -> some View {
    let timer = Timer.publish(
      every: triggerDate.timeIntervalSince(startDate), on: .main, in: .default
    ).autoconnect()

    content
      .onAppear {
        mainDeferredAction()
      }
      .onReceive(timer) { _ in
        mainDeferredAction()
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
