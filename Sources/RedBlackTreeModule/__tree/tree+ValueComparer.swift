// Copyright 2024 narumij
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2024 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

import Foundation

// MARK: common

@usableFromInline
protocol ValueComparer {
  associatedtype _Key
  associatedtype Element
  static func __key(_: Element) -> _Key
  static func value_comp(_: _Key, _: _Key) -> Bool
}

extension ValueComparer where _Key: Comparable {

  @inlinable @inline(__always)
  static func value_comp(_ a: _Key, _ b: _Key) -> Bool {
    a < b
  }
}

// MARK: key

@usableFromInline
protocol ScalarValueComparer: ValueComparer where _Key == Element {}

extension ScalarValueComparer {
  
  @inlinable @inline(__always)
  static func __key(_ e: Element) -> _Key { e }
}

// MARK: key value

@usableFromInline
protocol KeyValueComparer: ValueComparer {
  associatedtype _Value
}

extension KeyValueComparer {
  public typealias _KeyValue = (key: _Key, value: _Value)
}

extension KeyValueComparer where Element == _KeyValue {

  @inlinable @inline(__always)
  static func __key(_ element: Element) -> _Key { element.key }
  
  @inlinable @inline(__always)
  static func __value(_ element: Element) -> _Value { element.value }
}


