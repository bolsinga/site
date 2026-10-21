//
//  VenueDetail.swift
//
//
//  Created by Greg Bolsinga on 2/16/23.
//

import MapKit
import Shared
import SwiftUI

struct VenueDetail: View {
  @Environment(VaultModel.self) private var model

  let digest: VenueDigest
  let url: URL?
  let isPathNavigable: (ArchivePath) -> Bool

  @State private var mapItem: MKMapItem?

  @ViewBuilder private var firstSetElement: some View {
    HStack {
      Text("First Set")
      Spacer()
      Text(digest.rank.firstSet.rank.formatted())
    }
  }

  /// The map runs edge to edge under the toolbar, fading into the background where the venue's name and address sit.
  @ViewBuilder private var headerElement: some View {
    LocationMap(geocodingInProgress: model.geocodingInProgress, item: $mapItem, minHeight: 0)
      .containerRelativeFrame(.vertical) { height, _ in height * 0.45 }
      .mask(
        LinearGradient(
          stops: [.init(color: .black, location: 0.6), .init(color: .clear, location: 1)],
          startPoint: .top, endPoint: .bottom)
      )
      .overlay(alignment: .bottomLeading) {
        VStack(alignment: .leading) {
          Text(digest.name)
            .font(.largeTitle.bold())
          AddressView(location: digest.location)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
      }
  }

  @ViewBuilder private func card<Content: View>(
    _ title: Text, @ViewBuilder content: () -> Content
  ) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      title
        .font(.title3.bold())
      content()
    }
    .padding()
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(.background.secondary, in: .rect(cornerRadius: 20))
  }

  @ViewBuilder private var statsElement: some View {
    card(Text(ArchiveCategory.stats.localizedString)) {
      firstSetElement
      if digest.shows.count > 1 {
        StatsGrouping(venueDigest: digest)
      }
    }
  }

  @ViewBuilder private var showsElement: some View {
    card(Text("Shows")) {
      let shows = digest.shows.sorted()
      ForEach(shows) { show in
        ArchivePathLink(archivePath: show.id, isPathNavigable: isPathNavigable) {
          HStack {
            VenueBlurb(date: show.date, performers: show.performerNames)
            if isPathNavigable(show.id) {
              Spacer()
              Image(systemName: "chevron.right")
                .font(.footnote.bold())
                .foregroundStyle(.tertiary)
            }
          }
          .contentShape(.rect)
        }
        if show.id != shows.last?.id {
          Divider()
        }
      }
      .buttonStyle(.plain)
    }
  }

  @ViewBuilder private var relatedsElement: some View {
    if !digest.related.isEmpty {
      card(Text("Related Venues")) {
        ForEach(digest.related) { relatedVenue in
          ArchivePathLink(archivePath: relatedVenue.id, isPathNavigable: isPathNavigable) {
            HStack {
              Text(relatedVenue.name)
              if isPathNavigable(relatedVenue.id) {
                Spacer()
                Image(systemName: "chevron.right")
                  .font(.footnote.bold())
                  .foregroundStyle(.tertiary)
              }
            }
            .contentShape(.rect)
          }
          if relatedVenue.id != digest.related.last?.id {
            Divider()
          }
        }
        .buttonStyle(.plain)
      }
    }
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 16) {
        headerElement
        VStack(spacing: 16) {
          statsElement
          showsElement
          relatedsElement
        }
        .padding(.horizontal)
      }
    }
    // A ScrollView is transparent, so on macOS the view beneath (the venues map) shows through.
    .background(.background)
    .ignoresSafeArea(edges: .top)
    #if os(macOS)
      .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
    #else
      .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
    #endif
    #if !os(tvOS)
      .toolbar(removing: .title)
    #endif
    .toolbar { ArchiveSharableToolbarContent(item: digest, url: url) }
    .onAppear {
      self.mapItem = model.venueMapItemMap[digest.archivePath]
    }
    .onChange(of: model.venueMapItemMap) { _, newValue in
      self.mapItem = newValue[digest.archivePath]
    }
  }
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model
  NavigationStack {
    VenueDetail(
      digest: model.previewVenue("v103"),
      url: nil,
      isPathNavigable: { _ in
        true
      }
    )
  }
}
