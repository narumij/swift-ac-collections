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

/// 赤黒木の内部Index
///
/// (説明が古いので注意)
/// (現在はCoW時のノード解決や特殊ポインタ判定簡略の為に使っている)
///
/// ヒープの代わりに配列を使っているため、実際には内部配列のインデックスを使用している
///
/// インデックスが0からはじまるため、一般的にnullは0で表現するところを、-2で表現している
///
/// endはルートノードを保持するオブジェクトを指すかわりに、-1で表現している
///
/// llvmの`__tree`ではポインタとイテレータが使われているが、イテレータはこのインデックスで代替している
public typealias _PointerIndex = Int

extension _PointerIndex {

  /// 赤黒木のIndexで、nullを表す
  @inlinable
  package static var nullptr: Self {
    -2
  }

  /// 赤黒木のIndexで、終端を表す
  @inlinable
  package static var end: Self {
    -1
  }

  /// 数値を直接扱うことを避けるための初期化メソッド
  @inlinable
  @inline(__always)
  package static func node(_ p: Int) -> Self { p }
}

@inlinable
@inline(__always)
package func ___is_null_or_end(_ ptr: _PointerIndex) -> Bool {
  ptr < 0
}

/// 赤黒木の参照型を表す内部enum
///
/// (現在はプロトコルのテスト用に使っている)
//@available(*, deprecated, message: "もうつかっていない。配列インデックス方式の名残。")
public
  enum _PointerIndexRef: Equatable
{
  /// 右ノードへの参照
  case __right_(_PointerIndex)
  /// 左ノードへの参照
  case __left_(_PointerIndex)
}

extension TreeNodeProtocol where _NodePtr == Int, _NodeRef == _PointerIndexRef {

  @inlinable
  @inline(__always)
  internal func __ptr_(_ rhs: _NodeRef) -> _NodePtr {
    switch rhs {
    case .__right_(let basePtr):
      return __right_(basePtr)
    case .__left_(let basePtr):
      return __left_(basePtr)
    }
  }

  @inlinable
  @inline(__always)
  internal func __left_ref(_ p: _NodePtr) -> _NodeRef {
    assert(p != .nullptr)
    return .__left_(p)
  }

  @inlinable
  @inline(__always)
  internal func __right_ref(_ p: _NodePtr) -> _NodeRef {
    assert(p != .nullptr)
    return .__right_(p)
  }
}

extension TreeNodeProtocol where _NodePtr == Int, _NodeRef == _PointerIndexRef {

  @inlinable
  @inline(__always)
  internal func __ptr_(_ lhs: _NodeRef, _ rhs: _NodePtr) {
    switch lhs {
    case .__right_(let basePtr):
      return __right_(basePtr, rhs)
    case .__left_(let basePtr):
      return __left_(basePtr, rhs)
    }
  }
}
