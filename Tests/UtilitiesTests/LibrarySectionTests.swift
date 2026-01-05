//
//  LibrarySectionTests.swift
//
//
//  Created by Greg Bolsinga on 4/7/23.
//

import Testing

@testable import SiteApp

struct LibrarySectionTests {
  @Test func librarySection() {
    #expect("The Chapel".librarySection == .alphabetic("T"))

    #expect("The Chapel".removeCommonInitialPunctuation.librarySection == .alphabetic("C"))

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
}
