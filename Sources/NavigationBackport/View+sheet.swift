import SwiftUI

struct SheetModifier<Destination: View>: ViewModifier {
  var isActiveBinding: Binding<Bool>
  var destination: Destination

  func body(content: Content) -> some View {
    /// NOTE: On iOS 14.4 and below, a bug prevented multiple sheet/fullScreenCover modifiers being chained
    /// on the same view, so we conditionally add the sheet/cover modifiers as a workaround. See
    /// https://developer.apple.com/documentation/ios-ipados-release-notes/ios-ipados-14_5-release-notes
    if #available(iOS 14.5, *) {
      content
        .sheet(
          isPresented: isActiveBinding,
          onDismiss: nil,
          content: {
            destination // TODO: .environmentObject(Navigator<Screen>(allRoutes))
          }
        )
    } else {
      // TODO:
//      let asSheet = next?.route?.style.isSheet ?? false
//      content
//        .background(
//          NavigationLink(destination: next, isActive: pushBinding, label: EmptyView.init)
//            .hidden()
//        )
//        .present(
//          asSheet: asSheet,
//          isPresented: asSheet ? sheetBinding : coverBinding,
//          onDismiss: onDismiss,
//          content: {
//            next?
//              .environmentObject(FlowPathNavigator<Screen>(allRoutes))
//          }
//        )
    }
  }
}

extension View {
  func sheet<Destination: View>(isActive: Binding<Bool>, destination: Destination) -> some View {
    return modifier(SheetModifier(isActiveBinding: isActive, destination: destination))
  }
}
