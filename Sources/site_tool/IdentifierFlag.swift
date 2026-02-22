//
//  IdentifierFlag.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 2/21/26.
//

import ArgumentParser

enum IdentifierFlag: String, EnumerableFlag {
  /// Use BasicIdentifier
  case basic

  /// Use ArchivePathIdentifier
  case archivePath
}
