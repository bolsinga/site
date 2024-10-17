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
    var category: ArchiveCategory.DefaultCategory
    var categoryPaths: [ArchiveCategory: [ArchivePath]]

    internal init(
      category: ArchiveCategory.DefaultCategory = .defaultCategory,
      categoryPaths: [ArchiveCategory: [ArchivePath]] = [:]
    ) {
      self.category = category
      self.categoryPaths = categoryPaths
    }

    internal init?(jsonString: String) {
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

    fileprivate var pruned: State {
      State(category: category, categoryPaths: categoryPaths.filter { $0.key.hasCategoryPath })
    }

    fileprivate func path(for category: ArchiveCategory) -> [ArchivePath] {
      categoryPaths[category] ?? []
    }
  }

  var category: ArchiveCategory.DefaultCategory

  var todayPath: [ArchivePath]
  var showsPath: [ArchivePath]
  var venuesPath: [ArchivePath]
  var artistsPath: [ArchivePath]

  internal init(_ state: State = State()) {
    self.category = state.category

    self.todayPath = state.path(for: .today)
    self.showsPath = state.path(for: .shows)
    self.venuesPath = state.path(for: .venues)
    self.artistsPath = state.path(for: .artists)
  }

  @ObservationIgnored
  var description: String { state().jsonString }

  private func path(for category: ArchiveCategory) -> [ArchivePath] {
    switch category {
    case .today:
      todayPath
    case .stats:
      []
    case .shows:
      showsPath
    case .venues:
      venuesPath
    case .artists:
      artistsPath
    }
  }

  private func setPath(for category: ArchiveCategory, _ path: [ArchivePath]) {
    switch category {
    case .today:
      todayPath = path
    case .stats:
      break
    case .shows:
      showsPath = path
    case .venues:
      venuesPath = path
    case .artists:
      artistsPath = path
    }
  }

  private func state() -> State {
    let categoryPaths = ArchiveCategory.allCases.reduce(into: [:]) { $0[$1] = path(for: $1) }
    return State(category: category, categoryPaths: categoryPaths)
  }

  var path: [ArchivePath] {
    get {
      #if DEFAULT_CATEGORY_OPTIONAL
        guard let category = category else { return [] }
      #endif
      return path(for: category)
    }
    set {
      #if DEFAULT_CATEGORY_OPTIONAL
        guard let category = category else { return }
      #endif
      setPath(for: category, newValue)
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

  func navigate(to category: ArchiveCategory.DefaultCategory) {
    #if DEFAULT_CATEGORY_OPTIONAL
      Logger.archive.log("nav to category: \(category?.rawValue ?? "nil", privacy: .public)")
    #else
      Logger.archive.log("nav to category: \(category.rawValue, privacy: .public)")
    #endif
    self.category = category
    #if DEFAULT_CATEGORY_OPTIONAL
      guard let category = category else { return }
    #endif
    setPath(for: category, [])
  }

  var activity: ArchiveActivity {
    let result: ArchiveActivity = {
      #if DEFAULT_CATEGORY_OPTIONAL
        guard let category = category else { return .none }
      #endif
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
    let value = state().jsonString
    Logger.archive.log("saving: \(value, privacy: .public)")
    return value
  }
}
