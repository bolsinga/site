//
//  PerformersView.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/11/25.
//

import Foundation
import SwiftUI

/// A name, followed by a sparkle when it was the first time and a clock when it was the most
/// recent time.
private struct MarkedName: View {
  let name: String
  let isFirstTime: Bool
  let isMostRecent: Bool
  let accessibilityLabel: Text

  /// Smaller than the name, and scaled with Dynamic Type.
  @ScaledMetric(relativeTo: .caption2) private var markerSize = 9.0

  private var sparkle: Text {
    Text(Image(systemName: "sparkles")).font(.system(size: markerSize))
      .foregroundStyle(.tint)
  }

  private var recent: Text {
    Text(Image(systemName: "clock.badge.exclamationmark")).font(.system(size: markerSize))
      .foregroundStyle(.tint)
  }

  private var help: Text {
    switch (isFirstTime, isMostRecent) {
    case (true, true): Text("First and Most Recent Show")
    case (true, false): Text("First Show")
    default: Text("Most Recent Show")
    }
  }

  var body: some View {
    if isFirstTime || isMostRecent {
      // A non breaking space keeps the markers from wrapping onto a line by itself.
      markedName
        .accessibilityLabel(accessibilityLabel)
        #if !os(tvOS)
          .help(help)
        #endif
    } else {
      Text(name)
    }
  }

  private var markedName: Text {
    switch (isFirstTime, isMostRecent) {
    case (true, true): Text("\(name)\u{00A0}\(sparkle)\u{00A0}\(recent)")
    case (true, false): Text("\(name)\u{00A0}\(sparkle)")
    default: Text("\(name)\u{00A0}\(recent)")
    }
  }
}

/// A performer's name, followed by a sparkle when it was the first time seeing them and a clock when
/// it was the most recent time.
public struct PerformerName: View {
  let name: String
  let isFirstTime: Bool
  let isMostRecent: Bool

  public init(name: String, isFirstTime: Bool, isMostRecent: Bool = false) {
    self.name = name
    self.isFirstTime = isFirstTime
    self.isMostRecent = isMostRecent
  }

  private var accessibilityLabel: Text {
    switch (isFirstTime, isMostRecent) {
    case (true, true): Text("First and most recent time seeing \(name)")
    case (true, false): Text("First time seeing \(name)")
    default: Text("Most recent time seeing \(name)")
    }
  }

  public var body: some View {
    MarkedName(
      name: name, isFirstTime: isFirstTime, isMostRecent: isMostRecent,
      accessibilityLabel: accessibilityLabel)
  }
}

/// A venue's name, followed by a sparkle when it was the first time at it and a clock when it was
/// the most recent time.
public struct VenueName: View {
  let name: String
  let isFirstTime: Bool
  let isMostRecent: Bool

  public init(name: String, isFirstTime: Bool, isMostRecent: Bool = false) {
    self.name = name
    self.isFirstTime = isFirstTime
    self.isMostRecent = isMostRecent
  }

  private var accessibilityLabel: Text {
    switch (isFirstTime, isMostRecent) {
    case (true, true): Text("First and most recent time at \(name)")
    case (true, false): Text("First time at \(name)")
    default: Text("Most recent time at \(name)")
    }
  }

  public var body: some View {
    MarkedName(
      name: name, isFirstTime: isFirstTime, isMostRecent: isMostRecent,
      accessibilityLabel: accessibilityLabel)
  }
}

public struct PerformersView: View {
  let performers: [ArchiveItem]
  let firstTimeArtistIDs: Set<ArchivePath>
  let mostRecentArtistIDs: Set<ArchivePath>

  public init(
    performers: [ArchiveItem], firstTimeArtistIDs: Set<ArchivePath> = [],
    mostRecentArtistIDs: Set<ArchivePath> = []
  ) {
    self.performers = performers
    self.firstTimeArtistIDs = firstTimeArtistIDs
    self.mostRecentArtistIDs = mostRecentArtistIDs
  }

  public var body: some View {
    VStack(alignment: .leading) {
      // Keyed by id, as two performers can share a name.
      ForEach(Array(performers.enumerated()), id: \.element.id) { index, performer in
        PerformerName(
          name: performer.name, isFirstTime: firstTimeArtistIDs.contains(performer.id),
          isMostRecent: mostRecentArtistIDs.contains(performer.id)
        )
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

#Preview("Most Recent") {
  PerformersView(
    performers: previewPerformers, firstTimeArtistIDs: [.artist("ar0")],
    mostRecentArtistIDs: [.artist("ar0"), .artist("ar1")])
}

#Preview("No Performers") {
  PerformersView(performers: [])
}
