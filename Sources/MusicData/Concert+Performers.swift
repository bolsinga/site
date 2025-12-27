//
//  Concert+Performers.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/11/25.
//

import Foundation

extension Concert {
  public var performers: [String] {
    artists.map { $0.name }
  }
}
