import SwiftUI

struct ErrorView: View {
  let text: String

  var body: some View {
    VStack(spacing: 8) {
      Image(systemName: "exclamationmark.triangle")
      Text(text)
    }
  }
}
