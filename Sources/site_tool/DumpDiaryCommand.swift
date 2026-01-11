//
//  DumpDiaryCommand.swift
//  site_tool
//
//  Created by Greg Bolsinga on 1/11/26.
//

import ArgumentParser
import Foundation

struct DumpDiaryCommand: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "dumpDiary",
    abstract: "Dump a text output of the Diary."
  )

  @OptionGroup var rootURL: RootURLArguments

  func run() async throws {
    let diary = try await rootURL.diary()
    print("\(diary.title) has \(diary.entries.count) entries.")
  }
}
