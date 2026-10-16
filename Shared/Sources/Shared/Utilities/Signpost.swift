//
//  Signpost.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 1/19/26.
//

import Foundation
import os

struct Signpost: ~Copyable {
  let signPost: OSSignposter
  let name: StaticString
  var state: OSSignpostIntervalState?

  init(category: String, name: StaticString) {
    self.signPost = OSSignposter(
      subsystem: Bundle.main.bundleIdentifier ?? "unknown", category: category)
    self.name = name
  }

  deinit {
    guard let state else { return }
    self.signPost.endInterval(name, state)
  }

  mutating func start() {
    state = signPost.beginInterval(name)
  }
}
