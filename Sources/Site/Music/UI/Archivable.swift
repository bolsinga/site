//
//  Archivable.swift
//
//
//  Created by Greg Bolsinga on 5/25/23.
//

import SwiftUI

enum Kind: Hashable {
  case show(Show.ID)
  case venue(Venue.ID)
  case artist(Artist.ID)
  case year(Annum)
}

protocol Archivable {
  associatedtype ArchivableDestinationView: View

  var kind: Kind { get }
  @ViewBuilder var archiveDestinationView: ArchivableDestinationView { get }
}

extension Show: Archivable {
  var kind: Kind { .show(id) }

  @ViewBuilder var archiveDestinationView: some View {
    ShowDetail(show: self)
  }
}

extension Venue: Archivable {
  var kind: Kind { .venue(id) }

  @ViewBuilder var archiveDestinationView: some View {
    VenueDetail(venue: self)
  }
}

extension Artist: Archivable {
  var kind: Kind { .artist(id) }

  @ViewBuilder var archiveDestinationView: some View {
    ArtistDetail(artist: self)
  }
}

extension Annum: Archivable {
  var kind: Kind { .year(self) }

  @ViewBuilder var archiveDestinationView: some View {
    YearDetail(annum: self)
  }
}
