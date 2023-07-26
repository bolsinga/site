//
//  Program.swift
//  site
//
//  Created by Greg Bolsinga on 6/11/23.
//

import ArgumentParser
import Foundation

@main
struct Program: AsyncParsableCommand {
  @Argument(help: "Application Identifier (from developer.apple.com)")
  var applicationIdentifier: String

  @Argument(help: "Bundle Identifier")
  var bundleIdentifier: String

  func run() async throws {

    let contents = """
      {
        "applinks" : {
          "details" : [
            {
              "appIDs" : [ "\(applicationIdentifier).\(bundleIdentifier)" ],
              "components" : [
                 {
                    "/": "/bands/*",
                    "comment": "Allows artists."
                 },
                 {
                    "/": "/dates/*",
                    "comment": "Allows shows."
                 },
                 {
                    "/": "/venues/*",
                    "comment": "Allows venues."
                 }
              ]
            }
          ]
        }
      }
      """
    print(contents)
  }
}
