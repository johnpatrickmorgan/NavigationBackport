import Foundation
import SwiftUI

class PathHolder<Data>: ObservableObject {
  @Published var path: [Data]

  init(path: [Data] = []) {
    self.path = path
  }
}

@available(iOS, deprecated: 16.0, message: "Use SwiftUI's Navigation API beyond iOS 15")
public struct NBNavigationStack<Root: View, Data: Hashable>: View {
  @Binding var path: [Data]
  @ObservedObject var pathHolder: PathHolder<Data>

  var root: Root

  var erasedPath: Binding<[Any]> {
    Binding(
      get: { path.map { $0 } },
      set: { newValue in
        path = newValue.map { any in
          guard let data = any as? Data else {
            fatalError("Cannot add \(type(of: any)) to stack of \(Data.self)")
          }
          return data
        }
      }
    )
  }

  @StateObject var destinationBuilder = DestinationBuilderHolder()

  public var body: some View {
    NavigationView {
      Router(rootView: root, screens: $path)
        .environmentObject(NavigationPathHolder(erasedPath))
        .environmentObject(destinationBuilder)
    }.navigationViewStyle(supportedNavigationViewStyle)
  }

  init(path: Binding<[Data]>, pathHolder: PathHolder<Data>, @ViewBuilder root: () -> Root) {
    _path = path
    self.root = root()
    self.pathHolder = pathHolder
  }

  public init(path: Binding<[Data]>, @ViewBuilder root: () -> Root) {
    self.init(path: path, pathHolder: .init(), root: root)
  }
}

public extension NBNavigationStack where Data == AnyHashable {
  init(@ViewBuilder root: () -> Root) {
    let pathHolder = PathHolder<Data>()
    let path = Binding(
      get: { pathHolder.path },
      set: { pathHolder.path = $0 }
    )
    self.init(path: path, pathHolder: pathHolder, root: root)
  }
}

public extension NBNavigationStack where Data == AnyHashable {
  init(path: Binding<NBNavigationPath>, @ViewBuilder root: () -> Root) {
    let path: Binding<[Data]> = Binding(
      get: { path.wrappedValue.elements.map { $0 as! AnyHashable } },
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
