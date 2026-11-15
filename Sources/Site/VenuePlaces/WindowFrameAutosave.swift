//
//  WindowFrameAutosave.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 11/8/26.
//

#if os(macOS)
  import AppKit
  import SwiftUI

  /// Names the window it is in, so AppKit restores its last frame and saves each move and resize.
  private struct WindowFrameAutosave: NSViewRepresentable {
    let name: String

    final class WindowView: NSView {
      var name = ""

      override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        // Naming the window loads its saved frame, if there is one.
        if let window, window.frameAutosaveName != name {
          window.setFrameAutosaveName(name)
        }
      }
    }

    func makeNSView(context: Context) -> WindowView {
      let view = WindowView()
      view.name = name
      return view
    }

    func updateNSView(_ view: WindowView, context: Context) {}
  }

  /// Shows the window's close button as edited while there is something to save.
  private struct WindowEdited: NSViewRepresentable {
    let isEdited: Bool

    func makeNSView(context: Context) -> NSView { NSView() }

    func updateNSView(_ view: NSView, context: Context) {
      // The view is only in a window after it is made.
      DispatchQueue.main.async { view.window?.isDocumentEdited = isEdited }
    }
  }

  extension View {
    /// Marks the window as edited, as a document's is.
    func windowEdited(_ isEdited: Bool) -> some View {
      background(WindowEdited(isEdited: isEdited))
    }

    /// Remembers the window's position and size under the name, without scene restoration.
    func windowFrameAutosave(_ name: String) -> some View {
      background(WindowFrameAutosave(name: name))
    }
  }
#else
  import SwiftUI

  extension View {
    func windowEdited(_ isEdited: Bool) -> some View { self }
  }
#endif
