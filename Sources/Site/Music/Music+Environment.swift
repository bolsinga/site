//
//  Music+Environment.swift
//
//
//  Created by Greg Bolsinga on 3/24/23.
//

import SwiftUI

extension EnvironmentValues {
  public var music: Music {
    get {
      return self[MusicKey.self]
    }
    set {
      self[MusicKey.self] = newValue
    }
  }
}

public struct MusicKey: EnvironmentKey {
  public static let defaultValue: Music = Music(
    albums: [], artists: [], relations: [], shows: [], songs: [], timestamp: .now, venues: [])
}
