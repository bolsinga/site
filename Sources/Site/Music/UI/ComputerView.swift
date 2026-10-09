//
//  ComputerView.swift
//
//
//  Created by Greg Bolsinga on 10/8/26.
//

import SwiftUI

/// A vector recreation of an old 4-color GIF: two reel-to-reel decks
/// flanking a mixer tower. Only the reel blade hubs move, each stepping
/// through its own sequence of exact, independently hand-drawn frames
/// (see `Reel.bladeFrames`) rather than a shape that rotates.
struct ComputerView: View {
  /// A named group of the 4 colors used throughout the drawing, so the
  /// whole thing can be recolored as a set via the `palette` initializer
  /// parameter.
  struct Palette: Equatable, Sendable {
    var primary: Color
    var background: Color
    var secondary: Color
    var accent: Color

    static let classic = Palette(
      primary: Color(red: 0, green: 0, blue: 0),
      background: Color(red: 1, green: 1, blue: 1),
      secondary: Color(red: 0x81 / 255, green: 0x81 / 255, blue: 0x81 / 255),
      accent: Color(red: 0, green: 0x81 / 255, blue: 0x81 / 255)
    )
  }

  /// Reference type so code outside this view - a timer cycling palettes,
  /// a settings toggle - can drive `palette`/`isAnimating` over time
  /// without a `Binding` per property.
  @Observable
  final class Model {
    var palette: Palette
    var isAnimating: Bool

    init(palette: Palette = .classic, isAnimating: Bool = true) {
      self.palette = palette
      self.isAnimating = isAnimating
    }
  }

  var model = Model()

  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  @State private var geometryCache = GeometryCache()
  /// Set whenever `model.palette` changes, so a new palette eases in
  /// instead of cutting in instantly.
  @State private var paletteTransition: (from: Palette, to: Palette, start: Date)?

  private static let gridSize = Scene.gridSize
  /// The GIF's native frame rate; each reel holds its wobble step for one
  /// or more of these ticks (see `Reel.ticksPerStep`).
  private static let tickDuration: TimeInterval = 0.1
  private static let paletteTransitionDuration: TimeInterval = 0.4
  // Antialiasing is off: adjacent same-grid rects share exact edges, and
  // smoothing each one independently would leave a hairline of whatever
  // sits behind the canvas peeking through at every seam between them.
  private static let hardEdge = FillStyle(antialiased: false)

  var body: some View {
    Group {
      if model.isAnimating && !reduceMotion {
        TimelineView(.periodic(from: .now, by: Self.tickDuration)) { timeline in
          Canvas { context, size in
            draw(
              in: &context, size: size, tick: tick(for: timeline.date),
              palette: currentPalette(at: timeline.date))
          }
        }
      } else {
        // No TimelineView at all: nothing here ever changes, so there's no
        // reason to wake up every tick just to redraw the same pixels.
        Canvas { context, size in
          draw(in: &context, size: size, tick: 0, palette: model.palette)
        }
      }
    }
    .onChange(of: model.palette) { old, new in
      paletteTransition = (from: old, to: new, start: .now)
    }
    .aspectRatio(Self.gridSize.width / Self.gridSize.height, contentMode: .fit)
    .accessibilityHidden(true)
  }

  private func tick(for date: Date) -> Int {
    Int(date.timeIntervalSinceReferenceDate / Self.tickDuration)
  }

  private func bladeStep(for reel: Reel, tick: Int) -> Int {
    let cycleLength = reel.bladeFrames.count * reel.ticksPerStep
    return (tick % cycleLength) / reel.ticksPerStep
  }

  /// `model.palette` as of this instant, easing from whatever it was
  /// before if it changed within the last `paletteTransitionDuration`.
  private func currentPalette(at date: Date) -> Palette {
    guard let paletteTransition else { return model.palette }
    let progress = date.timeIntervalSince(paletteTransition.start) / Self.paletteTransitionDuration
    guard progress < 1 else { return model.palette }
    func blend(_ color: KeyPath<Palette, Color>) -> Color {
      paletteTransition.from[keyPath: color].mix(with: paletteTransition.to[keyPath: color], by: progress)
    }
    return Palette(
      primary: blend(\.primary), background: blend(\.background), secondary: blend(\.secondary),
      accent: blend(\.accent))
  }

  private func draw(in context: inout GraphicsContext, size: CGSize, tick: Int, palette: Palette) {
    geometryCache.ensure(for: size)

    for (role, path) in geometryCache.staticPaths {
      context.fill(path, with: .color(role(palette)), style: Self.hardEdge)
    }

    for (reel, paths) in zip(Scene.reels, geometryCache.bladePaths) {
      let step = bladeStep(for: reel, tick: tick)
      context.fill(paths[step], with: .color(reel.bladeRole(palette)), style: Self.hardEdge)
    }
  }

  /// Caches each layer's `Path` per canvas size, since only *which*
  /// precomputed blade step is on screen changes between ticks - rebuilding
  /// hundreds of `CGRect`s every tick for geometry that hasn't moved is
  /// wasted work.
  @MainActor
  private final class GeometryCache {
    private(set) var staticPaths: [(PaletteColor, Path)] = []
    /// Indexed [reelIndex][bladeStep].
    private(set) var bladePaths: [[Path]] = []
    private var size: CGSize?

    func ensure(for size: CGSize) {
      guard self.size != size else { return }
      self.size = size

      let gridSize = Scene.gridSize
      let scale = min(size.width / gridSize.width, size.height / gridSize.height)
      let offset = CGPoint(
        x: (size.width - gridSize.width * scale) / 2,
        y: (size.height - gridSize.height * scale) / 2)

      func path(for spans: [PixelSpan]) -> Path {
        var path = Path()
        for span in spans {
          path.addRect(
            CGRect(
              x: offset.x + CGFloat(span.xStart) * scale,
              y: offset.y + CGFloat(span.row) * scale,
              width: CGFloat(span.xEnd - span.xStart) * scale,
              height: scale))
        }
        return path
      }

      staticPaths = Scene.staticLayers.map { ($0.role, path(for: $0.spans)) }
      bladePaths = Scene.reels.map { reel in reel.bladeFrames.map(path(for:)) }
    }
  }
}

extension ComputerView {
  /// Drives the accent color's HDR brightness from `amount` (0...1), mapped
  /// exponentially onto `AccentHDRBrightnessModifier.headroomRange` since
  /// headroom is a linear multiplier but perceived brightness is not.
  func accentHDRBrightness(_ amount: Double) -> some View {
    modifier(AccentHDRBrightnessModifier(model: model, amount: amount))
  }
}

/// No system API maps a normalized value to HDR headroom. Maps
/// exponentially (vs. linearly) so equal steps of `amount` read as equal
/// brightness jumps, since headroom is a multiplier.
private struct AccentHDRBrightnessModifier: ViewModifier {
  static let headroomRange: ClosedRange<Double> = 1...4
  /// `Palette.classic.accent`'s own components, so computing a color doesn't
  /// need to resolve that (otherwise constant) `Color` on every `amount` change.
  private static let accentBase = (red: 0.0, green: Double(0x81) / 255, blue: Double(0x81) / 255)

  let model: ComputerView.Model
  let amount: Double

  func body(content: Content) -> some View {
    content
      .onChange(of: amount, initial: true) { _, amount in
        model.palette.accent = Self.accentColor(forAmount: amount)
      }
  }

  private static func accentColor(forAmount amount: Double) -> Color {
    let headroom =
      headroomRange.lowerBound
      * pow(headroomRange.upperBound / headroomRange.lowerBound, min(max(amount, 0), 1))
    return Color(
      .sRGB, red: accentBase.red * headroom, green: accentBase.green * headroom,
      blue: accentBase.blue * headroom
    ).headroom(headroom)
  }
}

extension ComputerView {
  /// Easter egg: the faster you drag (iOS) or move the pointer (macOS)
  /// over the computer, the brighter its accent glows. Opt-in, so call
  /// sites that just want the computer get the plain `.classic` look.
  func accentReactsToInteractionSpeed() -> some View {
    modifier(InteractionIntensityModifier(model: model))
  }
}

/// Tracks drag/hover speed and feeds it into `AccentHDRBrightnessModifier`
/// as `amount`, decaying toward `idleAmount` once movement stops.
private struct InteractionIntensityModifier: ViewModifier {
  private static let maxSpeed = 2000.0  // points/second mapping to full intensity.
  private static let decayDuration = 0.6
  private static let decayTickDuration = 1.0 / 30
  /// Never fully 0 once touched: macOS visibly pops when a window engages
  /// or disengages HDR, so staying just above headroom 1.0 avoids re-popping
  /// on every interaction.
  private static let idleAmount = 0.02
  /// Clamps `dt` against near-simultaneous coalesced events, which would
  /// otherwise spike `distance / dt` wildly.
  private static let minSampleInterval = 1.0 / 120
  /// Weight per raw sample; smooths out per-event noise that would
  /// otherwise snap `amount` around and restart `ComputerView`'s cross-fade.
  private static let sampleSmoothing = 0.25

  let model: ComputerView.Model

  @State private var amount = 0.0
  @State private var lastInteraction: (location: CGPoint, time: Date)?
  @State private var decayTask: Task<Void, Never>?

  func body(content: Content) -> some View {
    content
      .modifier(AccentHDRBrightnessModifier(model: model, amount: amount))
      #if os(iOS)
        .gesture(
          DragGesture(minimumDistance: 0).onChanged { value in
            recordInteraction(at: value.location, time: value.time)
          })
      #elseif os(macOS)
        .onContinuousHover(coordinateSpace: .local) { phase in
          switch phase {
          case .active(let location):
            recordInteraction(at: location, time: .now)
          case .ended:
            // Otherwise the pointer re-entering elsewhere reads as a huge,
            // instantaneous jump from wherever it last was.
            lastInteraction = nil
          }
        }
      #endif
  }

  #if os(iOS) || os(macOS)
    private func recordInteraction(at location: CGPoint, time: Date) {
      if let last = lastInteraction, time > last.time {
        let dt = max(time.timeIntervalSince(last.time), Self.minSampleInterval)
        let distance = Double(hypot(location.x - last.location.x, location.y - last.location.y))
        let rawAmount = min(distance / dt / Self.maxSpeed, 1)
        amount += (rawAmount - amount) * Self.sampleSmoothing
      }
      lastInteraction = (location, time)
      startDecayIfNeeded()
    }

    /// Only polls while there's intensity to fade, rather than for the
    /// view's whole lifetime.
    private func startDecayIfNeeded() {
      guard decayTask == nil else { return }
      let step = Self.decayTickDuration / Self.decayDuration
      decayTask = Task {
        while amount > Self.idleAmount {
          try? await Task.sleep(for: .seconds(Self.decayTickDuration))
          amount = max(Self.idleAmount, amount - step)
        }
        decayTask = nil
      }
    }
  #endif
}

/// A function instead of `KeyPath<Palette, Color>`, which isn't `Sendable`
/// even when its root and value are. `\.background`-style literals still
/// work at call sites since Swift converts key paths to functions.
private typealias PaletteColor = @Sendable (ComputerView.Palette) -> Color

private struct PixelSpan {
  var row: Int
  var xStart: Int
  var xEnd: Int
}

private enum Raster {
  static func rect(x: Range<Int>, y: Range<Int>) -> [PixelSpan] {
    y.map { PixelSpan(row: $0, xStart: x.lowerBound, xEnd: x.upperBound) }
  }
}

private struct Layer: Sendable {
  var role: PaletteColor
  var spans: [PixelSpan]
}

private struct Reel: Sendable {
  var discRole: PaletteColor
  /// This reel's housing silhouette (the disc as seen under the blades),
  /// traced directly from the source GIF - see `topLeftDiscRects` etc.
  /// below for how.
  var discSpans: [PixelSpan]
  var bladeRole: PaletteColor
  /// The exact blade pixels for each of the 8 wobble steps, extracted from
  /// the source GIF. Each step is its own independent frame - not a
  /// rotated shape - since the blade count and silhouette vary step to
  /// step.
  var bladeFrames: [[PixelSpan]]
  /// Ticks each step holds for: the left reels wobble every 200ms, the
  /// right ones every 100ms.
  var ticksPerStep: Int
}

/// The GIF's layout, measured in its native 240x180 pixel grid. Only the
/// reel blade hubs move; everything here is drawn once and reused.
private enum Scene {
  static let gridSize = CGSize(width: 240, height: 180)

  /// Each reel's 8 blade-cluster steps, as flat (xStart, xEnd, yStart,
  /// yEnd) rectangles in absolute grid coordinates - the same encoding as
  /// the static rects below, decoded by `spans(from:)`.
  private static let topLeftBladeFrames: [[Int]] = [
    [
      24, 32, 23, 24, 24, 33, 24, 25, 25, 31, 22, 23, 26, 30, 21, 22, 26, 32, 25, 26, 27, 29, 20, 21,
      28, 31, 26, 27, 28, 34, 35, 37, 29, 30, 27, 28, 29, 35, 33, 35, 30, 34, 37, 38, 30, 35, 31, 33,
      31, 32, 29, 30, 31, 34, 30, 31, 36, 45, 26, 28, 37, 41, 29, 30, 37, 44, 28, 29, 38, 45, 25, 26,
      40, 44, 24, 25, 42, 44, 23, 24,
    ],
    [
      24, 28, 31, 33, 24, 31, 27, 31, 34, 39, 31, 34, 35, 38, 30, 31, 35, 39, 26, 27, 35, 39, 37, 38,
      35, 41, 23, 26, 35, 41, 34, 37, 37, 41, 19, 20, 37, 42, 20, 23,
    ],
    [
      26, 32, 34, 35, 26, 33, 33, 34, 27, 32, 35, 36, 27, 34, 32, 33, 28, 31, 36, 37, 28, 33, 31, 32,
      29, 31, 37, 38, 29, 32, 30, 31, 29, 35, 18, 20, 30, 31, 29, 30, 30, 35, 20, 21, 30, 36, 21, 22,
      31, 34, 17, 18, 31, 36, 22, 24, 32, 34, 25, 26, 32, 36, 24, 25, 35, 44, 30, 31, 36, 44, 28, 30,
      37, 41, 27, 28, 37, 44, 31, 32, 39, 43, 32, 33, 41, 43, 33, 34,
    ],
    [
      25, 32, 22, 24, 25, 33, 24, 26, 26, 29, 21, 22, 29, 33, 26, 28, 33, 37, 32, 35, 33, 39, 35, 39,
      36, 44, 25, 28, 37, 40, 28, 29, 37, 44, 24, 25, 40, 43, 22, 24,
    ],
    [
      23, 30, 30, 31, 23, 32, 28, 30, 24, 26, 32, 33, 24, 28, 31, 32, 24, 31, 27, 28, 27, 31, 26, 27,
      33, 38, 23, 25, 33, 39, 21, 23, 34, 37, 25, 26, 34, 38, 18, 19, 34, 40, 19, 21, 35, 44, 31, 32,
      36, 37, 26, 27, 36, 42, 30, 31, 36, 44, 32, 33, 37, 40, 29, 30, 37, 43, 33, 34, 38, 39, 28, 29,
      38, 42, 34, 35, 39, 41, 35, 36,
    ],
    [
      25, 32, 22, 24, 25, 33, 24, 26, 26, 29, 21, 22, 29, 33, 26, 28, 33, 37, 32, 35, 33, 39, 35, 39,
      36, 44, 25, 28, 37, 40, 28, 29, 37, 44, 24, 25, 40, 43, 22, 24,
    ],
    [
      26, 32, 34, 35, 26, 33, 33, 34, 27, 32, 35, 36, 27, 34, 32, 33, 28, 31, 36, 37, 28, 33, 31, 32,
      29, 31, 37, 38, 29, 32, 30, 31, 29, 35, 18, 20, 30, 31, 29, 30, 30, 35, 20, 21, 30, 36, 21, 22,
      31, 34, 17, 18, 31, 36, 22, 24, 32, 34, 25, 26, 32, 36, 24, 25, 35, 44, 30, 31, 36, 44, 28, 30,
      37, 41, 27, 28, 37, 44, 31, 32, 39, 43, 32, 33, 41, 43, 33, 34,
    ],
    [
      24, 28, 31, 33, 24, 31, 27, 31, 34, 39, 31, 34, 35, 38, 30, 31, 35, 39, 26, 27, 35, 39, 37, 38,
      35, 41, 23, 26, 35, 41, 34, 37, 37, 41, 19, 20, 37, 42, 20, 23,
    ],
  ]

  private static let bottomLeftBladeFrames: [[Int]] = [
    [
      28, 37, 83, 84, 29, 36, 84, 85, 30, 36, 85, 86, 30, 37, 82, 83, 31, 35, 86, 87, 32, 35, 87, 88,
      32, 36, 81, 82, 34, 35, 80, 81, 34, 35, 88, 89, 34, 41, 68, 73, 35, 41, 73, 77, 39, 49, 81, 82,
      40, 47, 80, 81, 41, 45, 79, 80, 41, 48, 82, 83, 42, 44, 78, 79, 43, 48, 83, 84, 44, 47, 84, 85,
      45, 46, 85, 86,
    ],
    [
      28, 36, 72, 73, 28, 38, 73, 75, 29, 35, 70, 72, 29, 38, 75, 76, 30, 33, 69, 70, 32, 36, 76, 77,
      33, 35, 77, 79, 33, 40, 87, 89, 35, 40, 83, 86, 35, 42, 86, 87, 36, 40, 82, 83, 40, 43, 77, 79,
      40, 47, 73, 77, 46, 47, 72, 73,
    ],
    [
      27, 32, 82, 83, 27, 36, 76, 82, 37, 42, 74, 75, 37, 43, 73, 74, 38, 42, 75, 76, 38, 44, 72, 73,
      39, 41, 76, 77, 39, 44, 70, 71, 39, 45, 71, 72, 39, 48, 82, 83, 40, 41, 68, 69, 40, 41, 77, 78,
      40, 43, 69, 70, 40, 45, 81, 82, 40, 47, 83, 85, 41, 43, 80, 81, 41, 45, 86, 87, 41, 46, 85, 86,
      42, 43, 88, 89, 42, 44, 87, 88,
    ],
    [
      29, 36, 83, 85, 29, 38, 82, 83, 30, 36, 85, 86, 30, 39, 80, 82, 32, 35, 86, 87, 32, 37, 79, 80,
      32, 38, 68, 69, 33, 36, 77, 79, 33, 38, 69, 72, 33, 39, 72, 75, 37, 38, 75, 76, 42, 49, 75, 79,
      43, 49, 79, 80, 46, 47, 73, 75, 47, 49, 80, 82,
    ],
    [
      27, 37, 75, 76, 28, 33, 73, 74, 28, 35, 74, 75, 29, 32, 72, 73, 29, 36, 76, 77, 30, 31, 71, 72,
      31, 35, 77, 78, 32, 34, 78, 79, 35, 41, 80, 84, 35, 42, 84, 89, 39, 46, 74, 75, 39, 48, 73, 74,
      40, 44, 75, 76, 40, 46, 71, 72, 40, 47, 72, 73, 41, 42, 68, 69, 41, 42, 76, 77, 41, 44, 69, 70,
      41, 45, 70, 71,
    ],
    [
      29, 36, 83, 85, 29, 38, 82, 83, 30, 36, 85, 86, 30, 39, 80, 82, 32, 35, 86, 87, 32, 37, 79, 80,
      32, 38, 68, 69, 33, 36, 77, 79, 33, 38, 69, 72, 33, 39, 72, 75, 37, 38, 75, 76, 42, 49, 75, 79,
      43, 49, 79, 80, 46, 47, 73, 75, 47, 49, 80, 82,
    ],
    [
      27, 32, 82, 83, 27, 36, 76, 82, 37, 42, 74, 75, 37, 43, 73, 74, 38, 42, 75, 76, 38, 44, 72, 73,
      39, 41, 76, 77, 39, 44, 70, 71, 39, 45, 71, 72, 39, 48, 82, 83, 40, 41, 68, 69, 40, 41, 77, 78,
      40, 43, 69, 70, 40, 45, 81, 82, 40, 47, 83, 85, 41, 43, 80, 81, 41, 45, 86, 87, 41, 46, 85, 86,
      42, 43, 88, 89, 42, 44, 87, 88,
    ],
    [
      28, 36, 72, 73, 28, 38, 73, 75, 29, 35, 70, 72, 29, 38, 75, 76, 30, 33, 69, 70, 32, 36, 76, 77,
      33, 35, 77, 79, 33, 40, 87, 89, 35, 40, 83, 86, 35, 42, 86, 87, 36, 40, 82, 83, 40, 43, 77, 79,
      40, 47, 73, 77, 46, 47, 72, 73,
    ],
  ]

  private static let topRightBladeFrames: [[Int]] = [
    [
      180, 187, 26, 27, 180, 188, 27, 28, 181, 186, 25, 26, 181, 189, 28, 29, 182, 190, 29, 30, 183,
      185, 24, 25, 184, 189, 30, 31, 184, 190, 42, 43, 185, 188, 31, 32, 185, 191, 40, 42, 186, 187,
      32, 33, 186, 191, 38, 40, 186, 192, 37, 38, 187, 190, 35, 36, 187, 190, 43, 44, 187, 192, 36, 37,
      194, 203, 30, 33, 195, 199, 34, 35, 195, 203, 33, 34, 196, 202, 29, 30, 198, 202, 28, 29, 200,
      202, 27, 28,
    ],
    [
      179, 189, 36, 38, 181, 186, 39, 41, 181, 189, 38, 39, 182, 183, 41, 42, 183, 189, 35, 36, 186,
      188, 34, 35, 188, 190, 31, 32, 188, 191, 22, 24, 188, 193, 24, 31, 191, 193, 31, 32, 193, 200,
      36, 38, 193, 202, 39, 41, 193, 203, 38, 39, 195, 196, 35, 36, 195, 202, 41, 42, 198, 200, 42, 43,
    ],
    [
      179, 188, 29, 32, 180, 181, 26, 27, 180, 183, 27, 28, 180, 186, 28, 29, 181, 187, 32, 33, 185,
      187, 33, 34, 188, 193, 37, 38, 188, 194, 38, 40, 188, 195, 40, 41, 189, 193, 44, 45, 189, 195,
      41, 42, 189, 196, 42, 44, 190, 193, 36, 37, 190, 197, 28, 29, 191, 196, 29, 30, 191, 198, 27, 28,
      192, 195, 30, 31, 192, 199, 26, 27, 193, 194, 31, 32, 193, 198, 24, 25, 193, 199, 25, 26, 194,
      198, 23, 24, 195, 197, 22, 23,
    ],
    [
      182, 189, 40, 42, 183, 187, 42, 44, 183, 189, 24, 25, 183, 189, 38, 40, 183, 190, 37, 38, 184,
      189, 23, 24, 184, 189, 35, 37, 184, 190, 25, 28, 186, 187, 44, 45, 186, 190, 30, 31, 186, 191,
      28, 30, 187, 189, 21, 23, 193, 201, 33, 35, 193, 203, 30, 33,
    ],
    [
      178, 186, 32, 33, 178, 187, 33, 36, 179, 181, 38, 39, 179, 183, 37, 38, 179, 185, 36, 37, 182,
      186, 31, 32, 189, 194, 29, 30, 189, 195, 28, 29, 190, 195, 26, 28, 190, 196, 24, 26, 191, 194,
      22, 23, 191, 194, 30, 31, 191, 197, 23, 24, 191, 199, 36, 37, 192, 197, 35, 36, 192, 200, 37, 38,
      193, 196, 34, 35, 193, 201, 38, 39, 194, 195, 33, 34, 194, 201, 39, 40, 195, 200, 40, 41, 196,
      198, 41, 42,
    ],
    [
      182, 189, 40, 42, 183, 187, 42, 44, 183, 189, 24, 25, 183, 189, 38, 40, 183, 190, 37, 38, 184,
      189, 23, 24, 184, 189, 35, 37, 184, 190, 25, 28, 186, 187, 44, 45, 186, 190, 30, 31, 186, 191,
      28, 30, 187, 189, 21, 23, 193, 201, 33, 35, 193, 203, 30, 33,
    ],
    [
      179, 188, 29, 32, 180, 181, 26, 27, 180, 183, 27, 28, 180, 186, 28, 29, 181, 187, 32, 33, 185,
      187, 33, 34, 188, 193, 37, 38, 188, 194, 38, 40, 188, 195, 40, 41, 189, 193, 44, 45, 189, 195,
      41, 42, 189, 196, 42, 44, 190, 193, 36, 37, 190, 197, 28, 29, 191, 196, 29, 30, 191, 198, 27, 28,
      192, 195, 30, 31, 192, 199, 26, 27, 193, 194, 31, 32, 193, 198, 24, 25, 193, 199, 25, 26, 194,
      198, 23, 24, 195, 197, 22, 23,
    ],
    [
      179, 189, 36, 38, 181, 186, 39, 41, 181, 189, 38, 39, 182, 183, 41, 42, 183, 189, 35, 36, 186,
      188, 34, 35, 188, 190, 31, 32, 188, 191, 22, 24, 188, 193, 24, 31, 191, 193, 31, 32, 193, 200,
      36, 38, 193, 202, 39, 41, 193, 203, 38, 39, 195, 196, 35, 36, 195, 202, 41, 42, 198, 200, 42, 43,
    ],
  ]

  private static let bottomRightBladeFrames: [[Int]] = [
    [
      181, 189, 90, 91, 182, 189, 91, 92, 182, 190, 89, 90, 183, 188, 92, 93, 183, 191, 88, 89, 184,
      187, 93, 94, 185, 190, 87, 88, 186, 187, 94, 95, 186, 188, 86, 87, 189, 196, 73, 82, 195, 205,
      88, 89, 196, 204, 87, 88, 196, 205, 89, 90, 197, 202, 86, 87, 198, 204, 90, 91, 199, 200, 85, 86,
      199, 203, 91, 92, 201, 203, 92, 93,
    ],
    [
      180, 182, 85, 87, 180, 187, 80, 82, 180, 189, 82, 85, 191, 192, 87, 88, 191, 197, 88, 89, 192,
      197, 89, 92, 192, 199, 92, 94, 192, 201, 78, 80, 193, 194, 95, 97, 193, 199, 94, 95, 193, 200,
      80, 81, 193, 203, 77, 78, 194, 199, 81, 82, 194, 201, 75, 77, 196, 197, 82, 84, 196, 200, 74, 75,
      197, 199, 72, 74,
    ],
    [
      182, 191, 76, 77, 183, 189, 74, 75, 183, 190, 75, 76, 184, 189, 73, 74, 184, 190, 92, 93, 184,
      191, 77, 78, 184, 191, 91, 92, 185, 188, 72, 73, 185, 190, 78, 79, 185, 191, 90, 91, 185, 192,
      89, 90, 186, 187, 71, 72, 186, 190, 93, 94, 186, 191, 88, 89, 187, 189, 94, 95, 187, 190, 79, 80,
      187, 190, 86, 87, 187, 191, 87, 88, 188, 189, 80, 81, 188, 189, 85, 86, 195, 204, 79, 86,
    ],
    [
      179, 188, 85, 86, 181, 184, 89, 91, 181, 188, 86, 89, 182, 188, 84, 85, 189, 196, 72, 74, 191,
      194, 79, 81, 191, 196, 74, 79, 192, 202, 88, 89, 194, 201, 86, 88, 194, 204, 89, 91, 195, 199,
      85, 86, 195, 202, 91, 92, 196, 198, 84, 85, 196, 201, 92, 93, 198, 199, 93, 95,
    ],
    [
      180, 189, 79, 80, 180, 190, 80, 81, 181, 187, 78, 79, 181, 189, 81, 82, 182, 184, 76, 77, 182,
      186, 77, 78, 183, 188, 82, 83, 185, 186, 83, 84, 189, 196, 87, 96, 194, 202, 80, 81, 195, 200,
      81, 82, 195, 203, 79, 80, 196, 203, 77, 78, 196, 204, 78, 79, 197, 199, 82, 83, 197, 202, 76, 77,
      198, 199, 74, 75, 198, 201, 75, 76,
    ],
    [
      179, 188, 85, 86, 181, 184, 89, 91, 181, 188, 86, 89, 182, 188, 84, 85, 189, 196, 72, 74, 191,
      194, 79, 81, 191, 196, 74, 79, 192, 202, 88, 89, 194, 201, 86, 88, 194, 204, 89, 91, 195, 199,
      85, 86, 195, 202, 91, 92, 196, 198, 84, 85, 196, 201, 92, 93, 198, 199, 93, 95,
    ],
    [
      182, 191, 77, 78, 183, 189, 75, 76, 183, 190, 76, 77, 184, 189, 74, 75, 184, 190, 93, 94, 184,
      191, 78, 79, 184, 191, 92, 93, 185, 188, 73, 74, 185, 190, 79, 80, 185, 191, 91, 92, 185, 192,
      90, 91, 186, 187, 72, 73, 186, 190, 94, 95, 186, 191, 89, 90, 187, 189, 95, 96, 187, 190, 80, 81,
      187, 190, 87, 88, 187, 191, 88, 89, 188, 189, 81, 82, 188, 189, 86, 87, 195, 204, 80, 87,
    ],
    [
      180, 182, 85, 87, 180, 187, 80, 82, 180, 189, 82, 85, 191, 192, 87, 88, 191, 197, 88, 89, 192,
      197, 89, 92, 192, 199, 92, 94, 192, 201, 78, 80, 193, 194, 95, 97, 193, 199, 94, 95, 193, 200,
      80, 81, 193, 203, 77, 78, 194, 199, 81, 82, 194, 201, 75, 77, 196, 197, 82, 84, 196, 200, 74, 75,
      197, 199, 72, 74,
    ],
  ]

  /// Each reel's housing silhouette, traced from the disc color only - the
  /// blade color is shared with the backing panel, so using it too would
  /// misidentify backing pixels as housing.
  private static let topLeftDiscRects: [Int] = [
    20, 49, 25, 32, 21, 48, 23, 25, 21, 48, 32, 34, 22, 47, 21, 23, 22, 47, 34, 36, 23, 46, 20, 21,
    23, 46, 36, 37, 24, 45, 19, 20, 24, 45, 37, 38, 25, 44, 18, 19, 25, 44, 38, 39, 26, 42, 39, 40,
    26, 43, 17, 18, 28, 41, 16, 17, 28, 41, 40, 41, 30, 38, 15, 16, 31, 38, 41, 42,
  ]

  private static let bottomLeftDiscRects: [Int] = [
    23, 53, 75, 82, 24, 52, 72, 75, 24, 52, 82, 85, 25, 51, 71, 72, 25, 51, 85, 86, 26, 50, 69, 71,
    26, 50, 86, 88, 27, 49, 68, 69, 27, 49, 88, 89, 28, 47, 89, 90, 28, 48, 67, 68, 30, 46, 66, 67,
    30, 46, 90, 91, 31, 45, 65, 66, 31, 45, 91, 92, 34, 42, 64, 65, 34, 42, 92, 93,
  ]

  private static let topRightDiscRects: [Int] = [
    174, 207, 29, 37, 175, 206, 27, 29, 175, 206, 37, 39, 176, 205, 25, 27, 176, 205, 39, 41, 177,
    204, 24, 25, 177, 204, 41, 42, 178, 203, 23, 24, 178, 203, 42, 43, 179, 202, 22, 23, 179, 202,
    43, 44, 180, 201, 21, 22, 180, 201, 44, 45, 181, 200, 20, 21, 181, 200, 45, 46, 183, 198, 19, 20,
    183, 198, 46, 47, 186, 195, 18, 19, 186, 195, 47, 48,
  ]

  private static let bottomRightDiscRects: [Int] = [
    174, 211, 81, 88, 175, 210, 78, 81, 175, 210, 88, 91, 176, 209, 76, 78, 176, 209, 91, 93, 177,
    208, 75, 76, 177, 208, 93, 94, 178, 207, 74, 75, 178, 207, 94, 95, 179, 206, 73, 74, 179, 206,
    95, 96, 180, 205, 72, 73, 180, 205, 96, 97, 181, 203, 97, 98, 181, 204, 71, 72, 183, 202, 70, 71,
    183, 202, 98, 99, 185, 200, 69, 70, 185, 200, 99, 100, 188, 197, 68, 69, 188, 197, 100, 101,
  ]

  /// Fills the reel-sized holes left in the static backing (cut out so one
  /// frame's blade pixels wouldn't get baked into the backing color).
  /// Generous rects are fine since the disc and blade always draw on top.
  private static let reelBackingPatches: [(x: Range<Int>, y: Range<Int>)] = [
    (19..<50, 13..<44),  // Left module, top reel.
    (21..<56, 61..<95),  // Left module, bottom reel.
    (173..<208, 16..<51),  // Right module, top reel.
    (174..<211, 66..<102),  // Right module, bottom reel.
  ]

  static let reels: [Reel] = [
    // Left module, top reel.
    Reel(
      discRole: \.background, discSpans: spans(from: topLeftDiscRects), bladeRole: \.accent,
      bladeFrames: topLeftBladeFrames.map(spans(from:)), ticksPerStep: 2),
    // Left module, bottom reel.
    Reel(
      discRole: \.background, discSpans: spans(from: bottomLeftDiscRects), bladeRole: \.secondary,
      bladeFrames: bottomLeftBladeFrames.map(spans(from:)), ticksPerStep: 2),
    // Right module, top reel: redraws (and so wobbles) twice as fast.
    Reel(
      discRole: \.background, discSpans: spans(from: topRightDiscRects), bladeRole: \.secondary,
      bladeFrames: topRightBladeFrames.map(spans(from:)), ticksPerStep: 1),
    // Right module, bottom reel: redraws (and so wobbles) twice as fast.
    Reel(
      discRole: \.primary, discSpans: spans(from: bottomRightDiscRects), bladeRole: \.secondary,
      bladeFrames: bottomRightBladeFrames.map(spans(from:)), ticksPerStep: 1),
  ]

  /// Every non-reel pixel's exact color, extracted from the source GIF as
  /// vertically-merged (xStart, xEnd, yStart, yEnd) rectangles, 4 numbers
  /// per rectangle. This preserves the hand-inked, slightly irregular edges
  /// of the original artwork instead of rounding them off to clean rects.
  private static let primaryRects: [Int] = [
    1, 6, 2, 24, 1, 7, 24, 68, 1, 8, 68, 87, 1, 57, 1, 2, 2, 8, 87, 112, 2, 9, 112, 156, 2, 10, 156,
    173, 11, 39, 178, 179, 11, 66, 173, 178, 13, 177, 2, 3, 25, 237, 3, 4, 37, 237, 4, 5, 49, 212, 5,
    6, 61, 178, 6, 7, 67, 75, 7, 92, 68, 75, 92, 93, 68, 76, 93, 173, 78, 153, 173, 178, 79, 143, 13,
    17, 80, 143, 17, 25, 81, 91, 92, 96, 81, 92, 75, 80, 81, 143, 25, 32, 82, 90, 91, 92, 82, 90, 96,
    97, 82, 91, 74, 75, 82, 91, 80, 81, 82, 143, 32, 36, 83, 89, 90, 91, 83, 89, 97, 98, 83, 90, 73,
    74, 83, 90, 81, 82, 84, 88, 89, 90, 84, 88, 98, 99, 84, 89, 72, 73, 84, 89, 82, 83, 94, 160, 7,
    8, 97, 107, 86, 88, 97, 143, 36, 37, 98, 106, 88, 89, 99, 105, 89, 90, 100, 104, 90, 91, 115,
    152, 178, 179, 116, 127, 76, 81, 116, 127, 92, 97, 117, 126, 75, 76, 117, 126, 81, 82, 117, 126,
    91, 92, 117, 126, 97, 98, 118, 125, 74, 75, 118, 125, 82, 83, 118, 125, 90, 91, 118, 125, 98, 99,
    119, 124, 73, 74, 119, 124, 83, 84, 119, 124, 89, 90, 119, 124, 99, 100, 128, 143, 37, 38, 130,
    153, 172, 173, 130, 160, 8, 9, 133, 143, 91, 95, 133, 144, 76, 81, 134, 142, 90, 91, 134, 142,
    95, 96, 134, 143, 75, 76, 134, 143, 81, 82, 135, 141, 89, 90, 135, 141, 96, 97, 135, 142, 74, 75,
    135, 142, 82, 83, 136, 140, 88, 89, 136, 140, 97, 98, 136, 141, 73, 74, 136, 141, 83, 84, 150,
    160, 9, 30, 150, 161, 30, 47, 151, 161, 47, 71, 151, 162, 71, 86, 152, 162, 86, 114, 152, 163,
    114, 126, 153, 163, 126, 156, 153, 164, 156, 160, 154, 164, 160, 172, 165, 182, 178, 179, 165,
    216, 177, 178, 165, 233, 172, 177, 168, 183, 126, 127, 168, 184, 119, 120, 168, 185, 120, 121,
    168, 186, 121, 122, 168, 205, 122, 123, 168, 212, 125, 126, 168, 227, 123, 125, 169, 184, 116,
    119, 169, 185, 115, 116, 169, 186, 114, 115, 169, 198, 111, 112, 169, 227, 112, 114, 173, 183,
    133, 137, 174, 175, 84, 85, 174, 176, 81, 84, 174, 176, 85, 88, 174, 182, 132, 133, 174, 182,
    137, 138, 175, 176, 79, 81, 175, 176, 88, 90, 175, 177, 78, 79, 175, 177, 90, 91, 175, 181, 131,
    132, 175, 181, 138, 139, 176, 177, 76, 78, 176, 177, 91, 93, 177, 178, 75, 76, 177, 178, 93, 94,
    178, 179, 74, 75, 178, 179, 94, 95, 179, 180, 73, 74, 179, 180, 95, 96, 181, 182, 71, 72, 181,
    182, 97, 98, 190, 204, 121, 122, 190, 205, 114, 115, 191, 203, 120, 121, 191, 204, 115, 116,
    192, 202, 134, 137, 192, 203, 116, 120, 193, 201, 133, 134, 193, 201, 137, 138, 194, 200, 132,
    133, 194, 200, 138, 139, 195, 199, 131, 132, 195, 199, 139, 140, 203, 204, 71, 72, 205, 206, 73,
    74, 205, 206, 95, 96, 206, 207, 74, 75, 206, 207, 94, 95, 207, 208, 75, 76, 207, 208, 93, 94,
    208, 209, 76, 78, 208, 209, 91, 93, 208, 210, 78, 79, 208, 210, 90, 91, 209, 210, 79, 81, 209,
    210, 88, 90, 209, 211, 81, 84, 209, 211, 85, 88, 209, 227, 114, 115, 209, 227, 122, 123, 210,
    211, 84, 85, 210, 220, 132, 135, 210, 227, 115, 116, 210, 227, 121, 122, 211, 219, 131, 132, 211,
    219, 135, 136, 211, 227, 116, 121, 212, 218, 130, 131, 212, 218, 136, 137, 213, 217, 129, 130,
    213, 217, 137, 138, 230, 237, 5, 34, 231, 237, 34, 42, 231, 238, 42, 91, 232, 238, 91, 128, 232,
    239, 128, 148, 233, 239, 148, 172,
  ]

  private static let backgroundRects: [Int] = [
    6, 12, 9, 24, 6, 13, 2, 3, 6, 25, 3, 4, 6, 37, 4, 5, 6, 49, 5, 6, 6, 61, 6, 7, 6, 67, 7, 9, 7, 12,
    24, 55, 7, 13, 55, 68, 8, 13, 68, 100, 8, 21, 100, 101, 8, 50, 101, 102, 8, 68, 102, 112, 9, 68,
    112, 156, 10, 68, 156, 173, 21, 67, 9, 10, 36, 67, 10, 11, 42, 56, 53, 57, 43, 57, 47, 51, 52,
    67, 11, 12, 59, 67, 12, 57, 60, 67, 57, 92, 60, 68, 92, 102, 75, 81, 92, 93, 75, 82, 91, 92, 75,
    83, 90, 91, 75, 84, 89, 90, 75, 97, 86, 88, 75, 98, 88, 89, 76, 81, 93, 96, 76, 82, 96, 97, 76,
    83, 97, 98, 76, 84, 98, 99, 76, 96, 102, 103, 76, 119, 99, 100, 76, 134, 101, 102, 76, 152, 100,
    101, 80, 111, 51, 52, 80, 143, 46, 51, 81, 112, 39, 40, 81, 143, 40, 46, 88, 99, 89, 90, 88, 118,
    98, 99, 89, 100, 90, 91, 89, 117, 97, 98, 90, 116, 96, 97, 90, 117, 91, 92, 91, 116, 92, 96, 104,
    118, 90, 91, 105, 119, 89, 90, 106, 136, 88, 89, 107, 152, 86, 88, 124, 135, 89, 90, 124, 152,
    99, 100, 125, 134, 90, 91, 125, 152, 98, 99, 126, 133, 91, 92, 126, 136, 97, 98, 127, 133, 92,
    95, 127, 134, 95, 96, 127, 135, 96, 97, 140, 152, 88, 89, 140, 152, 97, 98, 141, 152, 89, 90,
    141, 152, 96, 97, 142, 152, 90, 91, 142, 152, 95, 96, 143, 152, 91, 95, 160, 165, 15, 30, 160,
    166, 14, 15, 160, 181, 13, 14, 160, 210, 12, 13, 160, 230, 7, 12, 161, 165, 30, 60, 161, 166, 60,
    71, 162, 166, 71, 105, 162, 169, 111, 114, 162, 232, 105, 111, 163, 168, 119, 145, 163, 168, 151,
    156, 163, 169, 114, 119, 163, 197, 150, 151, 163, 232, 145, 148, 163, 233, 148, 150, 164, 167,
    160, 169, 164, 168, 156, 160, 164, 198, 169, 170, 164, 233, 170, 172, 174, 175, 29, 33, 174, 175,
    34, 37, 175, 176, 27, 28, 176, 177, 25, 26, 178, 230, 6, 7, 184, 232, 144, 145, 196, 232, 104,
    105, 198, 232, 111, 112, 204, 205, 25, 26, 205, 206, 27, 28, 206, 207, 29, 33, 206, 207, 34, 37,
    209, 221, 59, 63, 210, 221, 52, 57, 212, 230, 5, 6, 212, 232, 143, 144, 224, 230, 12, 34, 224,
    231, 34, 57, 225, 231, 57, 91, 225, 232, 91, 104, 227, 232, 112, 143, 227, 233, 150, 160, 228,
    233, 160, 170,
  ]

  private static let secondaryRects: [Int] = [
    12, 16, 47, 51, 12, 17, 51, 53, 12, 18, 53, 55, 12, 19, 28, 29, 12, 20, 23, 28, 12, 20, 29, 34,
    12, 21, 9, 10, 12, 21, 21, 23, 12, 21, 34, 36, 12, 22, 19, 21, 12, 22, 36, 38, 12, 23, 18, 19,
    12, 23, 38, 39, 12, 24, 17, 18, 12, 24, 39, 40, 12, 25, 16, 17, 12, 25, 40, 41, 12, 27, 15, 16,
    12, 27, 41, 42, 12, 29, 14, 15, 12, 29, 42, 43, 12, 34, 13, 14, 12, 34, 43, 44, 12, 36, 10, 11,
    12, 52, 11, 12, 12, 59, 12, 13, 12, 59, 44, 47, 13, 22, 78, 79, 13, 23, 73, 78, 13, 23, 79, 84,
    13, 24, 71, 73, 13, 24, 84, 86, 13, 25, 69, 71, 13, 25, 86, 88, 13, 26, 68, 69, 13, 26, 88, 89,
    13, 27, 67, 68, 13, 27, 89, 90, 13, 28, 66, 67, 13, 28, 90, 91, 13, 29, 55, 56, 13, 29, 65, 66,
    13, 29, 91, 92, 13, 31, 64, 65, 13, 31, 92, 93, 13, 33, 63, 64, 13, 33, 93, 94, 13, 38, 62, 63,
    13, 38, 94, 95, 13, 42, 56, 57, 13, 60, 57, 62, 13, 60, 95, 100, 21, 60, 100, 101, 29, 43, 47,
    48, 35, 59, 13, 14, 35, 59, 43, 44, 38, 42, 53, 56, 38, 59, 52, 53, 39, 43, 48, 51, 39, 59, 51,
    52, 39, 60, 62, 63, 39, 60, 94, 95, 40, 59, 14, 15, 40, 59, 42, 43, 42, 59, 15, 16, 42, 59, 41,
    42, 44, 59, 16, 17, 44, 59, 40, 41, 44, 60, 63, 64, 44, 60, 93, 94, 45, 59, 17, 18, 45, 59, 39,
    40, 46, 59, 18, 19, 46, 59, 38, 39, 46, 60, 64, 65, 46, 60, 92, 93, 47, 59, 19, 21, 47, 59, 36,
    38, 48, 59, 21, 23, 48, 59, 34, 36, 48, 60, 65, 66, 48, 60, 91, 92, 49, 59, 23, 28, 49, 59, 29,
    34, 49, 60, 66, 67, 49, 60, 90, 91, 50, 59, 28, 29, 50, 60, 67, 68, 50, 60, 89, 90, 50, 60, 101,
    102, 51, 60, 68, 69, 51, 60, 88, 89, 52, 60, 69, 71, 52, 60, 86, 88, 53, 60, 71, 73, 53, 60, 84,
    86, 54, 60, 73, 78, 54, 60, 79, 84, 55, 60, 78, 79, 56, 59, 53, 57, 57, 59, 47, 51, 75, 79, 13,
    17, 75, 80, 17, 25, 75, 80, 46, 52, 75, 80, 57, 63, 75, 81, 25, 32, 75, 81, 39, 46, 75, 81, 63,
    70, 75, 81, 75, 80, 75, 82, 32, 36, 75, 82, 74, 75, 75, 82, 80, 81, 75, 83, 73, 74, 75, 83, 81,
    82, 75, 84, 72, 73, 75, 84, 82, 83, 75, 94, 7, 8, 75, 97, 36, 37, 75, 111, 56, 57, 75, 119, 83,
    84, 75, 128, 37, 38, 75, 130, 8, 9, 75, 150, 9, 13, 75, 150, 38, 39, 75, 151, 52, 56, 75, 151,
    70, 72, 75, 151, 84, 86, 76, 130, 172, 173, 76, 152, 103, 126, 76, 153, 126, 160, 76, 154, 160,
    172, 89, 118, 82, 83, 89, 151, 72, 73, 90, 117, 81, 82, 90, 119, 73, 74, 91, 116, 80, 81, 91,
    118, 74, 75, 92, 116, 76, 80, 92, 117, 75, 76, 96, 152, 102, 103, 111, 151, 51, 52, 112, 150, 39,
    40, 112, 151, 69, 70, 124, 136, 73, 74, 124, 136, 83, 84, 125, 135, 74, 75, 125, 135, 82, 83,
    126, 134, 75, 76, 126, 134, 81, 82, 127, 133, 76, 81, 134, 152, 101, 102, 137, 151, 56, 57, 141,
    151, 73, 74, 141, 151, 83, 84, 142, 151, 74, 75, 142, 151, 82, 83, 143, 150, 13, 38, 143, 150,
    40, 47, 143, 151, 47, 51, 143, 151, 57, 69, 143, 151, 75, 76, 143, 151, 81, 82, 144, 151, 76, 81,
    165, 172, 54, 55, 165, 173, 55, 58, 165, 174, 29, 37, 165, 174, 58, 60, 165, 175, 27, 29, 165,
    175, 37, 39, 165, 176, 25, 27, 165, 176, 39, 41, 165, 177, 24, 25, 165, 177, 41, 43, 165, 178,
    23, 24, 165, 178, 43, 44, 165, 179, 22, 23, 165, 179, 44, 45, 165, 180, 21, 22, 165, 180, 45, 46,
    165, 181, 20, 21, 165, 181, 46, 47, 165, 183, 19, 20, 165, 183, 47, 48, 165, 185, 18, 19, 165,
    185, 48, 49, 165, 190, 17, 18, 165, 190, 49, 50, 165, 210, 52, 54, 165, 224, 15, 17, 165, 224,
    50, 52, 166, 174, 60, 62, 166, 174, 81, 88, 166, 175, 78, 81, 166, 175, 88, 91, 166, 176, 76, 78,
    166, 176, 91, 93, 166, 177, 75, 76, 166, 177, 93, 94, 166, 178, 74, 75, 166, 178, 94, 95, 166,
    179, 73, 74, 166, 179, 95, 96, 166, 180, 72, 73, 166, 180, 96, 97, 166, 181, 71, 72, 166, 181,
    97, 98, 166, 183, 70, 71, 166, 183, 98, 99, 166, 184, 69, 70, 166, 184, 99, 100, 166, 187, 68,
    69, 166, 187, 100, 101, 166, 192, 67, 68, 166, 192, 101, 102, 166, 196, 104, 105, 166, 209, 62,
    63, 166, 224, 14, 15, 166, 225, 63, 67, 166, 225, 102, 104, 168, 173, 133, 137, 168, 174, 132,
    133, 168, 174, 137, 138, 168, 175, 131, 132, 168, 175, 138, 139, 168, 184, 144, 145, 168, 195,
    139, 140, 168, 212, 130, 131, 168, 212, 143, 144, 168, 213, 129, 130, 168, 227, 127, 129, 168,
    227, 140, 143, 181, 194, 138, 139, 181, 195, 131, 132, 181, 224, 13, 14, 182, 193, 137, 138, 182,
    194, 132, 133, 183, 192, 134, 137, 183, 193, 133, 134, 183, 227, 126, 127, 184, 192, 116, 120,
    185, 191, 115, 116, 185, 191, 120, 121, 186, 190, 114, 115, 186, 190, 121, 122, 189, 209, 61,
    62, 191, 224, 17, 18, 191, 224, 49, 50, 193, 225, 67, 68, 193, 225, 101, 102, 196, 224, 18, 19,
    196, 224, 48, 49, 198, 224, 19, 20, 198, 224, 47, 48, 198, 225, 68, 69, 198, 225, 100, 101, 199,
    211, 131, 132, 199, 227, 139, 140, 200, 210, 132, 133, 200, 224, 20, 21, 200, 224, 46, 47, 200,
    227, 138, 139, 201, 210, 133, 134, 201, 213, 137, 138, 201, 224, 21, 22, 201, 224, 45, 46, 201,
    225, 69, 70, 201, 225, 99, 100, 202, 210, 134, 135, 202, 211, 135, 136, 202, 212, 136, 137, 202,
    224, 22, 23, 202, 224, 44, 45, 202, 225, 70, 71, 202, 225, 98, 99, 203, 211, 116, 121, 203, 224,
    23, 24, 203, 224, 43, 44, 203, 225, 97, 98, 204, 210, 115, 116, 204, 210, 121, 122, 204, 224, 24,
    25, 204, 224, 41, 43, 204, 225, 71, 72, 205, 209, 114, 115, 205, 209, 122, 123, 205, 224, 25, 27,
    205, 224, 39, 41, 205, 225, 72, 73, 205, 225, 96, 97, 206, 209, 59, 61, 206, 224, 27, 29, 206,
    224, 37, 39, 206, 225, 57, 59, 206, 225, 73, 74, 206, 225, 95, 96, 207, 210, 54, 57, 207, 224,
    29, 37, 207, 225, 74, 75, 207, 225, 94, 95, 208, 225, 75, 76, 208, 225, 93, 94, 209, 225, 76, 78,
    209, 225, 91, 93, 210, 224, 12, 13, 210, 225, 78, 81, 210, 225, 88, 91, 211, 225, 81, 88, 212,
    227, 125, 126, 217, 227, 129, 130, 217, 227, 137, 138, 218, 227, 130, 131, 218, 227, 136, 137,
    219, 227, 131, 132, 219, 227, 135, 136, 220, 227, 132, 135, 221, 224, 52, 57, 221, 225, 59, 63,
  ]

  private static let accentRects: [Int] = [
    16, 29, 47, 48, 16, 39, 48, 51, 17, 38, 52, 53, 17, 39, 51, 52, 18, 38, 53, 55, 29, 38, 55, 56,
    80, 143, 57, 63, 81, 112, 69, 70, 81, 143, 63, 69, 111, 137, 56, 57, 167, 228, 160, 169, 168,
    227, 151, 160, 172, 207, 54, 55, 173, 206, 57, 58, 173, 207, 55, 57, 174, 189, 61, 62, 174, 206,
    58, 61, 197, 227, 150, 151, 198, 228, 169, 170,
  ]

  private static func spans(from flatRects: [Int]) -> [PixelSpan] {
    var result: [PixelSpan] = []
    for i in stride(from: 0, to: flatRects.count, by: 4) {
      let xs = flatRects[i], xe = flatRects[i + 1], ys = flatRects[i + 2], ye = flatRects[i + 3]
      result.append(contentsOf: Raster.rect(x: xs..<xe, y: ys..<ye))
    }
    return result
  }

  static let staticLayers: [Layer] = {
    var layers: [Layer] = [
      Layer(role: \.primary, spans: spans(from: primaryRects)),
      Layer(role: \.background, spans: spans(from: backgroundRects)),
      Layer(role: \.secondary, spans: spans(from: secondaryRects)),
      Layer(role: \.accent, spans: spans(from: accentRects)),
      Layer(role: \.secondary, spans: reelBackingPatches.flatMap { Raster.rect(x: $0.x, y: $0.y) }),
    ]
    for reel in reels {
      layers.append(Layer(role: reel.discRole, spans: reel.discSpans))
    }
    return layers
  }()
}

#Preview("Classic") {
  ComputerView()
    .padding()
}

#Preview("Custom Palette") {
  ComputerView(
    model: .init(palette: .init(primary: .black, background: .yellow, secondary: .brown, accent: .red)))
    .padding()
}

#Preview("Small") {
  ComputerView()
    .frame(width: 60, height: 45)
}

#Preview("Large") {
  ComputerView()
    .frame(width: 960, height: 720)
}

#Preview("Cycling Palette") {
  let palettes: [ComputerView.Palette] = [
    .classic,
    .init(primary: .black, background: .yellow, secondary: .brown, accent: .red),
    .init(primary: .indigo, background: .mint, secondary: .purple, accent: .orange),
  ]
  ComputerPaletteCyclingPreview(palettes: palettes)
}

/// Demonstrates driving `ComputerView` externally: owns the `Model`, and a
/// `.task` cycles its `palette` on a timer while this view does nothing
/// else - `ComputerView` picks up each change and eases into it on its own.
private struct ComputerPaletteCyclingPreview: View {
  let palettes: [ComputerView.Palette]

  @State private var model = ComputerView.Model()

  var body: some View {
    ComputerView(model: model)
      .padding()
      .task {
        var index = 0
        while !Task.isCancelled {
          try? await Task.sleep(for: .seconds(2))
          index = (index + 1) % palettes.count
          model.palette = palettes[index]
        }
      }
  }
}

#Preview("Accent HDR Brightness") {
  ComputerAccentHDRBrightnessPreview()
}

private struct ComputerAccentHDRBrightnessPreview: View {
  @State private var model = ComputerView.Model()
  @State private var amount = 0.0

  var body: some View {
    ComputerView(model: model)
      .accentHDRBrightness(amount)
      .padding()
      .task {
        let start = Date.now
        while !Task.isCancelled {
          let elapsed = Date.now.timeIntervalSince(start)
          amount = (sin(elapsed * 2 * .pi / 4) + 1) / 2
          try? await Task.sleep(for: .seconds(1.0 / 30))
        }
      }
  }
}
