import Foundation
import SwiftUI

@available(iOS, deprecated: 16.0, message: "Use SwiftUI's Navigation API beyond iOS 15")
/// A replacement for SwiftUI's `NavigationStack` that's available on older OS versions.
public struct NBNavigationStack<Root: View, Data: Hashable>: View {
  var unownedPath: Binding<[Data]>?
  @StateObject var ownedPath = NavigationPathHolder()
  @StateObject var pathAppender = PathAppender()
  @StateObject var destinationBuilder = DestinationBuilderHolder()
  @Environment(\.splitViewPane) var splitViewPane
  var root: Root

  var typedPath: Binding<[Data]> {
    if let unownedPath {
      return unownedPath
    } else {
      return Binding {
        ownedPath.path.map { $0 as! Data }
      } set: {
        ownedPath.path = $0
      }
    }
  }

  @ViewBuilder
  var content: some View {
    if splitViewPane == .detail {
      Router(rootView: root, screens: $ownedPath.path, screenType: Data.self)
    } else {
      if let splitViewPane {
        let _ = assertionFailure("""
          NBNavigationStack should only be embedded in the detail pane of an NBNavigationSplitView, not the \
          \(splitViewPane) pane. This is a limitation of NBNavigationSplitView compared to NavigationSplitView.
          """
        )
      }
      NavigationView {
        Router(rootView: root, screens: $ownedPath.path, screenType: Data.self)
      }
      .navigationViewStyle(supportedNavigationViewStyle)
    }
  }

  @ViewBuilder
  public var stateSyncingContent: some View {
    if let unownedPath {
      content
        .onChange(of: unownedPath.wrappedValue) {
          ownedPath.path = $0
        }
        .onChange(of: ownedPath.path) {
          unownedPath.wrappedValue = $0.compactMap { anyHashable in
            if let data = anyHashable.base as? Data {
              return data
            } else if anyHashable.base is LocalDestinationID {
              return nil
            }
            fatalError("Cannot add \(type(of: anyHashable.base)) to stack of \(Data.self)")
          }
        }
    } else {
      content
    }
  }

  public var body: some View {
    pathAppender.append = { [weak ownedPath] newElement in
      ownedPath?.path.append(newElement)
    }
    return stateSyncingContent
      .environmentObject(ownedPath)
      .environmentObject(pathAppender)
      .environmentObject(destinationBuilder)
      .environmentObject(Navigator(typedPath))
  }

  public init(path: Binding<[Data]>?, @ViewBuilder root: () -> Root) {
    unownedPath = path
    self.root = root()
  }
}

public extension NBNavigationStack where Data == AnyHashable {
  init(@ViewBuilder root: () -> Root) {
    self.init(path: nil, root: root)
  }
}

public extension NBNavigationStack where Data == AnyHashable {
  init(path: Binding<NBNavigationPath>, @ViewBuilder root: () -> Root) {
    let path = Binding(
      get: { path.wrappedValue.elements },
      set: { path.wrappedValue.elements = $0 }
    )
    self.init(path: path, root: root)
  }
}

private var supportedNavigationViewStyle: some NavigationViewStyle {
  #if os(macOS)
    .automatic
  #else
    .stack
  #endif
}
