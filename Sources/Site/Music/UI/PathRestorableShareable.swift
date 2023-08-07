//
//  PathRestorableShareable.swift
//
//
//  Created by Greg Bolsinga on 8/2/23.
//

import SwiftUI

protocol PathRestorableShareable: PathRestorable {
  func subject(vault: Vault) -> Text
  func message(vault: Vault) -> Text
}

extension Show: PathRestorableShareable {
  func subject(vault: Vault) -> Text {
    Text(self.formatted(.headlinerAndVenue, lookup: vault.lookup))
  }

  func message(vault: Vault) -> Text {
    Text(self.formatted(.full, lookup: vault.lookup))
  }
}

extension Venue: PathRestorableShareable {
  func subject(vault: Vault) -> Text {
    Text(self.name)
  }

  func message(vault: Vault) -> Text {
    Text(self.name)
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
  func subject(vault: Vault) -> Text {
    Text(self.name)
  }

  func message(vault: Vault) -> Text {
    Text(self.name)
  }
}
