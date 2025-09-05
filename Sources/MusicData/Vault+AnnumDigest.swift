//
//  Vault+AnnumDigest.swift
//
//
//  Created by Greg Bolsinga on 8/31/23.
//

import Foundation

extension Vault {
  public func digest(for annum: Annum) -> AnnumDigest {
    AnnumDigest(
      annum: annum, url: annum.archivePath.url(using: rootURL), concerts: concerts(during: annum))
  }
}
