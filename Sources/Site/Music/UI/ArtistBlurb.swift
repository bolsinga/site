//
//  ArtistBlurb.swift
//
//
//  Created by Greg Bolsinga on 2/28/23.
//

import SwiftUI

struct ArtistBlurb: View {
  let show: Show
  let venue: Venue?

  var body: some View {
    LabeledContent {
      Text(
        "\(show.artists.count) Artist(s)", bundle: .module,
        comment: "Content of the LabeledContent in a ArtistBlurb.")
    } label: {
      if let venue {
        Text(venue.name)
      }
      Text(show.date.formatted(.compact))
    }
  }
}

struct ArtistBlurbView_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault.previewData

    NavigationStack {
      let show = vault.music.shows[0]
      ArtistBlurb(show: show, venue: vault.lookup.venueForShow(show))
    }

    NavigationStack {
      let show = vault.music.shows[1]
      ArtistBlurb(show: show, venue: vault.lookup.venueForShow(show))
    }

    NavigationStack {
      let show = vault.music.shows[2]
      ArtistBlurb(show: show, venue: vault.lookup.venueForShow(show))
    }
  }
}
