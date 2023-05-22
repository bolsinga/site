//
//  StatsGrouping.swift
//
//
//  Created by Greg Bolsinga on 5/13/23.
//

import SwiftUI

struct StatsGrouping: View {
  enum Kind {
    case all
    case artist
    case venue
  }

  @Environment(\.vault) private var vault: Vault
  @Environment(\.statsThreshold) private var statsThreshold: Int

  let shows: [Show]
  let kind: Kind

  internal init(shows: [Show], kind: Kind) {
    self.shows = shows
    self.kind = kind
  }

  private var computedStateCounts: [String: Int] {
    shows.compactMap {
      do { return try vault.lookup.venueForShow($0).location } catch { return nil }
    }.map { $0.state }.reduce(into: [String: Int]()) {
      let count = $0[$1] ?? 0
      $0[$1] = count + 1
    }
  }

  private func computedYearsOfShows() -> [PartialDate] {
    return Array(
      Set(shows.map { $0.date.year != nil ? PartialDate(year: $0.date.year!) : PartialDate() })
    ).sorted(by: <)
  }

  private func computedVenuesOfShows() -> [Venue] {
    Array(
      Set(shows.compactMap { do { return try vault.lookup.venueForShow($0) } catch { return nil } })
    )
  }

  private func computeArtists(for venues: [Venue]) -> [Artist] {
    switch kind {
    case .artist:
      return []
    case .all, .venue:
      return Array(Set(venues.flatMap { vault.lookup.artistsForVenue($0) }))
    }
  }

  var body: some View {
    let knownShowDates = shows.filter { $0.date.day != nil }
      .filter { $0.date.month != nil }
      .filter { $0.date.year != nil }
      .compactMap { $0.date.date }

    let yearSpan = computedYearsOfShows().yearSpan()

    let venues = computedVenuesOfShows()
    let showVenues = venues.count > 1

    let artists = computeArtists(for: venues)
    let showArtists = artists.count > 1

    let stateCounts = computedStateCounts
    let showState = stateCounts.keys.count > 1

    let showWeekdayOrMonthChart = shows.count > statsThreshold

    let statsCategoryCases = StatsCategory.allCases
      .filter { $0 == .years ? yearSpan > 1 : true }
      .filter { $0 == .venues ? showVenues : true }
      .filter { $0 == .artists ? showArtists : true }
      .filter { $0 == .weekday ? showWeekdayOrMonthChart : true }
      .filter { $0 == .month ? showWeekdayOrMonthChart : true }
      .filter { $0 == .state ? showState : true }

    ForEach(statsCategoryCases, id: \.self) { category in
      Group {
        switch category {
        case .shows:
          Text("\(shows.count) Show(s)", bundle: .module, comment: "Shows Count for StatsGrouping.")
        case .years:
          Text("\(yearSpan) Year(s)", bundle: .module, comment: "Years Span for StatsGrouping.")
        case .venues:
          Text(
            "\(venues.count) Venue(s)", bundle: .module, comment: "Venues Count for StatsGrouping.")
        case .artists:
          Text(
            "\(artists.count) Artist(s)", bundle: .module,
            comment: "Artists Count for StatsGrouping.")
        case .weekday:
          let name = String(localized: "Weekdays", bundle: .module, comment: "Weekdays Stats")
          NavigationLink(name) { WeekdayChart(dates: knownShowDates).navigationTitle(name) }
        case .month:
          let name = String(localized: "Months", bundle: .module, comment: "Months Stats")
          NavigationLink(name) { MonthChart(dates: knownShowDates).navigationTitle(name) }
        case .state:
          let name = String(localized: "States", bundle: .module, comment: "States Stats")
          NavigationLink(name) { StateChart(counts: stateCounts).navigationTitle(name) }
        }
      }
    }
    .navigationTitle(Text(ArchiveCategory.stats.localizedString))
  }
}
