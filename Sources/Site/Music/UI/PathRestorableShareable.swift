//
//  PathRestorableShareable.swift
//
//
//  Created by Greg Bolsinga on 8/2/23.
//

import SwiftUI

// iOS Only:
// When sharing via Messages, link is shared followed by the message text.
// When sharing via Mail, subject is as expected, and message is link followed by message text.
// macos ventura: no subject nor message shown messages nor mail

protocol PathRestorableShareable: PathRestorable {
  func subject(vault: Vault) -> Text
  func message(vault: Vault) -> Text
}

extension Concert: PathRestorableShareable {
  func subject(vault: Vault) -> Text {
    Text(self.formatted(.headlinerAndVenue))
  }

  func message(vault: Vault) -> Text {
    Text(self.formatted(.full))
  }
}

extension Venue: PathRestorableShareable {
  private var descriptor: String {
    String(localized: "Shows at \(self.name)", bundle: .module, comment: "Venue shared string")
  }

  func subject(vault: Vault) -> Text {
    Text(descriptor)
  }

  func message(vault: Vault) -> Text {
    Text(descriptor)
  }
}

extension Annum: PathRestorableShareable {
  func subject(vault: Vault) -> Text {
    Text(self.formatted(.shared))
  }

  func message(vault: Vault) -> Text {
    Text(self.formatted(.shared))
  }
}

extension Artist: PathRestorableShareable {
  private var descriptor: String {
    String(localized: "Shows with \(self.name)", bundle: .module, comment: "Artist shared string")
  }

  func subject(vault: Vault) -> Text {
    Text(descriptor)
  }

  func message(vault: Vault) -> Text {
    Text(descriptor)
  }
}
