import NavigationBackport
import SwiftUI

struct NBNavigationPathView: View {
  @State var encodedPathData: Data?
  @State var path = NBNavigationPath()

  var body: some View {
    VStack {
      HStack {
        Button("Encode", action: encodePath)
          .disabled(try! encodedPathData == JSONEncoder().encode(path.codable))
        Button("Decode", action: decodePath)
          .disabled(encodedPathData == nil)
      }
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
          .nbNavigationDestination(for: ClassDestination.self, destination: { destination in
            ClassDestinationView(destination: destination)
          })
      }.usingNavigationStackWhenPossible(true)
    }
  }

  func encodePath() {
    guard let codable = path.codable else {
      return
    }
    encodedPathData = try! JSONEncoder().encode(codable)
  }

  func decodePath() {
    guard let encodedPathData = encodedPathData else {
      return
    }
    let codable = try! JSONDecoder().decode(NBNavigationPath.CodableRepresentation.self, from: encodedPathData)
    path = NBNavigationPath(codable)
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
      // Push child class via navigator
      Button("Show Class Destination", action: showClassDestination)
      // Push via Bool binding
      Toggle(isOn: $isPushing, label: { Text("Push local destination") }).padding()
    }
    .nbNavigationDestination(isPresented: $isPushing, destination: {
      Text("Local destination")
    })
    .navigationTitle("Home")
  }

  func show99RedBalloons() {
    navigator.push(99)
    navigator.push(EmojiVisualisation(emoji: "🎈", count: 99))
  }

  func showClassDestination() {
    navigator.push(SampleClassDestination())
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

private struct ClassDestinationView: View {
  let destination: ClassDestination

  var body: some View {
    Text(destination.data)
      .navigationTitle("A ClassDestination")
  }
}
