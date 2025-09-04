//
//  LibrarySectionFormatterTests.swift
//
//
//  Created by Greg Bolsinga on 4/7/23.
//

import Testing
import Utilities

@testable import Site

struct LibrarySectionFormatterTests {
  @Test func format() {
    #expect(LibrarySection.alphabetic("A").formatted() == "A")
    #expect(LibrarySection.numeric.formatted() == "Numeric")
    #expect(LibrarySection.punctuation.formatted() == "Punctuation")

    #expect(LibrarySection.alphabetic("A").formatted(.long) == "A")
    #expect(LibrarySection.numeric.formatted(.long) == "Numeric")
    #expect(LibrarySection.punctuation.formatted(.long) == "Punctuation")

    #expect(LibrarySection.alphabetic("A").formatted(.short) == "A")
    #expect(LibrarySection.numeric.formatted(.short) == "#")
    #expect(LibrarySection.punctuation.formatted(.short) == "!")
  }
}
