//
//  TopDate.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/26/25.
//

import Foundation

extension Array where Element == (Int, (Date, Int)) {
  var topDate: Date {
    map { $0.1 }.sorted { $0.1 < $1.1 }.reversed()[0].0
  }
}
