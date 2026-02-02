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
    case artistRankDigestMap
    case venueRankDigestMap
    case annumRankDigestMap
    case decadesMap
  }

  func encode(to encoder: any Encoder) throws {
    // Specialized encoder so that the annum and dictionary keys are formatted.
    //  It seems that .sortedKeys is "lexicographic" sorting, and Annum and Decade
    //  (despite implementing `<`) do not do that. The other keys are the same.
    var container = encoder.container(keyedBy: Keys.self)
    try container.encode(bracket.librarySortTokenMap, forKey: .librarySortTokenMap)

    try container.encode(bracket.artistRankDigestMap, forKey: .artistRankDigestMap)
    try container.encode(bracket.venueRankDigestMap, forKey: .venueRankDigestMap)

    try container.encode(
      bracket.annumRankDigestMap.reduce(
        into: [String: RankDigest](), { $0[$1.key.formatted(.json)] = $1.value }),
      forKey: .annumRankDigestMap)

    try container.encode(
      bracket.decadesMap.reduce(
        into: [String: [String: [Show.ID]]](),
        {
          $0[$1.key.formatted(.defaultDigits)] = $1.value.reduce(
            into: [String: [Show.ID]](),
            {
              $0[$1.key.formatted(.json)] = $1.value.sorted()
            })
        }),
      forKey: .decadesMap)
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
