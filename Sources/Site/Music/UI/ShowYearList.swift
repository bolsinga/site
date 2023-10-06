//
//  ShowYearList.swift
//
//
//  Created by Greg Bolsinga on 3/26/23.
//

import SwiftUI

struct ShowYearList: View {
  let decadesMap: [Decade: [Annum: [Concert.ID]]]
  let nearbyConcertIDs: Set<Concert.ID>
  @Binding var locationFilter: LocationFilter
  @Binding var geocodingProgress: Double
  @Binding var locationAuthorization: LocationAuthorization

  private var filteredDecadesMap: [Decade: [Annum: [Concert.ID]]] {
    switch locationFilter {
    case .none:
      return decadesMap
    case .nearby:
      return [Decade: [Annum: [Concert.ID]]](
        uniqueKeysWithValues: decadesMap.compactMap {
          let nearbyAnnums = [Annum: [Show.ID]](
            uniqueKeysWithValues: $0.value.compactMap {
              let nearbyIDs = $0.value.filter { nearbyConcertIDs.contains($0) }
              if nearbyIDs.isEmpty {
                return nil
              }
              return ($0.key, nearbyIDs)
            })
          if nearbyAnnums.isEmpty {
            return nil
          }
          return ($0.key, nearbyAnnums)
        })
    }
  }

  var body: some View {
    let decadesMap = filteredDecadesMap
    List {
      ForEach(decadesMap.keys.sorted(), id: \.self) { decade in
        let decadeMap = decadesMap[decade] ?? [:]
        Section {
          ForEach(decadeMap.keys.sorted(), id: \.self) { annum in
            let concerts = decadeMap[annum] ?? []
            NavigationLink(value: annum) {
              LabeledContent(
                annum.formatted(),
                value: String(
                  localized: "\(concerts.count) Show(s)", bundle: .module,
                  comment: "Value for the ShowYearList Shows per year."))
            }
          }
        } header: {
          Text(decade.formatted(.defaultDigits))
        }
      }
    }
    .listStyle(.plain)
    .navigationTitle(Text("Show Years", bundle: .module, comment: "Title for the ShowYearList."))
    .locationFilter(
      $locationFilter, geocodingProgress: $geocodingProgress,
      locationAuthorization: $locationAuthorization)
  }
}

struct ShowYearList_Previews: PreviewProvider {
  static var previews: some View {
    let vaultPreview = Vault.previewData

    NavigationStack {
      ShowYearList(
        decadesMap: vaultPreview.decadesMap, nearbyConcertIDs: Set(vaultPreview.concertMap.keys),
        locationFilter: .constant(.none), geocodingProgress: .constant(0),
        locationAuthorization: .constant(.allowed)
      )
      .musicDestinations(vaultPreview)
    }
  }
}
