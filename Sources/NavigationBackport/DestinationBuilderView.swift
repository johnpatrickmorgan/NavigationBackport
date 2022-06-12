import Foundation
import SwiftUI

struct DestinationBuilderView<Data>: View {
  let data: Data

  @EnvironmentObject var destinationBuilder: DestinationBuilderHolder

  var body: some View {
    return destinationBuilder.build(data)
  }
}
