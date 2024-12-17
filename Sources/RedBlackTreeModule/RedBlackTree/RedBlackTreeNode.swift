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

extension ___RedBlackTree {

  public struct ___Node {

    @usableFromInline
    var __right_: _NodePtr
    @usableFromInline
    var __left_: _NodePtr
    @usableFromInline
    var __parent_: _NodePtr
    @usableFromInline
    var __is_black_: Bool

    @inlinable
    mutating func clear() {
      __right_ = .nullptr
      __left_ = .nullptr
      __parent_ = .nullptr
      __is_black_ = false
    }

    @inlinable
    init(
      __is_black_: Bool,
      __left_: _NodePtr = .nullptr,
      __right_: _NodePtr = .nullptr,
      __parent_: _NodePtr = .nullptr
    ) {
      self.__right_ = __right_
      self.__left_ = __left_
      self.__parent_ = __parent_
      self.__is_black_ = __is_black_
    }

    @usableFromInline
    static let zero: Self = .init(__is_black_: false, __left_: 0, __right_: 0, __parent_: 0)
  }
}

extension ___RedBlackTree.___Node: Equatable {}

extension ___RedBlackTree.___Node {
  
  @inlinable
  mutating func invalidate() {
    __parent_ = .nullptr
  }
  
  @inlinable
  var isValid: Bool {
    __parent_ != .nullptr
  }
}
