//
//  ShowYearList.swift
//
//
//  Created by Greg Bolsinga on 3/26/23.
//

import SwiftUI

struct ShowYearList: View {
  let shows: [Show]

  @State private var decadesMap: [Decade: [Annum: [Show]]] = [:]

  var body: some View {
    List {
      ForEach(decadesMap.keys.sorted(), id: \.self) { decade in
        let decadeMap = decadesMap[decade] ?? [:]
        Section {
          ForEach(decadeMap.keys.sorted(), id: \.self) { annum in
            let shows = decadeMap[annum] ?? []
            NavigationLink(value: annum) {
              LabeledContent(
                annum.formatted(),
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
    .navigationDestination(for: Annum.self) { annum in
      YearDetail(shows: decadesMap[annum.decade]?[annum] ?? [], annum: annum)
    }.task {
      let decadeShowMap: [Decade: [Show]] = shows.reduce(into: [:]) {
        let decade = $1.date.decade
        var arr = $0[decade] ?? []
        arr.append($1)
        $0[decade] = arr
      }

      self.decadesMap = decadeShowMap.reduce(into: [:]) {
        $0[$1.key] = $1.value.reduce(into: [:]) {
          let annum = $1.date.annum
          var arr = $0[annum] ?? []
          arr.append($1)
          $0[annum] = arr
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
