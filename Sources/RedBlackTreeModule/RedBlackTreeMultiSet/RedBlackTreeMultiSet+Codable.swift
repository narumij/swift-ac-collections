//
//  RedBlackTreeMultiSet+Codable.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/05.
//

// MARK: - Codable

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet: Encodable where Element: Encodable {

    @inlinable
    public func encode(to encoder: Encoder) throws {
      var container = encoder.unkeyedContainer()
      for element in self {
        try container.encode(element)
      }
    }
  }

  extension RedBlackTreeMultiSet: Decodable where Element: Decodable {

    @inlinable
    public init(from decoder: Decoder) throws {
      self.init(__tree_: try .create(from: decoder))
    }
  }
#endif
