//
//  Program.swift
//  site
//
//  Created by Greg Bolsinga on 12/6/20.
//

import ArgumentParser
import Foundation

extension Vault {
  fileprivate func concertsForArtist(artistID: ID) -> any Collection<Concert> {
    self.shows(artistID: artistID).compactMap { concertMap[$0] }
  }

  fileprivate func dump(
    searchString: String?, concertsForArtist: (Artist) -> any Collection<Concert>
  ) {
    let concerts = concertMap.values.sorted(by: compare(lhs:rhs:))
    let artists = artists().sorted(by: compare(lhs:rhs:))
    let venues = venues().sorted(by: compare(lhs:rhs:))

    print("Artists: \(artists.count)")
    print("Shows: \(concerts.count)")
    print("Venues: \(venues.count)")

    for concert in concerts.reversed() {
      print(concert.formatted(.full))
    }

    for venue in venues {
      print(venue.formatted(.oneLine))
    }

    for artist in artists {
      let concerts = concertsForArtist(artist)

      guard !concerts.isEmpty else { continue }

      var concertParts: [String] = []
      for concert in concerts {
        concertParts.append(concert.formatted(.full))
      }
      print("\(artist.name): (\(concertParts.joined(separator: "; ")))")
    }

    if let searchString {
      let venues = self.venues(filteredBy: searchString).map { $0.name }
      let artists = self.artists(filteredBy: searchString).map { $0.name }
      let matches = venues + artists
      print("Matching (\(searchString)): \(matches.joined(separator: "; "))")
    }
  }
}

struct DumpVaultCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "dumpVault",
    abstract: "Dump a text output of the Vault."
  )

  @OptionGroup var rootURL: RootURLArguments

  @Flag(help: "Choose the Identifier for the Vault.")
  var identifier: IdentifierFlag = .archivePath

  @Option(help: "Search String to use.")
  var searchString: String?

  func run() async throws {
    switch identifier {
    case .basic:
      let vault = try await rootURL.vault(identifier: BasicIdentifier())
      vault.dump(searchString: searchString) {
        vault.concertsForArtist(artistID: $0.id)
      }
    case .archivePath:
      let vault = try await rootURL.vault(identifier: ArchivePathIdentifier())
      vault.dump(searchString: searchString) {
        vault.concertsForArtist(artistID: $0.archivePath)
      }
    }
  }
}
