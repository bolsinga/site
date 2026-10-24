//
//  VenuesMap.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 5/29/26.
//

import MapKit
import Shared
import SwiftUI
import os

extension Logger {
  fileprivate static let venuesMap = Logger(category: "venuesMap")
}

extension VaultModel {
  fileprivate func detail<V: Hashable & Identifiable & Nameable & PathRestorable>(for item: V)
    -> Details
  {
    guard let mapItem = venueMapItemMap[item.archivePath] else {
      return .init(coordinate: kCLLocationCoordinate2DInvalid, title: "Unknown")
    }
    return .init(coordinate: mapItem.location.coordinate, title: item.name)
  }
}

struct VenuesMap<V: Hashable & Identifiable & Nameable & PathRestorable>: View {
  @Environment(VaultModel.self) private var model

  let items: any Collection<V>
  let searchString: String

  let navigateToPath: (ArchivePath) -> Void

  @State private var shownID = UUID()
  @State private var openedDetail = false

  @ViewBuilder private func clusterMap(obscuredBy insets: EdgeInsets) -> some View {
    ClusterMap(
      items: items, anchorY: CategoryAnnotationView.tipOffset, resetID: shownID,
      isSearching: !searchString.isEmpty, obscuredInsets: insets
    ) {
      model.detail(for: $0)
    } onSelect: { item in
      Logger.venuesMap.info("select \(String(describing: item.archivePath))")
      openedDetail = true
      withAnimation { navigateToPath(item.archivePath) }
    } clusterLabel: {
      String(localized: "Cluster, \($0) venues")
    } itemContent: { item in
      CategoryAnnotationView(category: .venues, render: .default)
    } itemTitle: { item in
      CategoryTitleView(title: item.name)
    } clusterContent: {
      CategoryAnnotationView(category: .venues, render: .badge($0))
    }
  }

  var body: some View {
    // The system frosts the edges of content under the toolbar and the tab bar, unless the content
    // is a scroll view with its edge effects hidden. The map is in one that doesn't scroll, which
    // runs under the bars; the map is told how far they reach, so it keeps its legal text clear of
    // them and fits its pins between them.
    GeometryReader { proxy in
      ScrollView {
        clusterMap(obscuredBy: proxy.safeAreaInsets)
          // The size of the whole screen, as the proxy's is of what the bars leave. It is the
          // proxy that follows rotation; a frame relative to the scroll view does not.
          .frame(
            width: proxy.size.width + proxy.safeAreaInsets.leading + proxy.safeAreaInsets.trailing,
            height: proxy.size.height + proxy.safeAreaInsets.top + proxy.safeAreaInsets.bottom)
      }
      .scrollDisabled(true)
      .scrollEdgeEffectHidden(true, for: .all)
      .ignoresSafeArea()
    }
    #if os(macOS)
      // The window toolbar frosts its own background there, which the scroll view doesn't stop.
      .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
    #endif
    .onAppear {
      // Coming back from a venue's detail keeps the map as it was left.
      if openedDetail {
        openedDetail = false
      } else {
        shownID = UUID()
      }
    }
    .onChange(of: searchString) {
      // A search shows its results, wherever the map was moved to.
      shownID = UUID()
    }
  }
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model

  VenuesMap(items: model.previewAllVenues, searchString: "") { _ in }
}
