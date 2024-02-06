import Foundation
import SwiftUI

/// A view that manages state for presenting and pushing screens..
public struct FlowStack<Root: View, Data: Hashable>: View {
  var withNavigation: Bool
  @Binding var externalTypedPath: [Route<Data>]
  @State var internalTypedPath: [Route<Data>] = []
  @StateObject var path = RoutesHolder()
  @StateObject var routeAppender = RouteAppender()
  @StateObject var destinationBuilder = DestinationBuilderHolder()
  var root: Root
  var useInternalTypedPath: Bool

  var content: some View {
    routeAppender.append = { [weak path] newElement in
      path?.routes.append(newElement)
    }
    return Router(rootView: root, screens: $path.routes)
      .modifier(EmbedModifier(withNavigation: withNavigation))
      .environmentObject(path)
      .environmentObject(routeAppender)
      .environmentObject(destinationBuilder)
      .environmentObject(FlowNavigator(useInternalTypedPath ? $internalTypedPath : $externalTypedPath))
  }

  public var body: some View {
    content
      .onFirstAppear {
        path.withDelaysIfUnsupported(\.routes) {
          $0 = externalTypedPath.map { $0.erased() }
        }
      }
      .onChange(of: externalTypedPath) { externalTypedPath in
        path.withDelaysIfUnsupported(\.routes) {
          $0 = externalTypedPath.map { $0.erased() }
        }
      }
      .onChange(of: internalTypedPath) { internalTypedPath in
        path.withDelaysIfUnsupported(\.routes) {
          $0 = internalTypedPath.map { $0.erased() }
        }
      }
      .onChange(of: path.routes) { path in
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

  init(routes: Binding<[Route<Data>]>?, withNavigation: Bool, @ViewBuilder root: () -> Root) {
    _externalTypedPath = routes ?? .constant([])
    self.root = root()
    self.withNavigation = withNavigation
    useInternalTypedPath = routes == nil
  }
  
  public init(_ routes: Binding<[Route<Data>]>, withNavigation: Bool, @ViewBuilder root: () -> Root) {
    self.init(routes: routes, withNavigation: withNavigation, root: root)
  }
}

public extension FlowStack where Data == AnyHashable {
  init(withNavigation: Bool, @ViewBuilder root: () -> Root) {
    self.init(routes: nil, withNavigation: withNavigation, root: root)
  }
}

public extension FlowStack where Data == AnyHashable {
  init(_ path: Binding<FlowPath>, withNavigation: Bool, @ViewBuilder root: () -> Root) {
    let path = Binding(
      get: { path.wrappedValue.routes },
      set: { path.wrappedValue.routes = $0 }
    )
    self.init(path, withNavigation: withNavigation, root: root)
  }
}
