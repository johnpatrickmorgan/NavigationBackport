import NavigationBackport
import SwiftUI

struct ContentView: View {
  @State var path: NBNavigationPath = .init()

  @ViewBuilder private var SplashScreen: some View {
    VStack {
      Spacer()

      Text("0")

      Spacer()

      Button {
        path.push(Screen.first)
      } label: {
        Text("Next")
      }
    }
  }

  var body: some View {
    NBNavigationStack(path: $path) {
      SplashScreen
        .nbNavigationDestination(for: Screen.self) { screen in
          ViewForScreen(screen: screen)
        }
    }
  }
}

struct ViewForScreen: View {
  @EnvironmentObject var coordinator: PathNavigator
  var screen: Screen

  var body: some View {
    VStack {
      Spacer()

      Text(screen.number)

      Spacer()

      if let nextScreen = screen.nextScreen {
        Button {
          coordinator.push(nextScreen)
        } label: {
          Text("Next")
        }
      }
      Button {
        coordinator.popToRoot()
      } label: {
        Text("Pop to root")
      }
    }
  }
}

enum Screen: Hashable {
  case first
  case second
  case third
  case fourth
  case fifth

  var number: String {
    switch self {
    case .first:
      return "1"
    case .second:
      return "2"
    case .third:
      return "3"
    case .fourth:
      return "4"
    case .fifth:
      return "5"
    }
  }

  var nextScreen: Screen? {
    switch self {
    case .first:
      return .second
    case .second:
      return .third
    case .third:
      return .fourth
    case .fourth:
      return .fifth
    case .fifth:
      return nil
    }
  }
}
