//
//  DetailCard.swift
//
//
//  Created by Greg Bolsinga on 10/20/26.
//

import SwiftUI

struct DetailCard<Content: View>: View {
  let title: Text
  @ViewBuilder let content: () -> Content

  var body: some View {
    ClampedWidth {
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
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(.background.secondary, in: .rect(cornerRadius: 20))
    }
  }
}

/// Takes the width it is offered, whatever its content reports, so that a sub-pixel overshoot in the content can't widen a scroll view.
private struct ClampedWidth: Layout {
  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    guard let subview = subviews.first else { return .zero }
    let size = subview.sizeThatFits(proposal)
    return CGSize(width: proposal.width ?? size.width, height: size.height)
  }

  func placeSubviews(
    in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
  ) {
    subviews.first?.place(
      at: bounds.origin, anchor: .topLeading,
      proposal: ProposedViewSize(width: bounds.width, height: bounds.height))
  }
}

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
