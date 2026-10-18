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

struct Details {
  let coordinate: CLLocationCoordinate2D
  let title: String
}

struct ClusterMap<Item: Identifiable, ItemContent: View, ClusterContent: View>: ViewRepresentable {
  let items: any Collection<Item>
  let itemDetails: (Item) -> Details

  @ViewBuilder let itemContent: (Item) -> ItemContent
  @ViewBuilder let clusterContent: (Int) -> ClusterContent

  let onSelect: (Item) -> Void

  /// Distance from the top of the content to the point placed on the coordinate. The bottom if nil.
  let anchorY: CGFloat?

  init(
    items: any Collection<Item>,
    anchorY: CGFloat? = nil,
    itemDetails: @escaping (Item) -> Details,
    onSelect: @escaping (Item) -> Void,
    @ViewBuilder itemContent: @escaping (Item) -> ItemContent,
    @ViewBuilder clusterContent: @escaping (Int) -> ClusterContent
  ) {
    self.items = items
    self.itemDetails = itemDetails
    self.itemContent = itemContent
    self.clusterContent = clusterContent
    self.onSelect = onSelect
    self.anchorY = anchorY
  }

  func makeView(context: Context) -> MKMapView {
    Logger.clusterMap.info("makeView: \(items.count)")

    let coordinator = context.coordinator

    let mapView = MKMapView()
    mapView.delegate = coordinator
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
    coordinator.clusterContent = { AnyView(clusterContent($0)) }
    coordinator.onSelect = onSelect
    coordinator.anchorY = anchorY
  }

  final class Coordinator: NSObject, MKMapViewDelegate {
    var itemContent: (Item) -> AnyView = { _ in AnyView(EmptyView()) }
    var clusterContent: (Int) -> AnyView = { _ in AnyView(EmptyView()) }
    var onSelect: (Item) -> Void = { _ in }
    var anchorY: CGFloat?

    fileprivate var isApplyingUpdate = false
    private var annotationMap: [Item.ID: ItemAnnotation] = [:]
    private var fittedIDs: Set<Item.ID> = []
    private var needsFit = false

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

        var size = view.bounds.size
        // Member titles can make their annotations wider than the cluster; measure the longest.
        if let widest = members.max(by: { ($0.title ?? "").count < ($1.title ?? "").count }) {
          let memberSize = fittingSize(of: itemContent(widest.item))
          size = CGSize(
            width: max(size.width, memberSize.width), height: max(size.height, memberSize.height))
        }
        #if canImport(UIKit)
          let insets = UIEdgeInsets(
            top: size.height, left: size.width / 2.0, bottom: size.height, right: size.width / 2.0)
        #else
          let insets = NSEdgeInsets(
            top: size.height, left: size.width / 2.0, bottom: size.height, right: size.width / 2.0)
        #endif
        mapView.setVisibleMapRect(
          cluster.memberAnnotations.rect, edgePadding: insets, animated: true)
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
      view?.configure(content: itemContent(itemAnnotation.item), anchorY: anchorY)
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
      view?.configure(content: clusterContent(cluster.memberAnnotations.count), anchorY: anchorY)
      return view
    }

    fileprivate func synchronize(entries: [(Item, Details)], mapView: MKMapView) {
      // Items without a valid coordinate, such as venues not yet geocoded, have no annotation.
      let located = entries.filter { CLLocationCoordinate2DIsValid($0.1.coordinate) }
      let newItemIDs = Set(located.map { $0.0.id })

      var annotationsToAdd = [ItemAnnotation]()

      for (item, details) in located {
        if let existingAnnotation = annotationMap[item.id] {
          existingAnnotation.item = item
          existingAnnotation.coordinate = details.coordinate
          existingAnnotation.title = details.title

          if let annotationView = mapView.view(for: existingAnnotation) as? ItemAnnotationView {
            annotationView.configure(content: itemContent(item), anchorY: anchorY)
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

      // Items are located as they are geocoded; show them all whenever that set changes.
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
      guard needsFit, mapView.bounds.size != .zero else { return }
      needsFit = false

      let rect = annotationMap.values.reduce(MKMapRect.null) { $0.union($1.coordinate.rect) }
      guard !rect.isNull else { return }

      mapView.setVisibleMapRect(rect.proportionallyPadded, animated: true)
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

  /// Hosts SwiftUI content directly. The content's bottom center is anchored on the coordinate,
  /// so a pointer drawn at the bottom of the content points at the location.
  private class AnnotationView: MKAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
      super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
      clipsToBounds = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("no coder") }

    #if canImport(UIKit)
      private var hostingView: HostingView?

      func configure(content: AnyView, anchorY: CGFloat?) {
        let configuration = UIHostingConfiguration { content }.margins(.all, 0)
        let hostingView: HostingView
        if let existing = self.hostingView {
          hostingView = existing
          hostingView.configuration = configuration
        } else {
          hostingView = configuration.makeContentView()
          hostingView.isUserInteractionEnabled = false
          hostingView.clipsToBounds = false
          addSubview(hostingView)
          self.hostingView = hostingView
        }

        let size = hostingView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        bounds = CGRect(origin: .zero, size: size)
        hostingView.frame = bounds
        // The view is centered on the coordinate by default; shift it so the anchor point is there.
        centerOffset = CGPoint(x: 0, y: size.height / 2.0 - (anchorY ?? size.height))
      }
    #endif
    #if canImport(AppKit)
      private var hostingView: HostingView?

      func configure(content: AnyView, anchorY: CGFloat?) {
        let hostingView: HostingView
        if let existing = self.hostingView {
          hostingView = existing
          hostingView.rootView = content
        } else {
          hostingView = createHostingView(content: content)
          addSubview(hostingView)
          self.hostingView = hostingView
        }

        let size = hostingView.fittingSize
        setFrameSize(size)
        hostingView.frame = bounds
        // The view is centered on the coordinate by default; shift it so the anchor point is there.
        centerOffset = CGPoint(x: 0, y: size.height / 2.0 - (anchorY ?? size.height))
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

#Preview(traits: .vaultModel) {
  @Previewable @Environment(VaultModel.self) var model

  ClusterMap(items: model.previewAllVenues, anchorY: CategoryAnnotationView.tipOffset) {
    Details(
      coordinate: model.venueMapItemMap[$0.archivePath]?.location.coordinate
        ?? kCLLocationCoordinate2DInvalid,
      title: $0.name)
  } onSelect: { _ in

  } itemContent: {
    CategoryAnnotationView(category: .venues, render: .default, title: $0.name)
  } clusterContent: {
    CategoryAnnotationView(category: .venues, render: .badge($0))
  }
}
