import SwiftUI

enum TrafficLight: Int, CaseIterable {
  case red, amber, green

  var next: TrafficLight? {
    TrafficLight(rawValue: rawValue + 1)
  }

  var color: Color {
    switch self {
    case .red: return .red
    case .amber: return .orange
    case .green: return .green
    }
  }
}
