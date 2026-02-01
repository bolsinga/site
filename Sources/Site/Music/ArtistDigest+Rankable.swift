//
//  ArtistDigest+Rankable.swift
//  site
//
//  Created by Greg Bolsinga on 9/4/25.
//

import Foundation

extension ArtistDigest: Rankable {
  var firstSet: FirstSet { rank.firstSet }
  var showRank: Ranking { rank.showRank }
}
