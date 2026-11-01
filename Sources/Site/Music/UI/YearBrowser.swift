//
//  YearBrowser.swift
//  site
//
//  Created by Greg Bolsinga on 10/24/26.
//

import Shared
import SwiftUI

extension Annum {
  /// The years either side of this one in `annums`, in year order with unknown after the latest
  /// year. The ends wrap: before the oldest year is unknown, and after unknown is the oldest.
  func neighbors(in annums: some Collection<Annum>) -> (previous: Annum, next: Annum) {
    Set(annums).union([self]).sorted().wrappingNeighbors(of: self)
  }
}

/// A year's details that can be paged to the previous and next year, like the Today pager.
struct YearBrowser: View {
  let annum: Annum
  let annums: [Annum]
  let digest: (Annum) -> AnnumDigest?
  let url: (AnnumDigest) -> URL?
  let isPathNavigable: (ArchivePath) -> Bool
  /// Called with the year the pager settles on, so the navigation path names the year shown.
  let didShowAnnum: (Annum) -> Void

  var body: some View {
    PagedBrowser(
      item: annum, neighbors: { $0.neighbors(in: annums) }, digest: digest, url: url,
      title: { annum, _ in annum.formatted() }, didShow: didShowAnnum
    ) { annum, digest, neighbors in
      ShowsMapHeader(
        shows: digest?.shows ?? [], title: annum.formatted(), animatesChanges: true,
        neighborShows: neighbors.map(\.shows))
    } page: { digest, bottomContentMargin in
      YearDetail(
        digest: digest, url: url(digest), isPathNavigable: isPathNavigable,
        bottomContentMargin: bottomContentMargin)
    }
  }
}
