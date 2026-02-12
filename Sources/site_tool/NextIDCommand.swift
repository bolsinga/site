//
//  NextIDCommand.swift
//
//  Created by Greg Bolsinga on 8/3/23.
//

import ArgumentParser
import Foundation

extension String {
  fileprivate func convert(prefix: String) -> Int? {
    guard starts(with: prefix) else { return nil }
    return Int(replacingOccurrences(of: prefix, with: ""))
  }

  fileprivate var identifierIndex: Int? {
    for prefix in [ArchivePath.artistPrefix, ArchivePath.venuePrefix, ArchivePath.showPrefix] {
      if let index = convert(prefix: prefix) {
        return index
      }
    }
    return nil
  }
}

extension Collection where Element == String {
  var missingIndices: any Collection<Int> {
    let existingIndices = self.compactMap { $0.identifierIndex }
    let expectedIndices = Set(0...(existingIndices.count - 1))
    return expectedIndices.subtracting(existingIndices)
  }
}

extension Vault {
  fileprivate var nextShowID: Show.ID {
    let nextIndex = max(concertMap.count, 0)
    return "\(ArchivePath.showPrefix)\(nextIndex)"
  }

  fileprivate var nextVenueID: Venue.ID {
    let nextIndex = max(venueDigestMap.count, 0)
    return "\(ArchivePath.venuePrefix)\(nextIndex)"
  }

  fileprivate var nextArtistID: Venue.ID {
    let nextIndex = max(artistDigestMap.count, 0)
    return "\(ArchivePath.artistPrefix)\(nextIndex)"
  }

  fileprivate var missingShowIndices: any Collection<Int> {
    concertMap.values.map { $0.id }.missingIndices
  }

  fileprivate var missingVenueIndices: any Collection<Int> {
    venueDigestMap.values.map { $0.id }.missingIndices
  }

  fileprivate var missingArtistIndices: any Collection<Int> {
    artistDigestMap.values.map { $0.id }.missingIndices
  }
}

struct NextIDCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "nextID",
    abstract: "Prints the next ID for all the music entires."
  )

  @OptionGroup var rootURL: RootURLArguments

  func run() async throws {
    let vault = try await rootURL.vault(identifier: BasicIdentifier(), fileName: "music.json")

    print("Next Show: \(vault.nextShowID)")
    print("Next Venue: \(vault.nextVenueID)")
    print("Next Artist: \(vault.nextArtistID)")

    print("Missing Show IDs: \(vault.missingShowIndices)")
    print("Missing Venue IDs: \(vault.missingVenueIndices)")
    print("Missing Artist IDs: \(vault.missingArtistIndices)")
  }
}
