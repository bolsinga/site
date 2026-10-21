//
//  DetailCard.swift
//
//
//  Created by Greg Bolsinga on 10/20/26.
//

import SwiftUI

/// A titled, rounded card holding a detail view's section of content.
struct DetailCard<Content: View>: View {
  let title: Text
  var fillsHeight = false
  @ViewBuilder let content: () -> Content

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      title
        .font(.subheadline.weight(.semibold))
        .textCase(.uppercase)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .foregroundStyle(.secondary)
      content()
    }
    .padding()
    .frame(
      maxWidth: .infinity, maxHeight: fillsHeight ? .infinity : nil, alignment: .topLeading
    )
    .background(.background.secondary, in: .rect(cornerRadius: 20))
  }
}

/// The label of a row in a ``DetailCard``: a trailing chevron when the row navigates, and the whole row tappable.
struct DetailRowLabel<Content: View>: View {
  let isNavigable: Bool
  @ViewBuilder let content: () -> Content

  var body: some View {
    HStack {
      content()
      if isNavigable {
        Spacer()
        Image(systemName: "chevron.right")
          .font(.footnote.bold())
          .foregroundStyle(.tertiary)
      }
    }
    .contentShape(.rect)
  }
}
