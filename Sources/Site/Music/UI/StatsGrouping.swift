//
//  StatsGrouping.swift
//
//
//  Created by Greg Bolsinga on 5/13/23.
//

import SwiftUI

struct StatsGrouping: View {
  @Environment(\.statsThreshold) private var statsThreshold: Int

  let concerts: [Concert]
  let shouldCalculateArtistCount: Bool
  let yearsSpanRanking: Ranking?
  let computeShowsRank: (() -> Ranking)?
  let computeArtistVenuesRank: (() -> Ranking)?
  let computeVenueArtistsRank: (() -> Ranking)?
  let displayArchiveCategoryCounts: Bool  // Basically do not want this at the ArchiveCategory.stats.

  internal init(
    concerts: [Concert],
    shouldCalculateArtistCount: Bool = true,
    yearsSpanRanking: Ranking? = nil,
    computeShowsRank: (() -> Ranking)? = nil,
    computeArtistVenuesRank: (() -> Ranking)? = nil,
    computeVenueArtistsRank: (() -> Ranking)? = nil,
    displayArchiveCategoryCounts: Bool = true
  ) {
    self.concerts = concerts
    self.shouldCalculateArtistCount = shouldCalculateArtistCount
    self.yearsSpanRanking = yearsSpanRanking
    self.computeShowsRank = computeShowsRank
    self.computeArtistVenuesRank = computeArtistVenuesRank
    self.computeVenueArtistsRank = computeVenueArtistsRank
    self.displayArchiveCategoryCounts = displayArchiveCategoryCounts
  }

  private var computedStateCounts: [String: Int] {
    concerts.compactMap { $0.venue?.location }.map { $0.state }.reduce(
      into: [String: Int]()
    ) {
      let count = $0[$1] ?? 0
      $0[$1] = count + 1
    }
  }

  @ViewBuilder var yearsElement: some View {
    if let yearsSpanRanking {
      HStack {
        Text("\(yearsSpanRanking.value) Year(s)")
        Spacer()
        Text(yearsSpanRanking.formatted(.rankOnly))
      }
    }
  }

  private var computeVenues: [Venue] {
    Array(Set(concerts.compactMap { $0.venue }))
  }

  private var computeArtists: [Artist] {
    Array(Set(concerts.flatMap { $0.artists }))
  }

  @ViewBuilder var showCount: some View {
    Text("\(concerts.count) Show(s)")
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
    Text("\(venues.count) Venue(s)")
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
    Text("\(artists.count) Artist(s)")
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
    let knownShowDates = concerts.map { $0.show.date }.filter { $0.day != nil }
      .filter { $0.month != nil }
      .filter { $0.year != nil }
      .compactMap { $0.date }

    let venues = computeVenues
    let venuesCount = venues.count
    let showVenues = venuesCount > 1

    let artists = shouldCalculateArtistCount ? computeArtists : []
    let artistsCount = artists.count
    let showArtists = artistsCount > 1

    let stateCounts = computedStateCounts
    let showState = stateCounts.keys.count > 1

    let showWeekdayOrMonthChart = concerts.count > statsThreshold

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
          let name = String(localized: "Weekdays")
          NavigationLink(name) { WeekdayChart(dates: knownShowDates).navigationTitle(name) }
        case .month:
          let name = String(localized: "Months")
          NavigationLink(name) { MonthChart(dates: knownShowDates).navigationTitle(name) }
        case .state:
          NavigationLink {
            StateChart(counts: stateCounts)
          } label: {
            LabeledContent {
              Text(stateCounts.keys.count.formatted())
            } label: {
              Text("States")
            }
          }
        }
      }
    }
  }
}
