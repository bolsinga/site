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

extension EnvironmentValues {
  /// Presents a sheet that stays up only while the navigation state is unchanged.
  @Entry var presentSheet: (AnyView) -> Void = { _ in }
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
