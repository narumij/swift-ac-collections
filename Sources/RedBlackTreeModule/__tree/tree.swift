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

public protocol _TreePointer {
  associatedtype _NodePtr: Equatable
  associatedtype _NodeRef
}

public protocol TreePointer: _TreePointer
where _NodePtr == _Pointer
{
  associatedtype _Pointer
  var nullptr: _NodePtr { get }
  var end: _NodePtr { get }
}

public protocol _KeyProtocol {
  /// ツリーが比較に使用する値の型
  associatedtype _Key
}

public protocol _ValueProtocol {
  /// 要素の型
  associatedtype _Value
}

public protocol _TreeValue: _KeyProtocol & _ValueProtocol {}

// ルートノードの親相当の機能
@usableFromInline
protocol TreeEndNodeProtocol: TreePointer {
  /// 左ノードを返す
  ///
  /// 木を遡るケースではこちらが必ず必要
  @inlinable func __left_(_: pointer) -> pointer
  /// 左ノードを返す
  ///
  /// 根から末端に向かう処理は、こちらで足りる
  @inlinable func __left_unsafe(_ p: pointer) -> pointer
  /// 左ノードを更新する
  @inlinable func __left_(_ lhs: pointer, _ rhs: pointer)
}

extension TreeEndNodeProtocol {
  @usableFromInline
  typealias pointer = _Pointer
}

// 一般ノード相当の機能
@usableFromInline
protocol TreeNodeProtocol: TreeEndNodeProtocol {
  /// 右ノードを返す
  @inlinable func __right_(_: pointer) -> pointer
  /// 右ノードを更新する
  @inlinable func __right_(_ lhs: pointer, _ rhs: pointer)
  /// 色を返す
  @inlinable func __is_black_(_: pointer) -> Bool
  /// 色を更新する
  @inlinable func __is_black_(_ lhs: pointer, _ rhs: Bool)
  /// 親ノードを返す
  @inlinable func __parent_(_: pointer) -> pointer
  /// 親ノードを更新する
  @inlinable func __parent_(_ lhs: pointer, _ rhs: pointer)
  /// 親ノードを返す
  ///
  /// This is only to align the naming with C++.
  /// C++と名前を揃えているだけのもの
  @inlinable func __parent_unsafe(_: pointer) -> __parent_pointer
}

extension TreeNodeProtocol {
  @usableFromInline
  typealias __parent_pointer = _Pointer
}

@usableFromInline
protocol TreeNodeRefProtocol: TreePointer {
  /// 左ノードへの参照を返す
  @inlinable func __left_ref(_: _NodePtr) -> _NodeRef
  /// 右ノードへの参照を返す
  @inlinable func __right_ref(_: _NodePtr) -> _NodeRef
  /// 参照先を返す
  @inlinable func __ptr_(_ rhs: _NodeRef) -> _NodePtr
  /// 参照先を更新する
  @inlinable func __ptr_(_ lhs: _NodeRef, _ rhs: _NodePtr)
}

// 型の名前にねじれがあるので注意
@usableFromInline
protocol TreeNodeValueProtocol: TreePointer & _KeyProtocol where _Key == __node_value_type {
  associatedtype __node_value_type
  /// ノードから比較用の値を取り出す。
  /// SetやMultisetではElementに該当する
  /// DictionaryやMultiMapではKeyに該当する
  @inlinable func __get_value(_: _NodePtr) -> __node_value_type
}

// 型の名前にねじれがあるので注意
@usableFromInline
protocol TreeValueProtocol: TreePointer & _ValueProtocol where _Value == __value_type {
  associatedtype __value_type
  /// ノードの値要素を取得する
  @inlinable func __value_(_ p: _NodePtr) -> __value_type
}

@usableFromInline
protocol KeyProtocol: TreeNodeValueProtocol, TreeValueProtocol {
  /// 要素から比較用のキー値を取り出す。
  @inlinable func __key(_ e: _Value) -> _Key
}

extension KeyProtocol {

  @inlinable
  @inline(__always)
  internal func __get_value(_ p: _NodePtr) -> __node_value_type {
    __key(__value_(p))
  }
}

// 型の名前にねじれがあるので注意
@usableFromInline
protocol ValueProtocol: TreeNodeProtocol, TreeNodeValueProtocol {
  /// キー同士を比較する。通常`<`と同じ
  @inlinable func value_comp(_: __node_value_type, _: __node_value_type) -> Bool
}

@usableFromInline
protocol BeginNodeProtocol: TreePointer {
  /// 木の左端のノードを返す
  @inlinable var __begin_node_: _NodePtr { get nonmutating set }
}

@usableFromInline
protocol BeginProtocol: BeginNodeProtocol {
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
protocol EndNodeProtocol: TreePointer {
  /// 終端ノード（木の右端の次の仮想ノード）を返す
  var __end_node: _NodePtr { get }
}

extension EndNodeProtocol where _NodePtr == Int {
  /// 終端ノード（木の右端の次の仮想ノード）を返す
  @inlinable
  @inline(__always)
  internal var __end_node: _NodePtr { .end }
}

@usableFromInline
protocol EndProtocol: EndNodeProtocol {
  /// 終端ノード（木の右端の次の仮想ノード）を返す
  @inlinable var end: _NodePtr { get }
}

extension EndProtocol where _NodePtr == Int {
  /// 終端ノード（木の右端の次の仮想ノード）を返す
  @inlinable
  @inline(__always)
  internal var end: _NodePtr { .end }
}

@usableFromInline
protocol RootProtocol: TreePointer {
  /// 木の根ノードを返す
  @inlinable var __root: _NodePtr { get }
}

protocol ___RootProtocol: TreeNodeProtocol & EndProtocol {}

extension ___RootProtocol where _NodePtr == Int {
  @available(*, deprecated, message: "Kept only for the purpose of preventing loss of knowledge")
  /// 木の根ノードを返す
  internal var __root: _NodePtr { __left_(__end_node) }
}

@usableFromInline
protocol RootPtrProtocol: TreeNodeProtocol & TreeNodeRefProtocol & RootProtocol & EndProtocol {
  /// 木の根ノードへの参照を返す
  @inlinable func __root_ptr() -> _NodeRef
}

extension RootPtrProtocol where _NodePtr == Int {
  /// 木の根ノードへの参照を返す
  @inlinable
  @inline(__always)
  internal func __root_ptr() -> _NodeRef { __left_ref(__end_node) }
}

@usableFromInline
protocol SizeProtocol {
  /// 木のノードの数を返す
  ///
  /// 終端ノードは含まないはず
  var __size_: Int { get nonmutating set }
}

// MARK: -

@usableFromInline
protocol AllocatorProtocol: TreePointer & _ValueProtocol {
  /// ノードを構築する
  func __construct_node(_ k: _Value) -> _NodePtr
  /// ノードを破棄する
  func destroy(_ p: _NodePtr)
}

// MARK: common

/// ツリー使用条件をインジェクションするためのプロトコル
public protocol ValueComparer: _TreeValue, _TreeValue {
  /// 要素から比較キー値がとれること
  @inlinable static func __key(_: _Value) -> _Key
  /// 比較関数が実装されていること
  @inlinable static func value_comp(_: _Key, _: _Key) -> Bool

  @inlinable static func value_equiv(_ lhs: _Key, _ rhs: _Key) -> Bool
}

extension ValueComparer {

  @inlinable
  @inline(__always)
  public static func value_equiv(_ lhs: _Key, _ rhs: _Key) -> Bool {
    !value_comp(lhs, rhs) && !value_comp(rhs, lhs)
  }
}

// Comparableプロトコルの場合標準実装を付与する
extension ValueComparer where _Key: Comparable {

  /// Comparableプロトコルの場合の標準実装
  @inlinable
  @inline(__always)
  public static func value_comp(_ a: _Key, _ b: _Key) -> Bool {
    a < b
  }
}

// Equatableプロトコルの場合標準実装を付与する
extension ValueComparer where _Key: Equatable {

  @inlinable
  @inline(__always)
  public static func value_equiv(_ lhs: _Key, _ rhs: _Key) -> Bool {
    lhs == rhs
  }
}

/// ツリー使用条件をインジェクションされる側の実装プロトコル
public protocol ValueComparator: _TreeValue
where
  _Key == Base._Key,
  _Value == Base._Value
{
  associatedtype Base: ValueComparer
  @inlinable static func __key(_ e: _Value) -> _Key
  @inlinable static func value_comp(_ a: _Key, _ b: _Key) -> Bool
  @inlinable static func value_equiv(_ lhs: _Key, _ rhs: _Key) -> Bool
  @inlinable func __key(_ e: _Value) -> _Key
  @inlinable func value_comp(_ a: _Key, _ b: _Key) -> Bool
}

extension ValueComparator {

  @inlinable
  @inline(__always)
  public static func __key(_ e: _Value) -> _Key {
    Base.__key(e)
  }

  @inlinable
  @inline(__always)
  public static func value_comp(_ a: _Key, _ b: _Key) -> Bool {
    Base.value_comp(a, b)
  }

  @inlinable
  @inline(__always)
  public static func value_equiv(_ lhs: _Key, _ rhs: _Key) -> Bool {
    Base.value_equiv(lhs, rhs)
  }

  @inlinable
  @inline(__always)
  public func __key(_ e: _Value) -> _Key {
    Base.__key(e)
  }

  @inlinable
  @inline(__always)
  public func value_comp(_ a: _Key, _ b: _Key) -> Bool {
    Base.value_comp(a, b)
  }
}

extension ValueComparator {

  @inlinable
  @inline(__always)
  internal static func with_value_equiv<T>(_ f: ((_Key, _Key) -> Bool) -> T) -> T {
    f(value_equiv)
  }

  @inlinable
  @inline(__always)
  internal static func with_value_comp<T>(_ f: ((_Key, _Key) -> Bool) -> T) -> T {
    f(value_comp)
  }
}

extension ValueComparator where Base: ThreeWayComparator {

  @inlinable
  @inline(__always)
  internal func
    __lazy_synth_three_way_comparator(_ __lhs: _Key, _ __rhs: _Key)
    -> Base.__compare_result
  {
    Base.__lazy_synth_three_way_comparator(__lhs, __rhs)
  }
}
