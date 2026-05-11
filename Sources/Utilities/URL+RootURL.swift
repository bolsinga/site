//
//  URL+RootURL.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 5/11/26.
//

import Foundation

extension URL {
  var rootURL: URL? {
    let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false)

    var newUrlComponents = URLComponents()
    newUrlComponents.host = urlComponents?.host
    newUrlComponents.scheme = urlComponents?.scheme

    return newUrlComponents.url
  }
}
