//
//  ShowConcerts.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/27/26.
//

@preconcurrency import AppIntents
import Foundation
import Shared
import SwiftUI

/// Answers a request for concerts with a dialog and a list, which Siri can show without the app.
private func concertResult(_ concerts: [ConcertEntity])
  -> some IntentResult & ReturnsValue<[ConcertEntity]> & ProvidesDialog & ShowsSnippetView
{
  let dialog: IntentDialog =
    switch concerts.count {
    case 0: "No concerts found."
    case 1: "Found 1 concert."
    default: "Found \(concerts.count) concerts."
    }
  return .result(value: concerts, dialog: dialog) {
    ConcertsSnippetView(concerts: concerts)
  }
}

private struct ConcertsSnippetView: View {
  private static let limit = 6

  let concerts: [ConcertEntity]

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      ForEach(concerts.prefix(Self.limit)) { concert in
        VStack(alignment: .leading) {
          Text(concert.title).font(.headline).lineLimit(1)
          Text(concert.subtitle).font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
        }
      }
      if concerts.count > Self.limit {
        Text("And \(concerts.count - Self.limit) more")
          .font(.footnote)
          .foregroundStyle(.secondary)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
  }
}

/// Any mix of what narrows concerts. The requests below each take one part, for a phrase to say.
struct ShowConcerts: AppIntent {
  static let title = LocalizedStringResource("Show Concerts")

  static let description = IntentDescription(
    "Shows concerts by an artist, at a venue, in a city or on a date.",
    categoryName: "Discover", resultValueName: "Concerts")

  static var parameterSummary: some ParameterSummary {
    Summary("Show concerts") {
      \.$artist
      \.$venue
      \.$city
      \.$date
    }
  }

  @Parameter(title: "Artist")
  var artist: ArtistEntity?

  @Parameter(title: "Venue")
  var venue: VenueEntity?

  @Parameter(title: "City")
  var city: CityEntity?

  @Parameter(title: "Date")
  var date: Date?

  @Dependency
  private var vault: Vault

  func perform() async throws -> some IntentResult & ReturnsValue<[ConcertEntity]> & ProvidesDialog
    & ShowsSnippetView
  {
    concertResult(
      vault.concertEntities(
        matching: ConcertSearch(
          artistID: artist?.id, venueID: venue?.id, cityID: city?.id, date: date)))
  }
}

struct ShowConcertsByArtist: AppIntent {
  static let title = LocalizedStringResource("Show Concerts by Artist")

  static let description = IntentDescription("Shows the concerts of an artist.")

  static var parameterSummary: some ParameterSummary {
    Summary("Show concerts by \(\.$artist)")
  }

  @Parameter(title: "Artist")
  var artist: ArtistEntity

  @Dependency
  private var vault: Vault

  func perform() async throws -> some IntentResult & ReturnsValue<[ConcertEntity]> & ProvidesDialog
    & ShowsSnippetView
  {
    concertResult(vault.concertEntities(matching: ConcertSearch(artistID: artist.id)))
  }
}

struct ShowConcertsAtVenue: AppIntent {
  static let title = LocalizedStringResource("Show Concerts at Venue")

  static let description = IntentDescription("Shows the concerts at a venue.")

  static var parameterSummary: some ParameterSummary {
    Summary("Show concerts at \(\.$venue)")
  }

  @Parameter(title: "Venue")
  var venue: VenueEntity

  @Dependency
  private var vault: Vault

  func perform() async throws -> some IntentResult & ReturnsValue<[ConcertEntity]> & ProvidesDialog
    & ShowsSnippetView
  {
    concertResult(vault.concertEntities(matching: ConcertSearch(venueID: venue.id)))
  }
}

struct ShowConcertsInCity: AppIntent {
  static let title = LocalizedStringResource("Show Concerts in City")

  static let description = IntentDescription("Shows the concerts in a city.")

  static var parameterSummary: some ParameterSummary {
    Summary("Show concerts in \(\.$city)")
  }

  @Parameter(title: "City")
  var city: CityEntity

  @Dependency
  private var vault: Vault

  func perform() async throws -> some IntentResult & ReturnsValue<[ConcertEntity]> & ProvidesDialog
    & ShowsSnippetView
  {
    concertResult(vault.concertEntities(matching: ConcertSearch(cityID: city.id)))
  }
}

struct ShowConcertsOnDate: AppIntent {
  static let title = LocalizedStringResource("Show Concerts on Date")

  static let description = IntentDescription("Shows the concerts on a date.")

  static var parameterSummary: some ParameterSummary {
    Summary("Show concerts on \(\.$date)")
  }

  @Parameter(title: "Date", requestValueDialog: "Which date?")
  var date: Date

  @Dependency
  private var vault: Vault

  func perform() async throws -> some IntentResult & ReturnsValue<[ConcertEntity]> & ProvidesDialog
    & ShowsSnippetView
  {
    concertResult(vault.concertEntities(matching: ConcertSearch(date: date)))
  }
}

/// The concerts on this day of the year, in any year, as the Today tab shows.
struct ShowConcertsToday: AppIntent {
  static let title = LocalizedStringResource("Show Concerts Today")

  static let description = IntentDescription("Shows the concerts on this day of any year.")

  @Dependency
  private var vault: Vault

  func perform() async throws -> some IntentResult & ReturnsValue<[ConcertEntity]> & ProvidesDialog
    & ShowsSnippetView
  {
    let day = Date.now.dayOfLeapYear
    return concertResult(
      ((try? vault.concerts(on: day)) ?? []).compactMap { vault.concertEntity(for: $0.id) })
  }
}
