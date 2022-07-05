import Foundation
import SwiftUI

public extension Binding where Value: Collection {
  @_disfavoredOverload
  func withDelaysIfUnsupported<Screen>(_ transform: (inout [Screen]) -> Void, onCompletion: (() -> Void)? = nil) where Value == [Screen] {
    let start = wrappedValue
    let end = apply(transform, to: start)
    Task { @MainActor in
      await withDelaysIfUnsupported(from: start, to: end, keyPath: \.self)
      onCompletion?()
    }
  }

  func withDelaysIfUnsupported<Screen>(_ transform: (inout Value) -> Void) async where Value == [Screen] {
    let start = wrappedValue
    let end = apply(transform, to: start)
    await withDelaysIfUnsupported(from: start, to: end, keyPath: \.self)
  }
}

public extension Binding where Value == NBNavigationPath {
  @_disfavoredOverload
  func withDelaysIfUnsupported(_ transform: (inout NBNavigationPath) -> Void, onCompletion: (() -> Void)? = nil) {
    let start = wrappedValue
    let end = apply(transform, to: start)
    Task { @MainActor in
      await withDelaysIfUnsupported(from: start.elements, to: end.elements, keyPath: \.elements)
      onCompletion?()
    }
  }

  func withDelaysIfUnsupported(_ transform: (inout Value) -> Void) async {
    let start = wrappedValue
    let end = apply(transform, to: start)
    await withDelaysIfUnsupported(from: start.elements, to: end.elements, keyPath: \.elements)
  }
}

extension Binding {
  func withDelaysIfUnsupported<Screen>(_ transform: (inout [Screen]) -> Void, keyPath: WritableKeyPath<Value, [Screen]>) async {
    let start = wrappedValue[keyPath: keyPath]
    let end = apply(transform, to: start)
    await withDelaysIfUnsupported(from: start, to: end, keyPath: keyPath)
  }

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

func apply<T>(_ transform: (inout T) -> Void, to input: T) -> T {
  var transformed = input
  transform(&transformed)
  return transformed
}
