//
//  VenueBrowser.swift
//  site
//
//  Created by Greg Bolsinga on 10/26/26.
//

import Shared
import SwiftUI

/// A venue's details that can be paged to the previous and next venue, in library order.
struct VenueBrowser: View {
  let id: ArchivePath
  let venueIDs: [ArchivePath]
  let digest: (ArchivePath) -> VenueDigest?
  let url: (VenueDigest) -> URL?
  let isPathNavigable: (ArchivePath) -> Bool
  /// Called with the venue the pager settles on, so the navigation path names the venue shown.
  let didShow: (ArchivePath) -> Void

  var body: some View {
    PagedBrowser(
      item: id, neighbors: { venueIDs.wrappingNeighbors(of: $0) }, digest: digest, url: url,
      title: { _, digest in digest?.name ?? "" }, didShow: didShow
    ) { _, digest, neighbors in
      ShowsMapHeader(
        shows: digest?.shows ?? [], title: digest?.name ?? "", location: digest?.location,
        animatesChanges: true, neighborShows: neighbors.map(\.shows))
    } page: { digest, bottomContentMargin in
      VenueDetail(
        digest: digest, isPathNavigable: isPathNavigable,
        bottomContentMargin: bottomContentMargin)
    }
  }
}
