//
//  ConcertBlurb.swift
//
//
//  Created by Greg Bolsinga on 5/18/23.
//

import SwiftUI

public struct ConcertBlurb: View {
  public enum DateFormat: Sendable {
    case noYear
    case relative
    /// Relative to a fixed date instead of now, for views rendered ahead of time (widgets).
    case relativeTo(Date)
  }

  let venue: String
  let date: PartialDate
  let performers: [ArchiveItem]
  let dateFormat: DateFormat
  let firstTimeArtistIDs: Set<ArchivePath>
  let isFirstTimeVenue: Bool

  public init(
    venue: String, date: PartialDate, performers: [ArchiveItem], dateFormat: DateFormat,
    firstTimeArtistIDs: Set<ArchivePath> = [], isFirstTimeVenue: Bool = false
  ) {
    self.venue = venue
    self.date = date
    self.performers = performers
    self.dateFormat = dateFormat
    self.firstTimeArtistIDs = firstTimeArtistIDs
    self.isFirstTimeVenue = isFirstTimeVenue
  }

  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  /// The least width the venue and date keep, so a long lineup can't squeeze them into a sliver.
  @ScaledMetric private var detailsMinimumWidth = 120.0

  @ViewBuilder private func detailsView(alignment: HorizontalAlignment) -> some View {
    VStack(alignment: alignment) {
      VenueName(name: venue, isFirstTime: isFirstTimeVenue).font(.headline)
      switch dateFormat {
      case .noYear:
        Text(date.formatted(.noYear))
          .font(.footnote)
      case .relative:
        if let date = date.date {
          Text(date.formatted(.relative(presentation: .numeric)))
            .font(.footnote)
        }
      case .relativeTo(let reference):
        if let date = date.date {
          Text(Self.relativeFormatter.localizedString(for: date, relativeTo: reference))
            .font(.footnote)
        }
      }
    }
  }

  /// Matches `.relative(presentation: .numeric)`, which can only format relative to now.
  private static var relativeFormatter: RelativeDateTimeFormatter {
    let formatter = RelativeDateTimeFormatter()
    formatter.dateTimeStyle = .numeric
    return formatter
  }

  public var body: some View {
    if dynamicTypeSize.isAccessibilitySize {
      // Side by side leaves each column too narrow at these sizes, so the venue and date go below.
      VStack(alignment: .leading, spacing: 4) {
        PerformersView(performers: performers, firstTimeArtistIDs: firstTimeArtistIDs)
        detailsView(alignment: .leading)
      }
    } else {
      HStack {
        // The lineup wraps before it truncates; the venue wraps in the room that is left.
        PerformersView(performers: performers, firstTimeArtistIDs: firstTimeArtistIDs)
          .layoutPriority(1)
        Spacer(minLength: 8)
        detailsView(alignment: .trailing)
          .multilineTextAlignment(.trailing)
          .frame(minWidth: detailsMinimumWidth, alignment: .trailing)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
  }
}

extension ConcertBlurb {
  public init(digest: ShowDigest, dateFormat: DateFormat) {
    self.init(
      venue: digest.venue,
      date: digest.date,
      performers: digest.performers,
      dateFormat: dateFormat,
      firstTimeArtistIDs: digest.firstTimeArtistIDs,
      isFirstTimeVenue: digest.isFirstTimeVenue)
  }
}

private let previewShow = ShowDigest(
  id: .show("sh0"),
  date: PartialDate(year: 2010, month: 10, day: 17),
  performers: [
    ArchiveItem(id: .artist("ar0"), name: "Belle And Sebastian"),
    ArchiveItem(id: .artist("ar1"), name: "The National"),
  ],
  venue: "Treasure Island",
  venueID: .venue("v0"),
  location: Location(city: "San Francisco", state: "CA"),
  comment: nil,
  firstTimeArtistIDs: [.artist("ar1")], isFirstTimeVenue: true)

#Preview("No Year") {
  ConcertBlurb(digest: previewShow, dateFormat: .noYear)
}

#Preview("Relative") {
  ConcertBlurb(digest: previewShow, dateFormat: .relative)
}

#Preview("Relative To") {
  ConcertBlurb(
    digest: previewShow, dateFormat: .relativeTo(.now.addingTimeInterval(-86_400 * 365)))
}

private let longNamesShow = ShowDigest(
  id: .show("sh1"),
  date: PartialDate(year: 2010, month: 4, day: 6),
  performers: [
    ArchiveItem(id: .artist("ar0"), name: "PG-13"),
    ArchiveItem(id: .artist("ar1"), name: "Concept The Electric Octopus And The Long Name Band"),
    ArchiveItem(id: .artist("ar2"), name: "The Angels"),
  ],
  venue: "Carousel Lounge And Grill At The Corner Of Seventh And Brazos",
  venueID: .venue("v1"),
  location: Location(city: "Austin", state: "TX"),
  comment: nil,
  firstTimeArtistIDs: [.artist("ar1")], isFirstTimeVenue: true)

#Preview("Long Names") {
  ConcertBlurb(digest: longNamesShow, dateFormat: .noYear)
    .padding()
}

#Preview("Long Names, Accessibility") {
  ConcertBlurb(digest: longNamesShow, dateFormat: .noYear)
    .padding()
    .dynamicTypeSize(.accessibility2)
}
