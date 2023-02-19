//
//  Program.swift
//  site
//
//  Created by Greg Bolsinga on 12/6/20.
//

import ArgumentParser
import Diary
import Foundation
import LoadingState
import Music

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
    var diaryLoadingState: LoadingState<Diary> = .idle
    await diaryLoadingState.load(url: rootURL.appending(path: "diary.json"))
    if let diary = diaryLoadingState.value {
      print("\(diary.title) has \(diary.entries.count) entries.")
    }

    var musicLoadingState: LoadingState<Music> = .idle
    await musicLoadingState.load(url: rootURL.appending(path: "music.json"))
    if let music = musicLoadingState.value {
      print("Albums: \(music.albums.count)")
      print("Artists: \(music.artists.count)")
      print("Relations: \(music.relations.count)")
      print("Shows: \(music.shows.count)")
      print("Songs: \(music.songs.count)")
      print("Venues: \(music.venues.count)")

      for show in music.shows.sorted(by: <).reversed() {
        print(music.description(for: show))
      }
    }
  }
}
