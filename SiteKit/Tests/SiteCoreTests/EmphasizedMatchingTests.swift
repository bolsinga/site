//
//  EmphasizedMatchingTests.swift
//
//
//  Created by Greg Bolsinga on 6/15/24.
//

import Foundation
import Testing

@testable import SiteCore

struct EmphasizedMatchingTests {
  /// The text of the name, and the pieces of it that are bold.
  private func emphasized(_ name: String, matching fragment: String) -> (
    text: String, bold: [String]
  ) {
    let result = name.emphasizedAttributed(matching: fragment)
    let bold = result.runs.filter { $0.inlinePresentationIntent == .stronglyEmphasized }
      .map { String(result[$0.range].characters) }
    return (String(result.characters), bold)
  }

  @Test func justOneLetterMatchingWithOneMatch() {
    #expect(emphasized("Gre", matching: "G") == ("Gre", ["G"]))
    #expect(emphasized("Gre", matching: "g") == ("Gre", ["G"]))
  }

  @Test func justOneLetterMatchinWithMultipleMatches() {
    #expect(emphasized("Greg", matching: "G") == ("Greg", ["G"]))
    #expect(emphasized("Greg", matching: "g") == ("Greg", ["G"]))
  }

  @Test func twoLettersMatchingWithOneMatch() {
    #expect(emphasized("Greg", matching: "Gr") == ("Greg", ["Gr"]))
    #expect(emphasized("Greg", matching: "gr") == ("Greg", ["Gr"]))
  }

  @Test func twoLettersMatchingWithMultipleMatches() {
    #expect(emphasized("Gregr", matching: "Gr") == ("Gregr", ["Gr"]))
    #expect(emphasized("GregR", matching: "gr") == ("GregR", ["Gr"]))
  }

  @Test func noMatches() {
    #expect(emphasized("Greg", matching: "o") == ("Greg", []))
  }

  @Test func emptyStringMatches() {
    #expect(emphasized("Greg", matching: "") == ("Greg", []))
  }

  @Test func spacesAtTheEndsOfAMatchStayPlain() {
    #expect(emphasized("Greg Bolsinga", matching: "G") == ("Greg Bolsinga", ["G"]))
    #expect(emphasized("Greg Bolsinga", matching: "G ") == ("Greg Bolsinga", ["g"]))
    #expect(emphasized("Greg Bolsinga", matching: "G B") == ("Greg Bolsinga", ["g B"]))
    #expect(emphasized("Greg Bolsinga", matching: " B") == ("Greg Bolsinga", ["B"]))
    #expect(emphasized("Greg Bolsinga", matching: "B") == ("Greg Bolsinga", ["B"]))
    #expect(emphasized("Greg Bolsinga", matching: " ") == ("Greg Bolsinga", []))
  }

  @Test func diacriticsAreIgnoredLikeTheFilter() {
    #expect(emphasized("Café", matching: "cafe") == ("Café", ["Café"]))
    #expect(emphasized("Cafe", matching: "café") == ("Cafe", ["Cafe"]))
    #expect(emphasized("Mötley Crüe", matching: "crue") == ("Mötley Crüe", ["Crüe"]))
    #expect(emphasized("Sigur Rós", matching: "ROS") == ("Sigur Rós", ["Rós"]))
    #expect(
      emphasized("Cafe\u{0301} Tacvba", matching: "cafe tac")
        == ("Cafe\u{0301} Tacvba", ["Cafe\u{0301} Tac"]))
    #expect(emphasized("Café", matching: "é") == ("Café", ["é"]))
  }

  @Test func emphasisAndTheFilterAgreeOnWhatMatches() {
    let names = [
      "Café Tacvba", "Mötley Crüe", "Sigur Rós", "Björk", "Beyoncé", "Greg Bolsinga",
      "ＡＢＣ Band", "ｶﾀｶﾅ カタカナ",
    ]
    let fragments = [
      "cafe", "café", "crue", "ros", "bjork", "beyonce", "bolsinga", "greg b", "abc", "ＡＢＣ",
      "ａｂｃ", "カタ", "ｶﾀ", "zzz",
    ]
    for name in names {
      for fragment in fragments {
        #expect(
          emphasized(name, matching: fragment).bold.isEmpty
            == !name.localizedStandardContains(fragment), "\(name) / \(fragment)")
      }
    }
  }

  @Test func charactersMarkdownUsesStayInTheName() {
    #expect(emphasized("*NSYNC", matching: "ns") == ("*NSYNC", ["NS"]))
    #expect(emphasized("*NSYNC", matching: "*") == ("*NSYNC", ["*"]))
    #expect(emphasized("M_U_S_I_C", matching: "u_s") == ("M_U_S_I_C", ["U_S"]))
    #expect(emphasized("__init__", matching: "init") == ("__init__", ["init"]))
    #expect(emphasized("[Brackets](here)", matching: "ets") == ("[Brackets](here)", ["ets"]))
    #expect(emphasized("The `Code` Band", matching: "code") == ("The `Code` Band", ["Code"]))
    #expect(emphasized("Back\\slash", matching: "slash") == ("Back\\slash", ["slash"]))
  }
}
