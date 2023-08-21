//
//  StatsGrouping.swift
//
//
//  Created by Greg Bolsinga on 5/13/23.
//

import SwiftUI

struct StatsGrouping: View {
  @Environment(\.vault) private var vault: Vault
  @Environment(\.statsThreshold) private var statsThreshold: Int

  let shows: [Show]
  let shouldCalculateArtistCount: Bool
  let yearsSpanRanking: Ranking?
  let computeShowsRank: (() -> Ranking)?
  let computeArtistVenuesRank: (() -> Ranking)?
  let computeVenueArtistsRank: (() -> Ranking)?
  let displayArchiveCategoryCounts: Bool  // Basically do not want this at the ArchiveCategory.stats.

  internal init(
    shows: [Show],
    shouldCalculateArtistCount: Bool = true,
    yearsSpanRanking: Ranking? = nil,
    computeShowsRank: (() -> Ranking)? = nil,
    computeArtistVenuesRank: (() -> Ranking)? = nil,
    computeVenueArtistsRank: (() -> Ranking)? = nil,
    displayArchiveCategoryCounts: Bool = true
  ) {
    self.shows = shows
    self.shouldCalculateArtistCount = shouldCalculateArtistCount
    self.yearsSpanRanking = yearsSpanRanking
    self.computeShowsRank = computeShowsRank
    self.computeArtistVenuesRank = computeArtistVenuesRank
    self.computeVenueArtistsRank = computeVenueArtistsRank
    self.displayArchiveCategoryCounts = displayArchiveCategoryCounts
  }

  private var computedStateCounts: [String: Int] {
    shows.compactMap {
      do { return try vault.lookup.venueForShow($0).location } catch { return nil }
    }.map { $0.state }.reduce(into: [String: Int]()) {
      let count = $0[$1] ?? 0
      $0[$1] = count + 1
    }
  }

  @ViewBuilder var yearsElement: some View {
    if let yearsSpanRanking {
      HStack {
        Text(
          "\(yearsSpanRanking.value) Year(s)", bundle: .module,
          comment: "Years Span for StatsGrouping.")
        Spacer()
        Text(yearsSpanRanking.formatted(.rankOnly))
      }
    }
  }

  private var computeVenues: [Venue] {
    Array(
      Set(shows.compactMap { do { return try vault.lookup.venueForShow($0) } catch { return nil } })
    )
  }

  private var computeArtists: [Artist] {
    Array(Set(shows.flatMap { vault.lookup.artistsForShow($0) }))
  }

  @ViewBuilder var showCount: some View {
    Text("\(shows.count) Show(s)", bundle: .module, comment: "Shows Count for StatsGrouping.")
  }

  @ViewBuilder var showsElement: some View {
    if let computeShowsRank {
      HStack {
        showCount
        Spacer()
        Text(computeShowsRank().formatted(.rankOnly))
      }
    } else {
      showCount
    }
  }

  @ViewBuilder func count(venues: [Venue]) -> some View {
    Text("\(venues.count) Venue(s)", bundle: .module, comment: "Venues Count for StatsGrouping.")
  }

  @ViewBuilder func element(for venues: [Venue]) -> some View {
    if let computeArtistVenuesRank {
      HStack {
        count(venues: venues)
        Spacer()
        Text(computeArtistVenuesRank().formatted(.rankOnly))
      }
    } else {
      count(venues: venues)
    }
  }

  @ViewBuilder func count(artists: [Artist]) -> some View {
    Text("\(artists.count) Artist(s)", bundle: .module, comment: "Artists Count for StatsGrouping.")
  }

  @ViewBuilder func element(for artists: [Artist]) -> some View {
    if let computeVenueArtistsRank {
      HStack {
        count(artists: artists)
        Spacer()
        Text(computeVenueArtistsRank().formatted(.rankOnly))
      }
    } else {
      count(artists: artists)
    }
  }

  private func configure() -> ([StatsCategory], [Venue], [Artist], [Date], [String: Int]) {
    let knownShowDates = shows.filter { $0.date.day != nil }
      .filter { $0.date.month != nil }
      .filter { $0.date.year != nil }
      .compactMap { $0.date.date }

    let venues = computeVenues
    let venuesCount = venues.count
    let showVenues = venuesCount > 1

    let artists = shouldCalculateArtistCount ? computeArtists : []
    let artistsCount = artists.count
    let showArtists = artistsCount > 1

    let stateCounts = computedStateCounts
    let showState = stateCounts.keys.count > 1

    let showWeekdayOrMonthChart = shows.count > statsThreshold

    // This needs to be broken down like this or the swift compiler says it is too complex.
    var statsCategoryCases = [StatsCategory]()
    if displayArchiveCategoryCounts {
      statsCategoryCases.append(.shows)
    }
    if displayArchiveCategoryCounts && (yearsSpanRanking?.value ?? 0) > 1 {
      statsCategoryCases.append(.years)
    }
    if displayArchiveCategoryCounts && showVenues {
      statsCategoryCases.append(.venues)
    }
    if displayArchiveCategoryCounts && showArtists {
      statsCategoryCases.append(.artists)
    }
    if showWeekdayOrMonthChart {
      statsCategoryCases.append(.weekday)
    }
    if showWeekdayOrMonthChart {
      statsCategoryCases.append(.month)
    }
    if showState {
      statsCategoryCases.append(.state)
    }

    return (statsCategoryCases, venues, artists, knownShowDates, stateCounts)
  }

  var body: some View {
    let (statsCategoryCases, venues, artists, knownShowDates, stateCounts) = configure()

    ForEach(statsCategoryCases, id: \.self) { category in
      Group {
        switch category {
        case .shows:
          showsElement
        case .years:
          yearsElement
        case .venues:
          element(for: venues)
        case .artists:
          element(for: artists)
        case .weekday:
          let name = String(localized: "Weekdays", bundle: .module, comment: "Weekdays Stats")
          NavigationLink(name) { WeekdayChart(dates: knownShowDates).navigationTitle(name) }
        case .month:
          let name = String(localized: "Months", bundle: .module, comment: "Months Stats")
          NavigationLink(name) { MonthChart(dates: knownShowDates).navigationTitle(name) }
        case .state:
          NavigationLink {
            StateChart(counts: stateCounts)
          } label: {
            LabeledContent {
              Text(stateCounts.keys.count.formatted())
            } label: {
              Text("States", bundle: .module, comment: "States Stats")
            }
          }
        }
      }
    }
  }
}
