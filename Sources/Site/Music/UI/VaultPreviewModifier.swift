//
//  VaultPreviewModifier.swift
//  site
//
//  Created by Greg Bolsinga on 7/29/25.
//

import SwiftUI

struct VaultPreviewModifier: PreviewModifier {
  static func makeSharedContext() async throws -> VaultModel {
    VaultModel(vaultPreviewData, executeAsynchronousTasks: false)
  }

  func body(content: Content, context: VaultModel) -> some View {
    content
      .environment(context)
  }
}
