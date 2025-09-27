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

/// 赤黒木の内部Index
///
/// ヒープの代わりに配列を使っているため、実際には内部配列のインデックスを使用している
///
/// インデックスが0からはじまるため、一般的にnullは0で表現するところを、-1で表現している
///
/// endはルートノードを保持するオブジェクトを指すかわりに、-2で表現している
///
/// `__tree`ではポインタとイテレータが使われているが、イテレータはこのインデックスで代替している
public typealias _NodePtr = Int

public typealias _Pointer = _NodePtr

extension _NodePtr {

  /// 赤黒木のIndexで、nullを表す
  @inlinable
  @inline(__always)
  static var nullptr: Self { -1 }

  /// 赤黒木のIndexで、終端を表す
  @inlinable
  @inline(__always)
  static var end: Self { -2 }

  /// 数値を直接扱うことを避けるための初期化メソッド
  @inlinable
  @inline(__always)
  static func node(_ p: Int) -> Self { p }
}

@inlinable
@inline(__always)
func ___is_null_or_end(_ ptr: _NodePtr) -> Bool {
  ptr < 0
}

/// 赤黒木の参照型を表す内部enum
public
  enum _NodeRef: Equatable
{
  case nullptr
  /// 右ノードへの参照
  case __right_(_NodePtr)
  /// 左ノードへの参照
  case __left_(_NodePtr)
}

// ルートノード相当の機能
@usableFromInline
protocol TreeEndNodeProtocol {
  /// 木を遡るケースではこちらが必ず必要
  func __left_(_: pointer) -> pointer
  /// 根から末端に向かう処理は、こちらで足りる
  func __left_unsafe(_ p: pointer) -> pointer
  func __left_(_ lhs: pointer, _ rhs: pointer)
}

extension TreeEndNodeProtocol {
  @usableFromInline
  typealias pointer = _Pointer
}

// 一般ノード相当の機能
@usableFromInline
protocol TreeNodeProtocol: TreeEndNodeProtocol {
  func __right_(_: pointer) -> pointer
  func __right_(_ lhs: pointer, _ rhs: pointer)
  func __is_black_(_: pointer) -> Bool
  func __is_black_(_ lhs: pointer, _ rhs: Bool)
  func __parent_(_: pointer) -> pointer
  func __parent_(_ lhs: pointer, _ rhs: pointer)
  /// This is only to align the naming with C++.
  /// C++と名前を揃えているだけのもの
  func __parent_unsafe(_: pointer) -> __parent_pointer
}

extension TreeNodeProtocol {
  @usableFromInline
  typealias __parent_pointer = _Pointer
}

@usableFromInline
protocol TreeNodeRefProtocol {
  func __left_ref(_: _NodePtr) -> _NodeRef
  func __right_ref(_: _NodePtr) -> _NodeRef
  func __ptr_(_ rhs: _NodeRef) -> _NodePtr
  func __ptr_(_ lhs: _NodeRef, _ rhs: _NodePtr)
}

// 名前のねじれは移植元に由来する
@usableFromInline
protocol TreeValueProtocol {
  associatedtype _Key
  /// ノードから比較用のキー値を取り出す。
  /// SetやMultisetではElementに該当する
  /// DictionaryやMultiMapではKeyに該当する
  func __value_(_: _NodePtr) -> _Key
}

// 名前のねじれは移植元に由来する
@usableFromInline
protocol KeyProtocol {
  associatedtype _Key
  associatedtype Element
  /// 要素から比較用のキー値を取り出す。
  func __key(_ e: Element) -> _Key
}

// 名前のねじれは移植元に由来する
@usableFromInline
protocol ValueProtocol: TreeNodeProtocol, TreeValueProtocol {

  /// キー同士を比較する。通常`<`と同じ
  func value_comp(_: _Key, _: _Key) -> Bool
}

extension ValueProtocol {

  /// キー同士を比較する。通常`<`と同じ
  @inlinable
  @inline(__always)
  func ___comp(_ a: _Key, _ b: _Key) -> Bool {
    value_comp(a, b)
  }
}

@usableFromInline
protocol BeginNodeProtocol {
  /// 木の左端のノードを返す
  var __begin_node: _NodePtr { get nonmutating set }
}

@usableFromInline
protocol BeginProtocol: BeginNodeProtocol {
  // __begin_nodeが圧倒的に速いため
  @available(*, deprecated, renamed: "__begin_node")
  /// 木の左端のノードを返す
  func begin() -> _NodePtr
}

extension BeginProtocol {
  // __begin_nodeが圧倒的に速いため
  @available(*, deprecated, renamed: "__begin_node")
  @inlinable
  @inline(__always)
  /// 木の左端のノードを返す
  func begin() -> _NodePtr { __begin_node }
}

@usableFromInline
protocol EndNodeProtocol {
  /// 終端ノード（木の右端の次の仮想ノード）を返す
  func __end_node() -> _NodePtr
}

extension EndNodeProtocol {
  /// 終端ノード（木の右端の次の仮想ノード）を返す
  @inlinable
  @inline(__always)
  func __end_node() -> _NodePtr { .end }
}

@usableFromInline
protocol EndProtocol: EndNodeProtocol {
  /// 終端ノード（木の右端の次の仮想ノード）を返す
  func end() -> _NodePtr
}

extension EndProtocol {
  /// 終端ノード（木の右端の次の仮想ノード）を返す
  @inlinable
  @inline(__always)
  func end() -> _NodePtr { .end }
}

@usableFromInline
protocol RootProtocol {
  /// 木の根ノードを返す
  func __root() -> _NodePtr
}

protocol ___RootProtocol: TreeNodeProtocol & EndProtocol {}

extension ___RootProtocol {
  @available(*, deprecated, message: "Kept only for the purpose of preventing loss of knowledge")
  /// 木の根ノードを返す
  func __root() -> _NodePtr { __left_(__end_node()) }
}

@usableFromInline
protocol RootPtrProtocol: TreeNodeProtocol & RootProtocol & EndProtocol {
  /// 木の根ノードへの参照を返す
  func __root_ptr() -> _NodeRef
}

extension RootPtrProtocol {
  /// 木の根ノードへの参照を返す
  @inlinable
  @inline(__always)
  func __root_ptr() -> _NodeRef { __left_ref(__end_node()) }
}

@usableFromInline
protocol SizeProtocol {
  /// 木のノードの数を返す
  ///
  /// 終端ノードは含まないはず
  var size: Int { get nonmutating set }
}

// MARK: -

@usableFromInline
protocol AllocatorProtocol {
  associatedtype Element
  /// ノードを構築する
  func __construct_node(_ k: Element) -> _NodePtr
  /// ノードを破棄する
  func destroy(_ p: _NodePtr)
  /// ノードの値要素を取得する
  // TODO: マージプロトコルの作業時にさぼってここに配置しているので、直す
  func ___element(_ p: _NodePtr) -> Element
}

// MARK: common

/// ツリー使用条件をインジェクションするためのプロトコル
public protocol ValueComparer {
  /// ツリーが比較に使用する値の型
  associatedtype _Key
  /// 要素の型
  associatedtype Element
  /// 要素から比較キー値がとれること
  static func __key(_: Element) -> _Key
  /// 比較関数が実装されていること
  static func value_comp(_: _Key, _: _Key) -> Bool
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

extension ValueComparer {

  /// 比較のインスタンス関数の標準実装
  @inlinable
  @inline(__always)
  static func ___comp(_ a: _Key, _ b: _Key) -> Bool {
    value_comp(a, b)
  }
}

// MARK: key

/// 要素とキーが一致する場合のひな形
public protocol ScalarValueComparer: ValueComparer where _Key == Element {}

extension ScalarValueComparer {

  @inlinable
  @inline(__always)
  public static func __key(_ e: Element) -> _Key { e }
}

// MARK: key value

/// 要素がキーバリューの場合のひな形
public protocol KeyValueComparer: ValueComparer {
  associatedtype _Value
  static func __key(_ element: Element) -> _Key
}

// TODO: 最近タプルの最適化が甘いので、構造体に変更する
public typealias _KeyValueTuple_<_Key, _Value> = (key: _Key, value: _Value)

extension KeyValueComparer {
  public typealias _KeyValueTuple = _KeyValueTuple_<_Key, _Value>
}

extension KeyValueComparer where Element == _KeyValueTuple {

  @inlinable
  @inline(__always)
  public static func __key(_ element: Element) -> _Key { element.key }
}

// MARK: key value

/// 要素がカスタムでキーの取得が特殊な場合のひな形
public
  protocol _KeyCustomProtocol
{
  associatedtype Parameters
  static func value_comp(_ a: Parameters, _ b: Parameters) -> Bool
}

@usableFromInline
protocol CustomKeyValueComparer: KeyValueComparer where _Key == Custom.Parameters {
  associatedtype Custom: _KeyCustomProtocol
}

extension CustomKeyValueComparer {

  @inlinable
  @inline(__always)
  public static func value_comp(_ a: _Key, _ b: _Key) -> Bool {
    Custom.value_comp(a, b)
  }
}
