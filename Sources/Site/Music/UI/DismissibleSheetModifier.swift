//
//  DismissibleSheetModifier.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/19/25.
//

import SwiftUI

/// A sheet shown for the navigation state it was presented from.
struct PresentedSheet {
  let state: ArchiveNavigation.State
  let content: AnyView
}

/// Presents a sheet that stays up only while the navigation state is unchanged.
struct SheetPresenter: Equatable {
  let present: (AnyView) -> Void

  func callAsFunction(_ content: AnyView) { present(content) }

  // The action reads current state when called, so a new one never changes what dependents see.
  static func == (lhs: Self, rhs: Self) -> Bool { true }
}

extension EnvironmentValues {
  @Entry var presentSheet = SheetPresenter { _ in }
}

struct DismissibleSheetContent: View {
  @Environment(\.dismiss) private var dismiss

  let content: AnyView

  var body: some View {
    VStack {
      content
      #if os(macOS)
        Button(role: .close) { dismiss() }
      #endif
    }
    .padding(10)
    .presentationDetents([.medium, .large])
  }
}
