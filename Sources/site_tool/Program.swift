//
//  DumpVaultCommand.swift
//  site_tool
//
//  Created by Greg Bolsinga on 1/11/26.
//

import ArgumentParser
import Foundation

@main
struct Program: AsyncParsableCommand {
  public static let configuration = CommandConfiguration(
    commandName: "site_tool",
    abstract: "A tool for working with site data.",
    subcommands: [
      DumpVaultCommand.self, DumpDiaryCommand.self, DumpLookupCommand.self,
    ],
    defaultSubcommand: DumpVaultCommand.self
  )
}
