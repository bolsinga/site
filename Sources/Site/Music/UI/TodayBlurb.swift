//
//  TodayBlurb.swift
//
//
//  Created by Greg Bolsinga on 5/11/23.
//

import SwiftUI

struct TodayBlurb: View {
  @Environment(\.vault) private var vault: Vault

  let show: Show

  private var artists: [Artist] {
    vault.lookup.artistsForShow(show)
  }

  private var venue: Venue? {
    do {
      return try vault.lookup.venueForShow(show)
    } catch {
      return nil
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
      if let venue {
        Text(venue.name)
      }
      if let date = show.date.date {
        Text(date.formatted(.relative(presentation: .numeric)))
      }
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

struct TodayBlurb_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault.previewData

    TodayBlurb(show: vault.music.shows[0])
      .environment(\.vault, vault)

    TodayBlurb(show: vault.music.shows[1])
      .environment(\.vault, vault)

    TodayBlurb(show: vault.music.shows[2])
      .environment(\.vault, vault)
  }
}
