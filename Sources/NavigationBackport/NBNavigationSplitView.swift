import Foundation
import SwiftUI

@available(iOS, deprecated: 16.0, message: "Use SwiftUI's Navigation API beyond iOS 15")
public struct NBNavigationSplitView<Sidebar: View, Detail: View, Data: Hashable>: View {
  @Binding var path: [Data]
  @ObservedObject var pathHolder: PathHolder<Data>

  let sideBar: Sidebar
  let detail: Detail

  var erasedPath: Binding<[AnyHashable]> {
    Binding(
      get: { path.map(AnyHashable.init) },
      set: { newValue in
        path = newValue.map { anyHashable in
          guard let data = anyHashable.base as? Data else {
            fatalError("Cannot add \(type(of: anyHashable.base)) to stack of \(Data.self)")
          }
          return data
        }
      }
    )
  }

  @StateObject var destinationBuilder = DestinationBuilderHolder()

  public var body: some View {
    NavigationView {
      sideBar
      Router(rootView: detail, screens: $path)
        .environmentObject(NavigationPathHolder(erasedPath))
        .environmentObject(destinationBuilder)
    }.navigationViewStyle(DoubleColumnNavigationViewStyle())
  }

  init(path: Binding<[Data]>, pathHolder: PathHolder<Data>, @ViewBuilder sideBar: () -> Sidebar, @ViewBuilder detail: () -> Detail) {
    _path = path
    self.sideBar = sideBar()
    self.detail = detail()
    self.pathHolder = pathHolder
  }

  public init(path: Binding<[Data]>, @ViewBuilder sideBar: () -> Sidebar, @ViewBuilder detail: () -> Detail) {
    self.init(path: path, pathHolder: .init(), sideBar: sideBar, detail: detail)
  }
}

public extension NBNavigationSplitView where Data == AnyHashable {
  init(@ViewBuilder sideBar: () -> Sidebar, @ViewBuilder detail: () -> Detail) {
    let pathHolder = PathHolder<Data>()
    let path = Binding(
      get: { pathHolder.path },
      set: { pathHolder.path = $0 }
    )
    self.init(path: path, pathHolder: pathHolder, sideBar: sideBar, detail: detail)
  }
}

public extension NBNavigationSplitView where Data == AnyHashable {
  init(path: Binding<NBNavigationPath>, @ViewBuilder sideBar: () -> Sidebar, @ViewBuilder detail: () -> Detail) {
    let path = Binding(
      get: { path.wrappedValue.elements },
      set: { path.wrappedValue.elements = $0 }
    )
    self.init(path: path, sideBar: sideBar, detail: detail)
  }
}
