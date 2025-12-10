//
//  SectionHeaderBackgroundModifier.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/26/25.
//

import SwiftUI

private struct SectionHeaderBackgroundModifier: ViewModifier {
  func body(content: Content) -> some View {
    if #available(iOS 26, macOS 26, tvOS 26, *) {
      content
        .padding(5)
        .glassEffect(.regular.tint(.accent.opacity(0.3)))
    } else {
      content
    }
  }
}

extension View {
  func sectionHeaderBackground() -> some View {
    modifier(SectionHeaderBackgroundModifier())
  }
}
