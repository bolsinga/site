//
//  ArchiveCategoryStack.swift
//
//
//  Created by Greg Bolsinga on 5/21/23.
//

import SwiftUI

struct ArchiveCategoryStack: View {
  let vault: Vault

  @State private var navigationPath: NavigationPath = .init()

  var body: some View {
    NavigationStack(path: $navigationPath) {
      ArchiveCategoryList()
    }
    .environment(\.vault, vault)
  }
}

struct ArchiveCategoryStack_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault(
      music: Music(
        albums: [], artists: [], relations: [], shows: [], songs: [], timestamp: Date.now,
        venues: []))

    ArchiveCategoryStack(vault: vault)
  }
}
