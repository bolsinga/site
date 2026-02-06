//
//  DumpBracketCommand.swift
//  site_tool
//
//  Created by Greg Bolsinga on 1/11/26.
//

import ArgumentParser
import Foundation

private struct OrderedBracket: Encodable {
  let bracket: Bracket<ArchivePathIdentifier>

  private enum Keys: String, CodingKey {
    case librarySortTokenMap
    case artistRankDigestMap
    case venueRankDigestMap
    case annumRankDigestMap
    case decadesMap
  }

  func encode(to encoder: any Encoder) throws {
    // Specialized encoder so that the keys are formatted.
    //  It seems that .sortedKeys is "lexicographic" sorting.
    var container = encoder.container(keyedBy: Keys.self)
    try container.encode(bracket.librarySortTokenMap, forKey: .librarySortTokenMap)

    try container.encode(
      bracket.artistRankDigestMap.reduce(
        into: [String: RankDigest](), { $0[$1.key.formatted(.json)] = $1.value }),
      forKey: .artistRankDigestMap)
    try container.encode(
      bracket.venueRankDigestMap.reduce(
        into: [String: RankDigest](), { $0[$1.key.formatted(.json)] = $1.value }),
      forKey: .venueRankDigestMap)

    try container.encode(
      bracket.annumRankDigestMap.reduce(
        into: [String: RankDigest](), { $0[$1.key.formatted(.json)] = $1.value }),
      forKey: .annumRankDigestMap)

    try container.encode(
      bracket.decadesMap.reduce(
        into: [String: [String: [String]]](),
        {
          $0[$1.key.formatted(.defaultDigits)] = $1.value.reduce(
            into: [String: [String]](),
            {
              $0[$1.key.formatted(.json)] = $1.value.map { $0.formatted(.json) }.sorted()
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
