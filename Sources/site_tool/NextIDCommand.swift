//
//  NextIDCommand.swift
//
//  Created by Greg Bolsinga on 8/3/23.
//

import ArgumentParser
import Foundation

extension String {
  fileprivate func convertToIndex(prefix: String) -> Int? {
    guard starts(with: prefix) else { return nil }
    return Int(replacingOccurrences(of: prefix, with: ""))
  }

  fileprivate func identifierIndex(prefix: String) -> Int? {
    guard let index = convertToIndex(prefix: prefix) else { return nil }
    return index
  }
}

extension Collection where Element == String {
  fileprivate func missingIndices(prefix: String) -> any Collection<Int> {
    let existingIndices = self.compactMap { $0.identifierIndex(prefix: prefix) }
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
    concertMap.values.map { $0.id }.missingIndices(prefix: ArchivePath.showPrefix)
  }

  fileprivate var missingVenueIndices: any Collection<Int> {
    venueDigestMap.values.map { $0.id }.missingIndices(prefix: ArchivePath.venuePrefix)
  }

  fileprivate var missingArtistIndices: any Collection<Int> {
    artistDigestMap.values.map { $0.id }.missingIndices(prefix: ArchivePath.artistPrefix)
  }

  fileprivate func printIDs() {
    print("Next Show: \(nextShowID)")
    print("Next Venue: \(nextVenueID)")
    print("Next Artist: \(nextArtistID)")

    print("Missing Show IDs: \(missingShowIndices)")
    print("Missing Venue IDs: \(missingVenueIndices)")
    print("Missing Artist IDs: \(missingArtistIndices)")
  }
}

struct NextIDCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "nextID",
    abstract: "Prints the next ID for all the music entires."
  )

  @OptionGroup var rootURL: RootURLArguments

  @Flag(help: "Choose the Identifier for the Vault.")
  var identifier: IdentifierFlag = .archivePath

  func run() async throws {
    switch identifier {
    case .basic:
      try await rootURL.vault(identifier: BasicIdentifier(), fileName: "music.json").printIDs()
    case .archivePath:
      try await rootURL.vault(identifier: ArchivePathIdentifier(), fileName: "music.json")
        .printIDs()
    }
  }
}
