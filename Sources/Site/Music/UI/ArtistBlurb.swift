//
//  ArtistBlurb.swift
//
//
//  Created by Greg Bolsinga on 2/28/23.
//

import SwiftUI

struct ArtistBlurb: View {
  @Environment(\.vault) private var vault: Vault
  let show: Show

  private var venue: Venue? {
    do {
      return try vault.lookup.venueForShow(show)
    } catch {
      return nil
    }
  }

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

    ArtistBlurb(show: vault.music.shows[0])
      .environment(\.vault, vault)

    ArtistBlurb(show: vault.music.shows[1])
      .environment(\.vault, vault)

    ArtistBlurb(show: vault.music.shows[2])
      .environment(\.vault, vault)
  }
}
