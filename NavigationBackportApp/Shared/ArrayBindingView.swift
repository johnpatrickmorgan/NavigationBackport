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
            case let .numberList(numberList):
              NumberListView(numberList: numberList)
            case let .number(number):
              NumberView(number: number)
            case let .visualisation(visualisation):
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
  @State private var trafficLight: TrafficLight?

  var body: some View {
    ScrollView {
      VStack(spacing: 8) {
        // Push via NBNavigationLink
        NBNavigationLink(value: Screen.numberList(NumberList(range: 0 ..< 10)), label: { Text("Pick a number") })
        // Push via navigator
        Button("99 Red balloons", action: show99RedBalloons)
        // Push via Bool binding
        Button("Push local destination", action: { isPushing = true }).disabled(isPushing)
        // Push via Optional Hashable binding
        Button("Push traffic lights", action: {
          trafficLight = TrafficLight.allCases.first
        })
      }
    }
    .nbNavigationDestination(isPresented: $isPushing) {
      Text("Local destination")
    }
    .nbNavigationDestination(item: $trafficLight) { trafficLight in
      Text(String(describing: trafficLight))
        .foregroundColor(trafficLight.color)
        .onTapGesture { self.trafficLight = trafficLight.next }
    }
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
          .buttonStyle(.navigationLinkRowStyle)
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
