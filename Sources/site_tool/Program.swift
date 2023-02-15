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
struct Program: ParsableCommand {
  @Argument(
    help:
      "The path at which find diary.json."
  )
  var diaryPath: String

  @Argument(
    help:
      "The path at which find music.json."
  )
  var musicPath: String

  func run() throws {
    let diary = try Diary.diaryFromPath(diaryPath)
    print("\(diary.title) has \(diary.entries.count) entries.")

    let music = try Music.musicFromPath(musicPath)
    print("Albums: \(music.albums.count)")
    print("Artists: \(music.artists.count)")
    print("Relations: \(music.relations.count)")
    print("Shows: \(music.shows.count)")
    print("Songs: \(music.songs.count)")
    print("Venues: \(music.venues.count)")
  }
}
