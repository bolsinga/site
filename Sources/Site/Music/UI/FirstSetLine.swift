//
//  FirstSetLine.swift
//  site
//
//  Created by Greg Bolsinga on 11/1/26.
//

import SwiftUI

/// Where an item was first seen among every item of its kind.
struct FirstSetOrder {
  /// 1 is the first ever seen.
  let rank: Int
  let count: Int

  var ordinal: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .ordinal
    return formatter.string(from: rank as NSNumber) ?? String(rank)
  }
}

/// A line from the first item ever seen to the most recent, with a dot where this item falls.
struct FirstSetLine: View {
  let order: FirstSetOrder

  @ScaledMetric(relativeTo: .body) private var dotSize = 10

  private var fraction: Double {
    guard order.count > 1 else { return 0 }
    return Double(order.rank - 1) / Double(order.count - 1)
  }

  var body: some View {
    GeometryReader { proxy in
      let midY = proxy.size.height / 2
      ZStack {
        Capsule()
          .fill(.secondary.opacity(0.35))
          .frame(height: 3)
          .position(x: proxy.size.width / 2, y: midY)
        Circle()
          .fill(.tint)
          .overlay(Circle().stroke(.background, lineWidth: 1.5))
          .frame(width: dotSize, height: dotSize)
          .position(x: dotSize / 2 + fraction * (proxy.size.width - dotSize), y: midY)
      }
    }
    .frame(height: dotSize)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(Text("\(order.ordinal) of \(order.count)"))
  }
}

#Preview {
  VStack(spacing: 24) {
    FirstSetLine(order: FirstSetOrder(rank: 1, count: 200))
    FirstSetLine(order: FirstSetOrder(rank: 57, count: 200))
    FirstSetLine(order: FirstSetOrder(rank: 1034, count: 1034))
  }
  .frame(width: 96)
  .padding()
}
