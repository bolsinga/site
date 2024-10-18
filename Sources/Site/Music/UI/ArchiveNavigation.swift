//
//  ArchiveNavigation.swift
//
//
//  Created by Greg Bolsinga on 6/13/23.
//

import Foundation
import os

extension Logger {
  fileprivate static let archive = Logger(category: "archive")
}

extension ArchiveCategory {
  fileprivate var hasCategoryPath: Bool {
    if case .stats = self { return false }
    return true
  }
}

@Observable final class ArchiveNavigation: CustomStringConvertible {
  struct State: Codable, Equatable, Sendable {
    var category: ArchiveCategory?

    var todayPath: [ArchivePath]
    var showsPath: [ArchivePath]
    var venuesPath: [ArchivePath]
    var artistsPath: [ArchivePath]

    init(
      category: ArchiveCategory? = .defaultCategory, todayPath: [ArchivePath] = [],
      showsPath: [ArchivePath] = [], venuesPath: [ArchivePath] = [], artistsPath: [ArchivePath] = []
    ) {
      self.category = category
      self.todayPath = todayPath
      self.showsPath = showsPath
      self.venuesPath = venuesPath
      self.artistsPath = artistsPath
    }

    init?(jsonString: String) {
      guard let data = jsonString.data(using: .utf8),
        let state = try? JSONDecoder().decode(State.self, from: data)
      else { return nil }
      self = state
    }

    var jsonString: String {
      let encoder = JSONEncoder()
      encoder.outputFormatting = [.sortedKeys]
      guard let data = try? encoder.encode(self), let value = String(data: data, encoding: .utf8)
      else { return "" }
      return value
    }
  }

  private var state: State

  init(_ state: State = State()) {
    self.state = state
  }

  @ObservationIgnored
  var description: String { state.jsonString }

  var category: ArchiveCategory? {
    get {
      state.category
    }
    set {
      state.category = newValue
    }
  }

  var path: [ArchivePath] {
    get {
      guard let category = category else { return [] }
      switch category {
      case .today:
        return state.todayPath
      case .stats, .settings:
        return []
      case .shows:
        return state.showsPath
      case .venues:
        return state.venuesPath
      case .artists:
        return state.artistsPath
      }
    }
    set {
      guard let category = category else { return }
      switch category {
      case .today:
        state.todayPath = newValue
      case .stats, .settings:
        break
      case .shows:
        state.showsPath = newValue
      case .venues:
        state.venuesPath = newValue
      case .artists:
        state.artistsPath = newValue
      }
    }
  }

  func navigate(to path: ArchivePath) {
    guard path != self.path.last else {
      Logger.archive.log("already presented: \(path.formatted(), privacy: .public)")
      return
    }
    Logger.archive.log("nav to path: \(path.formatted(), privacy: .public)")
    self.path.append(path)
  }

  func navigate(to category: ArchiveCategory?) {
    Logger.archive.log("nav to category: \(category?.rawValue ?? "nil", privacy: .public)")
    self.state = State(category: category)
  }

  var activity: ArchiveActivity {
    let result: ArchiveActivity = {
      guard let category = category else { return .none }
      guard let last = path.last else { return .category(category) }
      return .path(last)
    }()
    Logger.archive.log(
      "activity: \(result, privacy: .public) path: \(self, privacy: .public)")
    return result
  }
}

extension ArchiveNavigation: RawRepresentable {
  convenience init?(rawValue: String) {
    Logger.archive.log("loading: \(rawValue, privacy: .public)")
    guard let state = State(jsonString: rawValue) else { return nil }
    self.init(state)
  }

  var rawValue: String {
    let value = state.jsonString
    Logger.archive.log("saving: \(value, privacy: .public)")
    return value
  }
}
