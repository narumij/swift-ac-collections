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
protocol _SequenceV2: UnsafeTreeHost, _PayloadValueBride, _KeyBride {}

extension _SequenceV2 {

  @inlinable @inline(__always)
  internal var ___is_empty: Bool {
    __tree_.count == 0
  }

  @inlinable @inline(__always)
  internal var ___count: Int {
    __tree_.count
  }

  @inlinable @inline(__always)
  internal func ___contains(_ __k: _Key) -> Bool {
    __tree_.__count_unique(__k) != 0
  }
}

extension _SequenceV2 {

  @inlinable @inline(__always)
  package var _start: _NodePtr {
    __tree_.__begin_node_
  }

  @inlinable @inline(__always)
  package var _end: _NodePtr {
    __tree_.__end_node
  }

  @inlinable @inline(__always)
  package var _sealed_start: _SealedPtr {
    __tree_.__begin_node_.sealed
  }

  @inlinable @inline(__always)
  package var _sealed_end: _SealedPtr {
    __tree_.__end_node.sealed
  }

  @inlinable @inline(__always)
  package var ___capacity: Int {
    __tree_.capacity
  }
}

extension _SequenceV2 {

  @inlinable @inline(__always)
  internal func ___min() -> _PayloadValue? {
    __tree_.___min()
  }

  @inlinable @inline(__always)
  internal func ___max() -> _PayloadValue? {
    __tree_.___max()
  }
}

extension _SequenceV2 {
  
  @inlinable @inline(__always)
  internal var ___first: _PayloadValue? {
    ___is_empty ? nil : __tree_[_unsafe_raw: _start]
  }

  @inlinable @inline(__always)
  internal var ___last: _PayloadValue? {
    ___is_empty ? nil : __tree_[_unsafe_raw: __tree_.__tree_prev_iter(_end)]
  }
}
