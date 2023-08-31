//
//  Vault+AnnumDigest.swift
//
//
//  Created by Greg Bolsinga on 8/31/23.
//

import Foundation

extension Vault {
  func digest(for annum: Annum) -> AnnumDigest {
    return AnnumDigest(
      annum: annum, url: createURL(for: annum.archivePath), concerts: concerts(during: annum))
  }
}
