//
//  VenueBlurb.swift
//
//
//  Created by Greg Bolsinga on 5/12/23.
//

import SwiftUI

struct VenueBlurb: View {
  @Environment(\.vault) private var vault: Vault

  let show: Show

  private var artists: [Artist] {
    do {
      return try vault.lookup.artistsForShow(show)
    } catch {
      return []
    }
  }

  @ViewBuilder private var artistsView: some View {
    VStack(alignment: .leading) {
      ForEach(artists) { artist in
        Text(artist.name).font(.headline)
      }
    }
  }

  @ViewBuilder private var detailsView: some View {
    VStack(alignment: .trailing) {
      Text(show.date.formatted(.compact))
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
    let vault = Vault.previewData

    VenueBlurb(show: vault.music.shows[0])
      .environment(\.vault, vault)

    VenueBlurb(show: vault.music.shows[1])
      .environment(\.vault, vault)

    VenueBlurb(show: vault.music.shows[2])
      .environment(\.vault, vault)
  }
}
