//
//  LibraryComparable.swift
//
//
//  Created by Greg Bolsinga on 4/12/23.
//

import Foundation

public protocol LibraryComparable: Identifiable {
  var sortname: String? { get }
  var name: String { get }
}

extension LibraryComparable {
  var librarySortString: String {
    sortname ?? name
  }

  var librarySortToken: String {
    librarySortString.removeCommonInitialPunctuation
  }
}
