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
  var root: Root
  var useInternalTypedPath: Bool

  var content: some View {
    pathAppender.append = { [weak path] newElement in
      path?.path.append(newElement)
    }
    return NavigationWrapper {
      Router(rootView: root, screens: $path.path)
    }
    .environmentObject(path)
    .environmentObject(pathAppender)
    .environmentObject(destinationBuilder)
    .environmentObject(Navigator(useInternalTypedPath ? $internalTypedPath : $externalTypedPath))
  }

  public var body: some View {
    content
      .onFirstAppear {
        path.withDelaysIfUnsupported(\.path) {
          $0 = externalTypedPath
        }
      }
      .onChange(of: externalTypedPath) { externalTypedPath in
        path.withDelaysIfUnsupported(\.path) {
          $0 = externalTypedPath
        }
      }
      .onChange(of: internalTypedPath) { internalTypedPath in
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
