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
  let isPathActive: (PathRestorable) -> Bool

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
    .pathRestorableUserActivityModifier(digest.annum, url: digest.url, isPathActive: isPathActive)
    .sharePathRestorable(digest.annum, url: digest.url)
  }
}

#Preview {
  NavigationStack {
    YearDetail(
      digest: vaultPreviewData.digest(for: Annum.year(2001)),
      concertCompare: vaultPreviewData.comparator.compare(lhs:rhs:),
      isPathNavigable: { _ in
        true
      },
      isPathActive: { _ in
        true
      }
    )
    .musicDestinations(vaultPreviewData)
  }
}
