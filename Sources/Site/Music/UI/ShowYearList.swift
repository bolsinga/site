//
//  ShowYearList.swift
//
//
//  Created by Greg Bolsinga on 3/26/23.
//

import SwiftUI

extension PartialDate {
  var yearOnly: PartialDate {
    PartialDate(year: year)
  }
}

struct ShowYearList: View {
  @Environment(\.vault) private var vault: Vault

  let shows: [Show]

  @State private var decadesMap: [Decade: [PartialDate: [Show]]] = [:]

  var body: some View {
    List {
      ForEach(decadesMap.keys.sorted(), id: \.self) { decade in
        let decadeMap = decadesMap[decade] ?? [:]
        Section {
          ForEach(decadeMap.keys.sorted(), id: \.self) { yearOnly in
            let shows = decadeMap[yearOnly] ?? []
            NavigationLink(value: yearOnly) {
              LabeledContent(
                yearOnly.formatted(.yearOnly),
                value: String(
                  localized: "\(shows.count) Show(s)", bundle: .module,
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
    .navigationDestination(for: PartialDate.self) {
      YearDetail(shows: decadesMap[$0.decade]?[$0] ?? [], yearPartialDate: $0)
    }.task {
      let decadeShowMap: [Decade: [Show]] = shows.reduce(into: [:]) {
        let decade = $1.date.decade
        var arr = $0[decade] ?? []
        arr.append($1)
        $0[decade] = arr
      }

      self.decadesMap = decadeShowMap.reduce(into: [:]) {
        $0[$1.key] = $1.value.reduce(into: [:]) {
          let yearOnly = $1.date.yearOnly
          var arr = $0[yearOnly] ?? []
          arr.append($1)
          $0[yearOnly] = arr
        }
      }
    }
  }
}

struct ShowYearList_Previews: PreviewProvider {
  static var previews: some View {
    let vault = Vault.previewData

    NavigationStack {
      ShowYearList(shows: vault.music.shows)
        .environment(\.vault, vault)
        .musicDestinations()
    }
  }
}
