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
  let action: @MainActor () -> Void

  func body(content: Content) -> some View {
    content
      .task {
        Logger.notification.log("task: \(name.rawValue, privacy: .public)")
        for await _ in NotificationCenter.default.notifications(named: name).map({ $0.name }) {
          Logger.notification.log("notified: \(name.rawValue, privacy: .public)")
          Task { @MainActor in
            Logger.notification.log("main action: \(name.rawValue, privacy: .public)")
            action()
          }
        }
      }
  }
}

extension View {
  func onNotification(name: Notification.Name, action: @MainActor @escaping () -> Void) -> some View
  {
    modifier(NotificationModifier(name: name, action: action))
  }
}
