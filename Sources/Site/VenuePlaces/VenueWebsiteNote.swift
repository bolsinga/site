//
//  VenueWebsiteNote.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/7/26.
//

import SwiftUI

/// One thing found about a venue's website.
struct VenueWebsiteNote: Hashable {
  enum Severity: Int, Comparable {
    case good
    case warning
    case problem

    static func < (lhs: Severity, rhs: Severity) -> Bool { lhs.rawValue < rhs.rawValue }

    var color: Color {
      switch self {
      case .good: .green
      case .warning: .orange
      case .problem: .red
      }
    }
  }

  let text: String
  let systemImage: String
  let severity: Severity

  /// What checking the website and Maps found, worst first.
  static func notes(
    web: URL?, name: String, webCheck: WebCheck?, mapsWebsite: URL??
  ) -> [VenueWebsiteNote] {
    var notes = [VenueWebsiteNote]()
    if let web, let webCheck {
      notes += webCheck.notes(for: web, name: name)
    }
    if let mapsWebsite, let maps = mapsWebsite {
      notes.append(mapsNote(maps, web: web, webCheck: webCheck))
    }
    return notes.sorted { $0.severity > $1.severity }
  }

  /// Whether Maps agrees with where the website is.
  private static func mapsNote(_ maps: URL, web: URL?, webCheck: WebCheck?) -> VenueWebsiteNote {
    guard let web else {
      return VenueWebsiteNote(
        text: String(localized: "Maps has a website: \(maps.absoluteString)"),
        systemImage: "map", severity: .warning)
    }
    let final = webCheck?.finalURL(from: web) ?? web
    if WebCheck.isSameSite(maps, web) || WebCheck.isSameSite(maps, final) {
      return VenueWebsiteNote(
        text: String(localized: "Maps has the same website"), systemImage: "map",
        severity: .good)
    }
    return VenueWebsiteNote(
      text: String(localized: "Maps has a different website: \(maps.absoluteString)"),
      systemImage: "map.fill", severity: .warning)
  }
}

extension Array where Element == VenueWebsiteNote {
  /// The worst note, when it is worth calling out.
  var issue: VenueWebsiteNote? {
    first.flatMap { $0.severity > .good ? $0 : nil }
  }
}

extension WebCheck {
  private var isParked: Bool {
    if case .parked = outcome { true } else { false }
  }

  fileprivate func notes(for url: URL, name: String) -> [VenueWebsiteNote] {
    var notes = [VenueWebsiteNote]()
    if isInsecure {
      notes.append(
        VenueWebsiteNote(
          text: String(localized: "Uses http, so its https version was checked"),
          systemImage: "lock.open.fill", severity: .warning))
    }
    switch outcome {
    case .ok:
      notes.append(
        VenueWebsiteNote(
          text: String(localized: "Loads"), systemImage: "checkmark.circle", severity: .good))
    case .redirected(let final):
      notes.append(
        isOtherSite(from: url)
          ? VenueWebsiteNote(
            text: String(localized: "Goes to another site: \(final.absoluteString)"),
            systemImage: "arrow.triangle.turn.up.right.diamond.fill", severity: .problem)
          : VenueWebsiteNote(
            text: String(localized: "Redirects to \(final.absoluteString)"),
            systemImage: "arrow.uturn.right.circle", severity: .warning))
    case .failed(let reason):
      notes.append(
        VenueWebsiteNote(
          text: String(localized: "Doesn't load: \(reason)"), systemImage: "xmark.octagon.fill",
          severity: .problem))
    case .parked(let final):
      notes.append(
        VenueWebsiteNote(
          text: String(localized: "The domain is parked or for sale: \(final.absoluteString)"),
          systemImage: "dollarsign.circle.fill", severity: .problem))
    }
    // A parked page wouldn't mention the venue anyway.
    if hasExpected == false, !isParked {
      notes.append(
        VenueWebsiteNote(
          text: String(localized: "The page doesn't mention “\(name)”"),
          systemImage: "text.magnifyingglass", severity: .warning))
    }
    return notes
  }
}

extension VenueWebsiteNote {
  var label: some View {
    Label(text, systemImage: systemImage)
      .foregroundStyle(severity.color)
  }
}
