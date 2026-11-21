//
//  NextIDCommand.swift
//
//  Created by Greg Bolsinga on 8/3/23.
//

import ArgumentParser
import Foundation
import Shared

extension Collection where Element == String {
  /// The numbers below the count of the ids that no id has.
  var archiveIndices: Set<Int> {
    let existingIndices = self.compactMap {
      Int($0.trimmingCharacters(in: .decimalDigits.inverted))
    }
    return Set(0..<existingIndices.count).subtracting(existingIndices)
  }

  /// The smallest gap in the ids, or the count of them when there is none.
  var nextArchiveIndex: Int {
    archiveIndices.min() ?? count
  }
}

extension Bracket {
  fileprivate func nextIndex(_ items: any Collection<ArchivePath>) -> Int {
    items.map { String(describing: $0) }.nextArchiveIndex
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

  func run() async throws {
    try await rootURL.bracket(artistsWithShowsOnly: false)
      .printNextIDs()
  }
}
