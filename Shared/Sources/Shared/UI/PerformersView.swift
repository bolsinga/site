//
//  PerformersView.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/11/25.
//

import Foundation
import SwiftUI

/// A name, followed by a sparkle when it was the first time.
private struct FirstTimeName: View {
  let name: String
  let isFirstTime: Bool
  let accessibilityLabel: Text

  /// Smaller than the name, and scaled with Dynamic Type.
  @ScaledMetric(relativeTo: .caption2) private var sparkleSize = 9.0

  private var sparkle: Text {
    Text(Image(systemName: "sparkles")).font(.system(size: sparkleSize))
      .foregroundStyle(.tint)
  }

  var body: some View {
    if isFirstTime {
      // A non breaking space keeps the sparkle from wrapping onto a line by itself.
      Text("\(name)\u{00A0}\(sparkle)")
        .accessibilityLabel(accessibilityLabel)
        #if !os(tvOS)
          .help(Text("First Show"))
        #endif
    } else {
      Text(name)
    }
  }
}

/// A performer's name, followed by a sparkle when it was the first time seeing them.
public struct PerformerName: View {
  let name: String
  let isFirstTime: Bool

  public init(name: String, isFirstTime: Bool) {
    self.name = name
    self.isFirstTime = isFirstTime
  }

  public var body: some View {
    FirstTimeName(
      name: name, isFirstTime: isFirstTime, accessibilityLabel: Text("First time seeing \(name)"))
  }
}

/// A venue's name, followed by a sparkle when it was the first time at it.
public struct VenueName: View {
  let name: String
  let isFirstTime: Bool

  public init(name: String, isFirstTime: Bool) {
    self.name = name
    self.isFirstTime = isFirstTime
  }

  public var body: some View {
    FirstTimeName(
      name: name, isFirstTime: isFirstTime, accessibilityLabel: Text("First time at \(name)"))
  }
}

public struct PerformersView: View {
  let performers: [ArchiveItem]
  let firstTimeArtistIDs: Set<ArchivePath>

  public init(performers: [ArchiveItem], firstTimeArtistIDs: Set<ArchivePath> = []) {
    self.performers = performers
    self.firstTimeArtistIDs = firstTimeArtistIDs
  }

  public var body: some View {
    VStack(alignment: .leading) {
      // Keyed by id, as two performers can share a name.
      ForEach(Array(performers.enumerated()), id: \.element.id) { index, performer in
        PerformerName(name: performer.name, isFirstTime: firstTimeArtistIDs.contains(performer.id))
          .font(index == 0 ? .headline : nil)
      }
    }
    // Each name takes the height its wrapped lines need, rather than truncating to the row's height.
    .fixedSize(horizontal: false, vertical: true)
  }
}

private let previewPerformers = [
  ArchiveItem(id: .artist("ar0"), name: "Belle And Sebastian"),
  ArchiveItem(id: .artist("ar1"), name: "The National"),
  ArchiveItem(id: .artist("ar2"), name: "Broken Social Scene"),
]

#Preview {
  PerformersView(performers: previewPerformers)
}

#Preview("First Times") {
  PerformersView(
    performers: previewPerformers, firstTimeArtistIDs: [.artist("ar0"), .artist("ar2")])
}

#Preview("No Performers") {
  PerformersView(performers: [])
}
