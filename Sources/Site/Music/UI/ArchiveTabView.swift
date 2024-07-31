//
//  ArchiveTabView.swift
//
//
//  Created by Greg Bolsinga on 7/31/24.
//

import SwiftUI

struct ArchiveTabView: View {
  var model: VaultModel

  var body: some View {
    TabView {
      ArchiveCategorySplit(model: model)
        .tabItem { ArchiveTab.classic.label }
    }
  }
}

#Preview {
  ArchiveTabView(model: VaultModel(vaultPreviewData, executeAsynchronousTasks: false))
}
