//
//  main.swift
//  site
//
//  Created by Greg Bolsinga on 12/6/20.
//

import Foundation
import json

let diary = try Diary.diaryFromPath(CommandLine.arguments[1])
print("\(diary.title) has \(diary.entries.count) entries.")

let music = try Music.musicFromPath(CommandLine.arguments[2])
print("Albums: \(music.albums.count)")
print("Artists: \(music.artists.count)")
print("Relations: \(music.relations.count)")
print("Shows: \(music.shows.count)")
print("Songs: \(music.songs.count)")
print("Venues: \(music.venues.count)")
