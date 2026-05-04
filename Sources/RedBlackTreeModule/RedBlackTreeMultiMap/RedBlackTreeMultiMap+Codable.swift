//
//  RedBlackTreeMultiMap+Codable.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/05.
//

// MARK: - Codable

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap: Encodable where Key: Encodable, Value: Encodable {

    @inlinable
    public func encode(to encoder: Encoder) throws {
      var container = encoder.unkeyedContainer()
      for element in __tree_.unsafeValues(__tree_.__begin_node_, __tree_.__end_node) {
        try container.encode(element)
      }
    }
  }

  extension RedBlackTreeMultiMap: Decodable where Key: Decodable, Value: Decodable {

    @inlinable
    public init(from decoder: Decoder) throws {
      self.init(__tree_: try .create(from: decoder))
    }
  }
#endif
