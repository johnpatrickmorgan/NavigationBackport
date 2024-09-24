import SwiftUI

public extension View {
  /// Sets the value to enable or disable the navigator functionality.
  /// This method allows you to specify whether the navigator feature should be active
  /// or inactive within the current view's environment. By passing `true`, you enable
  /// the navigator, granting access to enhanced navigation options. Passing `false`
  /// will disable this feature.
  /// - Parameter isEnabled: A Boolean value indicating whether the navigator should be enabled or disabled
  /// - Returns: A view that reflects the updated navigation environment setting.
  func nbNavigatorEnabled(_ isEnabled: Bool) -> some View {
    environment(\.useNavigator, isEnabled)
  }
}
