//
//  Vault+Environment.swift
//
//
//  Created by Greg Bolsinga on 4/12/23.
//

import SwiftUI

extension EnvironmentValues {
  public var vault: Vault {
    get {
      return self[VaultKey.self]
    }
    set {
      self[VaultKey.self] = newValue
    }
  }
}

public struct VaultKey: EnvironmentKey {
  public static let defaultValue: Vault = Vault(
    music: Music(
      albums: [], artists: [], relations: [], shows: [], songs: [], timestamp: .now, venues: []))
}
