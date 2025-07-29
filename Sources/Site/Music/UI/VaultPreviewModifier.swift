//
//  VaultPreviewModifier.swift
//  site
//
//  Created by Greg Bolsinga on 7/29/25.
//

import SwiftUI

struct VaultPreviewModifier: PreviewModifier {
  static func makeSharedContext() async throws -> VaultModel {
    let vaultPreviewData: Vault = {
      let artist1 = Artist(id: "ar0", name: "Artist With Longer Name")
      let artist2 = Artist(id: "ar1", name: "Artist 2")

      let venue = Venue(
        id: "v10",
        location: Location(
          city: "San Francisco", web: URL(string: "http://www.amoeba.com"),
          street: "1855 Haight St.",
          state: "CA"), name: "Amoeba Records")

      let show1 = Show(
        artists: [artist1.id, artist2.id], comment: "The show was Great!",
        date: PartialDate(year: 2001, month: 1, day: 15), id: "sh15", venue: venue.id)

      let show2 = Show(
        artists: [artist1.id, artist2.id], comment: "The show was Great!",
        date: PartialDate(year: 2010, month: 1), id: "sh16", venue: venue.id)

      let show3 = Show(
        artists: [artist1.id],
        date: PartialDate(), id: "sh17", venue: venue.id)

      let music = Music(
        albums: [],
        artists: [artist1, artist2],
        relations: [],
        shows: [show1, show2, show3],
        songs: [],
        timestamp: Date.now,
        venues: [venue])

      return Vault(music: music, url: URL(string: "https://www.example.com"))
    }()
    return VaultModel(vaultPreviewData, executeAsynchronousTasks: false)
  }

  func body(content: Content, context: VaultModel) -> some View {
    content
      .environment(context)
  }
}
