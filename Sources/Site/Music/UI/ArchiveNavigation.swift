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
  }

  private var state: State

  internal init(_ state: State = State()) {
    self.state = state.pruned
  }

  var description: String { state.jsonString }

  var category: ArchiveCategory.DefaultCategory {
    get {
      state.category
    }
    set {
      state.category = newValue
    }
  }

  var path: [ArchivePath] {
    get {
      #if DEFAULT_CATEGORY_OPTIONAL
        guard let category = state.category else { return [] }
      #endif
      return state.categoryPaths[category] ?? []
    }
    set {
      #if DEFAULT_CATEGORY_OPTIONAL
        guard let category = state.category else { return }
      #endif
      state.categoryPaths[category] = newValue
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
    state = State(category: category)
  }

  var activity: ArchiveActivity {
    let result: ArchiveActivity = {
      #if DEFAULT_CATEGORY_OPTIONAL
        guard let category = state.category else { return .none }
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
    let value = state.jsonString
    Logger.archive.log("saving: \(value, privacy: .public)")
    return value
  }
}
