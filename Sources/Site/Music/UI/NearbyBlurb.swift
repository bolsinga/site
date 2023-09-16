//
//  NearbyBlurb.swift
//
//
//  Created by Greg Bolsinga on 9/14/23.
//

import SwiftUI

struct NearbyBlurb: View {
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
      Text(concert.show.date.formatted(.compact))
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

struct NearbyBlurb_Previews: PreviewProvider {
  static var previews: some View {
    let vaultPreview = Vault.previewData

    NearbyBlurb(concert: vaultPreview.concerts[0])

    NearbyBlurb(concert: vaultPreview.concerts[1])

    NearbyBlurb(concert: vaultPreview.concerts[2])
  }
}
