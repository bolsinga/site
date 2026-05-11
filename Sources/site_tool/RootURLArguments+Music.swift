//
//  RootURLArguments+Music.swift
//  site_tool
//
//  Created by Greg Bolsinga on 1/11/26.
//

import Foundation

extension RootURLArguments {
  var showsURL: URL {
    url.appending(path: "shows.json")
  }
}
