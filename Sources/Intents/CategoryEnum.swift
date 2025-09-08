//
//  CategoryEnum.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 9/7/25.
//

import AppIntents
import Foundation

enum CategoryEnum: String {
  case today
  case shows
  case venues
  case artists
}

extension CategoryEnum: AppEnum {
  public static var typeDisplayRepresentation: TypeDisplayRepresentation {
    TypeDisplayRepresentation(name: "Category")
  }

  public static let caseDisplayRepresentations: [CategoryEnum: DisplayRepresentation] = [
    .today: DisplayRepresentation(title: "Today", image: .init(systemName: "calendar.circle")),
    .shows: DisplayRepresentation(
      title: "Shows", image: .init(systemName: "person.and.background.dotted")),
    .venues: DisplayRepresentation(title: "Venues", image: .init(systemName: "music.note.house")),
    .artists: DisplayRepresentation(title: "Artists", image: .init(systemName: "music.mic")),
  ]
}

extension CategoryEnum {
  var archiveCategory: ArchiveCategory {
    switch self {
    case .today:
      .today
    case .shows:
      .shows
    case .venues:
      .venues
    case .artists:
      .artists
    }
  }
}
