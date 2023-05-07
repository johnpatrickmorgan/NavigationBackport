import Foundation
import SwiftUI

@available(iOS, deprecated: 16.0, message: "Use SwiftUI's Navigation API beyond iOS 15")
/// A replacement for SwiftUI's `NavigationStack` that's available on older OS versions.
public struct NBNavigationStack<Root: View, Data: Hashable>: View {
  @Binding var externalTypedPath: [Data]
  @State var internalTypedPath: [Data] = []
  @StateObject var path = NavigationPathHolder()
  @StateObject var pathAppender = PathAppender()
  @StateObject var destinationBuilder = DestinationBuilderHolder()
  @Environment(\.useNavigationStack) var useNavigationStack
  var root: Root
  var useInternalTypedPath: Bool

  var requiresDelays: Bool {
    if #available(iOS 16.0, *), useNavigationStack == .whenAvailable {
      return false
    } else {
      return true
    }
  }

  var content: some View {
    pathAppender.append = { [weak path] newElement in
      path?.path.append(newElement)
    }
    if #available(iOS 16.0, *), useNavigationStack == .whenAvailable {
      return AnyView(
        NavigationStack(path: useInternalTypedPath ? $internalTypedPath : $externalTypedPath) {
          root
            .navigationDestination(for: AnyHashable.self, destination: { destinationBuilder.build($0) })
            .navigationDestination(for: LocalDestinationID.self, destination: { destinationBuilder.build($0) })
        }
          .environment(\.isWithinNavigationStack, true)
          .environmentObject(path)
          .environmentObject(pathAppender)
          .environmentObject(destinationBuilder)
          .environmentObject(Navigator(useInternalTypedPath ? $internalTypedPath : $externalTypedPath))
      )
    }
    return AnyView(
      NavigationWrapper {
        Router(rootView: root, screens: $path.path)
      }
      .environmentObject(path)
      .environmentObject(pathAppender)
      .environmentObject(destinationBuilder)
      .environmentObject(Navigator(useInternalTypedPath ? $internalTypedPath : $externalTypedPath))
    )
  }

  public var body: some View {
    content
      .onFirstAppear {
        guard requiresDelays else {
          path.path = externalTypedPath
          return
        }
        path.withDelaysIfUnsupported(\.path) {
          $0 = externalTypedPath
        }
      }
      .onChange(of: externalTypedPath) { externalTypedPath in
        guard requiresDelays else {
          path.path = externalTypedPath
          return
        }
        path.withDelaysIfUnsupported(\.path) {
          $0 = externalTypedPath
        }
      }
      .onChange(of: internalTypedPath) { internalTypedPath in
        guard requiresDelays else {
          path.path = internalTypedPath
          return
        }
        path.withDelaysIfUnsupported(\.path) {
          $0 = internalTypedPath
        }
      }
      .onChange(of: path.path) { path in
        if useInternalTypedPath {
          guard path != internalTypedPath.map({ $0 }) else { return }
          internalTypedPath = path.compactMap { anyHashable in
            if let data = anyHashable.base as? Data {
              return data
            } else if anyHashable.base is LocalDestinationID {
              return nil
            }
            fatalError("Cannot add \(type(of: anyHashable.base)) to stack of \(Data.self)")
          }
        } else {
          guard path != externalTypedPath.map({ $0 }) else { return }
          externalTypedPath = path.compactMap { anyHashable in
            if let data = anyHashable.base as? Data {
              return data
            } else if anyHashable.base is LocalDestinationID {
              return nil
            }
            fatalError("Cannot add \(type(of: anyHashable.base)) to stack of \(Data.self)")
          }
        }
      }
  }

  public init(path: Binding<[Data]>?, @ViewBuilder root: () -> Root) {
    _externalTypedPath = path ?? .constant([])
    self.root = root()
    useInternalTypedPath = path == nil
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
