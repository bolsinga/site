//
//  Music+Relations.swift
//
//
//  Created by Greg Bolsinga on 3/25/23.
//

import Foundation

extension Music {
  func related(_ item: Venue) -> [Venue] {
    return venues.filter {
      relations.filter { $0.members.contains(item.id) }.flatMap { $0.members }.contains($0.id)
    }.filter { $0.id != item.id }
  }

  func related(_ item: Artist) -> [Artist] {
    return artists.filter {
      relations.filter { $0.members.contains(item.id) }.flatMap { $0.members }.contains($0.id)
    }.filter { $0.id != item.id }
  }
}
