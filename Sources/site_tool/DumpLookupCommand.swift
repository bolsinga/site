//
//  DumpLookupCommand.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 2/7/26.
//

import ArgumentParser
import Foundation

extension Lookup {
  fileprivate func dump() throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    encoder.dateEncodingStrategy = .iso8601

    let data = try encoder.encode(self)
    guard let value = String(data: data, encoding: .utf8) else {
      print("cannot encode lookup")
      return
    }
    print(value)
  }
}

struct DumpLookupCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "dumpLookup",
    abstract: "Dump a text output of Lookup."
  )

  @OptionGroup var rootURL: RootURLArguments

  @Flag(help: "Choose the Identifier for Lookup.")
  var identifier: IdentifierFlag = .archivePath

  func run() async throws {
    switch identifier {
    case .basic:
      try await rootURL.lookup(identifier: BasicIdentifier()).dump()

    case .archivePath:
      try await rootURL.lookup(identifier: ArchivePathIdentifier()).dump()
    }
  }
}
