import NavigationBackport
import SwiftUI

enum Screen: Hashable {
  case number(Int)
  case numberList(NumberList)
  case visualisation(EmojiVisualisation)
}

struct ArrayBindingView: View {
  @State var path: [Screen] = []

  var body: some View {
    NBNavigationStack(path: $path) {
      HomeView(show99RedBalloons: show99RedBalloons)
        .nbNavigationDestination(for: Screen.self, destination: { screen in
          switch screen {
          case .numberList(let numberList):
            NumberListView(numberList: numberList)
          case .number(let number):
            NumberView(number: number, goBackToRoot: { path.removeLast(path.count) })
          case .visualisation(let visualisation):
            EmojiView(visualisation: visualisation)
          }
        })
    }
  }

  func show99RedBalloons() {
    /*
     NOTE: Pushing two screens in one update doesn't work in older versions of SwiftUI.
     The second screen would not be pushed onto the stack, leaving the data and UI out of sync.
     E.g., this would not work:
       path.append(99)
       path.append(EmojiVisualisation(emoji: "🎈", count: 99))
     But if you make those changes to the path argument of the `withDelaysIfUnsupported` closure,
     NavigationBackport will break your changes down into a series of smaller changes, which will
     then be applied one at a time, with delays in between. In this case, the first screen will be
     pushed after which the second will be pushed. On newer versions of SwiftUI the changes will be
     made in a single update.
    */
    $path.withDelaysIfUnsupported {
      $0.append(.number(99))
      $0.append(.visualisation(EmojiVisualisation(emoji: "🎈", count: 99)))
    }
  }
}

private struct HomeView: View {
  let show99RedBalloons: () -> Void

  var body: some View {
    VStack(spacing: 8) {
      NBNavigationLink(value: Screen.numberList(NumberList(range: 0 ..< 100)), label: { Text("Pick a number") })
      Button("99 Red balloons", action: show99RedBalloons)
    }.navigationTitle("Home")
  }
}

private struct NumberListView: View {
  let numberList: NumberList
  var body: some View {
    List {
      ForEach(numberList.range, id: \.self) { number in
        NBNavigationLink("\(number)", value: Screen.number(number))
      }
    }.navigationTitle("List")
  }
}

private struct NumberView: View {
  @State var number: Int
  let goBackToRoot: () -> Void

  var body: some View {
    VStack(spacing: 8) {
      Text("\(number)").font(.title)
      Stepper(
        label: { Text("\(number)") },
        onIncrement: { number += 1 },
        onDecrement: { number -= 1 }
      ).labelsHidden()
      NBNavigationLink(
        value: Screen.number(number + 1),
        label: { Text("Show next number") }
      )
      NBNavigationLink(
        value: Screen.visualisation(.init(emoji: "🐑", count: number)),
        label: { Text("Visualise with sheep") }
      )
      Button("Go back to root", action: goBackToRoot)
    }.navigationTitle("\(number)")
  }
}

private struct EmojiView: View {
  let visualisation: EmojiVisualisation

  var body: some View {
    Text(String(Array(repeating: visualisation.emoji, count: visualisation.count)))
      .navigationTitle("Visualise \(visualisation.count)")
  }
}
