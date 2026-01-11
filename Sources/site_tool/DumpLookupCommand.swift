//
//  DumpLookupCommand.swift
//  site_tool
//
//  Created by Greg Bolsinga on 1/11/26.
//

import ArgumentParser
import Foundation

struct DumpLookupCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "dumpLookup",
    abstract: "Dump a json representation of Music Lookup."
  )

  @OptionGroup var rootURL: RootURLArguments

  func run() async throws {
    let lookup = try await rootURL.lookup()

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    encoder.dateEncodingStrategy = .iso8601

    let data = try encoder.encode(lookup.self)
    guard let value = String(data: data, encoding: .utf8) else {
      print("cannot encode lookup")
      return
    }
    print(value)
  }
}
