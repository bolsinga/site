//
//  ArtistDigest.swift
//
//
//  Created by Greg Bolsinga on 8/30/23.
//

import Foundation

struct ArtistDigest {
  let artist: Artist
  let url: URL?
  let concerts: [Concert]
  let related: [Artist]
}
