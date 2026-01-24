// Copyright 2024-2025 narumij
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

public protocol _PairValueType: _KeyValueRawType
where _RawValue == RedBlackTreePair<_Key, _MappedValue> {}

public protocol PairValue_KeyProtocol: _PairValueType & _BaseRawValue_KeyInterface {}

extension PairValue_KeyProtocol {

  @inlinable
  @inline(__always)
  public static func __key(_ __v: _RawValue) -> _Key { __v.key }
}

public protocol PairValue_MappedValueProtocol: _PairValueType & _BaseRawValue_MappedValueInterface {}

extension PairValue_MappedValueProtocol {

  @inlinable
  @inline(__always)
  public static func ___mapped_value(_ __v: _RawValue) -> _MappedValue { __v.value }
}

public protocol PairValue_WithMappedValueProtocol: _PairValueType & WithMappedValueInterface {}

extension PairValue_WithMappedValueProtocol {

  @inlinable
  @inline(__always)
  public static func ___with_mapped_value<ResultType>(
    _ __v: inout _RawValue,
    _ __body: (inout _MappedValue) throws -> ResultType
  ) rethrows -> ResultType {
    try __body(&__v.value)
  }
}

// TODO: プロトコルインジェクションを整理すること
// __treenの基本要素ではないので、別カテゴリがいい

/// 要素がキーバリューの場合のひな形
public protocol KeyValueComparer: _KeyValueRawType & ValueComparer & HasDefaultThreeWayComparator
    & _BaseRawValue_MappedValueInterface & WithMappedValueInterface
{}

extension KeyValueComparer where _RawValue == RedBlackTreePair<_Key, _MappedValue> {

  @inlinable
  @inline(__always)
  public static func __key(_ element: _RawValue) -> _Key { element.key }

  @inlinable
  @inline(__always)
  public static func ___mapped_value(_ element: _RawValue) -> _MappedValue { element.value }

  @inlinable
  @inline(__always)
  public static func ___with_mapped_value<T>(
    _ element: inout _RawValue, _ f: (inout _MappedValue) throws -> T
  ) rethrows -> T {
    try f(&element.value)
  }
}
