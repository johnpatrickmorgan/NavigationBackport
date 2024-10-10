import SwiftUI

struct Presentable: View {
  let id = UUID()
  let content: AnyView

  init(_ content: some View) {
    self.content = AnyView(content)
  }

  var body: some View {
    content
  }
}

extension Presentable: Hashable {
  static func == (lhs: Presentable, rhs: Presentable) -> Bool {
    lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
