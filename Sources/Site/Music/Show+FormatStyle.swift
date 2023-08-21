//
//  Show+FormatStyle.swift
//
//
//  Created by Greg Bolsinga on 7/2/23.
//

import Foundation

extension Show {
  public struct FormatStyle: Codable, Equatable, Hashable {
    public enum Style: Codable, Equatable, Hashable {
      case full  // Headliner, Opener @ Venue on 12/01/2002
      case artistsAndVenue  // Headliner, Opener @ Venue
      case headlinerAndVenue  // Headliner @ Venue
    }

    let style: Style

    // This is Optional since this must conform to decodable (and Optional types are OK).
    //  If it is non-Optional, then Decoder init(from:) is required, which would mean it would have
    //  to create a Lookup, which is non-trivial.
    var lookup: Lookup?

    // Make this private so that in practice lookup is never nil
    private init(style: Style, lookup: Lookup?) {
      self.style = style
      self.lookup = lookup
    }

    public init(_ style: Style = .full, lookup: Lookup) {
      self.init(style: style, lookup: lookup)
    }

    public func style(_ style: Style, lookup: Lookup) -> Self {
      .init(style, lookup: lookup)
    }

    // Needed to ignore Lookup for Codable
    private enum CodingKeys: String, CodingKey {
      case style
    }

    // Needed to ignore Lookup for Equatable
    public static func == (lhs: Show.FormatStyle, rhs: Show.FormatStyle) -> Bool {
      lhs.style == rhs.style
    }

    // Needed to ignore Lookup for Hashable
    public func hash(into hasher: inout Hasher) {
      hasher.combine(style)
    }
  }
}

extension Show.FormatStyle: Foundation.FormatStyle {
  public func format(_ value: Show) -> String {
    guard let lookup else {
      fatalError("Show.FormatStyle requires Lookup")
    }
    let venue = lookup.venueForShow(value)
    switch style {
    case .full:
      let artists = lookup.artistsForShow(value).map { $0.name }.joined(separator: ", ")
      if let venue {
        return String(
          localized: "\(artists) @ \(venue.name) : \(value.date.formatted(.compact))",
          bundle: .module, comment: "Show.FormatStyle.full artists - venue - date")
      } else {
        return String(
          localized: "\(artists) : \(value.date.formatted(.compact))", bundle: .module,
          comment: "Show.FormatStyle.full artists - date - No Venue")
      }
    case .artistsAndVenue:
      let artists = lookup.artistsForShow(value).map { $0.name }.joined(separator: ", ")
      if let venue {
        return String(
          localized: "\(artists) @ \(venue.name)", bundle: .module,
          comment: "Show.FormatStyle.artistsAndVenue artists - venue")
      } else {
        return artists
      }
    case .headlinerAndVenue:
      let headliner = lookup.artistsForShow(value).first?.name ?? ""
      if let venue {
        return String(
          localized: "\(headliner), \(venue.name)", bundle: .module,
          comment: "Show.FormatStyle.headlinerAndVenue artist headliner - venue")
      } else {
        return headliner
      }
    }
  }
}

extension Show {
  public func formatted(_ style: Show.FormatStyle.Style = .full, lookup: Lookup) -> String {
    Self.FormatStyle(style, lookup: lookup).format(self)
  }

  public func formatted<F: Foundation.FormatStyle>(_ style: F) -> F.FormatOutput
  where F.FormatInput == Show {
    style.format(self)
  }
}

extension FormatStyle where Self == Show.FormatStyle {
  static func show(style: Show.FormatStyle.Style = .full, lookup: Lookup) -> Self {
    .init(style, lookup: lookup)
  }
}
