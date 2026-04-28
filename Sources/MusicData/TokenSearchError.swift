//
//  TokenSearchError.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 4/28/26.
//

import Foundation

enum TokenSearchError: LocalizedError {
  case invalidCompareTokenID(String)

  var errorDescription: String? {
    switch self {
    case .invalidCompareTokenID(let string):
      String(localized: "Invalid Token: \(string).")
    }
  }
}
