//
//  Vault+LibrarySectioner.swift
//
//
//  Created by Greg Bolsinga on 5/24/23.
//

import Foundation

extension Vault {
  func sectioner(for algorithm: LibrarySectionAlgorithm) -> LibrarySectioner {
    switch algorithm {
    case .alphabetical:
      return sectioner
    case .showCount:
      return rankSectioner
    case .showYearRange:
      return showSpanSectioner
    case .artistVenueRank:
      return artistVenueRankSectioner
    }
  }
}
