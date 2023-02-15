//
//  main.swift
//  site
//
//  Created by Greg Bolsinga on 12/6/20.
//

import Foundation
import json

let diaryURL = URL(fileURLWithPath: CommandLine.arguments[1])
let diaryJsonData = try Data(contentsOf: diaryURL, options: .mappedIfSafe)

let musicURL = URL(fileURLWithPath: CommandLine.arguments[2])
let musicJsonData = try Data(contentsOf: musicURL, options: .mappedIfSafe)

let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .iso8601

let diary = try decoder.decode(Diary.self, from: diaryJsonData)
print("\(diary.title) has \(diary.entries.count) entries.");

let music = try decoder.decode(Music.self, from: musicJsonData)
print("Albums: \(music.albums.count)")
print("Artists: \(music.artists.count)")
print("Relations: \(music.relations.count)")
print("Shows: \(music.shows.count)")
print("Songs: \(music.songs.count)")
print("Venues: \(music.venues.count)")
