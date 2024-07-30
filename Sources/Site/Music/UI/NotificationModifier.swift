//
//  NotificationModifier.swift
//
//
//  Created by Greg Bolsinga on 5/17/23.
//

import SwiftUI
import os

extension Logger {
  nonisolated(unsafe) static let notification = Logger(category: "notification")
#if swift(>=6.0)
  #warning("nonisolated(unsafe) unneeded.")
#endif
}

struct NotificationModifier: ViewModifier {
  let name: Notification.Name
  let action: @MainActor @Sendable () -> Void

  private func mainDeferredAction() {
    // This Task / @MainActor seems to accomplish a similar DispatchQueue.main.async feel.
    // Still not clear to me why this is necessary in SwiftUI.
    Task {
      Logger.notification.log("main action: \(name.rawValue, privacy: .public)")
      await action()
    }
  }

  func body(content: Content) -> some View {
    content
      .task {
        Logger.notification.log("task: \(name.rawValue, privacy: .public)")
        mainDeferredAction()
        for await _ in NotificationCenter.default.notifications(named: name).map({ $0.name }) {
          Logger.notification.log("notified: \(name.rawValue, privacy: .public)")
          mainDeferredAction()
        }
      }
  }
}

extension View {
  func onNotification(
    name: Notification.Name,
    action: @MainActor @Sendable @escaping () -> Void
  ) -> some View {
    modifier(NotificationModifier(name: name, action: action))
  }
}
