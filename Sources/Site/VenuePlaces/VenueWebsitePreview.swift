//
//  VenueWebsitePreview.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/7/26.
//

#if !os(tvOS)
  import SwiftUI
  import WebKit

  /// A venue's website, loaded in the app, with the URL it ends up at.
  struct VenueWebsitePreview: View {
    let url: URL

    @Environment(\.dismiss) private var dismiss
    @State private var page = WebPage()

    var body: some View {
      NavigationStack {
        WebView(page)
          .overlay {
            if page.isLoading {
              ProgressView(value: page.estimatedProgress)
                .frame(maxHeight: .infinity, alignment: .top)
            }
          }
          .safeAreaInset(edge: .bottom) {
            HStack {
              Text(page.url?.absoluteString ?? url.absoluteString)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
              Link(destination: url) {
                Label("Open in Safari", systemImage: "safari")
              }
              .help("Open in Safari")
            }
            .padding(8)
            .background(.bar)
          }
          .navigationTitle(page.title.isEmpty ? url.absoluteString : page.title)
          .toolbar {
            ToolbarItem(placement: .confirmationAction) {
              Button("Done") { dismiss() }
            }          }
      }
      #if os(macOS)
        .frame(minWidth: 800, minHeight: 600)
      #endif
      .task { page.load(URLRequest(url: url)) }
    }
  }
#endif
