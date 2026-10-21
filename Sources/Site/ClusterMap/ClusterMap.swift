//
//  ClusterMap.swift
//  SiteApp
//
//  Created by Greg Bolsinga on 6/7/26.
//

import MapKit
import SwiftUI
import os

extension Logger {
  fileprivate static let clusterMap = Logger(category: "clusterMap")
}

extension String {
  fileprivate static let itemClusterIdentifier = "gdb.map.cluster.item"
  fileprivate static let itemAnnotationViewReuseIdentifier = "gdb.map.itemView.reuse"
  fileprivate static let clusterAnnotationViewReuseIdentifier = "gdb.map.clusterView.reuse"
}

#if canImport(UIKit)
  private typealias MapEdgeInsets = UIEdgeInsets
#else
  private typealias MapEdgeInsets = NSEdgeInsets
#endif

extension MKMapRect {
  fileprivate func isNearlyEqual(to other: MKMapRect) -> Bool {
    let tolerance = other.width * 0.001
    return abs(minX - other.minX) <= tolerance && abs(minY - other.minY) <= tolerance
      && abs(width - other.width) <= tolerance && abs(height - other.height) <= tolerance
  }
}

struct Details {
  let coordinate: CLLocationCoordinate2D
  let title: String
}

struct ClusterMap<
  Item: Identifiable, ItemContent: View, TitleContent: View, ClusterContent: View
>: ViewRepresentable {
  let items: any Collection<Item>
  let itemDetails: (Item) -> Details

  @ViewBuilder let itemContent: (Item) -> ItemContent
  /// Drawn below the item, outside its frame, so it isn't part of what makes items cluster.
  @ViewBuilder let itemTitle: (Item) -> TitleContent
  @ViewBuilder let clusterContent: (Int) -> ClusterContent

  let onSelect: (Item) -> Void

  /// What VoiceOver says for a cluster of this many items.
  let clusterLabel: (Int) -> String

  /// Distance from the top of the content to the point placed on the coordinate. The bottom if nil.
  let anchorY: CGFloat?

  /// Once the user moves the map it is no longer fit as items change. A new value starts over.
  let resetID: UUID?

  let animatesFit: Bool

  /// A quieter base map: muted, without points of interest.
  let isSubdued: Bool

  /// While searching, the map returns to where it was when the search began if nothing matches.
  let isSearching: Bool

  init(
    items: any Collection<Item>,
    anchorY: CGFloat? = nil,
    resetID: UUID? = nil,
    animatesFit: Bool = true,
    isSubdued: Bool = false,
    isSearching: Bool = false,
    itemDetails: @escaping (Item) -> Details,
    onSelect: @escaping (Item) -> Void,
    clusterLabel: @escaping (Int) -> String,
    @ViewBuilder itemContent: @escaping (Item) -> ItemContent,
    @ViewBuilder itemTitle: @escaping (Item) -> TitleContent,
    @ViewBuilder clusterContent: @escaping (Int) -> ClusterContent
  ) {
    self.items = items
    self.itemDetails = itemDetails
    self.itemContent = itemContent
    self.itemTitle = itemTitle
    self.clusterContent = clusterContent
    self.onSelect = onSelect
    self.clusterLabel = clusterLabel
    self.anchorY = anchorY
    self.resetID = resetID
    self.animatesFit = animatesFit
    self.isSubdued = isSubdued
    self.isSearching = isSearching
  }

  func makeView(context: Context) -> MKMapView {
    Logger.clusterMap.info("makeView: \(items.count)")

    let coordinator = context.coordinator

    let mapView = MKMapView()
    mapView.delegate = coordinator
    if isSubdued {
      let configuration = MKStandardMapConfiguration(emphasisStyle: .muted)
      configuration.pointOfInterestFilter = .excludingAll
      mapView.preferredConfiguration = configuration
    }
    #if !os(tvOS)
      mapView.isRotateEnabled = false
      mapView.isPitchEnabled = false
    #endif
    refresh(coordinator)

    mapView.register(
      ItemAnnotationView.self,
      forAnnotationViewWithReuseIdentifier: .itemAnnotationViewReuseIdentifier)
    mapView.register(
      ClusterAnnotationView.self,
      forAnnotationViewWithReuseIdentifier: .clusterAnnotationViewReuseIdentifier)

    let entries = items.map { ($0, itemDetails($0)) }
    coordinator.synchronize(entries: entries, mapView: mapView)

    return mapView
  }

  func makeCoordinator() -> Coordinator {
    Logger.clusterMap.info("makeCoordinator")
    return Coordinator()
  }

  func updateView(_ view: MKMapView, context: Context) {
    Logger.clusterMap.info("updateView")

    let coordinator = context.coordinator

    refresh(coordinator)

    // Reading the details observes the model, so do it here, while SwiftUI is tracking this
    // update, to be updated again when it changes.
    let entries = items.map { ($0, itemDetails($0)) }

    // Changing the annotations lays out their views right away. Doing that while SwiftUI is
    // updating this view lays out the enclosing hosting view reentrantly, so wait a turn.
    Task { @MainActor in
      coordinator.setSearching(isSearching, mapView: view)
      coordinator.reset(for: resetID)

      guard !coordinator.isApplyingUpdate else {
        Logger.clusterMap.info("isApplyingUpdate - early return")
        return
      }
      coordinator.isApplyingUpdate = true
      defer { coordinator.isApplyingUpdate = false }

      coordinator.synchronize(entries: entries, mapView: view)
    }
  }

  private func refresh(_ coordinator: Coordinator) {
    coordinator.itemContent = { AnyView(itemContent($0)) }
    coordinator.itemTitle = { AnyView(itemTitle($0)) }
    coordinator.clusterContent = { AnyView(clusterContent($0)) }
    coordinator.onSelect = onSelect
    coordinator.clusterLabel = clusterLabel
    coordinator.anchorY = anchorY
    coordinator.animatesFit = animatesFit
  }

  final class Coordinator: NSObject, MKMapViewDelegate {
    var itemContent: (Item) -> AnyView = { _ in AnyView(EmptyView()) }
    var itemTitle: (Item) -> AnyView = { _ in AnyView(EmptyView()) }
    var clusterContent: (Int) -> AnyView = { _ in AnyView(EmptyView()) }
    var onSelect: (Item) -> Void = { _ in }
    var clusterLabel: (Int) -> String = { String($0) }
    var anchorY: CGFloat?

    fileprivate var isApplyingUpdate = false
    private var annotationMap: [Item.ID: ItemAnnotation] = [:]
    private var fittedIDs: Set<Item.ID> = []
    private var needsFit = false
    var animatesFit = true
    private var resetID: UUID?
    private var didFit = false
    /// Where the fit in progress is going, so its region changes aren't taken as the user's.
    private var fitTarget: MKMapRect?
    private var lastLayout: [CGFloat] = []
    private var userMovedMap = false
    private var isSearching = false
    private var rectBeforeSearch: MKMapRect?

    /// Fits and zooms jump instead of gliding when the person asks for less motion.
    private var reducesMotion: Bool {
      #if os(macOS)
        NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
      #else
        UIAccessibility.isReduceMotionEnabled
      #endif
    }

    fileprivate func setSearching(_ isSearching: Bool, mapView: MKMapView) {
      guard isSearching != self.isSearching else { return }
      self.isSearching = isSearching
      rectBeforeSearch = isSearching ? mapView.visibleMapRect : nil
    }

    fileprivate func reset(for resetID: UUID?) {
      guard resetID != self.resetID else { return }
      self.resetID = resetID
      userMovedMap = false
      needsFit = true
    }

    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
      // A new size or safe area, such as from rotation or resizing a window, changes the region
      // without the user.
      let safeArea = mapView.safeAreaInsets
      let layout = [
        mapView.bounds.width, mapView.bounds.height,
        safeArea.top, safeArea.left, safeArea.bottom, safeArea.right,
      ]
      let layoutChanged = layout != lastLayout
      lastLayout = layout

      // Only changes after the first fit that we didn't make are the user's.
      if didFit && fitTarget == nil && !layoutChanged {
        userMovedMap = true
      }
    }

    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
      updateTitleVisibility(in: mapView)
    }

    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
      updateTitleVisibility(in: mapView)
    }

    /// Hides the title of an item when it would cover another pin, or another title that is kept.
    /// Titles of the items nearest the middle of the map are kept first.
    private func updateTitleVisibility(in mapView: MKMapView) {
      // Hidden views can't cover anything.
      let pins = mapView.annotations
        .compactMap { mapView.view(for: $0) as? AnnotationView }
        .filter { $0.superview != nil && $0.isShown }
        .map { (view: $0, rect: $0.pinRect(in: mapView)) }
        .filter { $0.rect.intersects(mapView.bounds) }

      let middle = CGPoint(x: mapView.bounds.midX, y: mapView.bounds.midY)
      func distance(_ rect: CGRect) -> CGFloat {
        hypot(rect.midX - middle.x, rect.maxY - middle.y)
      }

      var keptTitles = [CGRect]()
      for pin in pins.sorted(by: { distance($0.rect) < distance($1.rect) }) {
        guard let title = pin.view.titleRect(in: mapView) else { continue }
        let padded = title.insetBy(dx: -2.0, dy: -1.0)
        let covered =
          pins.contains { $0.view !== pin.view && $0.rect.intersects(padded) }
          || keptTitles.contains { $0.intersects(padded) }
        if !covered { keptTitles.append(padded) }
        pin.view.setTitleHidden(covered, animated: !reducesMotion)
      }
    }

    /// The map extends under bars and controls; keep what is shown clear of them.
    private func edgePadding(
      for mapView: MKMapView, top: CGFloat = 0, horizontal: CGFloat = 0, bottom: CGFloat = 0
    ) -> MapEdgeInsets {
      let covered = mapView.safeAreaInsets
      return MapEdgeInsets(
        top: covered.top + top, left: covered.left + horizontal, bottom: covered.bottom + bottom,
        right: covered.right + horizontal)
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
      updateTitleVisibility(in: mapView)
      // A fit that was interrupted by another reports its end too; only the last one is done.
      guard let fitTarget, mapView.visibleMapRect.isNearlyEqual(to: fitTarget) else { return }
      self.fitTarget = nil
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
      if let item = annotation as? ItemAnnotation {
        return itemAnnotationView(for: item, in: mapView)
      }

      if let cluster = annotation as? MKClusterAnnotation {
        return clusterAnnotationView(for: cluster, in: mapView)
      }

      return nil
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
      if let cluster = view.annotation as? MKClusterAnnotation {
        Logger.clusterMap.info("Select Cluster Annotation")

        mapView.deselectAnnotation(cluster, animated: false)

        let members = cluster.memberAnnotations.compactMap { $0 as? ItemAnnotation }
        if members.count == cluster.memberAnnotations.count, isAtOneLocation(members) {
          presentMenu(for: members, from: view)
          return
        }

        // Titles are drawn outside the frame, below it. Keep room for the widest on the map.
        let size = view.bounds.size
        var titleSize = CGSize.zero
        if let widest = members.max(by: { ($0.title ?? "").count < ($1.title ?? "").count }) {
          titleSize = fittingSize(of: itemTitle(widest.item))
        }
        let titleHeight = titleSize.height > 0 ? titleSize.height + AnnotationView.titleSpacing : 0
        let extent = CGSize(
          width: max(size.width, titleSize.width), height: size.height + titleHeight)
        // On a small map, padding for the annotation can leave no room for what is being shown.
        let top = min(size.height, mapView.bounds.height / 4.0)
        let bottom = min(titleHeight, mapView.bounds.height / 4.0)
        let horizontal = min(extent.width / 2.0, mapView.bounds.width / 4.0)
        let insets = edgePadding(for: mapView, top: top, horizontal: horizontal, bottom: bottom)
        let memberRect = cluster.memberAnnotations.rect
        userMovedMap = true
        let visibleRect = mapView.visibleMapRect
        let fitRect = mapView.mapRectThatFits(memberRect, edgePadding: insets)
        // Showing all the members is the zoom, unless that is hardly a change. Then they are as
        // far apart as they will be shown, and the zoom goes on until they no longer overlap.
        // Zoom toward the tapped cluster; members can be spread far enough that their center is elsewhere.
        let center = MKMapPoint(cluster.coordinate)
        var target = fitRect
        if fitRect.width > visibleRect.width * 0.8 {
          let factor = separationFactor(of: members, in: fitRect, mapView: mapView, size: size)
          target = fitRect.zoomed(by: factor, around: center)
        }
        if target.isCloseTo(visibleRect) {
          // Already there, yet they still cluster; keep zooming in on them.
          target = visibleRect.zoomed(by: 2.0, around: center)
        }
        target = showingAMember(of: members, in: target, mapView: mapView, size: extent)
        mapView.setVisibleMapRect(target, animated: !reducesMotion)
        return
      }
      if let annotation = view.annotation as? ItemAnnotation {
        Logger.clusterMap.info("Select Item Annotation")
        mapView.deselectAnnotation(annotation, animated: false)
        // Selection is delivered in the middle of MapKit's event handling, where a SwiftUI state
        // change doesn't animate. Defer to the next turn of the run loop, like the menu path.
        let item = annotation.item
        Task { @MainActor [onSelect] in
          onSelect(item)
        }
      }
    }

    /// Zooming toward the middle of members can leave only the edges of annotations showing. If no
    /// member is entirely in `rect`, center on the one nearest the middle.
    private func showingAMember(
      of members: [ItemAnnotation], in rect: MKMapRect, mapView: MKMapView, size: CGSize
    ) -> MKMapRect {
      let pointsPerMapPoint = mapView.bounds.width / rect.width
      let dx = size.width / 2.0 / pointsPerMapPoint
      let dy = size.height / pointsPerMapPoint
      let middle = MKMapPoint(x: rect.midX, y: rect.midY)

      let points = members.map { MKMapPoint($0.coordinate) }
      let safe = rect.insetBy(dx: dx, dy: dy)
      guard dx * 2.0 < rect.width, dy * 2.0 < rect.height, !points.contains(where: safe.contains)
      else { return rect }

      guard let nearest = points.min(by: { $0.distance(to: middle) < $1.distance(to: middle) })
      else { return rect }
      return MKMapRect(
        x: nearest.x - rect.width / 2.0, y: nearest.y - rect.height / 2.0, width: rect.width,
        height: rect.height)
    }

    /// How much to zoom in from `rect` for the closest of the members not to overlap each other.
    private func separationFactor(
      of members: [ItemAnnotation], in rect: MKMapRect, mapView: MKMapView, size: CGSize
    ) -> Double {
      let pointsPerMapPoint = mapView.bounds.width / rect.width
      let points = members.map { MKMapPoint($0.coordinate) }
      var factor = 1.0
      for (index, first) in points.enumerated() {
        for second in points[(index + 1)...] {
          let dx = abs(first.x - second.x) * pointsPerMapPoint
          let dy = abs(first.y - second.y) * pointsPerMapPoint
          guard dx < size.width, dy < size.height, dx + dy > 0 else { continue }
          // Zooming scales both distances; one reaching its size is enough to separate.
          let needed = min(
            dx > 0 ? size.width / dx : .infinity, dy > 0 ? size.height / dy : .infinity)
          factor = max(factor, needed)
        }
      }
      return min(factor, Self.maxSeparationFactor)
    }

    private static var maxSeparationFactor: Double { 4.0 }

    private func isAtOneLocation(_ annotations: [ItemAnnotation]) -> Bool {
      guard let first = annotations.first else { return false }
      let firstPoint = MKMapPoint(first.coordinate)
      return annotations.allSatisfy { MKMapPoint($0.coordinate).distance(to: firstPoint) < 1.0 }
    }

    private func presentMenu(for annotations: [ItemAnnotation], from view: MKAnnotationView) {
      let sorted = annotations.sorted {
        ($0.title ?? "").localizedStandardCompare($1.title ?? "") == .orderedAscending
      }
      #if canImport(UIKit)
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for annotation in sorted {
          sheet.addAction(
            UIAlertAction(title: annotation.title, style: .default) { [weak self] _ in
              self?.onSelect(annotation.item)
            })
        }
        sheet.addAction(UIAlertAction(title: String(localized: "Cancel"), style: .cancel))
        sheet.popoverPresentationController?.sourceView = view
        sheet.popoverPresentationController?.sourceRect = view.bounds

        var presenter = view.window?.rootViewController
        while let presented = presenter?.presentedViewController {
          presenter = presented
        }
        presenter?.present(sheet, animated: true)
      #else
        let menu = NSMenu()
        for annotation in sorted {
          let menuItem = NSMenuItem(
            title: annotation.title ?? "", action: #selector(menuItemSelected(_:)),
            keyEquivalent: "")
          menuItem.target = self
          menuItem.representedObject = annotation
          menu.addItem(menuItem)
        }
        menu.popUp(
          positioning: nil, at: NSPoint(x: view.bounds.midX, y: view.bounds.midY), in: view)
      #endif
    }

    #if canImport(AppKit)
      @objc private func menuItemSelected(_ sender: NSMenuItem) {
        if let annotation = sender.representedObject as? ItemAnnotation {
          onSelect(annotation.item)
        }
      }
    #endif

    private func itemAnnotationView(
      for itemAnnotation: ItemAnnotation,
      in mapView: MKMapView
    ) -> ItemAnnotationView? {
      let view =
        mapView.dequeueReusableAnnotationView(
          withIdentifier: .itemAnnotationViewReuseIdentifier, for: itemAnnotation)
        as? ItemAnnotationView
      view?.clusteringIdentifier = itemAnnotation.clusteringIdentifier
      view?.configure(
        content: itemContent(itemAnnotation.item), title: itemTitle(itemAnnotation.item),
        anchorY: anchorY, accessibilityLabel: itemAnnotation.title)
      return view
    }

    private func clusterAnnotationView(
      for cluster: MKClusterAnnotation,
      in mapView: MKMapView
    ) -> ClusterAnnotationView? {
      let view =
        mapView.dequeueReusableAnnotationView(
          withIdentifier: .clusterAnnotationViewReuseIdentifier, for: cluster)
        as? ClusterAnnotationView
      let count = cluster.memberAnnotations.count
      view?.configure(
        content: clusterContent(count), title: nil, anchorY: anchorY,
        accessibilityLabel: clusterLabel(count))
      return view
    }

    fileprivate func synchronize(entries: [(Item, Details)], mapView: MKMapView) {
      let located = entries.filter { CLLocationCoordinate2DIsValid($0.1.coordinate) }
      let newItemIDs = Set(located.map { $0.0.id })

      var annotationsToAdd = [ItemAnnotation]()

      for (item, details) in located {
        if let existingAnnotation = annotationMap[item.id] {
          existingAnnotation.item = item
          existingAnnotation.coordinate = details.coordinate
          existingAnnotation.title = details.title

          if let annotationView = mapView.view(for: existingAnnotation) as? ItemAnnotationView {
            annotationView.configure(
              content: itemContent(item), title: itemTitle(item), anchorY: anchorY,
              accessibilityLabel: details.title)
          }
        } else {
          let annotation = ItemAnnotation(
            coordinate: details.coordinate,
            item: item,
            clusteringIdentifier: .itemClusterIdentifier)
          annotation.title = details.title
          annotationMap[item.id] = annotation
          annotationsToAdd.append(annotation)
        }
      }

      let removeItemIDs = Set(annotationMap.keys).subtracting(newItemIDs)
      if !removeItemIDs.isEmpty {
        let removed = removeItemIDs.compactMap { annotationMap.removeValue(forKey: $0) }
        Logger.clusterMap.info("removing \(removed.count) annotations.")
        mapView.removeAnnotations(removed)
      }
      if !annotationsToAdd.isEmpty {
        Logger.clusterMap.info("adding \(annotationsToAdd.count) annotations.")
        mapView.addAnnotations(annotationsToAdd)
      }

      if newItemIDs != fittedIDs {
        fittedIDs = newItemIDs
        needsFit = true
      }
      fitIfNeeded(mapView)
    }

    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
      fitIfNeeded(mapView)
    }

    /// Waits for the map to have a size, since fitting a map that hasn't been laid out is wrong.
    private func fitIfNeeded(_ mapView: MKMapView) {
      guard needsFit, !userMovedMap, mapView.bounds.size != .zero else { return }
      needsFit = false

      let rect = annotationMap.values.reduce(MKMapRect.null) { $0.union($1.coordinate.rect) }
      guard !rect.isNull else {
        if let rectBeforeSearch {
          show(rectBeforeSearch, in: mapView)
        }
        return
      }

      didFit = true
      show(rect.proportionallyPadded, in: mapView)
    }

    private func show(_ rect: MKMapRect, in mapView: MKMapView) {
      // No region change is reported if the map is already there, so don't wait for one.
      let insets = edgePadding(for: mapView)
      let target = mapView.mapRectThatFits(rect, edgePadding: insets)
      guard !target.isNearlyEqual(to: mapView.visibleMapRect) else { return }
      fitTarget = target
      mapView.setVisibleMapRect(
        rect, edgePadding: insets, animated: animatesFit && !reducesMotion)
    }
  }

  private final class ItemAnnotation: NSObject, MKAnnotation {
    @objc dynamic var coordinate: CLLocationCoordinate2D

    var item: Item
    let clusteringIdentifier: String?
    var title: String?

    internal init(
      coordinate: CLLocationCoordinate2D,
      item: Item,
      clusteringIdentifier: String? = nil
    ) {
      self.coordinate = coordinate
      self.item = item
      self.clusteringIdentifier = clusteringIdentifier
      super.init()
    }
  }

  private class AnnotationView: MKAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
      super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
      clipsToBounds = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("no coder") }

    fileprivate static var titleSpacing: CGFloat { 2.0 }

    fileprivate var isTitleHidden = false

    /// MapKit hides views it isn't showing, such as those it has just merged into a cluster.
    fileprivate var isShown: Bool {
      #if canImport(UIKit)
        !isHidden && alpha > 0.01
      #else
        !isHidden && alphaValue > 0.01
      #endif
    }

    override func prepareForReuse() {
      super.prepareForReuse()
      setTitleHidden(false, animated: false)
    }

    /// The pin's frame, in the map's coordinates, measured down from the top on every platform.
    fileprivate func pinRect(in mapView: MKMapView) -> CGRect {
      // The view's frame lags while MapKit moves it, as when a cluster splits, so place it from
      // the coordinate.
      guard let annotation else { return .null }
      var point = mapView.convert(annotation.coordinate, toPointTo: mapView)
      #if canImport(AppKit)
        if !mapView.isFlipped { point.y = mapView.bounds.height - point.y }
      #endif
      return CGRect(
        x: point.x + centerOffset.x - bounds.width / 2.0,
        y: point.y + centerOffset.y - bounds.height / 2.0,
        width: bounds.width, height: bounds.height)
    }

    /// The title's frame, below the pin, in the same coordinates. nil if there is no title to show.
    fileprivate func titleRect(in mapView: MKMapView) -> CGRect? {
      guard let titleHostingView, !titleHostingView.frame.isEmpty else { return nil }
      let pin = pinRect(in: mapView)
      let size = titleHostingView.bounds.size
      return CGRect(
        x: pin.midX - size.width / 2.0, y: pin.maxY + Self.titleSpacing,
        width: size.width, height: size.height)
    }

    #if canImport(UIKit)
      private var hostingController: UIHostingController<AnyView>?
      private var titleController: UIHostingController<AnyView>?
      fileprivate var titleHostingView: UIView? { titleController?.view }
      private var content: AnyView?
      private var title: AnyView?
      private var anchorY: CGFloat?

      /// Unlike a hosting configuration, a hosting controller can leave the safe area out of its
      /// layout. Under a bar, the map's safe area would otherwise move the content off its frame.
      private func hostingController(
        for content: AnyView, reusing existing: UIHostingController<AnyView>?
      ) -> UIHostingController<AnyView> {
        if let existing {
          existing.rootView = content
          return existing
        }
        let controller = UIHostingController(rootView: content)
        controller.safeAreaRegions = []
        controller.sizingOptions = .intrinsicContentSize
        controller.view.backgroundColor = .clear
        controller.view.isUserInteractionEnabled = false
        controller.view.clipsToBounds = false
        addSubview(controller.view)
        return controller
      }

      func configure(
        content: AnyView, title: AnyView?, anchorY: CGFloat?, accessibilityLabel: String?
      ) {
        self.content = content
        self.title = title
        self.anchorY = anchorY

        // The hosted content isn't interactive, so the annotation view is the one element.
        isAccessibilityElement = accessibilityLabel?.isEmpty == false
        self.accessibilityLabel = accessibilityLabel
        accessibilityTraits = .button

        let isNew = hostingController == nil
        let controller = hostingController(for: content, reusing: hostingController)
        hostingController = controller
        if isNew {
          // The view is sized once to fit its content, so size it again when the text size changes.
          registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) {
            (view: AnnotationView, _) in
            guard let content = view.content else { return }
            view.configure(
              content: content, title: view.title, anchorY: view.anchorY,
              accessibilityLabel: view.accessibilityLabel)
          }
        }

        let size = controller.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        bounds = CGRect(origin: .zero, size: size)
        controller.view.frame = bounds
        // The view is centered on the coordinate by default; shift it so the anchor point is there.
        centerOffset = CGPoint(x: 0, y: size.height / 2.0 - (anchorY ?? size.height))

        if let title {
          let controller = hostingController(for: title, reusing: titleController)
          titleController = controller
          controller.view.alpha = isTitleHidden ? 0.0 : 1.0
          let titleSize = controller.view.systemLayoutSizeFitting(
            UIView.layoutFittingCompressedSize)
          controller.view.frame = CGRect(
            x: (size.width - titleSize.width) / 2.0, y: size.height + Self.titleSpacing,
            width: titleSize.width, height: titleSize.height)
        } else {
          titleController?.view.removeFromSuperview()
          titleController = nil
        }
      }

      fileprivate func setTitleHidden(_ hidden: Bool, animated: Bool) {
        guard hidden != isTitleHidden else { return }
        isTitleHidden = hidden
        guard let titleHostingView else { return }
        let alpha = hidden ? 0.0 : 1.0
        if animated {
          UIView.animate(withDuration: 0.15) { titleHostingView.alpha = alpha }
        } else {
          titleHostingView.alpha = alpha
        }
      }
    #endif
    #if canImport(AppKit)
      private var hostingController: NSHostingController<AnyView>?
      private var titleController: NSHostingController<AnyView>?
      fileprivate var titleHostingView: NSView? { titleController?.view }

      /// Like on UIKit, a hosting controller can leave the safe area out of its layout. Under the
      /// toolbar, the map's safe area would otherwise move the content off its frame.
      private func hostingController(
        for content: AnyView, reusing existing: NSHostingController<AnyView>?
      ) -> NSHostingController<AnyView> {
        if let existing {
          existing.rootView = content
          return existing
        }
        let controller = NSHostingController(rootView: content)
        controller.safeAreaRegions = []
        controller.sizingOptions = .intrinsicContentSize
        addSubview(controller.view)
        return controller
      }

      func configure(
        content: AnyView, title: AnyView?, anchorY: CGFloat?, accessibilityLabel: String?
      ) {
        setAccessibilityElement(accessibilityLabel?.isEmpty == false)
        setAccessibilityRole(.button)
        setAccessibilityLabel(accessibilityLabel)

        let controller = hostingController(for: content, reusing: hostingController)
        hostingController = controller

        let size = controller.view.fittingSize
        setFrameSize(size)
        controller.view.frame = bounds
        // The view is centered on the coordinate by default; shift it so the anchor point is there.
        centerOffset = CGPoint(x: 0, y: size.height / 2.0 - (anchorY ?? size.height))

        if let title {
          let controller = hostingController(for: title, reusing: titleController)
          titleController = controller
          controller.view.alphaValue = isTitleHidden ? 0.0 : 1.0
          let titleSize = controller.view.fittingSize
          // AppKit's y axis points up here, unlike UIKit's; the bottom of the frame is y = 0.
          controller.view.frame = CGRect(
            x: (size.width - titleSize.width) / 2.0,
            y: isFlipped ? size.height + Self.titleSpacing : -titleSize.height - Self.titleSpacing,
            width: titleSize.width, height: titleSize.height)
        } else {
          titleController?.view.removeFromSuperview()
          titleController = nil
        }
      }

      fileprivate func setTitleHidden(_ hidden: Bool, animated: Bool) {
        guard hidden != isTitleHidden else { return }
        isTitleHidden = hidden
        guard let titleHostingView else { return }
        let alpha = hidden ? 0.0 : 1.0
        if animated {
          NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.15
            titleHostingView.animator().alphaValue = alpha
          }
        } else {
          titleHostingView.alphaValue = alpha
        }
      }

      override func hitTest(_ point: NSPoint) -> NSView? {
        frame.contains(point) ? self : nil
      }
    #endif
  }

  private final class ItemAnnotationView: AnnotationView {
    override var annotation: MKAnnotation? {
      didSet {
        if let clustered = annotation as? ItemAnnotation {
          clusteringIdentifier = clustered.clusteringIdentifier
        }
      }
    }
  }

  private final class ClusterAnnotationView: AnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
      super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
      displayPriority = .defaultHigh
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("no coder") }
  }
}

extension MKMapRect {
  fileprivate func zoomed(by factor: Double, around center: MKMapPoint) -> MKMapRect {
    guard factor > 1.0 else { return self }
    return MKMapRect(
      x: center.x - width / factor / 2.0, y: center.y - height / factor / 2.0,
      width: width / factor, height: height / factor)
  }

  fileprivate func isCloseTo(_ other: MKMapRect) -> Bool {
    let tolerance = other.width * 0.001
    return abs(minX - other.minX) <= tolerance && abs(minY - other.minY) <= tolerance
      && abs(width - other.width) <= tolerance && abs(height - other.height) <= tolerance
  }
}

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model

  ClusterMap(items: model.previewAllVenues, anchorY: CategoryAnnotationView.tipOffset) {
    Details(
      coordinate: model.venueMapItemMap[$0.archivePath]?.location.coordinate
        ?? kCLLocationCoordinate2DInvalid,
      title: $0.name)
  } onSelect: { _ in

  } clusterLabel: {
    "Cluster, \($0) venues"
  } itemContent: { _ in
    CategoryAnnotationView(category: .venues, render: .default)
  } itemTitle: {
    CategoryTitleView(title: $0.name)
  } clusterContent: {
    CategoryAnnotationView(category: .venues, render: .badge($0))
  }
}
