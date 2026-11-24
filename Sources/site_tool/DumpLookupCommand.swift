//
//  DumpLookupCommand.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 2/7/26.
//

import ArgumentParser
import Foundation
import SiteCore

extension Lookup {
  fileprivate func dump() throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    encoder.dateEncodingStrategy = .iso8601

    let data = try encoder.encode(self)
    guard let value = String(data: data, encoding: .utf8) else {
      throw OutputEncodingError(subject: "lookup")
    }
    print(value)
  }
}

struct DumpLookupCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "dumpLookup",
    abstract: "Dump a json representation of Lookup."
  )

  @OptionGroup var rootURL: RootURLArguments

  func run() async throws {
    try await rootURL.lookup().dump()
  }
}
