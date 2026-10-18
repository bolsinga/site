//
//  ViewRepresentable.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 6/7/26.
//

import SwiftUI

#if canImport(UIKit)
  protocol ViewRepresentable: UIViewRepresentable {
    associatedtype ViewType = UIViewType
    func makeView(context: Context) -> ViewType
    func updateView(_ view: ViewType, context: Context)
  }

  extension ViewRepresentable {
    func makeUIView(context: Context) -> ViewType {
      makeView(context: context)
    }

    func updateUIView(_ uiView: ViewType, context: Context) {
      updateView(uiView, context: context)
    }
  }

  typealias HostingView = (UIView & UIContentView)

  @MainActor func createHostingView(content: AnyView) -> HostingView {
    UIHostingConfiguration { content }.margins(.all, 0).makeContentView()
  }

  @MainActor func fittingSize(of content: AnyView) -> CGSize {
    createHostingView(content: content).systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
  }

#endif

#if canImport(AppKit)
  protocol ViewRepresentable: NSViewRepresentable {
    associatedtype ViewType = NSViewType
    func makeView(context: Context) -> ViewType
    func updateView(_ view: ViewType, context: Context)
  }

  extension ViewRepresentable {
    func makeNSView(context: Context) -> ViewType {
      makeView(context: context)
    }

    func updateNSView(_ nsView: ViewType, context: Context) {
      updateView(nsView, context: context)
    }
  }

  typealias HostingView = NSHostingView<AnyView>

  @MainActor func createHostingView(content: AnyView) -> HostingView {
    HostingView(rootView: content)
  }

  @MainActor func fittingSize(of content: AnyView) -> CGSize {
    createHostingView(content: content).fittingSize
  }
#endif
