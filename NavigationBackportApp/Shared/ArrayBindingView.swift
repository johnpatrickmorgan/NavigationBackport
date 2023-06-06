import NavigationBackport
import SwiftUI

enum Screen: Hashable {
  case number(Int)
  case numberList(NumberList)
  case visualisation(EmojiVisualisation)
}

struct ArrayBindingView: View {
  @State var savedPath: [Route<Screen>]?
  @State var path: [Route<Screen>] = []

  var body: some View {
    VStack {
      HStack {
        Button("Save", action: savePath)
          .disabled(savedPath == path)
        Button("Restore", action: restorePath)
          .disabled(savedPath == nil)
      }
      NBNavigationStack(path: $path, embedInNavigationView: true) {
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
  @State var isPushing = false
  @EnvironmentObject var navigator: Navigator<Screen>

  var body: some View {
    VStack(spacing: 8) {
      // Push via NBNavigationLink
      NBNavigationLink(value: .sheet(Screen.numberList(NumberList(range: 0 ..< 10)), embedInNavigationView: true), label: { Text("Pick a number") })
      // Push via navigator
      Button("99 Red balloons", action: show99RedBalloons)
      // Push via Bool binding
      Button("Push local destination", action: { isPushing = true }).disabled(isPushing)
    }.navigationTitle("Home")
      .nbNavigationDestination(isPresented: $isPushing, style: .push) {
        Text("Local destination")
      }
  }

  func show99RedBalloons() {
    navigator.push(.number(99))
    navigator.push(.visualisation(EmojiVisualisation(emoji: "🎈", count: 99)))
  }
}

private struct NumberListView: View {
  @EnvironmentObject var navigator: Navigator<Screen>
  let numberList: NumberList
  var body: some View {
    List {
      ForEach(numberList.range, id: \.self) { number in
        NBNavigationLink("\(number)", value: .sheet(Screen.number(number), embedInNavigationView: true))
      }
      Button("Go back", action: { navigator.goBack() })
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
        value: .push(Screen.number(number + 1)),
        label: { Text("Show next number") }
      )
      NBNavigationLink(
        value: .sheet(Screen.visualisation(.init(emoji: "🐑", count: number)), embedInNavigationView: false),
        label: { Text("Visualise with sheep") }
      )
      Button("Go back to root", action: { navigator.goBackToRoot() })
    }.navigationTitle("\(number)")
  }
}

private struct EmojiView: View {
  @EnvironmentObject var navigator: Navigator<Screen>
  let visualisation: EmojiVisualisation

  var body: some View {
    Text(visualisation.text)
      .navigationTitle("Visualise \(visualisation.count)")
    Button("Go back", action: { navigator.goBack() })
  }
}
