//
//  CategoryAnnotationView.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 6/14/26.
//

import Shared
import SwiftUI

private let annotationSize: CGFloat = 45
private let imageSize = annotationSize * 2.0 / 3.0
private let badgeSize = annotationSize / 3.0
private let fontSize = annotationSize / 6.0
private let badgeOffsetX = annotationSize / 6.0 + 1
private let badgeOffsetY = annotationSize / 5.0
private let pointerTipExtent: CGFloat = 4.0

private struct Badge: View {
  let count: Int

  // The count is text, so its circle grows with the text size.
  @ScaledMetric(relativeTo: .caption2) private var scaledBadgeSize = badgeSize
  @ScaledMetric(relativeTo: .caption2) private var scaledFontSize = fontSize

  var body: some View {
    ZStack {
      Circle()
        .fill()
        .foregroundStyle(.white)
      Circle()
        .foregroundStyle(.red)
      Text(String(count))
        .font(.system(size: scaledFontSize))
        .bold()
        .foregroundStyle(.white)
    }
    .frame(width: scaledBadgeSize, height: scaledBadgeSize)
    .offset(x: badgeOffsetX, y: badgeOffsetY)
  }
}

struct CategoryAnnotationView: View {
  enum Render {
    case `default`
    case badge(Int)

    @ViewBuilder fileprivate var badge: some View {
      switch self {
      case .default:
        EmptyView()
      case .badge(let count):
        Badge(count: count)
      }
    }
  }

  internal init(
    category: ArchiveCategory,
    render: CategoryAnnotationView.Render
  ) {
    self.systemImageName = category.systemImage
    self.render = render
  }

  private let systemImageName: String
  let render: Render

  /// Distance from the top of the view to the pointer's tip.
  static let tipOffset = annotationSize + pointerTipExtent

  var body: some View {
    ZStack {
      Path { path in
        path.move(to: .init(x: annotationSize / 2.0, y: annotationSize + pointerTipExtent))
        path.addLine(to: .init(x: annotationSize / 2.0 - 10, y: annotationSize - 6.0))
        path.addLine(to: .init(x: annotationSize / 2.0 + 10, y: annotationSize - 6.0))
      }
      .foregroundStyle(.primary)
      Circle()
        .foregroundStyle(.accent)
      Circle()
        .strokeBorder(lineWidth: 2)
      Group {
        Image(systemName: systemImageName)
          .resizable()
          .scaledToFit()
          .frame(width: imageSize, height: imageSize)
        render.badge
      }
    }
    .frame(width: annotationSize, height: annotationSize)
    // The pointer's tip extends below the circle; include it so the tip is the bottom of the pin.
    .padding(.bottom, pointerTipExtent)
    // A map is crowded, so stop growing before the pin covers its neighbors.
    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
  }
}

/// The name shown below a pin. The map draws it outside the pin's frame, so it doesn't make
/// pins cluster sooner.
struct CategoryTitleView: View {
  let title: String

  var body: some View {
    Text(title)
      .font(.caption2)
      .lineLimit(1)
      .fixedSize()
      .padding(.horizontal, 4)
      .foregroundStyle(.black)
      .background(Color.accentColor.opacity(0.3), in: .capsule)
      .background(.white, in: .capsule)
      .overlay(Capsule().strokeBorder(.black, lineWidth: 1))
      .dynamicTypeSize(...DynamicTypeSize.accessibility1)
  }
}

#Preview("Default") {
  CategoryAnnotationView(category: .venues, render: .default)
}

#Preview("0") {
  CategoryAnnotationView(category: .artists, render: .badge(0))
}

#Preview("Title") {
  VStack(spacing: 2) {
    CategoryAnnotationView(category: .venues, render: .default)
    CategoryTitleView(title: "The Fillmore")
  }
}

#Preview("3") {
  CategoryAnnotationView(category: .venues, render: .badge(3))
}

#Preview("10") {
  CategoryAnnotationView(category: .artists, render: .badge(10))
}
