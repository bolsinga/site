//
//  Program.swift
//  site
//
//  Created by Greg Bolsinga on 12/6/20.
//

import ArgumentParser
import Foundation

extension Vault where ID == String {
  fileprivate var digests: ([Concert], [ArtistDigest], [VenueDigest]) {
    (
      concertMap.values.sorted(by: comparator.compare(lhs:rhs:)),
      artistDigestMap.values.sorted(by: comparator.libraryCompare(lhs:rhs:)),
      venueDigestMap.values.sorted(by: comparator.libraryCompare(lhs:rhs:))
    )
  }

  fileprivate func concertsForArtistDigest(artistDigest: ArtistDigest) -> any Collection<Concert> {
    artistDigest.shows.compactMap {
      switch $0.id {
      case .show(let iD):
        return concertMap[iD]
      default:
        return nil
      }
    }
  }
}

extension Vault where ID == ArchivePath {
  fileprivate var digests: ([Concert], [ArtistDigest], [VenueDigest]) {
    (
      concertMap.values.sorted(by: comparator.compare(lhs:rhs:)),
      artistDigestMap.values.sorted(by: comparator.libraryCompare(lhs:rhs:)),
      venueDigestMap.values.sorted(by: comparator.libraryCompare(lhs:rhs:))
    )
  }

  fileprivate func concertsForArtistDigest(artistDigest: ArtistDigest) -> any Collection<Concert> {
    artistDigest.shows.compactMap { concertMap[$0.id] }
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

  private func dump(
    concerts: [Concert],
    artistDigests: [ArtistDigest],
    venueDigests: [VenueDigest],
    concertsForArtist: (ArtistDigest) -> any Collection<Concert>
  ) {
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
  }

  func run() async throws {
    switch identifier {
    case .string:
      let vault = try await rootURL.vault(identifier: BasicIdentifier())
      let (concerts, artistDigests, venueDigests) = vault.digests
      dump(concerts: concerts, artistDigests: artistDigests, venueDigests: venueDigests) {
        vault.concertsForArtistDigest(artistDigest: $0)
      }
    case .archivePath:
      let vault = try await rootURL.vault(identifier: ArchivePathIdentifier())
      let (concerts, artistDigests, venueDigests) = vault.digests
      dump(concerts: concerts, artistDigests: artistDigests, venueDigests: venueDigests) {
        vault.concertsForArtistDigest(artistDigest: $0)
      }
    }
  }
}
