//
//  YearDetail.swift
//
//
//  Created by Greg Bolsinga on 3/26/23.
//

import SwiftUI

struct YearDetail: View {
  let digest: AnnumDigest
  let concertCompare: (Concert, Concert) -> Bool
  let isPathNavigable: (PathRestorable) -> Bool

  private var concerts: [Concert] {
    digest.concerts
  }

  @ViewBuilder private var statsElement: some View {
    let concerts = concerts
    if !concerts.isEmpty {
      Section(header: Text(ArchiveCategory.stats.localizedString)) {
        StatsGrouping(concerts: concerts)
      }
    }
  }

  @ViewBuilder private var showsElement: some View {
    let concerts = concerts
    if !concerts.isEmpty {
      Section(header: Text("Shows", bundle: .module)) {
        ForEach(concerts.sorted(by: concertCompare)) { concert in
          PathRestorableLink(pathRestorable: concert, isPathNavigable: isPathNavigable) {
            ConcertBlurb(concert: concert)
          }
        }
      }
    }
  }

  var body: some View {
    List {
      statsElement
      showsElement
    }
    #if os(iOS)
      .listStyle(.grouped)
    #endif
    .navigationTitle(Text(digest.annum.formatted()))
    .archiveShare(digest)
  }
}

#Preview {
  NavigationStack {
    YearDetail(
      digest: vaultPreviewData.digest(for: Annum.year(2001)),
      concertCompare: vaultPreviewData.comparator.compare(lhs:rhs:),
      isPathNavigable: { _ in
        true
      }
    )
    .musicDestinations(vaultPreviewData)
  }
}
