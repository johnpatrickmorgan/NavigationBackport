import NavigationBackport
import SwiftUI

struct NBNavigationPathView: View {
  @State var encodedPathData: Data?
  @State var path = NBNavigationPath()

  var body: some View {
    VStack {
      HStack {
        Button("Encode", action: encodePath)
        Button("Decode", action: decodePath)
          .disabled(encodedPathData == nil)
      }
      NBNavigationStack(path: $path) {
        HomeView(show99RedBalloons: show99RedBalloons)
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
    $path.withDelaysIfUnsupported {
      $0 = NBNavigationPath(codable)
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
      $0.append(99)
      $0.append(EmojiVisualisation(emoji: "🎈", count: 99))
    }
  }
}

private struct HomeView: View {
  let show99RedBalloons: () -> Void

  var body: some View {
    VStack(spacing: 8) {
      NBNavigationLink(value: NumberList(range: 0 ..< 100), label: { Text("Pick a number") })
      Button("99 Red balloons", action: show99RedBalloons)
    }.navigationTitle("Home")
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

private struct EmojiView: View {
  let visualisation: EmojiVisualisation

  var body: some View {
    Text(visualisation.text)
      .navigationTitle("Visualise \(visualisation.count)")
  }
}
