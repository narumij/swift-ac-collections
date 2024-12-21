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

@usableFromInline
protocol ___RedBlackTreeSetInternal: ValueComparer
where Element == _Key, Element: Equatable {
  func _read<R>(_ body: (___UnsafeHandle<Self>) throws -> R) rethrows -> R
}

#if false
  extension ___RedBlackTreeSetInternal {

    @inlinable @inline(__always)
    func ___lt(_ p: Element) -> Element? {
      _read {
        var it = $0.__lower_bound(p, $0.__root(), .end)
        if it == $0.__begin_node { return nil }
        it = $0.__tree_prev_iter(it)
        return it != .end ? $0.__value_ptr[it] : nil
      }
    }

    @inlinable @inline(__always)
    func ___gt(_ p: Element) -> Element? {
      _read {
        let it = $0.__upper_bound(p, $0.__root(), .end)
        return it != .end ? $0.__value_ptr[it] : nil
      }
    }

    @inlinable @inline(__always)
    func ___le(_ p: Element) -> Element? {
      _read {
        var __parent = _NodePtr.nullptr
        _ = $0.__find_equal(&__parent, p)
        if __parent == .nullptr {
          return nil
        }
        if __parent == $0.__begin_node,
          $0.value_comp(p, $0.__value_(__parent))
        {
          return nil
        }
        if $0.value_comp(p, $0.__value_(__parent)) {
          __parent = $0.__tree_prev_iter(__parent)
        }
        return __parent != .end ? $0.__value_(__parent) : nil
      }
    }

    @inlinable @inline(__always)
    func ___ge(_ p: Element) -> Element? {
      _read {
        var __parent = _NodePtr.nullptr
        _ = $0.__find_equal(&__parent, p)
        if __parent != .nullptr, __parent != .end, $0.value_comp($0.__value_(__parent), p) {
          __parent = $0.__tree_next_iter(__parent)
        }
        return __parent != .end ? $0.__value_(__parent) : nil
      }
    }
  }
#endif
