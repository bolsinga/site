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
      Text(
        "\(concert.show.artists.count) Artist(s)", bundle: .module,
        comment: "Content of the LabeledContent in a ArtistBlurb.")
    } label: {
      if let venue = concert.venue {
        Text(venue.name)
      }
      Text(concert.show.date.formatted(.compact))
    }
  }
}

struct ArtistBlurbView_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault.previewData

    NavigationStack {
      ArtistBlurb(concert: vault.concert(from: vault.music.shows[0]))
    }

    NavigationStack {
      ArtistBlurb(concert: vault.concert(from: vault.music.shows[1]))
    }

    NavigationStack {
      ArtistBlurb(concert: vault.concert(from: vault.music.shows[2]))
    }
  }
}
