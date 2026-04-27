//
//  TokenCompareTests.swift
//
//
//  Created by Greg Bolsinga on 2/26/23.
//

import Testing

@testable import SiteApp

extension String {
  fileprivate var removeCommonInitialPunctuation: String {
    LibraryCompareTokenizer().removeCommonInitialPunctuation(self)
  }
}

struct TokenCompareTests {
  private func libraryCompare(lhs: String, rhs: String) -> Bool {
    lhs.removeCommonInitialPunctuation.tokenCompare(other: rhs.removeCommonInitialPunctuation)
  }

  @Test func stringBasic() {
    #expect(libraryCompare(lhs: "A", rhs: "B"))
    #expect(!libraryCompare(lhs: "B", rhs: "A"))
  }

  @Test func stringThePrefix() {
    #expect(libraryCompare(lhs: "The White Album", rhs: "White Denim"))
    #expect(!libraryCompare(lhs: "White Denim", rhs: "The White Album"))
  }

  @Test func stringAPrefix() {
    // These should compare as false, since removing the prefix matches the other word.
    #expect(!libraryCompare(lhs: "A Cord", rhs: "Cord"))
    #expect(!libraryCompare(lhs: "Cord", rhs: "A Cord"))
  }

  @Test func stringAnPrefix() {
    // These should compare as false, since removing the prefix matches the other word.
    #expect(!libraryCompare(lhs: "An Other", rhs: "Other"))
    #expect(!libraryCompare(lhs: "Other", rhs: "An Other"))
  }

  @Test func prefixThreeWords() {
    // These should compare as false, since removing the prefix matches the other words.
    #expect(!libraryCompare(lhs: "An Other Test", rhs: "Other Test"))
    #expect(!libraryCompare(lhs: "Other Test", rhs: "An Other Test"))
  }

  @Test func stringPartialPrefix() {
    #expect(libraryCompare(lhs: "These", rhs: "They Might"))
    #expect(!libraryCompare(lhs: "They Might", rhs: "These"))

    #expect(libraryCompare(lhs: "Them", rhs: "They Might"))
    #expect(!libraryCompare(lhs: "They Might", rhs: "Them"))
  }

  @Test func stringSmog() {
    #expect(!libraryCompare(lhs: "Smog", rhs: "(Smog)"))
    #expect(!libraryCompare(lhs: "(Smog)", rhs: "Smog"))
  }

  @Test func stringQuotation() {
    #expect(!libraryCompare(lhs: "\"Song Title\"", rhs: "Song Title"))
    #expect(!libraryCompare(lhs: "Song Title", rhs: "\"Song Title\""))
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
