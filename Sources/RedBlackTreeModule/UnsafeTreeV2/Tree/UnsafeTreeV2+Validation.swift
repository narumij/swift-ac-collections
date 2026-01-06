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

@inlinable
@inline(__always)
func ___is_null_or_end__(pointerIndex: Int) -> Bool {
  // 名前が衝突するしパッケージ名を書きたくないため中継している
  ___is_null_or_end(pointerIndex)
}

extension UnsafeTreeV2 {
  
  @inlinable
  @inline(__always)
  internal func ___is_null_or_end(_ ptr: _NodePtr) -> Bool {
//    ptr == nullptr || ptr == end
//    ptr.pointee.___node_id_ < 0
    ___is_null_or_end__(pointerIndex: ptr.pointee.___node_id_)
  }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  internal func ___is_begin(_ p: _NodePtr) -> Bool {
    p == __begin_node_
  }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  internal func ___is_end(_ p: _NodePtr) -> Bool {
    p == end
  }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  internal func ___is_root(_ p: _NodePtr) -> Bool {
    p == __root
  }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  internal func ___initialized_contains(_ p: _NodePtr) -> Bool {
    0..<initializedCount ~= p.pointee.___node_id_
  }

  /// 真の場合、操作は失敗する
  ///
  /// 添え字アクセスチェック用
  ///
  /// endを無効として扱う
  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  internal func ___is_subscript_null(_ p: _NodePtr) -> Bool {

    // 初期化済みチェックでnullptrとendは除外される
    //    return !___initialized_contains(p) || ___is_garbaged(p)
    // begin -> false
    // end -> true
    return ___is_null_or_end(p) || initializedCount <= p.pointee.___node_id_ || ___is_garbaged(p)
  }

  /// 真の場合、操作は失敗する
  ///
  /// beginを有効として扱う
  ///
  /// endを無効として扱う
  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  internal func ___is_next_null(_ p: _NodePtr) -> Bool {
    ___is_subscript_null(p)
  }

  /// 真の場合、操作は失敗する
  ///
  /// beginを無効として扱う
  ///
  /// endを有効として扱う
  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  internal func ___is_prev_null(_ p: _NodePtr) -> Bool {

    // begin -> true
    // end -> false
    return p == nullptr || initializedCount <= p.pointee.___node_id_ || ___is_begin(p) || ___is_garbaged(p)
  }

  /// 真の場合、操作は失敗する
  ///
  /// 範囲チェック用
  ///
  /// endを有効として扱う
  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  internal func ___is_offset_null(_ p: _NodePtr) -> Bool {
    return p == nullptr || initializedCount <= p.pointee.___node_id_ || ___is_garbaged(p)
  }

  /// 真の場合、操作は失敗する
  ///
  /// `end..<end`のケースを有効として扱う
  ///
  /// ベースコレクションの場合、回収済みでさえなければ、`start..<end`に必ず含まれているので、範囲チェックを省略している
  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  internal func ___is_range_null(_ p: _NodePtr, _ l: _NodePtr) -> Bool {
    // end..<endのケースを許可するため、左辺を___is_offset_nullとしている
    ___is_offset_null(p) || ___is_offset_null(l)
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal func ___ensureValid(after i: _NodePtr) {
    if ___is_next_null(i) {
      fatalError(.invalidIndex)
    }
  }

  @inlinable
  @inline(__always)
  internal func ___ensureValid(before i: _NodePtr) {
    if ___is_prev_null(i) {
      fatalError(.invalidIndex)
    }
  }

  @inlinable
  @inline(__always)
  internal func ___ensureValid(offset i: _NodePtr) {
    if ___is_offset_null(i) {
      fatalError(.invalidIndex)
    }
  }

  @inlinable
  @inline(__always)
  internal func ___ensureValid(subscript i: _NodePtr) {
    if ___is_subscript_null(i) {
      fatalError(.invalidIndex)
    }
  }

  @inlinable
  @inline(__always)
  internal func ___ensureValid(begin i: _NodePtr, end j: _NodePtr) {
    if ___is_range_null(i, j) {
      fatalError(.invalidIndex)
    }
  }
}
