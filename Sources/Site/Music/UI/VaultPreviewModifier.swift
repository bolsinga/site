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

extension PreviewTrait where T == Preview.ViewTraits {
  static var vaultModel: Self = .modifier(VaultPreviewModifier())
}

extension VaultModel {
  func previewArtist(_ id: String) -> ArtistDigest {
    vault.artistDigestMap[id]!
  }

  var previewAllArtists: any Collection<ArtistDigest> {
    vault.artistDigestMap.values.shuffled()
  }

  func previewVenue(_ id: String) -> VenueDigest {
    vault.venueDigestMap[id]!
  }

  var previewAllVenues: any Collection<VenueDigest> {
    vault.venueDigestMap.values.shuffled()
  }

  func previewConcert(_ id: String) -> Concert {
    vault.concertMap[id]!
  }
}
