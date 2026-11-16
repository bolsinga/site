//
//  WebCheckTests.swift
//
//
//  Created by Greg Bolsinga on 11/7/26.
//

import Foundation
import Testing

@testable import SiteApp

struct WebCheckTests {
  let url = URL(string: "https://www.example.com")!

  private func response(_ status: Int, at final: URL? = nil) -> HTTPURLResponse {
    HTTPURLResponse(url: final ?? url, statusCode: status, httpVersion: nil, headerFields: nil)!
  }

  @Test func loads() {
    #expect(WebCheck(url: url, response: response(200)).outcome == .ok)
  }

  @Test func addedSlashIsNotARedirect() {
    let check = WebCheck(
      url: url, response: response(200, at: URL(string: "https://www.example.com/")!))
    #expect(check.outcome == .ok)
  }

  @Test func redirects() {
    let final = URL(string: "https://www.example.com/home")!
    let check = WebCheck(url: url, response: response(200, at: final))
    #expect(check.outcome == .redirected(final))
    #expect(check.isIssue)
    #expect(!check.isOtherSite(from: url))
  }

  @Test func redirectsWithoutWWW() {
    let check = WebCheck(
      url: url, response: response(200, at: URL(string: "https://example.com/")!))
    #expect(!check.isOtherSite(from: url))
  }

  @Test func redirectsToAnotherSite() {
    let check = WebCheck(
      url: url, response: response(200, at: URL(string: "https://other.example.net")!))
    #expect(check.isOtherSite(from: url))
  }

  @Test func loadsHTTPAsHTTPS() {
    #expect(WebCheck.loadable(URL(string: "http://www.example.com")!) == url)
    let secure = URL(string: "https://www.example.com/a?b=c")!
    #expect(WebCheck.loadable(secure) == secure)
  }

  @Test func failsOnErrorStatus() {
    guard case .failed(let reason) = WebCheck(url: url, response: response(404)).outcome else {
      Issue.record("not failed")
      return
    }
    #expect(reason.hasPrefix("404"))
  }

  @Test func parkedByPage() {
    let check = WebCheck(
      url: url, response: response(200),
      page: "<html><body><h1>This domain is for sale!</h1></body></html>")
    #expect(check.outcome == .parked(url))
    #expect(check.isIssue)
  }

  @Test func parkedByHost() {
    let final = URL(string: "https://www.hugedomains.com/domain_profile.cfm?d=example.com")!
    let check = WebCheck(url: url, response: response(200, at: final))
    #expect(check.outcome == .parked(final))
    #expect(check.isOtherSite(from: url))
  }

  @Test func readsTitle() {
    #expect(
      WebCheck.title(of: "<head><TITLE lang=\"en\">\n Bottom of the Hill &amp; Bar </TITLE>")
        == "Bottom of the Hill & Bar")
    #expect(WebCheck.title(of: "<title></title>") == nil)
  }

  @Test func readsRefresh() {
    let page = "<meta http-equiv=\"refresh\" content=\"0; URL=/calendar.html\">"
    #expect(
      WebCheck.refreshURL(in: page, at: url)?.absoluteString
        == "https://www.example.com/calendar.html")
    #expect(
      WebCheck.refreshURL(
        in: "<META HTTP-EQUIV=Refresh CONTENT='5;url=https://other.example.net/'>", at: url)
        == URL(string: "https://other.example.net/"))
    #expect(WebCheck.refreshURL(in: "<meta charset=\"UTF-8\">", at: url) == nil)
  }

  @Test func mentionsName() async {
    let page = "<title>Bottom&nbsp;of&nbsp;the&nbsp;Hill | San Francisco</title>"
    let check = WebCheck(url: url, response: response(200), page: page) {
      AutoMatch.text($0, mentions: "The Bottom of the Hill")
    }
    #expect(check.hasExpected == true)
    #expect(!check.isIssue)
  }

  @Test func doesNotMentionName() {
    let check = WebCheck(url: url, response: response(200), page: "<title>Welcome</title>") {
      AutoMatch.text($0, mentions: "Bottom of the Hill")
    }
    #expect(check.hasExpected == false)
    #expect(check.isIssue)
  }

  @Test func nameWithinTextNotTextWithinName() {
    #expect(!AutoMatch.text("Hill", mentions: "Bottom of the Hill"))
    #expect(AutoMatch.text("Slims & more", mentions: "Slim's"))
  }
}

struct VenueWebsiteNoteTests {
  let web = URL(string: "http://www.example.com")!
  let ok = WebCheck(outcome: .ok)

  @Test func mapsSameSite() {
    let notes = VenueWebsiteNote.notes(
      web: web, name: "n", webCheck: ok, mapsWebsite: URL(string: "https://example.com/")!)
    #expect(notes.issue == nil)
  }

  @Test func mapsSameSiteAsRedirect() {
    let moved = WebCheck(outcome: .redirected(URL(string: "https://new.example.org")!))
    let notes = VenueWebsiteNote.notes(
      web: web, name: "n", webCheck: moved, mapsWebsite: URL(string: "https://new.example.org")!)
    #expect(!notes.contains { $0.text.hasPrefix("Maps has a different") })
  }

  @Test func mapsDifferentSite() {
    let notes = VenueWebsiteNote.notes(
      web: web, name: "n", webCheck: ok, mapsWebsite: URL(string: "https://other.example.org")!)
    #expect(notes.issue?.severity == .warning)
  }

  @Test func mapsHasNoWebsite() {
    let notes = VenueWebsiteNote.notes(web: web, name: "n", webCheck: ok, mapsWebsite: .some(nil))
    #expect(notes.issue == nil)
  }

  @Test func worstFirst() {
    let check = WebCheck(outcome: .failed("gone"), isInsecure: true)
    let notes = VenueWebsiteNote.notes(web: web, name: "n", webCheck: check, mapsWebsite: nil)
    #expect(notes.map(\.severity) == [.problem, .warning])
  }

  @Test func parkedDoesNotAlsoNoteMissingName() {
    let check = WebCheck(outcome: .parked(web), hasExpected: false)
    let notes = VenueWebsiteNote.notes(web: web, name: "n", webCheck: check, mapsWebsite: nil)
    #expect(notes.count == 1)
  }

  @Test(arguments: [
    WebCheck(outcome: .ok),
    WebCheck(outcome: .redirected(URL(string: "https://example.com/new")!), isInsecure: true),
    WebCheck(outcome: .failed("404 not found")),
    WebCheck(
      outcome: .parked(URL(string: "https://sedo.com")!), title: "For sale", hasExpected: false),
  ])
  func savedCheckRoundTrips(check: WebCheck) throws {
    let saved = VenueWebCheck(
      url: URL(string: "https://example.com")!, name: "Venue", check: check,
      checked: Date(timeIntervalSinceReferenceDate: 800_000_000))
    let data = try JSONEncoder().encode(saved)
    #expect(try JSONDecoder().decode(VenueWebCheck.self, from: data) == saved)
  }

  @Test func venueCheckKeepsMapsWebsite() throws {
    let check = VenueCheck(
      identifier: "I1", verification: .verified, mapsWebsite: URL(string: "https://example.com"))
    let data = try JSONEncoder().encode(check)
    #expect(try JSONDecoder().decode(VenueCheck.self, from: data) == check)
  }

  @Test func venueCheckSavedWithoutMapsWebsiteIsRead() throws {
    let data = Data(#"{"identifier":"I1","verification":{"verified":{}}}"#.utf8)
    #expect(try JSONDecoder().decode(VenueCheck.self, from: data).mapsWebsite == nil)
  }
}
