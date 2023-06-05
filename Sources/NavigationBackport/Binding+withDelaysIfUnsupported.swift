import Foundation
import SwiftUI

public extension Binding where Value: Collection {
  /// Any changes can be made to the screens array passed to the transform closure. If those
  /// changes are not supported within a single update by SwiftUI, the changes will be
  /// applied in stages.
  @_disfavoredOverload
  func withDelaysIfUnsupported<Screen>(_ transform: (inout [Route<Screen>]) -> Void, onCompletion: (() -> Void)? = nil) where Value == [Route<Screen>] {
    let start = wrappedValue
    let end = apply(transform, to: start)

    let didUpdateSynchronously = synchronouslyUpdateIfSupported(from: start, to: end)
    guard !didUpdateSynchronously else { return }

    Task { @MainActor in
      await withDelaysIfUnsupported(from: start, to: end, keyPath: \.self)
      onCompletion?()
    }
  }

  /// Any changes can be made to the screens array passed to the transform closure. If those
  /// changes are not supported within a single update by SwiftUI, the changes will be
  /// applied in stages.
  func withDelaysIfUnsupported<Screen>(_ transform: (inout [Route<Screen>]) -> Void) async where Value == [Route<Screen>] {
    let start = wrappedValue
    let end = apply(transform, to: start)

    let didUpdateSynchronously = synchronouslyUpdateIfSupported(from: start, to: end)
    guard !didUpdateSynchronously else { return }

    await withDelaysIfUnsupported(from: start, to: end, keyPath: \.self)
  }

  fileprivate func synchronouslyUpdateIfSupported<Screen>(from start: [Route<Screen>], to end: [Route<Screen>]) -> Bool where Value == [Route<Screen>] {
    guard NavigationBackport.canSynchronouslyUpdate(from: start, to: end) else {
      return false
    }
    wrappedValue = end
    return true
  }
}

public extension Binding where Value == NBNavigationPath {
  /// Any changes can be made to the screens array passed to the transform closure. If those
  /// changes are not supported within a single update by SwiftUI, the changes will be
  /// applied in stages.
  @_disfavoredOverload
  func withDelaysIfUnsupported(_ transform: (inout NBNavigationPath) -> Void, onCompletion: (() -> Void)? = nil) {
    let start = wrappedValue
    let end = apply(transform, to: start)

    let didUpdateSynchronously = synchronouslyUpdateIfSupported(from: start.elements, to: end.elements)
    guard !didUpdateSynchronously else { return }

    Task { @MainActor in
      await withDelaysIfUnsupported(from: start.elements, to: end.elements, keyPath: \.elements)
      onCompletion?()
    }
  }

  /// Any changes can be made to the screens array passed to the transform closure. If those
  /// changes are not supported within a single update by SwiftUI, the changes will be
  /// applied in stages.
  func withDelaysIfUnsupported(_ transform: (inout Value) -> Void) async {
    let start = wrappedValue
    let end = apply(transform, to: start)

    let didUpdateSynchronously = synchronouslyUpdateIfSupported(from: start.elements, to: end.elements)
    guard !didUpdateSynchronously else { return }

    await withDelaysIfUnsupported(from: start.elements, to: end.elements, keyPath: \.elements)
  }

  fileprivate func synchronouslyUpdateIfSupported(from start: [Route<AnyHashable>], to end: [Route<AnyHashable>]) -> Bool {
    guard NavigationBackport.canSynchronouslyUpdate(from: start, to: end) else {
      return false
    }
    wrappedValue.elements = end
    return true
  }
}

extension Binding {
  @MainActor
  func withDelaysIfUnsupported<Screen>(from start: [Route<Screen>], to end: [Route<Screen>], keyPath: WritableKeyPath<Value, [Route<Screen>]>) async {
    let steps = NavigationBackport.calculateSteps(from: start, to: end)

    wrappedValue[keyPath: keyPath] = steps.first!
    await scheduleRemainingSteps(steps: Array(steps.dropFirst()), keyPath: keyPath)
  }

  @MainActor
  func scheduleRemainingSteps<Screen>(steps: [[Route<Screen>]], keyPath: WritableKeyPath<Value, [Route<Screen>]>) async {
    guard let firstStep = steps.first else {
      return
    }
    wrappedValue[keyPath: keyPath] = firstStep
    do {
      try await Task.sleep(nanoseconds: UInt64(0.65 * 1_000_000_000))
      await scheduleRemainingSteps(steps: Array(steps.dropFirst()), keyPath: keyPath)
    } catch {}
  }
}
