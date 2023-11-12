//
//  Concert+FormatStyle.swift
//
//
//  Created by Greg Bolsinga on 7/2/23.
//

import Foundation

extension Concert {
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

extension Concert.FormatStyle: Foundation.FormatStyle {
  public func format(_ value: Concert) -> String {
    let venue = value.venue
    switch style {
    case .full:
      let artists = value.artists.map { $0.name }.joined(separator: ", ")
      if let venue {
        return String(
          localized: "\(artists) @ \(venue.name) : \(value.show.date.formatted(.compact))",
          bundle: .module)
      } else {
        return String(
          localized: "\(artists) : \(value.show.date.formatted(.compact))", bundle: .module)
      }
    case .artistsAndVenue:
      let artists = value.artists.map { $0.name }.joined(separator: ", ")
      if let venue {
        return String(localized: "\(artists) @ \(venue.name)", bundle: .module)
      } else {
        return artists
      }
    case .headlinerAndVenue:
      let headliner = value.artists.first?.name ?? ""
      if let venue {
        return String(localized: "\(headliner), \(venue.name)", bundle: .module)
      } else {
        return headliner
      }
    }
  }
}

extension Concert {
  public func formatted(_ style: Concert.FormatStyle.Style = .full) -> String {
    Self.FormatStyle(style).format(self)
  }

  public func formatted<F: Foundation.FormatStyle>(_ style: F) -> F.FormatOutput
  where F.FormatInput == Concert {
    style.format(self)
  }
}

extension FormatStyle where Self == Concert.FormatStyle {
  static func show(style: Concert.FormatStyle.Style = .full) -> Self {
    .init(style)
  }
}
