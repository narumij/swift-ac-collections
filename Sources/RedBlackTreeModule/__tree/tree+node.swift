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

@usableFromInline
protocol ___tree_root_node {
  var __left_: _pointer { get set }
}

extension ___tree_root_node {
  public typealias _pointer = _NodePtr
}

@usableFromInline
protocol ___tree_base_node: ___tree_root_node {
  var __right_: _pointer { get set }
  var __parent_: _pointer { get set }
  var __is_black_: Bool { get set }
}

extension ___tree_base_node {
  
  @inlinable @inline(__always)
  public mutating func clear() {
    __left_ = .nullptr
    __right_ = .nullptr
    __parent_ = .nullptr
    __is_black_ = false
  }
}
