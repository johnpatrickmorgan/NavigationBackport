import NavigationBackport
import SwiftUI

struct NoBindingView: View {
  var body: some View {
    NBNavigationStack {
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

private struct HomeView: View {
  @EnvironmentObject var navigator: PathNavigator
  @State var isPushing = false

  var body: some View {
    VStack(spacing: 8) {
      // Push via link
      NBNavigationLink(value: NumberList(range: 0 ..< 100), label: { Text("Pick a number") })
      // Push via navigator
      Button("99 Red balloons", action: show99RedBalloons)
      // Push via Bool binding
      VStack {
        Text("Push local destination")
        Toggle(isOn: $isPushing, label: { EmptyView() })
          .labelsHidden()
      }.padding()
    }.navigationTitle("Home")
      .nbNavigationDestination(isPresented: $isPushing, destination: {
        Text("Local destination")
      })
  }

  func show99RedBalloons() {
    navigator.withDelaysIfUnsupported {
      $0.append(99)
      $0.append(EmojiVisualisation(emoji: "🎈", count: 99))
    }
  }
}

private struct NumberListView: View {
  let numberList: NumberList
  var body: some View {
    List {
      ForEach(numberList.range, id: \.self) { number in
        NBNavigationLink("\(number)", value: number)
      }
    }.navigationTitle("List")
  }
}

private struct NumberView: View {
  @EnvironmentObject var navigator: PathNavigator
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
        value: number + 1,
        label: { Text("Show next number") }
      )
      NBNavigationLink(
        value: EmojiVisualisation(emoji: "🐑", count: number),
        label: { Text("Visualise with sheep") }
      )
      Button("Pop to root") {
        navigator.popToRoot()
      }
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
