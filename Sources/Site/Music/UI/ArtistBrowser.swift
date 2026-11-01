//
//  ArtistBrowser.swift
//  site
//
//  Created by Greg Bolsinga on 10/26/26.
//

import Shared
import SwiftUI

/// An artist's details that can be paged to the previous and next artist, in library order.
struct ArtistBrowser: View {
  let id: ArchivePath
  let artistIDs: [ArchivePath]
  let digest: (ArchivePath) -> ArtistDigest?
  let url: (ArtistDigest) -> URL?
  let isPathNavigable: (ArchivePath) -> Bool
  /// Called with the artist the pager settles on, so the navigation path names the artist shown.
  let didShow: (ArchivePath) -> Void

  var body: some View {
    PagedBrowser(
      item: id, neighbors: { artistIDs.wrappingNeighbors(of: $0) }, digest: digest, url: url,
      title: { _, digest in digest?.name ?? "" }, didShow: didShow
    ) { _, digest, neighbors in
      ShowsMapHeader(
        shows: digest?.shows ?? [], title: digest?.name ?? "", animatesChanges: true,
        neighborShows: neighbors.map(\.shows))
    } page: { digest, bottomContentMargin in
      ArtistDetail(
        digest: digest, isPathNavigable: isPathNavigable,
        bottomContentMargin: bottomContentMargin)
    }
  }
}
