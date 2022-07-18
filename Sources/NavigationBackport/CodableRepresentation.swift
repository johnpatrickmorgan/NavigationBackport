
import Foundation

public extension NBNavigationPath {
  struct CodableRepresentation {
    static let encoder = JSONEncoder()
    static let decoder = JSONDecoder()
    
    var elements: [AnyHashable]
  }
  
  var codable: CodableRepresentation? {
    guard elements.allSatisfy({ $0 is Codable }) else {
      return nil
    }
    return CodableRepresentation(elements: elements)
  }
  
  init(_ codable: CodableRepresentation) {
    self.init(codable.elements)
  }
}

extension NBNavigationPath.CodableRepresentation: Encodable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.unkeyedContainer()
    for element in elements.map({ $0.base }).reversed() {
      if #available(iOS 14.0, *) {
        try container.encode(_mangledTypeName(type(of: element)))
      } else {
        try container.encode(String(reflecting: type(of: element)))
      }
      guard let element = element as? Encodable else {
        throw EncodingError.invalidValue(
          element, .init(
            codingPath: container.codingPath,
            debugDescription: "\(type(of: element)) is not encodable."
          )
        )
      }
      #if swift(<5.7)
        func encode<A: Encodable>(_: A.Type) throws -> Data {
          try Self.encoder.encode(element as! A)
        }
        let data = try _openExistential(type(of: element), do: encode)
        let string = String(decoding: data, as: UTF8.self)
        try container.encode(string)
      #else
        let string = try String(decoding: Self.encoder.encode(element), as: UTF8.self)
        try container.encode(string)
      #endif
    }
  }
}

extension NBNavigationPath.CodableRepresentation: Decodable {
  public init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()
    self.elements = []
    while !container.isAtEnd {
      let typeName = try container.decode(String.self)
      guard let type = _typeByName(typeName) as? any (Hashable & Decodable).Type else {
        throw DecodingError.dataCorruptedError(
          in: container,
          debugDescription: "\(typeName) is not decodable."
        )
      }
      let encodedValue = try container.decode(String.self)
      #if swift(<5.7)
        func decode<A: Decodable>(_: A.Type) throws -> A {
          try Self.decoder.decode(A.self, from: Data(encodedValue.utf8))
        }
        let value = try _openExistential(type, do: decode)
      #else
        let value = try Self.decoder.decode(type, from: Data(encodedValue.utf8))
      #endif
      self.elements.insert(AnyHashable(value), at: 0)
    }
  }
}

//extension NBNavigationPath: Equatable {
//
//}
