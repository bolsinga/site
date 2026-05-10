//
//  ArchivePath.swift
//
//
//  Created by Greg Bolsinga on 6/10/23.
//

import Foundation

public enum ArchivePath: Hashable, Sendable {
  public typealias ID = String

  case show(ID)
  case venue(ID)
  case artist(ID)
  case year(Annum)
}
