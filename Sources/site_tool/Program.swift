//
//  Program.swift
//  site
//
//  Created by Greg Bolsinga on 12/6/20.
//

import ArgumentParser
import Foundation
import json

@main
struct Program: AsyncParsableCommand {
  enum URLError: Error {
    case notURLString(String)
  }

  @Argument(
    help:
      "The root URL for the json files.",
    transform: ({
      let url = URL(string: $0)
      guard let url else { throw URLError.notURLString($0) }
      return url
    })
  )
  var rootURL: URL

  func run() async throws {
    let diary = try await Diary.diaryFromURL(rootURL.appending(path: "diary.json"))
    print("\(diary.title) has \(diary.entries.count) entries.")

    let music = try await Music.musicFromURL(rootURL.appending(path: "music.json"))
    print("Albums: \(music.albums.count)")
    print("Artists: \(music.artists.count)")
    print("Relations: \(music.relations.count)")
    print("Shows: \(music.shows.count)")
    print("Songs: \(music.songs.count)")
    print("Venues: \(music.venues.count)")
  }
}
