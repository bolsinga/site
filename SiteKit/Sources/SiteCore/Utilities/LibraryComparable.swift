//
//  LibraryComparable.swift
//
//
//  Created by Greg Bolsinga on 4/12/23.
//

import Foundation

package protocol LibraryComparable {
  var sortname: String? { get }
  var name: String { get }
}

extension LibraryComparable {
  package var librarySortString: String {
    sortname ?? name
  }
}
