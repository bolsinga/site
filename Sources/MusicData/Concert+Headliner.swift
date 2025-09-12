//
//  Concert+Headliner.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/11/25.
//

import Foundation

extension Concert {
  public var headliner: Artist {
    artists[0]
  }

  public var support: [Artist] {
    Array(artists.dropFirst())
  }
}
