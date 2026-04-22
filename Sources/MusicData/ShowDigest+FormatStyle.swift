//
//  ShowDigest+FormatStyle.swift
//
//
//  Created by Greg Bolsinga on 7/2/23.
//

import Foundation

extension ShowDigest {
  public struct FormatStyle: Codable, Equatable, Hashable {
    public enum Style: Codable, Equatable, Hashable {
      case full  // Headliner, Opener @ Venue on 12/01/2002
      case artistsAndVenue  // Headliner, Opener @ Venue
      case headlinerAndVenue  // Headliner @ Venue
    }

    let style: Style

    public init(_ style: Style = .full) {
      self.style = style
    }

    public func style(_ style: Style) -> Self {
      .init(style)
    }
  }
}

extension ShowDigest.FormatStyle: Foundation.FormatStyle {
  public func format(_ value: ShowDigest) -> String {
    let venue = value.venue
    switch style {
    case .full:
      let artists = value.performers.joined(separator: ", ")
      return String(
        localized: "\(artists) @ \(venue) : \(value.date.formatted(.compact))",
        comment: "full.venue")
    case .artistsAndVenue:
      let artists = value.performers.joined(separator: ", ")
      return String(
        localized: "\(artists) @ \(venue)",
        comment: "artistAndVenue.no.venue")
    case .headlinerAndVenue:
      let headliner = value.performers.first ?? ""
      return String(
        localized: "\(headliner), \(venue)",
        comment: "headlinerAndVenue.no.venue")
    }
  }
}

extension ShowDigest {
  public func formatted(_ style: ShowDigest.FormatStyle.Style = .full) -> String {
    Self.FormatStyle(style).format(self)
  }

  public func formatted<F: Foundation.FormatStyle>(_ style: F) -> F.FormatOutput
  where F.FormatInput == ShowDigest {
    style.format(self)
  }
}

extension FormatStyle where Self == ShowDigest.FormatStyle {
  static func show(style: ShowDigest.FormatStyle.Style = .full) -> Self {
    .init(style)
  }
}
