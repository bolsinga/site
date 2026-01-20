//
//  DumpBracketCommand.swift
//  site_tool
//
//  Created by Greg Bolsinga on 1/11/26.
//

import ArgumentParser
import Foundation

private struct OrderedBracket: Encodable {
  let bracket: Bracket

  private enum Keys: String, CodingKey {
    case librarySortTokenMap
    case artistRankingMap
    case venueRankingMap
    case artistShowSpanRankingMap
    case venueShowSpanRankingMap
    case artistVenueRankingMap
    case venueArtistRankingMap
    case annumShowRankingMap
    case annumVenueRankingMap
    case annumArtistRankingMap
    case decadesMap
    case artistFirstSetsMap
    case venueFirstSetsMap
  }

  func encode(to encoder: any Encoder) throws {
    // Specialized encoder so that the annum and dictionary keys are formatted.
    //  It seems that .sortedKeys is "lexicographic" sorting, and Annum and Decade
    //  (despite implementing `<`) do not do that. The other keys are the same.
    var container = encoder.container(keyedBy: Keys.self)
    try container.encode(bracket.librarySortTokenMap, forKey: .librarySortTokenMap)
    try container.encode(bracket.artistRankingMap, forKey: .artistRankingMap)
    try container.encode(bracket.venueRankingMap, forKey: .venueRankingMap)
    try container.encode(bracket.artistShowSpanRankingMap, forKey: .artistShowSpanRankingMap)
    try container.encode(bracket.venueShowSpanRankingMap, forKey: .venueShowSpanRankingMap)
    try container.encode(bracket.artistVenueRankingMap, forKey: .artistVenueRankingMap)
    try container.encode(bracket.venueArtistRankingMap, forKey: .venueArtistRankingMap)
    try container.encode(
      bracket.annumShowRankingMap.reduce(
        into: [String: Ranking](), { $0[$1.key.formatted(.json)] = $1.value }),
      forKey: .annumShowRankingMap)
    try container.encode(
      bracket.annumVenueRankingMap.reduce(
        into: [String: Ranking](), { $0[$1.key.formatted(.json)] = $1.value }),
      forKey: .annumVenueRankingMap)
    try container.encode(
      bracket.annumArtistRankingMap.reduce(
        into: [String: Ranking](), { $0[$1.key.formatted(.json)] = $1.value }),
      forKey: .annumArtistRankingMap)
    try container.encode(
      bracket.decadesMap.reduce(
        into: [String: [String: [Show.ID]]](),
        {
          $0[$1.key.formatted(.defaultDigits)] = $1.value.reduce(
            into: [String: [Show.ID]](),
            {
              $0[$1.key.formatted(.json)] = $1.value
            })
        }),
      forKey: .decadesMap)
    try container.encode(bracket.artistFirstSetsMap, forKey: .artistFirstSetsMap)
    try container.encode(bracket.venueFirstSetsMap, forKey: .venueFirstSetsMap)
  }
}

struct DumpBracketCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "dumpBracket",
    abstract: "Dump a json representation of Music Bracket."
  )

  @OptionGroup var rootURL: RootURLArguments

  func run() async throws {
    let bracket = OrderedBracket(bracket: try await rootURL.bracket())

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    encoder.dateEncodingStrategy = .iso8601

    let data = try encoder.encode(bracket.self)
    guard let value = String(data: data, encoding: .utf8) else {
      print("cannot encode bracket")
      return
    }
    print(value)
  }
}
