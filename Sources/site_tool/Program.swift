//
//  Program.swift
//  site
//
//  Created by Greg Bolsinga on 12/6/20.
//

import ArgumentParser
import Foundation

@main
struct Program: AsyncParsableCommand {
  enum ProgramError: Error {
    case notURLString(String)
    case noVaultModel
  }

  @Argument(
    help:
      "The root URL for the json files.",
    transform: ({
      let url = URL(string: $0)
      guard let url else { throw ProgramError.notURLString($0) }
      return url
    })
  )
  var rootURL: URL

  @MainActor
  func run() async throws {
    let vault = try await Vault.load(rootURL.appending(path: "music.json").absoluteString)

    let concerts = vault.concertMap.values.sorted(by: vault.comparator.compare(lhs:rhs:))
    let artistDigests = vault.artistDigestMap.values.sorted(
      by: vault.comparator.libraryCompare(lhs:rhs:))
    let venueDigests = vault.venueDigestMap.values.sorted(
      by: vault.comparator.libraryCompare(lhs:rhs:))

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
      let concerts = digest.shows.compactMap {
        switch $0.id {
        case .show(let iD):
          return vault.concertMap[iD]
        default:
          return nil
        }
      }

      guard !concerts.isEmpty else { continue }

      var concertParts: [String] = []
      for concert in concerts {
        concertParts.append(concert.formatted(.full))
      }
      print("\(digest.artist.name): (\(concertParts.joined(separator: "; "))")
    }
  }
}
