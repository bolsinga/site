//
//  VenueBlurb.swift
//
//
//  Created by Greg Bolsinga on 5/12/23.
//

import SwiftUI

struct VenueBlurb: View {
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

struct VenueBlurb_Previews: PreviewProvider {
  static var previews: some View {
    let vaultPreview = Vault.previewData

    VenueBlurb(concert: vaultPreview.concerts[0])

    VenueBlurb(concert: vaultPreview.concerts[1])

    VenueBlurb(concert: vaultPreview.concerts[2])
  }
}
