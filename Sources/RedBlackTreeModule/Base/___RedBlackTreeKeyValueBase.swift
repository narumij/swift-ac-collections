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

public protocol ___RedBlackTreeKeyValueBase
where Element == (key: _Key, value: _MappedValue) {
  associatedtype _Key
  associatedtype _MappedValue
  associatedtype _Value
  associatedtype Element
  static func ___element(_ __value: _Value) -> Element
  static func ___tree_value(_ __element: Element) -> _Value
}

extension ___RedBlackTreeKeyValueBase {

  @inlinable
  @inline(__always)
  public func ___element(_ __value: _Value) -> Element {
    Self.___element(__value)
  }

  @inlinable
  @inline(__always)
  public func ___tree_value(_ __element: Element) -> _Value {
    Self.___tree_value(__element)
  }
}

extension ___RedBlackTreeKeyValueBase where _Value == RedBlackTreePair<_Key, _MappedValue> {

  @inlinable
  @inline(__always)
  public static func ___element(_ __value: _Value) -> Element {
    (__value.key, __value.value)
  }

  @inlinable
  @inline(__always)
  public static func ___tree_value(_ __element: Element) -> _Value {
    RedBlackTreePair(__element.key, __element.value)
  }
}
