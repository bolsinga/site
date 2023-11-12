//
//  ArtistBlurb.swift
//
//
//  Created by Greg Bolsinga on 2/28/23.
//

import SwiftUI

struct ArtistBlurb: View {
  let concert: Concert

  var body: some View {
    LabeledContent {
      Text("\(concert.show.artists.count) Artist(s)", bundle: .module)
    } label: {
      if let venue = concert.venue {
        Text(venue.name)
      }
      Text(concert.show.date.formatted(.compact))
    }
  }
}

#Preview {
  ArtistBlurb(concert: vaultPreviewData.concerts[0])
}

#Preview {
  ArtistBlurb(concert: vaultPreviewData.concerts[1])
}

#Preview {
  ArtistBlurb(concert: vaultPreviewData.concerts[2])
}
