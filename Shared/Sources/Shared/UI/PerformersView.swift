//
//  PerformersView.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/11/25.
//

import CoreText
import Foundation
import SwiftUI

extension EnvironmentValues {
  /// Whether names are marked with the dots for the first and most recent times. The dots mean
  /// something only by their color, so a monochrome rendering, like a tinted widget, leaves them out.
  @Entry public var showsNameMarkers = true
}

/// A name, followed by a green dot when it was the first time and a red dot when it was the most
/// recent time.
private struct MarkedName: View {
  let name: String
  let isFirstTime: Bool
  let isMostRecent: Bool
  let accessibilityLabel: Text

  @Environment(\.showsNameMarkers) private var showsNameMarkers

  @Environment(\.font) private var environmentFont
  @Environment(\.fontResolutionContext) private var fontResolutionContext

  private var capHeight: CGFloat {
    CTFontGetCapHeight((environmentFont ?? .body).resolve(in: fontResolutionContext).ctFont)
  }

  private var markerSize: CGFloat { capHeight * 0.55 }

  /// How far to lift a dot, whose symbol sits on the baseline at its own small size, so it is
  /// centered between the baseline and the top of the name's capitals, whatever the font size.
  private var dotBaselineOffset: CGFloat {
    (capHeight - markerSize * Self.symbolCapHeightRatio) / 2
  }

  /// The cap height of the system font, as a fraction of its size.
  private static let symbolCapHeightRatio: CGFloat = 0.705

  /// Softer than the system colors, which are bright beside text.
  private let firstTimeColor = Color.green.mix(with: .gray, by: 0.4)
  private let mostRecentColor = Color.red.mix(with: .gray, by: 0.4)

  private func dot(_ color: Color) -> Text {
    Text(Image(systemName: "circle.fill")).font(.system(size: markerSize))
      .foregroundStyle(color)
      .baselineOffset(dotBaselineOffset)
  }

  @Environment(\.displayScale) private var displayScale
  @Environment(\.colorScheme) private var colorScheme

  /// Both dots, one above the other. Inline text can't stack two symbols, so they are drawn into
  /// a single image that sits in the text like one symbol does.
  private var stackedDots: Text {
    let dots = VStack(spacing: -markerSize * 0.06) {
      Image(systemName: "circle.fill").foregroundStyle(firstTimeColor)
      Image(systemName: "circle.fill").foregroundStyle(mostRecentColor)
    }
    .font(.system(size: markerSize))
    .environment(\.colorScheme, colorScheme)
    let renderer = ImageRenderer(content: dots)
    renderer.scale = displayScale
    guard let image = renderer.cgImage else {
      return Text("\(firstTime)\u{00A0}\(mostRecent)")
    }
    let height = CGFloat(image.height) / displayScale
    return Text(Image(decorative: image, scale: displayScale))
      .baselineOffset((capHeight - height) / 2)
  }

  private var firstTime: Text { dot(firstTimeColor) }

  private var mostRecent: Text { dot(mostRecentColor) }

  private var help: Text {
    switch (isFirstTime, isMostRecent) {
    case (true, true): Text("First and Most Recent Show")
    case (true, false): Text("First Show")
    default: Text("Most Recent Show")
    }
  }

  var body: some View {
    if showsNameMarkers && (isFirstTime || isMostRecent) {
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
    case (true, true): Text("\(name)\u{00A0}\(stackedDots)")
    case (true, false): Text("\(name)\u{00A0}\(firstTime)")
    default: Text("\(name)\u{00A0}\(mostRecent)")
    }
  }
}

/// A performer's name, marked when it was the first or most recent time seeing them.
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

/// A venue's name, marked when it was the first or most recent time at it.
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
