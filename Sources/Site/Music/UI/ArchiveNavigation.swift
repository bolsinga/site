//
//  ArchiveNavigation.swift
//
//
//  Created by Greg Bolsinga on 6/13/23.
//

import Foundation
import os

extension Logger {
  nonisolated(unsafe) static let archive = Logger(category: "archive")
  #if swift(>=6.0)
    #warning("nonisolated(unsafe) unneeded.")
  #endif
}

@Observable final class ArchiveNavigation {
  struct State: Codable, Equatable, Sendable {
    #if os(iOS) || os(tvOS)
      typealias DefaultCategory = ArchiveCategory?
      static var defaultCategory: DefaultCategory { .today }
    #elseif os(macOS)
      typealias DefaultCategory = ArchiveCategory
      static var defaultCategory: DefaultCategory { .today }
    #endif

    var category: DefaultCategory
    var path: [ArchivePath]

    internal init(category: DefaultCategory = defaultCategory, path: [ArchivePath] = []) {
      self.category = category
      self.path = path
    }
  }

  var state: State

  internal init(_ state: State = State()) {
    self.state = state
  }

  var navigationPath: [ArchivePath] {
    get {
      state.path
    }
    set {
      state.path = newValue
    }
  }

  func navigate(to path: ArchivePath) {
    guard path != navigationPath.last else {
      Logger.archive.log("already presented: \(path.formatted(), privacy: .public)")
      return
    }
    Logger.archive.log("nav to path: \(path.formatted(), privacy: .public)")
    var newPath = navigationPath
    newPath.append(path)
    navigationPath = newPath
  }

  func navigate(to category: State.DefaultCategory) {
    #if os(iOS) || os(tvOS)
      Logger.archive.log("nav to category: \(category?.rawValue ?? "nil", privacy: .public)")
    #elseif os(macOS)
      Logger.archive.log("nav to category: \(category.rawValue, privacy: .public)")
    #endif
    state = State(category: category)
  }
}

extension ArchiveNavigation: RawRepresentable {
  convenience init?(rawValue: String) {
    Logger.archive.log("loading: \(rawValue, privacy: .public)")
    guard let data = rawValue.data(using: .utf8) else { return nil }
    guard let state = try? JSONDecoder().decode(State.self, from: data) else { return nil }
    self.init(state)
  }

  var rawValue: String {
    guard let data = try? JSONEncoder().encode(state) else { return "" }
    guard let value = String(data: data, encoding: .utf8) else { return "" }
    Logger.archive.log("saving: \(value, privacy: .public)")
    return value
  }
}
