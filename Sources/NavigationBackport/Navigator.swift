import SwiftUI

public typealias PathNavigator = Navigator<AnyHashable>

/// An object available via the environment that gives access to the current path.
/// Supports push and pop operations when `Screen` conforms to `NBScreen`.
@MainActor
public class Navigator<Screen>: ObservableObject {
  private let pathBinding: Binding<[Screen]>

  /// The current navigation path.
  public var path: [Screen] {
    get { pathBinding.wrappedValue }
    set { pathBinding.wrappedValue = newValue }
  }

  init(_ pathBinding: Binding<[Screen]>) {
    self.pathBinding = pathBinding
  }

  /// Any changes can be made to the screens array passed to the transform closure. If those
  /// changes are not supported within a single update by SwiftUI, the changes will be
  /// applied in stages.
  @_disfavoredOverload
  public func withDelaysIfUnsupported(transform: (inout [Screen]) -> Void, onCompletion: (() -> Void)? = nil) {
    let start = path
    let end = apply(transform, to: start)
    Task { @MainActor in
      await pathBinding.withDelaysIfUnsupported(from: start, to: end, keyPath: \.self)
      onCompletion?()
    }
  }

  /// Any changes can be made to the screens array passed to the transform closure. If those
  /// changes are not supported within a single update by SwiftUI, the changes will be
  /// applied in stages.
  @MainActor
  public func withDelaysIfUnsupported(transform: (inout [Screen]) -> Void) async {
    await pathBinding.withDelaysIfUnsupported(transform)
  }
}
