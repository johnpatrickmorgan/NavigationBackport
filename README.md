# Navigation Backport

This package recreates the new NavigationStack APIs introduced in WWDC22, so that you can use them on older versions of iOS, tvOS and watchOS. 
 
✅ `NavigationStack` -> `NBNavigationStack`

✅ `NavigationLink` -> `NBNavigationLink`

✅ `NavigationPath` -> `NBNavigationPath`

✅ `navigationDestination` -> `nbNavigationDestination`

You no longer need to wait to adopt these APIs, and when you eventually bump your deployment target to iOS 16, you can remove this library and easily migrate to its SwiftUI equivalent.

## Example

```swift
struct ContentView: View {
  @State var path = NBNavigationPath()

  var body: some View {
    NBNavigationStack(path: $path) {
      HomeView()
        .nbNavigationDestination(for: Int.self, destination: { number in
          NumberView(number: number, goBackToRoot: { path.removeLast(path.count) })
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
      NBNavigationLink(value: 1, label: { Text("Go to number one") })
    }.navigationTitle("Home")
  }
}

struct NumberView: View {
  let number: Int
  let goBackToRoot: () -> Void

  var body: some View {
    VStack(spacing: 8) {
      NBNavigationLink(value: number + 1, label: { Text("Show next number") })
      NBNavigationLink(
        value: EmojiVisualisation(emoji: "🐑", count: number),
        label: { Text("Visualise with sheep") }
      )
      Button("Go back to root", action: goBackToRoot)
    }.navigationTitle("\(number)")
  }
}

struct EmojiVisualisation: Hashable {
  let emoji: Character
  let count: Int
}

struct EmojiView: View {
  let visualisation: EmojiVisualisation
  
  var body: some View {
    Text(String(Array(repeating: visualisation.emoji, count: visualisation.count)))
      .navigationTitle("Visualise \(visualisation.count)")
  }
}
```
 
 ## Deeplinking
 
 Before iOS 16, SwiftUI did not support pushing more than one screen in a single state update. This makes it tricky to make large updates to the navigation state, e.g. when deeplinking straight to a view deep in the navigation hierarchy. `NavigationBackport` provides an API to work around this: you can wrap such path changes within a call to `withDelaysIfUnsupported`, and the library will break down the large update into a series of smaller updates that SwiftUI supports, if necessary:

```swift
$path.withDelaysIfUnsupported {
  $0.append(Screen.orders)
  $0.append(Screen.editOrder(id: id))
  $0.append(Screen.confirmChanges(orderId: id))
}
```

On the latest OS versions, the new screens will be pushed in one update but on older OS versions, the new screens will be pushed one by one.

## To do

The package is not yet fully complete. Here are some outstanding tasks: 
  
 - [ ] Codable support for NavigationPath
 - [ ] Codable support for NavigationLink
 - [ ] Backport NavigationSplitView
 - [ ] Conditionally use SwiftUI Navigation API if available?
