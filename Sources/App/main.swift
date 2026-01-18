//
//  main.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 1/18/26.
//

import ArgumentParser
import Foundation

#if os(macOS)
  extension CommandLine {
    fileprivate static var isTool: Bool {
      arguments.count > 1 && !arguments[1].contains("NSTreatUnknownArgumentsAsOpen")
    }
  }
#endif

#if os(macOS)
  if CommandLine.isTool {
    await Program.asyncMain()
  } else {
    SiteAppApp.main()
  }
#else
  SiteAppApp.main()
#endif
