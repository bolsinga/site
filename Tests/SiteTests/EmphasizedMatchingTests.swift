//
//  EmphasizedMatchingTests.swift
//
//
//  Created by Greg Bolsinga on 6/15/24.
//

import Testing

@testable import SiteApp

struct EmphasizedMatchingTests {
  @Test func justOneLetterMatchingWithOneMatch() {
    #expect("Gre".emphasized(matching: "G") == "**G**re")
    #expect("Gre".emphasized(matching: "g") == "**G**re")
  }

  @Test func justOneLetterMatchinWithMultipleMatches() {
    #expect("Greg".emphasized(matching: "G") == "**G**reg")
    #expect("Greg".emphasized(matching: "g") == "**G**reg")
  }

  @Test func twoLettersMatchingWithOneMatch() {
    #expect("Greg".emphasized(matching: "Gr") == "**Gr**eg")
    #expect("Greg".emphasized(matching: "gr") == "**Gr**eg")
  }

  @Test func twoLettersMatchingWithMultipleMatches() {
    #expect("Gregr".emphasized(matching: "Gr") == "**Gr**egr")
    #expect("GregR".emphasized(matching: "gr") == "**Gr**egR")
  }

  @Test func noMatches() {
    #expect("Greg".emphasized(matching: "o") == "Greg")
  }

  @Test func emptyStringMatches() {
    #expect("Greg".emphasized(matching: "") == "Greg")
  }

  @Test func emphasizeRespectingSpacesQuirks() {
    #expect("A".emphasizedRespectingSpacesQuirks == "**A**")
    #expect(" A".emphasizedRespectingSpacesQuirks == " **A**")
    #expect("A ".emphasizedRespectingSpacesQuirks == "**A** ")
    #expect(" A ".emphasizedRespectingSpacesQuirks == " **A** ")
  }

  @Test func spaceStringMatches() {
    #expect("Greg Bolsinga".emphasized(matching: "G") == "**G**reg Bolsinga")
    #expect("Greg Bolsinga".emphasized(matching: "G ") == "Gre**g** Bolsinga")
    #expect("Greg Bolsinga".emphasized(matching: "G B") == "Gre**g B**olsinga")
    #expect("Greg Bolsinga".emphasized(matching: " B") == "Greg **B**olsinga")
    #expect("Greg Bolsinga".emphasized(matching: "B") == "Greg **B**olsinga")
  }
}
