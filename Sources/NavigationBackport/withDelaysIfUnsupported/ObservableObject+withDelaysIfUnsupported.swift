import Foundation
import SwiftUI

public extension ObservableObject {
  /// Any changes can be made to the routes array passed to the transform closure. If those
  /// changes are not supported within a single update by SwiftUI, the changes will be
  /// applied in stages. An async version of this function is also available.
  @_disfavoredOverload
  @MainActor
  func withDelaysIfUnsupported<Screen>(_ keyPath: WritableKeyPath<Self, [Route<Screen>]>, transform: (inout [Route<Screen>]) -> Void, onCompletion: (() -> Void)? = nil) {
    let start = self[keyPath: keyPath]
    let end = apply(transform, to: start)

    let didUpdateSynchronously = synchronouslyUpdateIfSupported(keyPath, from: start, to: end)
    guard !didUpdateSynchronously else { return }

    Task { @MainActor in
      await withDelaysIfUnsupported(keyPath, from: start, to: end)
      onCompletion?()
    }
  }

  /// Any changes can be made to the routes array passed to the transform closure. If those
  /// changes are not supported within a single update by SwiftUI, the changes will be
  /// applied in stages.
  @MainActor
  func withDelaysIfUnsupported<Screen>(_ keyPath: WritableKeyPath<Self, [Route<Screen>]>, transform: (inout [Route<Screen>]) -> Void) async {
    let start = self[keyPath: keyPath]
    let end = apply(transform, to: start)

    let didUpdateSynchronously = synchronouslyUpdateIfSupported(keyPath, from: start, to: end)
    guard !didUpdateSynchronously else { return }

    await withDelaysIfUnsupported(keyPath, from: start, to: end)
  }

  /// Any changes can be made to the routes array passed to the transform closure. If those
  /// changes are not supported within a single update by SwiftUI, the changes will be
  /// applied in stages. An async version of this function is also available.
  @_disfavoredOverload
  @MainActor
  func withDelaysIfUnsupported(_ keyPath: WritableKeyPath<Self, FlowPath>, transform: (inout FlowPath) -> Void, onCompletion: (() -> Void)? = nil) {
    let start = self[keyPath: keyPath]
    let end = apply(transform, to: start)

    let didUpdateSynchronously = synchronouslyUpdateIfSupported(keyPath.appending(path: \.routes), from: start.routes, to: end.routes)
    guard !didUpdateSynchronously else { return }

    Task { @MainActor in
      await withDelaysIfUnsupported(keyPath.appending(path: \.routes), from: start.routes, to: end.routes)
      onCompletion?()
    }
  }

  /// Any changes can be made to the routes array passed to the transform closure. If those
  /// changes are not supported within a single update by SwiftUI, the changes will be
  /// applied in stages.
  @MainActor
  func withDelaysIfUnsupported(_ keyPath: WritableKeyPath<Self, FlowPath>, transform: (inout FlowPath) -> Void) async {
    let start = self[keyPath: keyPath]
    let end = apply(transform, to: start)

    let didUpdateSynchronously = synchronouslyUpdateIfSupported(keyPath.appending(path: \.routes), from: start.routes, to: end.routes)
    guard !didUpdateSynchronously else { return }

    await withDelaysIfUnsupported(keyPath.appending(path: \.routes), from: start.routes, to: end.routes)
  }

  @MainActor
  fileprivate func withDelaysIfUnsupported<Screen>(_ keyPath: WritableKeyPath<Self, [Route<Screen>]>, from start: [Route<Screen>], to end: [Route<Screen>]) async {
    let binding = Binding(
      get: { [weak self] in self?[keyPath: keyPath] ?? [] },
      set: { [weak self] in self?[keyPath: keyPath] = $0 }
    )
    await binding.withDelaysIfUnsupported(from: start, to: end, keyPath: \.self)
  }

  fileprivate func synchronouslyUpdateIfSupported<Screen>(_ keyPath: WritableKeyPath<Self, [Route<Screen>]>, from start: [Route<Screen>], to end: [Route<Screen>]) -> Bool {
    guard FlowPath.canSynchronouslyUpdate(from: start, to: end) else {
      return false
    }
    // Even though self is known to be a class, the compiler complains that self is immutable
    // without this indirection.
    var copy = self
    copy[keyPath: keyPath] = end
    return true
  }
}
