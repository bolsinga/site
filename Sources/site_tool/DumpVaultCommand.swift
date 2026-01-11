//
//  Program.swift
//  site
//
//  Created by Greg Bolsinga on 12/6/20.
//

import ArgumentParser
import Foundation

extension Vault {
  fileprivate func dump() {
    let concerts = concertMap.values.sorted(by: comparator.compare(lhs:rhs:))
    let artistDigests = artistDigestMap.values.sorted(by: comparator.libraryCompare(lhs:rhs:))
    let venueDigests = venueDigestMap.values.sorted(by: comparator.libraryCompare(lhs:rhs:))

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
          return concertMap[iD]
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

struct DumpVaultCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "dumpVault",
    abstract: "Dump a text output of the Vault."
  )

  @OptionGroup var rootURL: RootURLArguments

  func run() async throws {
    let vault = try await rootURL.vault()
    vault.dump()
  }
}
