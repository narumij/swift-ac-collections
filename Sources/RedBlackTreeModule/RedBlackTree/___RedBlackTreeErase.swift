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

import Collections
import Foundation

@usableFromInline
protocol ___RedBlackTreeEraseProtocol: ___RedBlackTreeContainer, EraseProtocol {
  mutating func erase(_ __p: _NodePtr) -> _NodePtr
}

extension ___RedBlackTreeEraseProtocol {

  @inlinable
  @discardableResult
  mutating func ___remove(at ptr: _NodePtr) -> Element? {
    guard
      // 下二つのコメントアウトと等価
      0 <= ptr,
      // ptr != .nullptr,
      // ptr != .end,
      ___nodes[ptr].isValid
    else {
      return nil
    }
    let e = ___values[ptr]
    _ = erase(ptr)
    return e
  }

  public mutating func ___removeAll(keepingCapacity keepCapacity: Bool = false) {
    ___header = .zero
    ___nodes.removeAll(keepingCapacity: keepCapacity)
    ___values.removeAll(keepingCapacity: keepCapacity)
    ___stock = []
  }
}

