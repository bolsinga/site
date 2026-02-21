//
//  Program.swift
//  site
//
//  Created by Greg Bolsinga on 12/6/20.
//

import ArgumentParser
import Foundation

extension Vault {
  fileprivate func concertsForArtistDigest(artistDigest: ArtistDigest) -> any Collection<Concert>
  where ID == String {
    artistDigest.shows.compactMap {
      switch $0.id {
      case .show(let iD):
        return concertMap[iD]
      default:
        return nil
      }
    }
  }

  fileprivate func concertsForArtistDigest(artistDigest: ArtistDigest) -> any Collection<Concert>
  where ID == ArchivePath {
    artistDigest.shows.compactMap { concertMap[$0.id] }
  }

  fileprivate func dump(
    searchString: String?, concertsForArtist: (ArtistDigest) -> any Collection<Concert>
  ) {
    let concerts = concertMap.values.sorted(by: compare(lhs:rhs:))
    let artistDigests = artistDigestMap.values.sorted(by: compare(lhs:rhs:))
    let venueDigests = venueDigestMap.values.sorted(by: compare(lhs:rhs:))

    print("Artists: \(artistDigests.count)")
    print("Shows: \(concerts.count)")
    print("Venues: \(venueDigests.count)")

    for concert in concerts.reversed() {
      print(concert.formatted(.full))
    }

    for digest in venueDigests {
      print(digest.venue.formatted(.oneLine))
    }

    for digest in artistDigests {
      let concerts = concertsForArtist(digest)

      guard !concerts.isEmpty else { continue }

      var concertParts: [String] = []
      for concert in concerts {
        concertParts.append(concert.formatted(.full))
      }
      print("\(digest.artist.name): (\(concertParts.joined(separator: "; "))")
    }

    if let searchString {
      let venues = venues(filteredBy: searchString).map { $0.name }
      let artists = artists(filteredBy: searchString).map { $0.name }
      let matches = venues + artists
      print("Matching (\(searchString)): \(matches.joined(separator: "; "))")
    }
  }
}

enum IdentifierFlag: String, EnumerableFlag {
  case string
  case archivePath
}

struct DumpVaultCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "dumpVault",
    abstract: "Dump a text output of the Vault."
  )

  @OptionGroup var rootURL: RootURLArguments

  @Flag(help: "Choose the Identifier for Vault.")
  var identifier: IdentifierFlag = .archivePath

  @Option(help: "Search String to use.")
  var searchString: String?

  func run() async throws {
    switch identifier {
    case .string:
      let vault = try await rootURL.vault(identifier: BasicIdentifier())
      vault.dump(searchString: searchString) {
        vault.concertsForArtistDigest(artistDigest: $0)
      }
    case .archivePath:
      let vault = try await rootURL.vault(identifier: ArchivePathIdentifier())
      vault.dump(searchString: searchString) {
        vault.concertsForArtistDigest(artistDigest: $0)
      }
    }
  }
}
