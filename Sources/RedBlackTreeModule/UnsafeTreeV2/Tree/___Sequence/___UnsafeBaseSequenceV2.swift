// Copyright 2024-2026 narumij
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
// Copyright © 2003-2025 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

@usableFromInline
protocol ___UnsafeBaseSequenceV2: ___UnsafeBaseV2 {
  func ___index_or_nil(_ p: _NodePtr) -> Index?
}

extension ___UnsafeBaseSequenceV2 {

  @inlinable
  @inline(__always)
  internal func ___contains(_ __k: _Key) -> Bool {
    __tree_.__count_unique(__k) != 0
  }
}

extension ___UnsafeBaseSequenceV2 {

  @inlinable
  @inline(__always)
  internal func ___min() -> _PayloadValue? {
    __tree_.__root == __tree_.nullptr ? nil : __tree_[__tree_.__tree_min(__tree_.__root)]
  }

  @inlinable
  @inline(__always)
  internal func ___max() -> _PayloadValue? {
    __tree_.__root == __tree_.nullptr ? nil : __tree_[__tree_.__tree_max(__tree_.__root)]
  }
}

extension ___UnsafeBaseSequenceV2 {

  @inlinable
  @inline(__always)
  internal func ___lower_bound(_ __k: _Key) -> _NodePtr {
    __tree_.lower_bound(__k)
  }

  @inlinable
  @inline(__always)
  internal func ___upper_bound(_ __k: _Key) -> _NodePtr {
    __tree_.upper_bound(__k)
  }

  @inlinable
  @inline(__always)
  internal func ___index_lower_bound(_ __k: _Key) -> Index {
    ___index(___lower_bound(__k))
  }

  @inlinable
  @inline(__always)
  internal func ___index_upper_bound(_ __k: _Key) -> Index {
    ___index(___upper_bound(__k))
  }
}

extension ___UnsafeBaseSequenceV2 {

  @inlinable
  @inline(__always)
  internal func ___first_index(of member: _Key) -> Index? {
    let ptr = __tree_.__ptr_(__tree_.__find_equal(member).__child)
    return ___index_or_nil(ptr)
  }
}
