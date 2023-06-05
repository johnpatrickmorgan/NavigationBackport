//import Foundation
//
//struct RehostingView: UIViewControllerRepresentable {
//  typealias UIViewControllerType = UIViewController
//
//  func makeUIViewController(context: Context) -> UIViewControllerType {
//    let vc = UIHostingController(
//        rootView: NBNavigationStack(root: { Text("Home") }).nbUseNavigationStack(.whenAvailable)
//      )
//    return vc
//  }
//
//  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
//}
//
//class HostingViewController: UIHostingController<HostedView> {
//  init() {
//    super.init(rootView: HostedView())
//  }
//
//  required init?(coder aDecoder: NSCoder) {
//    super.init(coder: aDecoder, rootView: HostedView())
//  }
//}
//
//struct HostedView: View {
//  @State var path = NBNavigationPath()
//  @State var showLocal = false
//
//  var body: some View {
//    NBNavigationStack(path: $path) {
//      VStack {
//        Toggle("Show local", isOn: $showLocal)
//        NBNavigationLink(value: 42, label: { Text("Show 42") })
//      }
//      .nbNavigationDestination(for: Int.self, destination: { number in
//        Text("\(number)")
//      })
//      .nbNavigationDestination(isPresented: $showLocal, destination: { Text("Local") })
//    }
//  }
//}
