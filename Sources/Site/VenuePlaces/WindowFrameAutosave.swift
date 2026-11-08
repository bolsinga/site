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

  extension View {
    /// Remembers the window's position and size under the name, without scene restoration.
    func windowFrameAutosave(_ name: String) -> some View {
      background(WindowFrameAutosave(name: name))
    }
  }
#endif
