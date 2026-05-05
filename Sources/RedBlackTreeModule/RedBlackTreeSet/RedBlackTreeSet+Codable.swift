//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project
//
// Copyright (c) 2024 - 2026 narumij.
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.
//
//===----------------------------------------------------------------------===//

// MARK: - Codable

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet: Encodable where Element: Encodable {
    
    /// Encodes the elements of this set into the given encoder in an unkeyed
    /// container.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    @inlinable
    public func encode(to encoder: Encoder) throws {
      var container = encoder.unkeyedContainer()
      for element in self {
        try container.encode(element)
      }
    }
  }

  extension RedBlackTreeSet: Decodable where Element: Decodable {
    
    /// Creates a new set by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    @inlinable
    public init(from decoder: Decoder) throws {
      self.init(__tree_: try .create(from: decoder))
    }
  }
#endif
