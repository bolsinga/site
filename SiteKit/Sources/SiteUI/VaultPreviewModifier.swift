//
//  VaultPreviewModifier.swift
//  site
//
//  Created by Greg Bolsinga on 7/29/25.
//

import Foundation
import Shared
import SiteCore
import SwiftUI

private enum VaultPreviewError: Error {
  case noSample
}

struct VaultPreviewModifier: PreviewModifier {
  static func makeSharedContext() async throws -> VaultModel {
    try await VaultModel.sample()
  }

  func body(content: Content, context: VaultModel) -> some View {
    content
      .environment(context)
  }
}

struct VaultErrorPreviewModifier: PreviewModifier {
  let error: Error

  static func makeSharedContext() async throws -> VaultModel {
    try await VaultModel.sample()
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
  /// A model of a few shows of the archive, which starts no tasks.
  @MainActor static func sample() async throws -> VaultModel {
    guard let url = #bundle.url(forResource: "sample-shows", withExtension: "json") else {
      throw VaultPreviewError.noSample
    }
    let vault = try await Vault(
      json: try Data(contentsOf: url), rootURL: URL(string: "https://www.bolsinga.com/")!)
    return VaultModel(vault, executeAsynchronousTasks: false)
  }

  func previewArtist(_ id: String) -> ArtistDigest {
    vault.digest(artist: .artist(id))!
  }

  var previewAllArtists: any Collection<RankedArchiveItem> {
    vault.artistIDs().compactMap { vault.rankedArtist(id: $0.0) }.shuffled()
  }

  func previewVenue(_ id: String) -> VenueDigest {
    vault.digest(venue: .venue(id))!
  }

  var previewAllVenues: any Collection<RankedArchiveItem> {
    vault.venueIDs().compactMap { vault.rankedVenue(id: $0.0) }.shuffled()
  }

  func previewShow(_ id: String) -> ShowDigest {
    vault.digest(show: .show(id))!
  }

  func previewAnnum(_ id: Annum) -> AnnumDigest {
    vault.digest(annum: id)!
  }
}
