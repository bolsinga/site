//
//  LibraryComparatorTests.swift
//
//
//  Created by Greg Bolsinga on 2/26/23.
//

import Testing

@testable import SiteApp

extension LibraryComparator {
  func libraryCompare(lhs: String, rhs: String) -> Bool {
    libraryCompareTokens(
      lhs: lhs.removeCommonInitialPunctuation, rhs: rhs.removeCommonInitialPunctuation)
  }
}

extension String {
  fileprivate var removeCommonInitialPunctuation: String {
    LibraryCompareTokenizer().removeCommonInitialPunctuation(self)
  }
}

struct LibraryComparatorTests {
  let comparator = LibraryComparator<String>()

  @Test func stringBasic() {
    #expect(comparator.libraryCompare(lhs: "A", rhs: "B"))
    #expect(!comparator.libraryCompare(lhs: "B", rhs: "A"))
  }

  @Test func stringThePrefix() {
    #expect(comparator.libraryCompare(lhs: "The White Album", rhs: "White Denim"))
    #expect(!comparator.libraryCompare(lhs: "White Denim", rhs: "The White Album"))
  }

  @Test func stringAPrefix() {
    // These should compare as false, since removing the prefix matches the other word.
    #expect(!comparator.libraryCompare(lhs: "A Cord", rhs: "Cord"))
    #expect(!comparator.libraryCompare(lhs: "Cord", rhs: "A Cord"))
  }

  @Test func stringAnPrefix() {
    // These should compare as false, since removing the prefix matches the other word.
    #expect(!comparator.libraryCompare(lhs: "An Other", rhs: "Other"))
    #expect(!comparator.libraryCompare(lhs: "Other", rhs: "An Other"))
  }

  @Test func prefixThreeWords() {
    // These should compare as false, since removing the prefix matches the other words.
    #expect(!comparator.libraryCompare(lhs: "An Other Test", rhs: "Other Test"))
    #expect(!comparator.libraryCompare(lhs: "Other Test", rhs: "An Other Test"))
  }

  @Test func stringPartialPrefix() {
    #expect(comparator.libraryCompare(lhs: "These", rhs: "They Might"))
    #expect(!comparator.libraryCompare(lhs: "They Might", rhs: "These"))

    #expect(comparator.libraryCompare(lhs: "Them", rhs: "They Might"))
    #expect(!comparator.libraryCompare(lhs: "They Might", rhs: "Them"))
  }

  @Test func stringSmog() {
    #expect(!comparator.libraryCompare(lhs: "Smog", rhs: "(Smog)"))
    #expect(!comparator.libraryCompare(lhs: "(Smog)", rhs: "Smog"))
  }

  @Test func stringQuotation() {
    #expect(!comparator.libraryCompare(lhs: "\"Song Title\"", rhs: "Song Title"))
    #expect(!comparator.libraryCompare(lhs: "Song Title", rhs: "\"Song Title\""))
  }

  @Test func aPrefixChomp() {
    #expect("A Cord Down".removeCommonInitialPunctuation == "Cord Down")
    #expect("A Cord".removeCommonInitialPunctuation == "Cord")
  }

  @Test func anPrefixChomp() {
    #expect("An Other Word".removeCommonInitialPunctuation == "Other Word")
    #expect("An Other".removeCommonInitialPunctuation == "Other")
  }

  @Test func thePrefixChomp() {
    #expect("The White Album".removeCommonInitialPunctuation == "White Album")
    #expect("The White".removeCommonInitialPunctuation == "White")
  }

  @Test func prefixLowercaseTwoWords() {
    #expect("the White".removeCommonInitialPunctuation == "White")
  }

  @Test func smogChomp() {
    #expect("(Smog)".removeCommonInitialPunctuation == "Smog")
  }

  @Test func multipleSmogChomp() {
    #expect("(Smog Haze)".removeCommonInitialPunctuation == "Smog Haze")
  }

  @Test func trailOfDeadChomp() {
    #expect(
      "...And You Will Know Us By The Trail Of Dead".removeCommonInitialPunctuation
        == "And You Will Know Us By The Trail Of Dead")
  }

  @Test func hardDaysChomp() {
    #expect("A Hard Day's Night".removeCommonInitialPunctuation == "Hard Day's Night")
  }

  @Test func oldEnoughChomp() {
    #expect(
      "Old Enough To Know Better - 15 Years Of Merge Records (Disc 1)"
        .removeCommonInitialPunctuation
        == "Old Enough To Know Better - 15 Years Of Merge Records (Disc 1)")
  }

  @Test func quotedChomp() {
    #expect("\"Song Title\"".removeCommonInitialPunctuation == "Song Title")
    #expect("\"Longer Song Title\"".removeCommonInitialPunctuation == "Longer Song Title")
  }
}
