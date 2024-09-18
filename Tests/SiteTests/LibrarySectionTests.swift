//
//  LibrarySectionTests.swift
//
//
//  Created by Greg Bolsinga on 4/7/23.
//

import Testing

@testable import Site

struct LibrarySectionTests {
  @Test func librarySection() {
    #expect("The Chapel".librarySection == .alphabetic("C"))

    #expect("33 Degrees".librarySection == .numeric)

    #expect("!!!".librarySection == .punctuation)
  }

  @Test func comparable() {
    #expect(LibrarySection.alphabetic("A") < .alphabetic("Z"))
    #expect(!(LibrarySection.alphabetic("A") > .alphabetic("Z")))

    #expect(LibrarySection.alphabetic("A") < .numeric)
    #expect(!(LibrarySection.alphabetic("A") > .numeric))

    #expect(LibrarySection.alphabetic("A") < .punctuation)
    #expect(!(LibrarySection.alphabetic("A") > .punctuation))

    #expect(LibrarySection.numeric < .punctuation)
    #expect(!(LibrarySection.numeric > .punctuation))
  }

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
