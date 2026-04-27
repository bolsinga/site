//
//  VaultPreviewModifier.swift
//  site
//
//  Created by Greg Bolsinga on 7/29/25.
//

import SwiftUI

private enum VaultPreviewError: Error {
  case noModel
}

struct VaultPreviewModifier: PreviewModifier {
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

struct VaultErrorPreviewModifier: PreviewModifier {
  let error: Error

  static func makeSharedContext() async throws -> VaultModel {
    let siteModel = SiteModel(urlString: "https://www.bolsinga.com/json/shows.json")
    await siteModel.load(executeAsynchronousTasks: false)
    guard siteModel.error == nil else { throw siteModel.error! }
    guard let vaultModel = siteModel.vaultModel else { throw VaultPreviewError.noModel }
    return vaultModel
  }

  func body(content: Content, context: VaultModel) -> some View {
    content
      .task {
        context.error = error
      }
      .environment(context)
  }
}

extension PreviewTrait where T == Preview.ViewTraits {
  static var vaultModel: Self = .modifier(VaultPreviewModifier())

  static var vaultModelWithError: Self = .modifier(
    VaultErrorPreviewModifier(error: VaultError.illegalURL("preview error")))
}

extension VaultModel {
  func previewArtist(_ id: String) -> ArtistDigest {
    vault.digest(artist: id)!
  }

  var previewAllArtists: any Collection<RankedArchiveItem> {
    vault.artistIDs().compactMap { vault.rankedArtist(id: $0.0) }.shuffled()
  }

  func previewVenue(_ id: String) -> VenueDigest {
    vault.digest(venue: id)!
  }

  var previewAllVenues: any Collection<RankedArchiveItem> {
    vault.venueIDs().compactMap { vault.rankedVenue(id: $0.0) }.shuffled()
  }

  func previewShow(_ id: String) -> ShowDigest {
    vault.digest(show: id)!
  }

  func previewAnnum(_ id: Annum) -> AnnumDigest {
    vault.digest(annum: id)!
  }
}
