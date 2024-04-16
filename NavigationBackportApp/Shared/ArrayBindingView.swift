import NavigationBackport
import SwiftUI

enum Screen: NBScreen {
  case number(Int)
  case numberList(NumberList)
  case visualisation(EmojiVisualisation)
}

struct ArrayBindingView: View {
  @State var savedPath: [Screen]?
  @State var path: [Screen] = ProcessArguments.nonEmptyAtLaunch ? [.number(1), .number(2), .number(3), .number(4)] : []

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
    path = savedPath
  }
}

private struct HomeView: View {
  @EnvironmentObject var navigator: Navigator<Screen>
  @State var isPushing = false
  @State var pokemon: String?

  var body: some View {
    ScrollView {
      VStack(spacing: 8) {
        // Push via NBNavigationLink
        NBNavigationLink(value: Screen.numberList(NumberList(range: 0 ..< 10)), label: { Text("Pick a number") })
        // Push via navigator
        Button("99 Red balloons", action: show99RedBalloons)
        // Push via Bool binding
        Button("Push local destination", action: { isPushing = true }).disabled(isPushing)
        // Push via `nbNavigationDestination(item:)`
        Button("Push local pokemon", action: {
          pokemon = "Bulbasaur"
          DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { pokemon? = "Ivysaur" }
          DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { pokemon? = "Venusaur" }
          DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) { pokemon = nil }
        }).disabled(pokemon != nil)
      }
    }
    .nbNavigationDestination(isPresented: $isPushing) {
      Text("Local destination")
    }
    .nbNavigationDestination(item: $pokemon) { pokemon in Text(pokemon) }
    .navigationTitle("Home")
  }

  func show99RedBalloons() {
    navigator.push(.number(99))
    navigator.push(.visualisation(EmojiVisualisation(emoji: "🎈", count: 99)))
  }
}

private struct NumberListView: View {
  let numberList: NumberList
  var body: some View {
    List {
      ForEach(numberList.range, id: \.self) { number in
        NBNavigationLink("\(number)", value: Screen.number(number))
      }
    }
    .navigationTitle("List")
  }
}

private struct NumberView: View {
  @EnvironmentObject var navigator: Navigator<Screen>
  @State var number: Int

  var body: some View {
    ScrollView {
      VStack(spacing: 8) {
        Text("\(number)").font(.title)
        #if os(tvOS)
        #else
          Stepper(
            label: { Text("\(number)") },
            onIncrement: { number += 1 },
            onDecrement: { number -= 1 }
          ).labelsHidden()
        #endif
        NBNavigationLink(
          value: Screen.number(number + 1),
          label: { Text("Show next number") }
        )
        NBNavigationLink(
          value: Screen.visualisation(.init(emoji: "🐑", count: number)),
          label: { Text("Visualise with sheep") }
        )
        Button("Go back to root", action: { navigator.popToRoot() })
      }
    }
    .navigationTitle("\(number)")
  }
}

private struct EmojiView: View {
  let visualisation: EmojiVisualisation

  var body: some View {
    Text(visualisation.text)
      .navigationTitle("Visualise \(visualisation.count)")
  }
}
