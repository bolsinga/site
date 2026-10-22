//
//  PerformersView.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/11/25.
//

import Foundation
import SwiftUI

/// A performer's name, followed by a sparkle when it was the first time seeing them.
public struct PerformerName: View {
  let name: String
  let isFirstTime: Bool

  public init(name: String, isFirstTime: Bool) {
    self.name = name
    self.isFirstTime = isFirstTime
  }

  @ScaledMetric(relativeTo: .caption2) private var sparkleSize = 9.0

  private var sparkle: Text {
    Text(Image(systemName: "sparkles")).font(.system(size: sparkleSize))
      .foregroundStyle(Color.accentColor)
  }

  public var body: some View {
    if isFirstTime {
      Text("\(name) \(sparkle)")
        .accessibilityLabel(Text("First time seeing \(name)"))
        #if !os(tvOS)
          .help(Text("First Show"))
        #endif
    } else {
      Text(name)
    }
  }
}

public struct PerformersView: View {
  let performers: [String]
  let firstTimePerformers: Set<String>

  public init(performers: [String], firstTimePerformers: Set<String> = []) {
    self.performers = performers
    self.firstTimePerformers = firstTimePerformers
  }

  private var headliner: String { performers[0] }
  private var support: [String] { Array(performers.dropFirst()) }

  public var body: some View {
    VStack(alignment: .leading) {
      PerformerName(name: headliner, isFirstTime: firstTimePerformers.contains(headliner))
        .font(.headline)
      ForEach(support, id: \.self) {
        PerformerName(name: $0, isFirstTime: firstTimePerformers.contains($0))
      }
    }
  }
}

#Preview {
  PerformersView(performers: ["Belle And Sebastian", "The National", "Broken Social Scene"])
}

#Preview("First Times") {
  PerformersView(
    performers: ["Belle And Sebastian", "The National", "Broken Social Scene"],
    firstTimePerformers: ["Belle And Sebastian", "Broken Social Scene"])
}
