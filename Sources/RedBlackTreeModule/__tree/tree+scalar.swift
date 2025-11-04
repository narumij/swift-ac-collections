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

/// 要素とキーが一致する場合のひな形
public protocol ScalarValueComparer: ValueComparer where _Key == _Value {}

extension ScalarValueComparer {

  @inlinable
  @inline(__always)
  public static func __key(_ e: _Value) -> _Key { e }
}

extension ScalarValueComparer {
  
  @inlinable
  @inline(__always)
  public static func ___element_comp(_ lhs: _Value, _ rhs: _Value) -> Bool {
    value_comp(lhs, rhs)
  }
  
  @inlinable
  @inline(__always)
  public static func ___element_equiv(_ lhs: _Value, _ rhs: _Value) -> Bool {
    value_equiv(lhs, rhs)
  }
}

extension ScalarValueComparer where _Value: Hashable {

  @inlinable
  @inline(__always)
  public static func ___element_hash(_ lhs: _Value, into hasher: inout Hasher) {
    hasher.combine(lhs)
  }
}
