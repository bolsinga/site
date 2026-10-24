//
//  FirstTimesCard.swift
//
//
//  Created by Greg Bolsinga on 10/23/26.
//

import Shared
import SwiftUI

/// How many artists and venues were seen for the first time in a day's shows.
struct FirstTimesCard: View {
  let artistCount: Int
  let venueCount: Int

  init(shows: [ShowDigest]) {
    self.artistCount = shows.firstTimeArtistCount
    self.venueCount = shows.firstTimeVenueCount
  }

  private func text(artists count: Int) -> AttributedString {
    count == 1
      ? AttributedString(localized: "**\(count)** New Artist")
      : AttributedString(localized: "**\(count)** New Artists")
  }

  private func text(venues count: Int) -> AttributedString {
    count == 1
      ? AttributedString(localized: "**\(count)** New Venue")
      : AttributedString(localized: "**\(count)** New Venues")
  }

  var body: some View {
    // Nothing to say when everything on the day was seen before.
    if artistCount > 0 || venueCount > 0 {
      DetailCard(title: Text("First Times")) {
        StatRows {
          if artistCount > 0 {
            StatRow(text: text(artists: artistCount), animatesChanges: false)
          }
          if venueCount > 0 {
            StatRow(text: text(venues: venueCount), animatesChanges: false)
          }
        }
      }
    }
  }
}

private func previewShow(_ id: String, artists: [String], venue: String, isFirstTimeVenue: Bool)
  -> ShowDigest
{
  ShowDigest(
    id: .show(id), date: PartialDate(year: 2010, month: 10, day: 17),
    performers: artists.map { ArchiveItem(id: .artist($0), name: $0) }, venue: venue,
    venueID: .venue(venue), location: Location(city: "San Francisco", state: "CA"), comment: nil,
    firstTimeArtistIDs: Set(artists.map { .artist($0) }), isFirstTimeVenue: isFirstTimeVenue)
}

#Preview("Several") {
  FirstTimesCard(
    shows: [
      previewShow("sh0", artists: ["a0", "a1", "a2"], venue: "v0", isFirstTimeVenue: true),
      previewShow("sh1", artists: ["a3"], venue: "v1", isFirstTimeVenue: true),
    ]
  )
  .padding()
}

#Preview("One") {
  FirstTimesCard(shows: [previewShow("sh0", artists: ["a0"], venue: "v0", isFirstTimeVenue: false)])
    .padding()
}
