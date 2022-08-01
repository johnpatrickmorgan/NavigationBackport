# Navigation Backport

This package uses the navigation APIs available in older SwiftUI versions (such as `NavigationView` and `NavigationLink`) to recreate the new `NavigationStack` APIs introduced in WWDC22, so that you can start targeting those APIs on older versions of iOS, tvOS and watchOS. 
 
✅ `NavigationStack` -> `NBNavigationStack`

✅ `NavigationLink` -> `NBNavigationLink`

✅ `NavigationPath` -> `NBNavigationPath`

✅ `navigationDestination` -> `nbNavigationDestination`

✅ `NavigationPath.CodableRepresentation` -> `NBNavigationPath.CodableRepresentation`


You can migrate to these APIs now, and when you eventually bump your deployment target to iOS 16, you can remove this library and easily migrate to its SwiftUI equivalent. `NavigationStack`'s full API is replicated, so you can initialise an `NBNavigationStack` with a binding to an `Array`, with a binding to a `NBNavigationPath` binding, or with no binding at all.

## Example

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
  let number: Int
  let goBackToRoot: () -> Void

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
      Button("Go back to root", action: goBackToRoot)
    }.navigationTitle("\(number)")
  }
}

struct EmojiVisualisation: Hashable {
  let emoji: String
  let count: Int
  
  var description: String {
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
 
 ## Deep-linking
 
 Before `NavigationStack`, SwiftUI did not support pushing more than one screen in a single state update, e.g. when deep-linking to a screen multiple layers deep in a navigation hierarchy. `NavigationBackport` provides an API to work around this limitation: you can wrap such path changes within a call to `withDelaysIfUnsupported`, and the library will, if necessary, break down the larger update into a series of smaller updates that SwiftUI supports, with delays in between. For example, the following code that tries to push three screens in one update will not work:

```swift
  path.append(Screen.orders)
  path.append(Screen.editOrder(id: id))
  path.append(Screen.confirmChanges(orderId: id))
```

However, the amended code below will successfully push all three screens, one after another:

```swift
$path.withDelaysIfUnsupported {
  $0.append(Screen.orders)
  $0.append(Screen.editOrder(id: id))
  $0.append(Screen.confirmChanges(orderId: id))
}
```

You can make any changes to the path passed into the `withDelaysIfUnsupported` closure, and the library will calculate the minimal number of state updates required to successfully update the UI.
