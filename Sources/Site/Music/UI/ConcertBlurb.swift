//
//  ConcertBlurb.swift
//
//
//  Created by Greg Bolsinga on 5/18/23.
//

import SwiftUI

struct ConcertBlurb: View {
  let concert: Concert

  @ViewBuilder private var artistsView: some View {
    VStack(alignment: .leading) {
      ForEach(concert.artists) { artist in
        Text(artist.name).font(.headline)
      }
    }
  }

  @ViewBuilder private var detailsView: some View {
    VStack(alignment: .trailing) {
      if let venue = concert.venue {
        Text(venue.name)
      }
      Text(concert.show.date.formatted(.noYear))
    }
    .font(.footnote)
  }

  var body: some View {
    HStack {
      artistsView
      Spacer()
      detailsView
    }
  }
}

#Preview {
  ConcertBlurb(concert: vaultPreviewData.concerts[0])
}

#Preview {
  ConcertBlurb(concert: vaultPreviewData.concerts[1])
}

#Preview {
  ConcertBlurb(concert: vaultPreviewData.concerts[2])
}
