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
  case year(Int)
}

protocol Archivable {
  associatedtype ArchivableDestinationView: View

  var archiveKind: Kind { get }
  @ViewBuilder var archiveDestinationView: ArchivableDestinationView { get }
}

extension Show: Archivable {
  var archiveKind: Kind { .show(id) }

  @ViewBuilder var archiveDestinationView: some View {
    ShowDetail(show: self)
  }
}

extension Venue: Archivable {
  var archiveKind: Kind { .venue(id) }

  @ViewBuilder var archiveDestinationView: some View {
    VenueDetail(venue: self)
  }
}

extension Artist: Archivable {
  var archiveKind: Kind { .artist(id) }

  @ViewBuilder var archiveDestinationView: some View {
    ArtistDetail(artist: self)
  }
}

struct ArchiveView<T: Archivable>: View {
  let archivable: T

  var body: some View {
    archivable.archiveDestinationView
  }
}

struct ArchiveDestinationModifier: ViewModifier {
  @Environment(\.vault) var vault: Vault

  // Is there a way to extend Kind to make a ArchiveView?
  // The @Environment Vault needs to be on a SwiftUI type to work properly....
  func body(content: Content) -> some View {
    content
      .navigationDestination(for: Kind.self) { kind in
        switch kind {
        case .show(let iD):
          if let archivable = vault.lookup.showMap[iD] {
            ArchiveView(archivable: archivable)
          }
        case .venue(let iD):
          if let archivable = vault.lookup.venueMap[iD] {
            ArchiveView(archivable: archivable)
          }
        case .artist(let iD):
          if let archivable = vault.lookup.artistMap[iD] {
            ArchiveView(archivable: archivable)
          }
          
        case .year(let year):
          Text("year: \(year.formatted(.number))")
        }
      }
  }
}

extension View {
  func archiveDestinations() -> some View {
    modifier(ArchiveDestinationModifier())
  }
}
