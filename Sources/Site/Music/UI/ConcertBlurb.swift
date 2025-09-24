//
//  ConcertBlurb.swift
//
//
//  Created by Greg Bolsinga on 5/18/23.
//

import SwiftUI

struct ConcertBlurb: View {
  enum DateFormat {
    case noYear
    case relative
  }

  let concert: Concert
  let dateFormat: DateFormat

  @ViewBuilder private var detailsView: some View {
    VStack(alignment: .trailing) {
      if let venue = concert.venue {
        Text(venue.name).font(.headline)
      }
      switch dateFormat {
      case .noYear:
        Text(concert.show.date.formatted(.noYear))
          .font(.footnote)
      case .relative:
        if let date = concert.show.date.date {
          Text(date.formatted(.relative(presentation: .numeric)))
            .font(.footnote)
        }
      }
    }
  }

  var body: some View {
    HStack {
      PerformersView(concert: concert)
      Spacer()
      detailsView
    }
  }
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  ConcertBlurb(concert: model.vault.concerts[0], dateFormat: .noYear)
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  ConcertBlurb(concert: model.vault.concerts[1], dateFormat: .relative)
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  ConcertBlurb(concert: model.vault.concerts[2], dateFormat: .noYear)
}
