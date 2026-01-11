//
//  RootURLArguments+Diary.swift
//  site_tool
//
//  Created by Greg Bolsinga on 1/11/26.
//

import Foundation

extension RootURLArguments {
  func diary() async throws -> Diary {
    try await Diary.load(url: url.appending(path: "diary.json"))
  }
}
