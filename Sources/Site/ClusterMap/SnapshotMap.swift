//
//  SnapshotMap.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 10/31/26.
//

import MapKit
import SwiftUI
import os

extension Logger {
  fileprivate static let snapshotMap = Logger(category: "snapshotMap")
}

#if canImport(UIKit)
  private typealias PlatformImage = UIImage

  extension Image {
    fileprivate init(platformImage: PlatformImage) { self.init(uiImage: platformImage) }
  }
#else
  private typealias PlatformImage = NSImage

  extension Image {
    fileprivate init(platformImage: PlatformImage) { self.init(nsImage: platformImage) }
  }
#endif

/// What a snapshot shows: the part of the map, at a size and appearance.
private struct SnapshotRequest: Hashable {
  let x: Double
  let y: Double
  let width: Double
  let height: Double
  let size: CGSize
  let isDark: Bool
  let scale: CGFloat
  /// Where the dots are, which decides where they are drawn.
  let coordinates: [Coordinate]

  struct Coordinate: Hashable {
    let latitude: Double
    let longitude: Double
  }

  var mapRect: MKMapRect { MKMapRect(x: x, y: y, width: width, height: height) }

  init(
    mapRect: MKMapRect, size: CGSize, isDark: Bool, scale: CGFloat,
    coordinates: [CLLocationCoordinate2D]
  ) {
    self.x = mapRect.minX
    self.y = mapRect.minY
    self.width = mapRect.width
    self.height = mapRect.height
    self.size = size
    self.isDark = isDark
    self.scale = scale
    self.coordinates = coordinates.map { Coordinate(latitude: $0.latitude, longitude: $0.longitude) }
  }

  var cacheKey: NSString { "\(hashValue)" as NSString }
}

/// A rendered map with where its dots go. Only the image is kept, not the snapshot.
private final class ShownSnapshot {
  let request: SnapshotRequest
  let image: PlatformImage
  let dotPoints: [CGPoint]

  init(request: SnapshotRequest, image: PlatformImage, dotPoints: [CGPoint]) {
    self.request = request
    self.image = image
    self.dotPoints = dotPoints
  }

  /// The bytes the image's pixels take.
  var cost: Int {
    Int(request.size.width * request.scale * request.size.height * request.scale * 4)
  }
}

/// Header images are several megabytes each, so only a few are kept.
@MainActor private let snapshotCache: NSCache<NSString, ShownSnapshot> = {
  let cache = NSCache<NSString, ShownSnapshot>()
  cache.totalCostLimit = 30 * 1024 * 1024
  return cache
}()

extension MKMapRect {
  fileprivate func zoomedOut(by factor: Double) -> MKMapRect {
    guard factor > 1.0 else { return self }
    return MKMapRect(
      x: midX - width * factor / 2.0, y: midY - height * factor / 2.0,
      width: width * factor, height: height * factor)
  }
}

/// A still image of a map with dots drawn over it, for a map that is never touched. Unlike a live
/// map it keeps no tiles or rendering state, so having many costs little.
struct SnapshotMap<Item: Identifiable, Dot: View>: View {
  let items: [Item]
  let coordinate: (Item) -> CLLocationCoordinate2D
  /// How many times wider than the items the fit shows.
  let fitZoomOutFactor: Double
  /// The fraction of the map's height, from the bottom, that the fit leaves clear.
  var fitBottomFraction: Double = 0.0
  /// Dots closer together than this show as one.
  let dotSize: CGFloat
  /// Whether a new map fades in over the last one.
  var animatesChanges = false
  /// The items of the maps either side, made ahead into the cache so paging shows them at once.
  var neighborItems: [[Item]] = []
  @ViewBuilder let dot: () -> Dot

  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.displayScale) private var displayScale
  @State private var size = CGSize.zero
  @State private var insets = EdgeInsets()
  @State private var shown: ShownSnapshot?

  /// How much of the top inset, the bars, items may spill into above and below the clear area.
  private static var spillFraction: CGFloat { 0.45 }

  private var coordinates: [CLLocationCoordinate2D] { coordinates(of: items) }

  private func coordinates(of items: [Item]) -> [CLLocationCoordinate2D] {
    items.map(coordinate).filter(CLLocationCoordinate2DIsValid)
  }

  /// The map rect that shows the items centered in the area the bars and the fade leave clear.
  private func fittedRect(for coordinates: [CLLocationCoordinate2D]) -> MKMapRect? {
    let itemsRect = coordinates.reduce(MKMapRect.null) { $0.union($1.rect) }
    guard !itemsRect.isNull else { return nil }
    let rect = itemsRect.proportionallyPadded.zoomedOut(by: fitZoomOutFactor)

    let bottom = insets.bottom + size.height * fitBottomFraction
    let areaWidth = size.width - insets.leading - insets.trailing
    let areaHeight = size.height - insets.top - bottom
    guard areaWidth > 0, areaHeight > 0, rect.width > 0, rect.height > 0 else { return nil }
    // Items spread far north to south can spill a little into the bars and the fade.
    let spill = fitBottomFraction > 0 ? insets.top * Self.spillFraction : 0
    let mapPointsPerPoint = max(rect.width / areaWidth, rect.height / (areaHeight + spill * 2.0))
    // The middle of the map, unless the bars leave less room above it than the fade does below.
    let centerY =
      fitBottomFraction > 0
      ? max(size.height / 2.0, insets.top + areaHeight / 2.0) : insets.top + areaHeight / 2.0
    return MKMapRect(
      x: rect.midX - (insets.leading + areaWidth / 2.0) * mapPointsPerPoint,
      y: rect.midY - centerY * mapPointsPerPoint,
      width: size.width * mapPointsPerPoint, height: size.height * mapPointsPerPoint)
  }

  private var request: SnapshotRequest? { request(for: coordinates) }

  private func request(for coordinates: [CLLocationCoordinate2D]) -> SnapshotRequest? {
    let size = CGSize(width: size.width.rounded(), height: size.height.rounded())
    guard size.width > 0, size.height > 0, let mapRect = fittedRect(for: coordinates) else {
      return nil
    }
    return SnapshotRequest(
      mapRect: mapRect, size: size, isDark: colorScheme == .dark, scale: displayScale,
      coordinates: coordinates)
  }

  /// What to make ahead: the maps either side, at this map's size and appearance.
  private var neighborRequests: [(SnapshotRequest, [CLLocationCoordinate2D])] {
    neighborItems.compactMap { items in
      let coordinates = coordinates(of: items)
      return request(for: coordinates).map { ($0, coordinates) }
    }
  }

  /// Where the dots go; dots closer together than a dot show as one.
  private func dotPoints(
    in snapshot: MKMapSnapshotter.Snapshot, for coordinates: [CLLocationCoordinate2D]
  ) -> [CGPoint] {
    var points = [CGPoint]()
    for coordinate in coordinates {
      #if canImport(UIKit)
        let point = snapshot.point(for: coordinate)
      #else
        // AppKit's snapshot points start at the bottom of the image; SwiftUI's start at the top.
        let flipped = snapshot.point(for: coordinate)
        let point = CGPoint(x: flipped.x, y: snapshot.image.size.height - flipped.y)
      #endif
      guard !points.contains(where: { hypot($0.x - point.x, $0.y - point.y) < dotSize }) else {
        continue
      }
      points.append(point)
    }
    return points
  }

  var body: some View {
    ZStack(alignment: .topLeading) {
      if let shown {
        ZStack(alignment: .topLeading) {
          Image(platformImage: shown.image)
            .resizable()
            .frame(width: shown.request.size.width, height: shown.request.size.height)
          ForEach(Array(shown.dotPoints.enumerated()), id: \.offset) {
            dot().position($0.element)
          }
        }
        .id(shown.request)
        .transition(.opacity)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .onGeometryChange(for: CGSize.self) { $0.size } action: { size = $0 }
    .onGeometryChange(for: EdgeInsets.self) { $0.safeAreaInsets } action: { insets = $0 }
    .task(id: request) {
      let neighborRequests = neighborRequests
      // With no items there is nothing to fit, so the last map stays.
      if let request, let shown = await snapshot(for: request, coordinates: coordinates) {
        present(shown)
      }
      // One at a time, after this map, and given up when this map changes.
      for (request, coordinates) in neighborRequests {
        guard !Task.isCancelled else { return }
        _ = await snapshot(for: request, coordinates: coordinates)
      }
    }
  }

  /// The cached map for the request, or a new one, which is cached.
  private func snapshot(
    for request: SnapshotRequest, coordinates: [CLLocationCoordinate2D]
  ) async -> ShownSnapshot? {
    if let cached = snapshotCache.object(forKey: request.cacheKey) {
      return cached
    }

    let options = MKMapSnapshotter.Options()
    options.mapRect = request.mapRect
    options.size = request.size
    let configuration = MKStandardMapConfiguration(emphasisStyle: .muted)
    configuration.pointOfInterestFilter = .excludingAll
    options.preferredConfiguration = configuration
    #if canImport(UIKit)
      options.traitCollection = UITraitCollection { traits in
        traits.userInterfaceStyle = request.isDark ? .dark : .light
        traits.displayScale = request.scale
      }
    #else
      options.appearance = NSAppearance(named: request.isDark ? .darkAqua : .aqua)
    #endif

    nonisolated(unsafe) let snapshotter = MKMapSnapshotter(options: options)
    do {
      let snapshot = try await withTaskCancellationHandler {
        try await snapshotter.start()
      } onCancel: {
        snapshotter.cancel()
      }
      guard !Task.isCancelled else { return nil }
      let shown = ShownSnapshot(
        request: request, image: snapshot.image,
        dotPoints: dotPoints(in: snapshot, for: coordinates))
      snapshotCache.setObject(shown, forKey: request.cacheKey, cost: shown.cost)
      return shown
    } catch {
      if !Task.isCancelled {
        Logger.snapshotMap.error("snapshot failed: \(error, privacy: .public)")
      }
      return nil
    }
  }

  private func present(_ shown: ShownSnapshot) {
    withAnimation(animatesChanges ? .default : nil) {
      self.shown = shown
    }
  }
}
