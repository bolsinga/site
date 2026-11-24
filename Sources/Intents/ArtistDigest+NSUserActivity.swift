import AppIntents
import Foundation
import SiteCore

extension ArtistDigest {
  var restorableActivity: RestorableActivity {
    RestorableActivity(id: id) { userActivity, url in
      userActivity.isEligibleForHandoff = true

      userActivity.isEligibleForSearch = true
      userActivity.title = self.name
      userActivity.addSearchableContent(
        description: String(localized: "See Shows With This Artist"))

      if let url {
        userActivity.appEntityIdentifier = EntityIdentifier(
          for: ArtistEntity(digest: self, url: url))
      }
    }
  }
}
