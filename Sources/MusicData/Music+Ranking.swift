//
//  Music+Ranking.swift
//
//
//  Created by Greg Bolsinga on 5/23/23.
//

import Foundation

extension Collection where Element == Show {
  fileprivate func dates(withArtist id: Artist.ID) -> Set<PartialDate> {
    reduce(into: Set<PartialDate>()) {
      guard $1.artists.contains(id) else { return }
      $0.insert($1.date)
    }
  }

  fileprivate func dates(withVenue id: Venue.ID) -> Set<PartialDate> {
    reduce(into: Set<PartialDate>()) {
      guard $1.venue == id else { return }
      $0.insert($1.date)
    }
  }

  fileprivate func venues(withArtist id: Artist.ID) -> [Venue.ID] {
    self.compactMap {
      guard $0.artists.contains(id) else { return nil }
      return $0.venue
    }
  }

  fileprivate func artists(withVenue id: Venue.ID) -> [Artist.ID] {
    self.flatMap {
      guard $0.venue == id else { return [Artist.ID]() }
      return $0.artists
    }
  }

  fileprivate func artists(annum: Annum) -> [Artist.ID] {
    self.flatMap {
      guard $0.date.annum == annum else { return [Artist.ID]() }
      return $0.artists
    }
  }

  fileprivate func venues(annum: Annum) -> [Venue.ID] {
    self.compactMap {
      guard $0.date.annum == annum else { return nil }
      return $0.venue
    }
  }
}

extension Music {
  var artistRankings: [Artist.ID: Ranking] {
    let artistShowCounts: [(Artist.ID, Int)] = self.artists.reduce(into: [:]) { d, item in
      d[item.id] = self.shows.count(where: { $0.artists.contains(item.id) })
    }.map { $0 }

    return computeRankings(items: artistShowCounts)
  }

  var venueRankings: [Venue.ID: Ranking] {
    let venuesShowCount: [(Venue.ID, Int)] = self.venues.reduce(into: [:]) { d, item in
      d[item.id] = self.shows.count(where: { $0.venue == item.id })
    }.map { $0 }

    return computeRankings(items: venuesShowCount)
  }

  var artistSpanRankings: [Artist.ID: Ranking] {
    let artistShowSpans: [(Artist.ID, Int)] = self.artists.reduce(into: [:]) { d, item in
      d[item.id] = self.shows.dates(withArtist: item.id).yearSpan
    }.map { $0 }

    return computeRankings(items: artistShowSpans)
  }

  var venueSpanRankings: [Venue.ID: Ranking] {
    let venueShowSpans: [(Venue.ID, Int)] = self.venues.reduce(into: [:]) { d, item in
      d[item.id] = self.shows.dates(withVenue: item.id).yearSpan
    }.map { $0 }

    return computeRankings(items: venueShowSpans)
  }

  var artistVenueRankings: [Artist.ID: Ranking] {
    let artistVenueCounts: [(Artist.ID, Int)] = self.artists.reduce(into: [:]) { d, item in
      d[item.id] = Set(self.shows.venues(withArtist: item.id)).count
    }.map { $0 }

    return computeRankings(items: artistVenueCounts)
  }

  var venueArtistRankings: [Venue.ID: Ranking] {
    let venueArtistCounts: [(Venue.ID, Int)] = self.venues.reduce(into: [:]) { d, item in
      d[item.id] = Set(self.shows.artists(withVenue: item.id)).count
    }.map { $0 }

    return computeRankings(items: venueArtistCounts)
  }

  private var annums: [Annum] {
    Array(shows.map { $0.date.annum }.uniqued())
  }

  var annumShowRankings: [Annum: Ranking] {
    let annumShowCounts: [(Annum, Int)] = annums.map { annum in
      (annum, shows.count(where: { $0.date.annum == annum }))
    }
    return computeRankings(items: annumShowCounts)
  }

  var annumVenueRankings: [Annum: Ranking] {
    let annumVenueCounts: [(Annum, Int)] = annums.map { annum in
      (annum, Array(shows.venues(annum: annum).uniqued()).count)
    }
    return computeRankings(items: annumVenueCounts)
  }

  var annumArtistRankings: [Annum: Ranking] {
    let annumArtistCounts: [(Annum, Int)] = annums.map { annum in
      (annum, Array(shows.artists(annum: annum).uniqued()).count)
    }
    return computeRankings(items: annumArtistCounts)
  }

  var decadesMap: [Decade: [Annum: Set<Show.ID>]] {
    shows.reduce(into: [:]) {
      let decade = $1.date.decade
      var decadeDict = $0[decade] ?? [:]

      let annum = $1.date.annum
      var s = decadeDict[annum] ?? Set<Show.ID>()
      s.insert($1.id)
      decadeDict[annum] = s

      $0[decade] = decadeDict
    }
  }

  var artistFirstSets: [Artist.ID: FirstSet] {
    var artistsTracked = Set<Artist.ID>()
    var allUnknownDateArtists = Set<Artist.ID>()
    var firstSetsOrdered = [(Artist.ID, FirstSet)]()

    var order = 1
    shows.sorted(by: { PartialDate.compareWithUnknownsMuted(lhs: $0.date, rhs: $1.date) }).forEach {
      show in
      if show.date.isUnknown {
        show.artists.forEach { allUnknownDateArtists.insert($0) }
      } else {
        show.artists.filter { !artistsTracked.contains($0) }.reversed().forEach { artistID in
          firstSetsOrdered.append((artistID, FirstSet(rank: .rank(order), date: show.date)))
          order += 1

          artistsTracked.insert(artistID)
        }
      }
    }

    let onlyUnknownDateArtists = allUnknownDateArtists.subtracting(artistsTracked)
    onlyUnknownDateArtists.forEach { artistID in
      firstSetsOrdered.append((artistID, FirstSet.empty))
    }

    return firstSetsOrdered.reduce(into: [:]) { $0[$1.0] = $1.1 }
  }

  var venueFirstSets: [Venue.ID: FirstSet] {
    var venuesTracked = Set<Venue.ID>()
    var allUnknownDateVenues = Set<Venue.ID>()
    var firstSetsOrdered = [(Venue.ID, FirstSet)]()

    var order = 1
    shows.sorted(by: { PartialDate.compareWithUnknownsMuted(lhs: $0.date, rhs: $1.date) }).forEach {
      show in
      if show.date.isUnknown {
        allUnknownDateVenues.insert(show.venue)
      } else if !venuesTracked.contains(show.venue) {
        firstSetsOrdered.append((show.venue, FirstSet(rank: .rank(order), date: show.date)))
        venuesTracked.insert(show.venue)
        order += 1
      }
    }

    let onlyUnknownDateVenues = allUnknownDateVenues.subtracting(venuesTracked)
    onlyUnknownDateVenues.forEach { venueID in
      firstSetsOrdered.append((venueID, FirstSet.empty))
    }

    return firstSetsOrdered.reduce(into: [:]) { $0[$1.0] = $1.1 }
  }

  var relationMap: [String: [String]] {
    relations.reduce(into: [String: [String]]()) { d, relation in
      d = relation.members.reduce(into: d) { d, id in
        var arr = (d[id] ?? [])
        arr = Array(Set(arr).union(relation.members.filter { $0 != id }))
        d[id] = arr
      }
    }
  }
}
