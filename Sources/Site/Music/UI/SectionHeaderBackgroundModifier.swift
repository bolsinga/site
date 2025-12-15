//
//  SectionHeaderBackgroundModifier.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/26/25.
//

import SwiftUI

private struct SectionHeaderBackgroundModifier: ViewModifier {
  func body(content: Content) -> some View {
    content
      .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
      .glassEffect(.regular.tint(.accent.opacity(0.3)))
  }
}

extension View {
  func sectionHeaderBackground() -> some View {
    modifier(SectionHeaderBackgroundModifier())
  }
}
