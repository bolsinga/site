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

  internal init(
    shows: [Show],
    shouldCalculateArtistCount: Bool = true,
    yearsSpanRanking: Ranking? = nil,
    computeShowsRank: (() -> Ranking)? = nil
  ) {
    self.shows = shows
    self.shouldCalculateArtistCount = shouldCalculateArtistCount
    self.yearsSpanRanking = yearsSpanRanking
    self.computeShowsRank = computeShowsRank
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
          "\(yearsSpanRanking.count) Year(s)", bundle: .module,
          comment: "Years Span for StatsGrouping.")
        Spacer()
        Text(yearsSpanRanking.formatted(.rankOnly))
      }
    }
  }

  private var computeVenuesCount: Int {
    Set(shows.compactMap { do { return try vault.lookup.venueForShow($0) } catch { return nil } })
      .count
  }

  private var computeArtistCount: Int {
    Set(
      shows.flatMap {
        do { return try vault.lookup.artistsForShow($0) } catch { return [Artist]() }
      }
    ).count
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

  var body: some View {
    let knownShowDates = shows.filter { $0.date.day != nil }
      .filter { $0.date.month != nil }
      .filter { $0.date.year != nil }
      .compactMap { $0.date.date }

    let venuesCount = computeVenuesCount
    let showVenues = venuesCount > 1

    let artistsCount = shouldCalculateArtistCount ? computeArtistCount : 0
    let showArtists = artistsCount > 1

    let stateCounts = computedStateCounts
    let showState = stateCounts.keys.count > 1

    let showWeekdayOrMonthChart = shows.count > statsThreshold

    let statsCategoryCases = StatsCategory.allCases
      .filter { $0 == .years ? (yearsSpanRanking?.count ?? 0) > 1 : true }
      .filter { $0 == .venues ? showVenues : true }
      .filter { $0 == .artists ? showArtists : true }
      .filter { $0 == .weekday ? showWeekdayOrMonthChart : true }
      .filter { $0 == .month ? showWeekdayOrMonthChart : true }
      .filter { $0 == .state ? showState : true }

    ForEach(statsCategoryCases, id: \.self) { category in
      Group {
        switch category {
        case .shows:
          showsElement
        case .years:
          yearsElement
        case .venues:
          Text(
            "\(venuesCount) Venue(s)", bundle: .module, comment: "Venues Count for StatsGrouping.")
        case .artists:
          Text(
            "\(artistsCount) Artist(s)", bundle: .module,
            comment: "Artists Count for StatsGrouping.")
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
