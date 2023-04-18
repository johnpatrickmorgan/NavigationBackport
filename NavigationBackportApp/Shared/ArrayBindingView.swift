import NavigationBackport
import SwiftUI

enum Screen: NBScreen {
  case number(Int)
  case numberList(NumberList)
  case visualisation(EmojiVisualisation)
}

struct ArrayBindingView: View {
  @State var savedPath: [Screen]?
  @State var path: [Screen] = []

  var body: some View {
    VStack {
      HStack {
        Button("Save", action: savePath)
          .disabled(savedPath == path)
        Button("Restore", action: restorePath)
          .disabled(savedPath == nil)
      }
      NBNavigationStack(path: $path) {
        HomeView()
          .nbNavigationDestination(for: Screen.self, destination: { screen in
            switch screen {
            case .numberList(let numberList):
              NumberListView(numberList: numberList)
            case .number(let number):
              NumberView(number: number)
            case .visualisation(let visualisation):
              EmojiView(visualisation: visualisation)
            }
          })
      }
    }
  }

  func savePath() {
    savedPath = path
  }

  func restorePath() {
    guard let savedPath = savedPath else { return }
    $path.withDelaysIfUnsupported {
      $0 = savedPath
    }
  }
}

private struct HomeView: View {
  @State var isPushing = false
  @EnvironmentObject var navigator: Navigator<Screen>

  var body: some View {
    VStack(spacing: 8) {
      // Push via NBNavigationLink
      NBNavigationLink(value: Screen.numberList(NumberList(range: 0 ..< 100)), label: { Text("Pick a number") })
      // Push via navigator
      Button("99 Red balloons", action: show99RedBalloons)
      // Push via Bool binding
      VStack {
        Text("Push local destination")
        Toggle(isOn: $isPushing, label: { EmptyView() })
          .labelsHidden()
      }.padding()
    }.navigationTitle("Home")
      .nbNavigationDestination(isPresented: $isPushing) {
        Text("Local destination")
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
    navigator.withDelaysIfUnsupported {
      $0.push(.number(99))
      $0.push(.visualisation(EmojiVisualisation(emoji: "🎈", count: 99)))
    }
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
  @EnvironmentObject var navigator: Navigator<Screen>
  @State var number: Int

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
      Button("Go back to root", action: { navigator.popToRoot() })
    }.navigationTitle("\(number)")
  }
}

private struct EmojiView: View {
  let visualisation: EmojiVisualisation

  var body: some View {
    Text(visualisation.text)
      .navigationTitle("Visualise \(visualisation.count)")
  }
}
