import Foundation

enum Deeplink {
  case viewModelTab(ViewModelTabDeeplink)
  
  init?(url: URL) {
    guard url.scheme == "flowstacksapp" else { return nil }
    switch url.host {
    case "numbers":
      guard let numberDeeplink = ViewModelTabDeeplink(pathComponents: url.pathComponents.dropFirst()) else {
        return nil
      }
      self = .viewModelTab(numberDeeplink)
    default:
      return nil
    }
  }
}

enum ViewModelTabDeeplink {
  case numbers([Int])
  
  init?<C: Collection>(pathComponents: C) where C.Element == String {
    let numbers = pathComponents.compactMap(Int.init)
    guard numbers.count == pathComponents.count else {
      return nil
    }
    self = .numbers(numbers)
  }
}
