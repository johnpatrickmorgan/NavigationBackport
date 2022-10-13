/// An empty protocol extending Hashable. Allows access to utility extensions on Array where the element
/// conforms to NBScreen, rather than polluting all Arrays with navigation APIs.
public protocol NBScreen: Hashable {}

extension AnyHashable: NBScreen {}
