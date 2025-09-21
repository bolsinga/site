//
//  AnnumDigest.swift
//
//
//  Created by Greg Bolsinga on 8/31/23.
//

import Foundation

public struct AnnumDigest: Sendable {
  public let annum: Annum
  public let url: URL?
  public let concerts: [Concert]

  public init(annum: Annum, url: URL? = nil, concerts: [Concert]) {
    self.annum = annum
    self.url = url
    self.concerts = concerts
  }
}
