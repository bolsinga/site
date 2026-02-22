//
//  DumpBracketCommand.swift
//  site_tool
//
//  Created by Greg Bolsinga on 1/11/26.
//

import ArgumentParser
import Foundation

private struct OrderedBracket<Identifier: ArchiveIdentifier>: Encodable {
  let bracket: Bracket<Identifier>
  let formatId: @Sendable (Identifier.ID) -> String  // Z.formatted(.json)
  let formatAnnumId: @Sendable ((Identifier.AnnumID)) -> String

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
        into: [String: RankDigest](), { $0[formatId($1.key)] = $1.value }),
      forKey: .artistRankDigestMap)
    try container.encode(
      bracket.venueRankDigestMap.reduce(
        into: [String: RankDigest](), { $0[formatId($1.key)] = $1.value }),
      forKey: .venueRankDigestMap)

    try container.encode(
      bracket.annumRankDigestMap.reduce(
        into: [String: RankDigest](), { $0[formatAnnumId($1.key)] = $1.value }),
      forKey: .annumRankDigestMap)

    try container.encode(
      bracket.decadesMap.reduce(
        into: [String: [String: [String]]](),
        {
          $0[$1.key.formatted(.defaultDigits)] = $1.value.reduce(
            into: [String: [String]](),
            {
              $0[formatAnnumId($1.key)] = $1.value.map { formatId($0) }.sorted()
            })
        }),
      forKey: .decadesMap)
  }

  fileprivate func dump() throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    encoder.dateEncodingStrategy = .iso8601

    let data = try encoder.encode(self)
    guard let value = String(data: data, encoding: .utf8) else {
      print("cannot encode bracket")
      return
    }
    print(value)
  }
}

extension ArchivePathIdentifier {
  func formatID(_ item: ID) -> String {
    item.formatted(.json)
  }

  func formatAnnumID(_ item: AnnumID) -> String {
    item.formatted(.json)
  }
}

extension BasicIdentifier {
  func formatID(_ item: ID) -> String {
    item
  }

  func formatAnnumID(_ item: AnnumID) -> String {
    item.formatted(.json)
  }
}

struct DumpBracketCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "dumpBracket",
    abstract: "Dump a json representation of Music Bracket."
  )

  @OptionGroup var rootURL: RootURLArguments

  @Flag(help: "Choose the Identifier for Bracket.")
  var identifier: IdentifierFlag = .archivePath

  func run() async throws {
    switch identifier {
    case .basic:
      let identifier = BasicIdentifier()
      let bracket = OrderedBracket(
        bracket: try await rootURL.bracket(identifier: identifier),
        formatId: identifier.formatID(_:), formatAnnumId: identifier.formatAnnumID(_:))
      try bracket.dump()
    case .archivePath:
      let identifier = ArchivePathIdentifier()
      let bracket = OrderedBracket(
        bracket: try await rootURL.bracket(identifier: identifier),
        formatId: identifier.formatID(_:), formatAnnumId: identifier.formatAnnumID(_:))
      try bracket.dump()
    }
  }
}
