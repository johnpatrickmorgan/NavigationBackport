import Foundation

public extension Navigator {
  /// Any changes can be made to the screens array passed to the transform closure. If those
  /// changes are not supported within a single update by SwiftUI, the changes will be
  /// applied in stages.
  @_disfavoredOverload
  @MainActor
  func withDelaysIfUnsupported(transform: (inout [Screen]) -> Void, onCompletion: (() -> Void)? = nil) {
    let start = path
    let end = apply(transform, to: start)

    let didUpdateSynchronously = synchronouslyUpdateIfSupported(from: start, to: end)
    guard !didUpdateSynchronously else { return }

    Task { @MainActor in
      await pathBinding.withDelaysIfUnsupported(from: start, to: end, keyPath: \.self)
      onCompletion?()
    }
  }

  /// Any changes can be made to the screens array passed to the transform closure. If those
  /// changes are not supported within a single update by SwiftUI, the changes will be
  /// applied in stages.
  @MainActor
  func withDelaysIfUnsupported(transform: (inout [Screen]) -> Void) async {
    let start = path
    let end = apply(transform, to: start)

    let didUpdateSynchronously = synchronouslyUpdateIfSupported(from: start, to: end)
    guard !didUpdateSynchronously else { return }

    await pathBinding.withDelaysIfUnsupported(transform)
  }

  fileprivate func synchronouslyUpdateIfSupported(from start: [Screen], to end: [Screen]) -> Bool {
    guard NavigationBackport.canSynchronouslyUpdate(from: start, to: end) else {
      return false
    }
    path = end
    return true
  }
}
