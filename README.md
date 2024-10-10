# Navigation Backport

This package uses the navigation APIs available in older SwiftUI versions (such as `NavigationView` and `NavigationLink`) to recreate the new `NavigationStack` APIs introduced in WWDC22, so that you can start targeting those APIs on older versions of iOS, tvOS, macOS and watchOS. When running on an OS version that supports `NavigationStack`, `NavigationStack` will be used under the hood.
 
✅ `NavigationStack` -> `NBNavigationStack`

✅ `NavigationLink` -> `NBNavigationLink`

✅ `NavigationPath` -> `NBNavigationPath`

✅ `navigationDestination` -> `nbNavigationDestination`

✅ `NavigationPath.CodableRepresentation` -> `NBNavigationPath.CodableRepresentation`


You can migrate to these APIs now, and when you eventually bump your deployment target, you can remove this library and easily migrate to its SwiftUI equivalent. `NavigationStack`'s full API is replicated, so you can initialise an `NBNavigationStack` with a binding to an `Array`, with a binding to an `NBNavigationPath` binding, or with no binding at all.

## Example

<details>
  <summary>Click to expand an example</summary>

```swift
import NavigationBackport
import SwiftUI

struct ContentView: View {
  @State var path = NBNavigationPath()

  var body: some View {
    NBNavigationStack(path: $path) {
      HomeView()
        .nbNavigationDestination(for: NumberList.self, destination: { numberList in
          NumberListView(numberList: numberList)
        })
        .nbNavigationDestination(for: Int.self, destination: { number in
          NumberView(number: number)
        })
        .nbNavigationDestination(for: EmojiVisualisation.self, destination: { visualisation in
          EmojiView(visualisation: visualisation)
        })
    }
  }
}

struct HomeView: View {
  var body: some View {
    VStack(spacing: 8) {
      NBNavigationLink(value: NumberList(range: 0 ..< 100), label: { Text("Pick a number") })
    }.navigationTitle("Home")
  }
}

struct NumberList: Hashable {
  let range: Range<Int>
}

struct NumberListView: View {
  let numberList: NumberList
  var body: some View {
    List {
      ForEach(numberList.range, id: \.self) { number in
        NBNavigationLink("\(number)", value: number)
      }
    }.navigationTitle("List")
  }
}

struct NumberView: View {
  @EnvironmentObject var navigator: PathNavigator
  
  let number: Int

  var body: some View {
    VStack(spacing: 8) {
      Text("\(number)")
      NBNavigationLink(
        value: number + 1,
        label: { Text("Show next number") }
      )
      NBNavigationLink(
        value: EmojiVisualisation(emoji: "🐑", count: number),
        label: { Text("Visualise with sheep") }
      )
      Button("Go back to root", action: { navigator.popToRoot() })
    }.navigationTitle("\(number)")
  }
}

struct EmojiVisualisation: Hashable {
  let emoji: String
  let count: Int
  
  var text: String {
    Array(repeating: emoji, count: count).joined()
  }
}

struct EmojiView: View {
  let visualisation: EmojiVisualisation

  var body: some View {
    Text(visualisation.text)
      .navigationTitle("Visualise \(visualisation.count)")
  }
}
```

</details>

## Additional features

As well as replicating the standard features of the new `NavigationStack` APIs, some helpful utilities have also been added. 

### Navigator

A `Navigator` object is available through the environment, giving access to the current navigation path. The navigator can be accessed via the environment, e.g. for a NBNavigationPath-backed stack:

```swift
@EnvironmentObject var navigator: PathNavigator
```

Or for a stack backed by an Array, e.g. `[ScreenType]`:

```swift
@EnvironmentObject var navigator: Navigator<ScreenType>
```

As well as allowing you to inspect the path elements, the navigator can be used to push new screens, pop, pop to a specific screen or pop to the root.

### Navigation functions

Whether interacting with an `Array`, an `NBNavigationPath`, or a `Navigator`, a number of utility functions are available for easier navigation, such as:

```swift
path.push(Profile(name: "John"))

path.pop()

path.popToRoot()

path.popTo(Profile.self)
```

Note that, if you want to use these methods on an `Array`, ensure the `Array`'s `Element` conforms to `NBScreen`, a protocol that inherits from Hashable without adding any additional requirements. This avoids polluting all arrays with APIs specific to navigation.

## Deep-linking
 
 Before `NavigationStack`, SwiftUI did not support pushing more than one screen in a single state update, e.g. when deep-linking to a screen multiple layers deep in a navigation hierarchy. `NavigationBackport` works around this limitation: you can make any such path changes, and the library will, behind the scenes, break down the larger update into a series of smaller updates that SwiftUI supports if necessary, with delays in between. For example, the following code that pushes three screens in one state update will push the screens one by one if needed:

```swift
  path.append(Screen.orders)
  path.append(Screen.editOrder(id: id))
  path.append(Screen.confirmChanges(orderId: id))
```

This only happens when necessary: on versions of SwiftUI that support `NavigationStack`, all three screens will be pushed successfully in one update.

## Support for iOS/tvOS 13

This library targets iOS/tvOS versions 14 and above, since it uses `StateObject`, which is unavailable on iOS/tvOS 13. However, there is an `ios13` branch, which uses [SwiftUIBackports](https://github.com/shaps80/SwiftUIBackports)' backported StateObject, so that it works on iOS/tvOS 13 too.

## FlowStacks

Want to further upgrade your navigation APIs? [FlowStacks](https://github.com/johnpatrickmorgan/FlowStacks) enhances these familiar APIs to allow you to additionally drive sheet and full-screen cover navigation from a single unified interface. 

-------

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/T6T114GWOT)
