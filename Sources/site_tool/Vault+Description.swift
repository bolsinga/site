//
//  Vault+Description.swift
//
//
//  Created by Greg Bolsinga on 2/16/23.
//

import Site

extension Vault {
  public func description(for artist: Artist, shows: [Show]) -> String {
    var parts: [String] = []
    parts.append(artist.name)

    var showParts: [String] = []
    for show in shows {
      let concert = self.lookup.concert(from: show)
      showParts.append(concert.formatted(.full))
    }

    parts.append("(\(showParts.joined(separator: "; ")))")

    return parts.joined(separator: ": ")
  }
}
