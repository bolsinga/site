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

@Observable final class ArchiveNavigation {
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
  }

  private var state: State

  internal init(_ state: State = State()) {
    self.state = state
  }

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
      #if os(iOS) || os(tvOS)
        guard let category = state.category else { return [] }
      #endif
      return state.categoryPaths[category] ?? []
    }
    set {
      #if os(iOS) || os(tvOS)
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
    #if os(iOS) || os(tvOS)
      Logger.archive.log("nav to category: \(category?.rawValue ?? "nil", privacy: .public)")
    #elseif os(macOS)
      Logger.archive.log("nav to category: \(category.rawValue, privacy: .public)")
    #endif
    state = State(category: category)
  }

  var activity: ArchiveActivity {
    #if os(iOS) || os(tvOS)
      guard let category = state.category else { return .none }
    #endif
    guard !path.isEmpty, let last = path.last else { return .category(category) }
    return .path(last)
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
