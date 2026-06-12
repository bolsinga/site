//
//  NextIDCommand.swift
//
//  Created by Greg Bolsinga on 8/3/23.
//

import ArgumentParser
import Foundation

extension Collection where Element == String {
  fileprivate var archiveIndices: Set<Int> {
    let existingIndices = self.compactMap {
      Int($0.trimmingCharacters(in: .decimalDigits.inverted))
    }
    let expectedIndices = Set(0...(existingIndices.count - 1))
    return expectedIndices.subtracting(existingIndices)
  }
}

extension Bracket {
  fileprivate func nextIndex(_ items: any Collection<ID>) -> Int {
    guard let first = items.map({ String(describing: $0) }).archiveIndices.sorted().first else {
      return items.count + 1
    }
    return first
  }

  fileprivate var nextShowIndex: Int {
    nextIndex(showMap.keys)
  }

  fileprivate var nextVenueIndex: Int {
    nextIndex(venueMap.keys)
  }

  fileprivate var nextArtistIndex: Int {
    nextIndex(artistMap.keys)
  }

  fileprivate func printNextIDs() {
    print("Next Show: \(nextShowIndex)")
    print("Next Venue: \(nextVenueIndex)")
    print("Next Artist: \(nextArtistIndex)")
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
      try await rootURL.bracket(identifier: BasicIdentifier(), artistsWithShowsOnly: false)
        .printNextIDs()
    case .archivePath:
      try await rootURL.bracket(identifier: ArchivePathIdentifier(), artistsWithShowsOnly: false)
        .printNextIDs()
    }
  }
}
