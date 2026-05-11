//
//  VaultError.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 5/11/26.
//

import Foundation

public enum VaultError: Error {
  case illegalURL(String)
  case noRootURL(String)
}

extension VaultError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .illegalURL(let urlString):
      return String(localized: "URL (\(urlString)) is not valid.")
    case .noRootURL(let urlString):
      return String(localized: "URL (\(urlString)) cannot create root URL.")
    }
  }
}
