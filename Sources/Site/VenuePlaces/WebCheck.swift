//
//  WebCheck.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/7/26.
//

import Foundation

/// What loading a URL found.
struct WebCheck: Codable, Equatable, Sendable {
  enum Outcome: Codable, Equatable, Sendable {
    case ok
    /// The site sent the request on to another URL.
    case redirected(URL)
    /// The site didn't load, with why.
    case failed(String)
    /// The page, at the URL it ended up at, says its domain is parked or for sale.
    case parked(URL)
  }

  let outcome: Outcome
  /// The URL was http, which the app can't load, so its https version was checked.
  var isInsecure = false
  /// The page's title, when it loaded.
  var title: String?
  /// Whether the page has what was expected, when something was and the page loaded.
  var hasExpected: Bool?

  /// Requests in flight at once during a batch.
  static var concurrentChecks: Int { 8 }

  /// How much of a page is read; titles and names are near the top.
  private static var pageLimit: Int { 256 * 1024 }

  private static let session: URLSession = {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.timeoutIntervalForRequest = 20
    return URLSession(configuration: configuration)
  }()

  /// The https version of an http URL, or the URL itself.
  static func loadable(_ url: URL) -> URL {
    guard url.scheme?.lowercased() == "http",
      var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
    else { return url }
    components.scheme = "https"
    return components.url ?? url
  }

  /// Pages that redirect with a meta refresh that are followed.
  private static var refreshLimit: Int { 3 }

  /// Loads the URL, following redirects, and reads the top of the page.
  static func check(_ url: URL, expects: (@Sendable (String) -> Bool)? = nil) async -> WebCheck {
    let loadable = loadable(url)
    do {
      var (response, page) = try await load(loadable)
      for _ in 0..<refreshLimit {
        guard let refresh = refreshURL(in: page, at: response.url ?? loadable) else { break }
        (response, page) = try await load(refresh)
      }
      var check = WebCheck(url: loadable, response: response, page: page, expects: expects)
      check.isInsecure = loadable != url
      return check
    } catch {
      return WebCheck(outcome: .failed(error.localizedDescription), isInsecure: loadable != url)
    }
  }

  private static func load(_ url: URL) async throws -> (URLResponse, String) {
    let (bytes, response) = try await session.bytes(from: url)
    var data = Data()
    for try await byte in bytes {
      data.append(byte)
      if data.count >= pageLimit { break }
    }
    return (response, String(decoding: data, as: UTF8.self))
  }

  /// Where a `<meta http-equiv="refresh">` sends the page, resolved against where it is.
  static func refreshURL(in page: String, at url: URL) -> URL? {
    guard
      let match = page.firstMatch(
        of: /(?i)<meta[^>]*http-equiv=["']?refresh["']?[^>]*content=["']\s*\d*\s*;?\s*url\s*=\s*['"]?([^"'>\s]+)/
      )
    else { return nil }
    return URL(string: String(match.1), relativeTo: url)?.absoluteURL
  }

  init(outcome: Outcome, isInsecure: Bool = false, title: String? = nil, hasExpected: Bool? = nil) {
    self.outcome = outcome
    self.isInsecure = isInsecure
    self.title = title
    self.hasExpected = hasExpected
  }

  init(
    url: URL, response: URLResponse, page: String = "",
    expects: (@Sendable (String) -> Bool)? = nil
  ) {
    let final = response.url ?? url
    if let http = response as? HTTPURLResponse, !(200..<400).contains(http.statusCode) {
      self.init(
        outcome: .failed(
          "\(http.statusCode) \(HTTPURLResponse.localizedString(forStatusCode: http.statusCode))"))
      return
    }
    let text = Self.text(of: page)
    let outcome: Outcome =
      if Self.isParked(host: final.host(), text: text) {
        .parked(final)
      } else if Self.normalized(final) != Self.normalized(url) {
        .redirected(final)
      } else {
        .ok
      }
    self.init(outcome: outcome, title: Self.title(of: page), hasExpected: expects?(text))
  }

  var isIssue: Bool { outcome != .ok || isInsecure || hasExpected == false }

  /// Whether a redirect leaves the site, which may mean what it was for is gone.
  func isOtherSite(from url: URL) -> Bool {
    switch outcome {
    case .redirected(let final), .parked(let final): !Self.isSameSite(final, url)
    case .ok, .failed: false
    }
  }

  /// Where loading the URL ended up.
  func finalURL(from url: URL) -> URL {
    switch outcome {
    case .redirected(let final), .parked(let final): final
    case .ok, .failed: Self.loadable(url)
    }
  }

  /// The same host, ignoring case and a leading "www.".
  static func isSameSite(_ lhs: URL, _ rhs: URL) -> Bool {
    site(of: lhs) == site(of: rhs)
  }

  private static func site(of url: URL) -> String? {
    guard let host = url.host()?.lowercased() else { return nil }
    return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
  }

  /// The URL as a string, with an empty path as "/", since loading one adds it.
  private static func normalized(_ url: URL) -> String {
    guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
      return url.absoluteString
    }
    if components.path.isEmpty { components.path = "/" }
    return components.string ?? url.absoluteString
  }

  /// Domain marketplaces and parking services that pages for sale end up at.
  private static let parkingHosts = [
    "sedo.com", "sedoparking.com", "afternic.com", "dan.com", "hugedomains.com", "bodis.com",
    "parkingcrew.net", "above.com", "undeveloped.com", "porkbun.com", "atom.com",
  ]

  private static let parkingPhrases = [
    "domain is for sale", "domain may be for sale", "buy this domain", "domain for sale",
    "this domain has been registered", "parked free", "domain parking",
    "make an offer on this domain", "inquire about this domain",
  ]

  static func isParked(host: String?, text: String) -> Bool {
    if let host = host?.lowercased(),
      parkingHosts.contains(where: { host == $0 || host.hasSuffix("." + $0) })
    {
      return true
    }
    let text = text.lowercased()
    return parkingPhrases.contains { text.contains($0) }
  }

  /// The page with the entities that split words replaced.
  private static func text(of page: String) -> String {
    page
      .replacing("&nbsp;", with: " ")
      .replacing("&amp;", with: "&")
      .replacing("&#39;", with: "'")
      .replacing("&#039;", with: "'")
      .replacing("&rsquo;", with: "’")
      .replacing("&quot;", with: "\"")
      .replacing("&gt;", with: ">")
      .replacing("&lt;", with: "<")
  }

  static func title(of page: String) -> String? {
    guard let match = page.firstMatch(of: /(?is)<title[^>]*>(.*?)<\/title>/) else { return nil }
    let title = text(of: String(match.1)).trimmingCharacters(in: .whitespacesAndNewlines)
    return title.isEmpty ? nil : title
  }
}
