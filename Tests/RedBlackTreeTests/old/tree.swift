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

#if DEBUG
  @testable import RedBlackTreeModule

import Foundation

// MARK: -

@usableFromInline
protocol _TreeNode_KeyProtocol:
  _TreeNode_KeyInterface
    & _TreeRawValue_KeyInterface
    & _TreeNode_RawValueInterface
{}

extension _TreeNode_KeyProtocol {

  #if true
    @inlinable
    @inline(__always)
    internal func __get_value(_ p: _NodePtr) -> _Key {
      __key(__value_(p))
    }
  #else
    @inlinable
    @inline(__always)
    internal func __get_value(_ p: _NodePtr) -> __node_value_type {
      __key(__value_(p))
    }
  #endif
}

@usableFromInline
protocol BeginProtocol: BeginNodeInterface {
  // __begin_node_が圧倒的に速いため
  @available(*, deprecated, renamed: "__begin_node_")
  /// 木の左端のノードを返す
  @inlinable func begin() -> _NodePtr
}

extension BeginProtocol {
  // __begin_node_が圧倒的に速いため
  @available(*, deprecated, renamed: "__begin_node_")
  @inlinable
  @inline(__always)
  /// 木の左端のノードを返す
  internal func begin() -> _NodePtr { __begin_node_ }
}

@usableFromInline
protocol EndNodeProtocol: EndNodeInterface {}

extension EndNodeProtocol where _NodePtr == Int {
  /// 終端ノード（木の右端の次の仮想ノード）を返す
  @inlinable
  @inline(__always)
  internal var __end_node: _NodePtr { .end }
}

@usableFromInline
protocol EndProtocol: EndInterface {}

extension EndProtocol where _NodePtr == Int {
  /// 終端ノード（木の右端の次の仮想ノード）を返す
  @inlinable
  @inline(__always)
  internal var end: _NodePtr { .end }
}

protocol ___RootProtocol: RootInterface & TreeNodeAccessInterface & EndNodeProtocol {}

extension ___RootProtocol where _NodePtr == Int {
  @available(*, deprecated, message: "Kept only for the purpose of preventing loss of knowledge")
  /// 木の根ノードを返す
  internal var __root: _NodePtr { __left_(__end_node) }
}

@usableFromInline
protocol RootPtrProtocol: RootPtrInterface & TreeNodeAccessInterface & TreeNodeRefAccessInterface
    & RootInterface & EndProtocol & EndNodeProtocol
{
}

extension RootPtrProtocol where _NodePtr == Int {
  /// 木の根ノードへの参照を返す
  @inlinable
  @inline(__always)
  internal func __root_ptr() -> _NodeRef { __left_ref(__end_node) }
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
#endif
