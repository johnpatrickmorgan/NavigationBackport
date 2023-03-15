import Foundation
import SwiftUI

@available(iOS, deprecated: 16.0, message: "Use SwiftUI's Navigation API beyond iOS 15")
/// A replacement for SwiftUI's `NavigationStack` that's available on older OS versions.
public struct NBNavigationStack<Root: View, Data: Hashable>: View {
  var unownedPath: Binding<[Data]>?
  @StateObject var ownedPath = NavigationPathHolder()
  @StateObject var pathAppender = PathAppender()
  @StateObject var destinationBuilder = DestinationBuilderHolder()
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

  var content: some View {
    pathAppender.append = { [weak ownedPath] newElement in
      ownedPath?.path.append(newElement)
    }
    return NavigationView {
      Router(rootView: root, screens: $ownedPath.path)
    }
    .navigationViewStyle(supportedNavigationViewStyle)
    .environmentObject(ownedPath)
    .environmentObject(pathAppender)
    .environmentObject(destinationBuilder)
    .environmentObject(Navigator(typedPath))
  }

  public var body: some View {
    if let unownedPath {
      content
        .onAppear {
          guard ownedPath.path != unownedPath.wrappedValue.map({ $0 }) else { return }
          ownedPath.withDelaysIfUnsupported(\.path) {
            $0 = unownedPath.wrappedValue
          }
        }
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
