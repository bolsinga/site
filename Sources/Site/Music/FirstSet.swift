//
//  FirstSet.swift
//
//
//  Created by Greg Bolsinga on 6/5/23.
//

import Foundation

struct FirstSet {
  let rank: Rank
  let date: PartialDate

  static var empty: FirstSet {
    FirstSet(rank: .unknown, date: PartialDate())
  }
}
