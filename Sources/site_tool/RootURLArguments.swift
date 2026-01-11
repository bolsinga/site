//
//  RootURLArguments.swift
//  site_tool
//
//  Created by Greg Bolsinga on 1/10/26.
//

import ArgumentParser
import Foundation

struct RootURLArguments: ParsableArguments {
  enum RootURLError: Error {
    case notURLString(String)
  }

  @Argument(
    help:
      "The root URL for the json files.",
    transform: ({
      let url = URL(string: $0)
      guard let url else { throw RootURLError.notURLString($0) }
      return url
    })
  )
  var url: URL
}
