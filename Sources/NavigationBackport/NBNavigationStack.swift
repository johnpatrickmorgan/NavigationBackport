import Foundation
import SwiftUI

@available(iOS, deprecated: 16.0, message: "Use SwiftUI's Navigation API beyond iOS 15")
/// A replacement for SwiftUI's `NavigationStack` that's available on older OS versions.
public struct NBNavigationStack<Root: View, Data: Hashable>: View {
  var embedInNavigationView: Bool
  @Binding var externalTypedPath: [Route<Data>]
  @State var internalTypedPath: [Route<Data>] = []
  @StateObject var path = NavigationPathHolder()
  @StateObject var pathAppender = PathAppender()
  @StateObject var destinationBuilder = DestinationBuilderHolder()
  var root: Root
  var useInternalTypedPath: Bool

  var content: some View {
    pathAppender.append = { [weak path] newElement in
      path?.path.append(newElement)
    }
    return Router(rootView: root, screens: $path.path)
      .modifier(EmbedModifier(embedInNavigationView: embedInNavigationView))
      .environmentObject(path)
      .environmentObject(pathAppender)
      .environmentObject(destinationBuilder)
      .environmentObject(Navigator(useInternalTypedPath ? $internalTypedPath : $externalTypedPath))
  }

  public var body: some View {
    content
      .onFirstAppear {
        path.withDelaysIfUnsupported(\.path) {
          $0 = externalTypedPath.map { $0.erased() }
        }
      }
      .onChange(of: externalTypedPath) { externalTypedPath in
        path.withDelaysIfUnsupported(\.path) {
          $0 = externalTypedPath.map { $0.erased() }
        }
      }
      .onChange(of: internalTypedPath) { internalTypedPath in
        path.withDelaysIfUnsupported(\.path) {
          $0 = internalTypedPath.map { $0.erased() }
        }
      }
      .onChange(of: path.path) { path in
        if useInternalTypedPath {
          guard path != internalTypedPath.map({ $0.erased() }) else { return }
          internalTypedPath = path.compactMap { route in
            if let data = route.screen.base as? Data {
              return route.map { _ in data }
            } else if route.screen.base is LocalDestinationID {
              return nil
            }
            fatalError("Cannot add \(type(of: route.screen.base)) to stack of \(Data.self)")
          }
        } else {
          guard path != externalTypedPath.map({ $0.erased() }) else { return }
          externalTypedPath = path.compactMap { route in
            if let data = route.screen.base as? Data {
              return route.map { _ in data }
            } else if route.screen.base is LocalDestinationID {
              return nil
            }
            fatalError("Cannot add \(type(of: route.screen.base)) to stack of \(Data.self)")
          }
        }
      }
  }

  public init(path: Binding<[Route<Data>]>?, embedInNavigationView: Bool, @ViewBuilder root: () -> Root) {
    _externalTypedPath = path ?? .constant([])
    self.root = root()
    self.embedInNavigationView = embedInNavigationView
    useInternalTypedPath = path == nil
  }
}

public extension NBNavigationStack where Data == AnyHashable {
  init(embedInNavigationView: Bool, @ViewBuilder root: () -> Root) {
    self.init(path: nil, embedInNavigationView: embedInNavigationView, root: root)
  }
}

public extension NBNavigationStack where Data == AnyHashable {
  init(path: Binding<NBNavigationPath>, embedInNavigationView: Bool, @ViewBuilder root: () -> Root) {
    let path = Binding(
      get: { path.wrappedValue.elements },
      set: { path.wrappedValue.elements = $0 }
    )
    self.init(path: path, embedInNavigationView: embedInNavigationView, root: root)
  }
}
