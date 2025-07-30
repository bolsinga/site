//
//  VaultPreviewModifier.swift
//  site
//
//  Created by Greg Bolsinga on 7/29/25.
//

import SwiftUI

struct VaultPreviewModifier: PreviewModifier {
  fileprivate enum VaultPreviewError: Error {
    case noModel
  }

  static func makeSharedContext() async throws -> VaultModel {
    let siteModel = SiteModel(urlString: "https://www.bolsinga.com/json/shows.json")
    await siteModel.load(executeAsynchronousTasks: false)
    guard siteModel.error == nil else { throw siteModel.error! }
    guard let vaultModel = siteModel.vaultModel else { throw VaultPreviewError.noModel }
    return vaultModel
  }

  func body(content: Content, context: VaultModel) -> some View {
    content
      .environment(context)
  }
}
