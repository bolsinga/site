//
//  DumpVaultCommand.swift
//  site_tool
//
//  Created by Greg Bolsinga on 1/11/26.
//

import ArgumentParser
import Foundation

struct Program: AsyncParsableCommand {
  public static let configuration = CommandConfiguration(
    commandName: "site_tool",
    abstract: "A tool for working with site data.",
    subcommands: [
      DumpVaultCommand.self, DumpDiaryCommand.self, DumpBracketCommand.self, NextIDCommand.self,
      AssociatedDomainsCommand.self, DumpLookupCommand.self,
    ],
    defaultSubcommand: DumpVaultCommand.self
  )

  static public func asyncMain() async {
    // This was necessary so that main.swift knew this was an AsyncParsableCommand. Not sure why.
    await main()
  }
}
