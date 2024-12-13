import Foundation
import SwiftUI

@available(iOS, deprecated: 16.0, message: "Use SwiftUI's Navigation API beyond iOS 15")
/// A replacement for SwiftUI's `NavigationStack` that's available on older OS versions.
public struct NBNavigationStack<Root: View, Data: Hashable>: View {
  @Binding var externalTypedPath: [Data]
  @State var internalTypedPath: [Data] = []
  @StateObject var path: NavigationPathHolder
  @StateObject var destinationBuilder = DestinationBuilderHolder()
  @StateObject var navigator: Navigator<Data> = .init(.constant([]))
  @Environment(\.useNavigationStack) var useNavigationStack
  // NOTE: Using `Environment(\.scenePhase)` doesn't work if the app uses UIKIt lifecycle events (via AppDelegate/SceneDelegate).
  // We do not need to re-render the view when appIsActive changes, and doing so can cause animation glitches, so it is wrapped
  // in `NonReactiveState`.
  @State var appIsActive = NonReactiveState(value: true)
  var root: Root
  var useInternalTypedPath: Bool

  var isUsingNavigationView: Bool {
    if #available(iOS 16.0, *, macOS 13.0, *, watchOS 9.0, *, tvOS 16.0, *), useNavigationStack == .whenAvailable {
      return false
    } else {
      return true
    }
  }

  @ViewBuilder
  var content: some View {
    if #available(iOS 16.0, *, macOS 13.0, *, watchOS 9.0, *, tvOS 16.0, *), useNavigationStack == .whenAvailable {
      NavigationStack(path: useInternalTypedPath ? $internalTypedPath : $externalTypedPath) {
        root
          .navigationDestination(for: LocalDestinationID.self, destination: { DestinationBuilderView(data: $0) })
          .navigationDestination(for: Data.self, destination: { DestinationBuilderView(data: $0) })
          .anyHashableNavigationDestination(for: Data.self, destination: { DestinationBuilderView(data: $0) })
      }
      .environment(\.isWithinNavigationStack, true)
    } else {
      NavigationView {
        Router(rootView: root, screens: $path.path)
      }
      .navigationViewStyle(supportedNavigationViewStyle)
      .environment(\.isWithinNavigationStack, false)
    }
  }

  public var body: some View {
    content
      .environmentObject(path)
      .environmentObject(Unobserved(object: path))
      .environmentObject(destinationBuilder)
      .environmentObject(navigator)
      .onFirstAppear {
        if useInternalTypedPath {
          // We can only access the StateObject once the view has been added to the view tree.
          navigator.pathBinding = $internalTypedPath
        }
      }
      .onFirstAppear {
        guard isUsingNavigationView else {
          return
        }
        // For NavigationView, only initialising with one pushed screen is supported.
        // Any others will be pushed one after another with delays.
        path.path = Array(path.path.prefix(1))
        path.withDelaysIfUnsupported(\.path) {
          $0 = externalTypedPath
        }
      }
      .onChange(of: externalTypedPath) { externalTypedPath in
        guard isUsingNavigationView else {
          return
        }
        guard path.path != externalTypedPath.map({ $0 }) else { return }
        guard appIsActive.value else { return }
        path.withDelaysIfUnsupported(\.path) {
          $0 = externalTypedPath
        }
      }
      .onChange(of: internalTypedPath) { internalTypedPath in
        guard isUsingNavigationView else {
          return
        }
        guard path.path != internalTypedPath.map({ $0 }) else { return }
        guard appIsActive.value else { return }
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
    #if os(iOS)
      .onReceive(NotificationCenter.default.publisher(for: didBecomeActive)) { _ in
        appIsActive.value = true
        guard isUsingNavigationView else { return }
        path.withDelaysIfUnsupported(\.path) {
          $0 = useInternalTypedPath ? internalTypedPath : externalTypedPath
        }
      }
      .onReceive(NotificationCenter.default.publisher(for: willResignActive)) { _ in
        appIsActive.value = false
      }
    #elseif os(tvOS)
      .onReceive(NotificationCenter.default.publisher(for: didBecomeActive)) { _ in
        appIsActive.value = true
        guard isUsingNavigationView else { return }
        path.withDelaysIfUnsupported(\.path) {
          $0 = useInternalTypedPath ? internalTypedPath : externalTypedPath
        }
      }
      .onReceive(NotificationCenter.default.publisher(for: willResignActive)) { _ in
        appIsActive.value = false
      }
    #endif
  }

  public init(path: Binding<[Data]>?, @ViewBuilder root: () -> Root) {
    _externalTypedPath = path ?? .constant([])
    self.root = root()
    _path = StateObject(wrappedValue: NavigationPathHolder(path: path?.wrappedValue ?? []))
    useInternalTypedPath = path == nil

    let navigator = useInternalTypedPath ? Navigator(.constant([])) : Navigator($externalTypedPath)
    _navigator = StateObject(wrappedValue: navigator)
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
      set: { path.transaction($1).wrappedValue.elements = $0 }
    )
    self.init(path: path, root: root)
  }
}

var supportedNavigationViewStyle: some NavigationViewStyle {
  #if os(macOS)
    .automatic
  #else
    .stack
  #endif
}

#if os(iOS)
  private let didBecomeActive = UIApplication.didBecomeActiveNotification
  private let willResignActive = UIApplication.willResignActiveNotification
#elseif os(tvOS)
  private let didBecomeActive = UIApplication.didBecomeActiveNotification
  private let willResignActive = UIApplication.willResignActiveNotification
#endif

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *, tvOS 16.0, *)
extension View {
  @ViewBuilder
  func anyHashableNavigationDestination<D, C>(
    for data: D.Type,
    @ViewBuilder destination: @escaping (D) -> C
  ) -> some View where D: Hashable, C: View {
    if ObjectIdentifier(D.self) == ObjectIdentifier(AnyHashable.self) {
      // No need to add AnyHashable navigation destination as it's already been added as the Data
      // navigation destination.
      self
    } else {
      // Including this ensures that `PathNavigator` can always be used.
      navigationDestination(for: AnyHashable.self, destination: { DestinationBuilderView(data: $0) })
    }
  }
}
