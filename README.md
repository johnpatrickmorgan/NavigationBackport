# FlowStacks

This package takes SwiftUI's familiar and powerful `NavigationStack` API and gives it superpowers, allowing you to use the same API not just for push navigation, but also for presenting sheets and full-screen covers. And because it's implemented using the navigation APIs available in older SwiftUI versions, you can use it on earlier versions of iOS, tvOS, watchOS and macOS.

If you already know SwiftUI's `NavigationStack` APIs, `FlowStacks` should feel familiar and intuitive. Just replace 'Navigation' with 'Flow' in type and function names:
 
✅ `NavigationStack` -> `FlowStack`

✅ `NavigationLink` -> `FlowLink`

✅ `NavigationPath` -> `FlowPath`

✅ `navigationDestination` -> `flowDestination`

✅ `NavigationPath.CodableRepresentation` -> `FlowPath.CodableRepresentation`


`NavigationStack`'s full API is replicated, so you can initialise a `FlowStack` with a binding to an `Array`, with a binding to a `FlowPath` binding, or with no binding at all. The only difference is that the array should be a `[Route<MyScreen>]`s instead of `[MyScreen]`. The `Route` combines the destination data with info about what style of presentation is used: `push`, `sheet` or `cover`. Similarly, when you create a `FlowLink`, you also specify the style of presentation. 

## Additional features

As well as replicating the standard features of the new `NavigationStack` APIs, some helpful utilities have also been added. 

### FlowNavigator

A `FlowNavigator` object is available through the environment, giving access to the current navigation path. The navigator can be accessed via the environment, e.g. for a FlowPath-backed stack:

```swift
@EnvironmentObject var navigator: FlowPathNavigator
```

Or for a stack backed by a routes array, e.g. `[Route<ScreenType>]`:

```swift
@EnvironmentObject var navigator: Navigator<ScreenType>
```

### Convenience methods

Whether interacting with an `Array`, a `FlowPath`, or a `FlowNavigator`, a number of convenience methods are available for easier navigation, including:

| Method       | Effect                                            |
|--------------|---------------------------------------------------|
| push         | Pushes a new screen onto the stack.               |
| presentSheet | Presents a new screen as a sheet.†                |
| presentCover | Presents a new screen as a full-screen cover.†    |
| goBack       | Goes back one screen in the stack.                |
| goBackToRoot | Goes back to the very first screen in the stack.  |
| goBackTo     | Goes back to a specific screen in the stack.      |
| pop          | Pops the current screen if it was pushed.         |
| dismiss      | Dismisses the most recently presented screen.     |

### Deep-linking
 
 Before `NavigationStack`, SwiftUI did not support pushing more than one screen in a single state update, e.g. when deep-linking to a screen multiple layers deep in a navigation hierarchy. `NavigationBackport` works around this limitation: you can make any such path changes, and the library will, behind the scenes, break down the larger update into a series of smaller updates that SwiftUI supports if necessary, with delays in between. For example, the following code that pushes three screens in one state update will push the screens one by one:

```swift
  navigator.push(.orders)
  navigator.push(.editOrder(id: id))
  navigator.push(.confirmChanges(orderId: id))
```

## Example

<details>
  <summary>Click to expand an example</summary>

```swift
import FlowStacks
import SwiftUI

struct ContentView: View {
  @State var path = FlowPath()

  var body: some View {
    FlowStack($path) {
      HomeView()
        .flowDestination(for: NumberList.self, destination: { numberList in
          NumberListView(numberList: numberList)
        })
        .flowDestination(for: Int.self, destination: { number in
          NumberView(number: number)
        })
        .flowDestination(for: EmojiVisualisation.self, destination: { visualisation in
          EmojiView(visualisation: visualisation)
        })
    }
  }
}

struct HomeView: View {
  var body: some View {
    FlowLink(value: NumberList(range: 0 ..< 100), style: .push, label: { Text("Pick a number") })
      .navigationTitle("Home")
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
        FlowLink("\(number)", value: number)
      }
    }.navigationTitle("List")
  }
}

struct NumberView: View {
  @EnvironmentObject var navigator: FlowPathNavigator
  let number: Int

  var body: some View {
    VStack(spacing: 8) {
      Text("\(number)")
      FlowLink(
        value: number + 1,
        style: .push,
        label: { Text("Show next number") }
      )
      FlowLink(
        value: EmojiVisualisation(emoji: "🐑", count: number),
        style: .sheet,
        label: { Text("Visualise with sheep") }
      )
      Button("Go back to root") {
        navigator.goBackToRoot()
      }
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

## Using NavigationStack when available

By default, `NavigationView` is used under the hood for navigation, even on SwiftUI versions that support `NavigationStack`. If you prefer to use `NavigationStack` when available, apply the following modifier anywhere above the `FlowStack`:

```swift
MyApp()
  .useNavigationStack(.whenAvailable)
```

It should not make any discernible difference, but you might find that using `NavigationStack` prevents some spurious warnings being logged by SwiftUI. 

## How does it work? 

This [blog post](https://johnpatrickmorgan.github.io/2021/07/03/NStack/) outlines how an array of screens can be translated into a hierarchy of views and `NavigationLink`s. `FlowStacks` uses a similar approach to allow both push navigation and sheet/cover presentation.
