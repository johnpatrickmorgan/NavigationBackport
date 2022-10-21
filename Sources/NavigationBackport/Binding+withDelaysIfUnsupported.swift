import Foundation
import SwiftUI

public extension Binding where Value: Collection {
  /// Any changes can be made to the screens array passed to the transform closure. If those
  /// changes are not supported within a single update by SwiftUI, the changes will be
  /// applied in stages.
  @_disfavoredOverload
  func withDelaysIfUnsupported<Screen>(_ transform: (inout [Screen]) -> Void, onCompletion: (() -> Void)? = nil) where Value == [Screen] {
    let start = wrappedValue
    let end = apply(transform, to: start)
    Task { @MainActor in
      await withDelaysIfUnsupported(from: start, to: end, keyPath: \.self)
      onCompletion?()
    }
  }

  /// Any changes can be made to the screens array passed to the transform closure. If those
  /// changes are not supported within a single update by SwiftUI, the changes will be
  /// applied in stages.
  func withDelaysIfUnsupported<Screen>(_ transform: (inout [Screen]) -> Void) async where Value == [Screen] {
    let start = wrappedValue
    let end = apply(transform, to: start)
    await withDelaysIfUnsupported(from: start, to: end, keyPath: \.self)
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
    await withDelaysIfUnsupported(from: start.elements, to: end.elements, keyPath: \.elements)
  }
}

extension Binding {
  @MainActor
  func withDelaysIfUnsupported<Screen>(from start: [Screen], to end: [Screen], keyPath: WritableKeyPath<Value, [Screen]>) async {
    let steps = NavigationBackport.calculateSteps(from: start, to: end)

    wrappedValue[keyPath: keyPath] = steps.first!
    await scheduleRemainingSteps(steps: Array(steps.dropFirst()), keyPath: keyPath)
  }

  @MainActor
  func scheduleRemainingSteps<Screen>(steps: [[Screen]], keyPath: WritableKeyPath<Value, [Screen]>) async {
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
