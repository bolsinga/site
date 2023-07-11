//
//  NotificationModifier.swift
//
//
//  Created by Greg Bolsinga on 5/17/23.
//

import SwiftUI
import os

extension Logger {
  static let notification = Logger(category: "notification")
}

struct NotificationModifier: ViewModifier {
  let name: Notification.Name
  let action: () -> Void

  private func mainDeferredAction() {
    // This Task / @MainActor seems to accomplish a similar DispatchQueue.main.async feel.
    // Still not clear to me why this is necessary in SwiftUI.
    Task { @MainActor in
      Logger.notification.log("main action: \(name.rawValue, privacy: .public)")
      action()
    }
  }

  func body(content: Content) -> some View {
    content
      .task {
        Logger.notification.log("task: \(name.rawValue, privacy: .public)")
        mainDeferredAction()
        for await _ in NotificationCenter.default.notifications(named: name) {
          Logger.notification.log("notified: \(name.rawValue, privacy: .public)")
          mainDeferredAction()
        }
      }
  }
}

extension View {
  func onNotification(
    name: Notification.Name,
    action: @escaping () -> Void
  ) -> some View {
    modifier(NotificationModifier(name: name, action: action))
  }
}
