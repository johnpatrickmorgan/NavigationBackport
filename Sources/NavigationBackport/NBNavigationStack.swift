import Foundation
import SwiftUI

@available(iOS, deprecated: 16.0, message: "Use SwiftUI's Navigation API beyond iOS 15")
/// A replacement for SwiftUI's `NavigationStack` that's available on older OS versions.
public struct NBNavigationStack<Root: View, Data: Hashable>: View {
  @Binding var unownedPath: [Data]
  @State var hiddenPath: [Data] = []
  @StateObject var ownedPath = NavigationPathHolder()
  @StateObject var pathAppender = PathAppender()
  @StateObject var destinationBuilder = DestinationBuilderHolder()
  var root: Root
  var useHiddenPath: Bool

  var content: some View {
    pathAppender.append = { [weak ownedPath] newElement in
      ownedPath?.path.append(newElement)
    }
    return NavigationWrapper {
      Router(rootView: root, screens: $ownedPath.path)
    }
    .environmentObject(ownedPath)
    .environmentObject(pathAppender)
    .environmentObject(destinationBuilder)
    .environmentObject(Navigator(useHiddenPath ? $hiddenPath : $unownedPath))
  }

  public var body: some View {
    content
      .onFirstAppear {
        ownedPath.withDelaysIfUnsupported(\.path) {
          $0 = unownedPath
        }
      }
      .onChange(of: unownedPath) { unownedPath in
        ownedPath.withDelaysIfUnsupported(\.path) {
          $0 = unownedPath
        }
      }
      .onChange(of: hiddenPath) { hiddenPath in
        ownedPath.withDelaysIfUnsupported(\.path) {
          $0 = hiddenPath
        }
      }
      .onChange(of: ownedPath.path) { ownedPath in
        if useHiddenPath {
          guard ownedPath != hiddenPath.map({ $0 }) else { return }
          hiddenPath = ownedPath.compactMap { anyHashable in
            if let data = anyHashable.base as? Data {
              return data
            } else if anyHashable.base is LocalDestinationID {
              return nil
            }
            fatalError("Cannot add \(type(of: anyHashable.base)) to stack of \(Data.self)")
          }
        } else {
          guard ownedPath != unownedPath.map({ $0 }) else { return }
          unownedPath = ownedPath.compactMap { anyHashable in
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
    _unownedPath = path ?? .constant([])
    self.root = root()
    useHiddenPath = path == nil
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

struct NavigationWrapper<Content: View>: View {
  var content: Content
  @Environment(\.useNavigationStack) var useNavigationStack

  var body: some View {
    if #available(iOS 16.0, *), useNavigationStack == .whenAvailable {
      return AnyView(NavigationStack { content })
        .environment(\.isWithinNavigationStack, true)
    } else {
      return AnyView(NavigationView { content }
        .navigationViewStyle(supportedNavigationViewStyle))
        .environment(\.isWithinNavigationStack, false)
    }
  }

  init(content: () -> Content) {
    self.content = content()
  }
}

public enum UseNavigationStackPolicy {
  case whenAvailable
  case never
}

public extension View {
  func nbUseNavigationStack(_ policy: UseNavigationStackPolicy) -> some View {
    environment(\.useNavigationStack, policy)
  }
}

private var supportedNavigationViewStyle: some NavigationViewStyle {
  #if os(macOS)
    .automatic
  #else
    .stack
  #endif
}

struct UseNavigationStackPolicyKey: EnvironmentKey {
  static let defaultValue = UseNavigationStackPolicy.never
}

struct IsWithinNavigationStackKey: EnvironmentKey {
  static let defaultValue = false
}

extension EnvironmentValues {
  var useNavigationStack: UseNavigationStackPolicy {
    get { self[UseNavigationStackPolicyKey.self] }
    set { self[UseNavigationStackPolicyKey.self] = newValue }
  }

  var isWithinNavigationStack: Bool {
    get { self[IsWithinNavigationStackKey.self] }
    set { self[IsWithinNavigationStackKey.self] = newValue }
  }
}
