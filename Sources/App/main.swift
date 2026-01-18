//
//  main.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 1/18/26.
//

import ArgumentParser
import Foundation

extension CommandLine {
  fileprivate static var isTool: Bool {
    arguments.count > 1 && !arguments[1].contains("NSTreatUnknownArgumentsAsOpen")
  }
}

if CommandLine.isTool {
  await Program.asyncMain()
} else {
  SiteAppApp.main()
}
