//
//  ArchivePath.swift
//
//
//  Created by Greg Bolsinga on 6/10/23.
//

import Foundation

public enum ArchivePath: Hashable, Sendable {
  case show(String)
  case venue(String)
  case artist(String)
  case year(Annum)
}
