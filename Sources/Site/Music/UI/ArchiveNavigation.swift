//
//  ArchiveNavigation.swift
//
//
//  Created by Greg Bolsinga on 6/13/23.
//

import Foundation
import MusicData
import SwiftUI
import Utilities
import os

extension Logger {
  fileprivate static let archive = Logger(category: "archive")
}

@MainActor @Observable final class ArchiveNavigation {
  struct State: Codable, Equatable, Sendable {
    var category: ArchiveCategory

    var todayPath: [ArchivePath]
    var showsPath: [ArchivePath]
    var venuesPath: [ArchivePath]
    var artistsPath: [ArchivePath]

    init(
      category: ArchiveCategory = .defaultCategory, todayPath: [ArchivePath] = [],
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

    init(path: ArchivePath) {
      let category = path.category
      switch category {
      case .today:
        self.init(category: category, todayPath: [path])
      case .stats, .settings, .search:
        self.init(category: category)
      case .shows:
        self.init(category: category, showsPath: [path])
      case .venues:
        self.init(category: category, venuesPath: [path])
      case .artists:
        self.init(category: category, artistsPath: [path])
      }
    }

    enum Change {
      case none
      case category
      case path
      case both
    }

    private func samePaths(for other: State) -> Bool {
      self.todayPath == other.todayPath && self.showsPath == other.showsPath
        && self.venuesPath == other.venuesPath && self.artistsPath == other.artistsPath
    }

    func change(for other: State) -> Change {
      if self.category == other.category {
        return samePaths(for: other) ? .none : .path
      }
      return samePaths(for: other) ? .category : .both
    }

    func update(with other: State) -> State {
      switch other.category {
      case .today:
        State(
          category: other.category, todayPath: other.todayPath, showsPath: showsPath,
          venuesPath: venuesPath, artistsPath: artistsPath)
      case .shows:
        State(
          category: other.category, todayPath: todayPath, showsPath: other.showsPath,
          venuesPath: venuesPath, artistsPath: artistsPath)
      case .venues:
        State(
          category: other.category, todayPath: todayPath, showsPath: showsPath,
          venuesPath: other.venuesPath, artistsPath: artistsPath)
      case .artists:
        State(
          category: other.category, todayPath: todayPath, showsPath: showsPath,
          venuesPath: venuesPath, artistsPath: other.artistsPath)
      case .stats, .settings, .search:
        State(
          category: other.category, todayPath: todayPath, showsPath: showsPath,
          venuesPath: venuesPath, artistsPath: artistsPath)
      }
    }
  }

  var state: State

  @ObservationIgnored
  private let useDispatchMainWorkaround: Bool  // Disable for testing (so changes occur immediately).

  init(_ state: State = State(), useDispatchMainWorkaround: Bool = true) {
    self.state = state
    self.useDispatchMainWorkaround = useDispatchMainWorkaround
  }

  @ObservationIgnored
  var description: String { state.jsonString }

  var category: ArchiveCategory {
    get {
      state.category
    }
    set {
      state.category = newValue
    }
  }

  var path: [ArchivePath] {
    get {
      switch category {
      case .today:
        return state.todayPath
      case .stats, .settings, .search:
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
      switch category {
      case .today:
        state.todayPath = newValue
      case .stats, .settings, .search:
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

  private func update(state other: State) {
    switch self.state.change(for: other) {
    case .none:
      break
    case .category, .path:
      self.state = self.state.update(with: other)
    case .both:
      // Without this workaround, changing the category will update the UI
      //  such that the path is cleared after the first property changes.
      if useDispatchMainWorkaround {
        // Do not animate the first category property change
        //  to eliminate a double animation.
        var t = Transaction()
        t.disablesAnimations = true
        withTransaction(t) {
          self.state = self.state.update(with: State(category: other.category))
        }
        // Make the path change on the next turn of the RunLoop
        //  with an animation.
        DispatchQueue.main.async {
          // NOTE: This DispatchQueue.main is the reason why this class is
          //  @MainActor. If this is removed in the future, remove the annotation too.
          self.state = self.state.update(with: other)
        }
      } else {
        self.state = self.state.update(with: other)
      }
    }
  }

  func navigate(to path: ArchivePath) {
    guard path != self.path.last else {
      Logger.archive.log("already presented: \(path.formatted(), privacy: .public)")
      return
    }
    Logger.archive.log("nav to path: \(path.formatted(), privacy: .public)")
    self.update(state: State(path: path))
  }

  func navigate(to category: ArchiveCategory) {
    Logger.archive.log("nav to category: \(category.rawValue, privacy: .public)")
    self.update(state: State(category: category))
  }

  var activity: ArchiveActivity {
    let result: ArchiveActivity = {
      guard let last = path.last else { return .category(category) }
      return .path(last)
    }()
    Logger.archive.log(
      "activity: \(result, privacy: .public) path: \(self, privacy: .public)")
    return result
  }
}

#if swift(>=6.2)
  extension ArchiveNavigation: @MainActor CustomStringConvertible {}
#else
  extension ArchiveNavigation: @preconcurrency CustomStringConvertible {}
#endif

#if swift(>=6.2)
  extension ArchiveNavigation: @MainActor RawRepresentable {}
#else
  extension ArchiveNavigation: @preconcurrency RawRepresentable {}
#endif

extension ArchiveNavigation {
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
