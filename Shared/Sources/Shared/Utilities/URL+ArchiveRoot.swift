//
//  URL+ArchiveRoot.swift
//
//
//  Created by Greg Bolsinga on 10/16/26.
//

import Foundation

extension URL {
  /// The one place the app and widget extension both get this from.
  public static let archiveRoot: URL? = URL(string: "https://www.bolsinga.com")
}
