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

  @ViewBuilder private var detailsView: some View {
    VStack(alignment: .trailing) {
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
    HStack {
      PerformersView(performers: performers, firstTimeArtistIDs: firstTimeArtistIDs)
      Spacer()
      detailsView
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
