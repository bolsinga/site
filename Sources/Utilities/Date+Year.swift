//
//  Date+Year.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 1/4/26.
//

import Foundation

private let yearComponents = Set([Calendar.Component.year])

extension Date {
  var year: Int? {
    let comps = Calendar.autoupdatingCurrent.dateComponents(yearComponents, from: self)
    return comps.year
  }
}
