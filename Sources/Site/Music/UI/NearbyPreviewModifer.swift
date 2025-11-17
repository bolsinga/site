//
//  NearbyPreviewModifer.swift
//  site
//
//  Created by Greg Bolsinga on 7/29/25.
//

import SwiftUI

struct NearbyPreviewModifer: PreviewModifier {
  static func makeSharedContext() async throws -> NearbyModel {
    NearbyModel()
  }

  func body(content: Content, context: NearbyModel) -> some View {
    content
      .environment(context)
  }
}

extension PreviewTrait where T == Preview.ViewTraits {
  static var nearbyModel: Self = .modifier(NearbyPreviewModifer())
}
