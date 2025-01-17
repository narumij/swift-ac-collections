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
public
  typealias _NodePtr = Int

public
  typealias _Pointer = _NodePtr


extension _NodePtr {

  /// 赤黒木のIndexで、nullを表す
  @inlinable
  static var nullptr: Self { -1 }

  /// 赤黒木のIndexで、終端を表す
  @inlinable
  static var end: Self { -2 }

  /// 数値を直接扱うことを避けるための初期化メソッド
  @inlinable
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
  func __left_(_: pointer) -> pointer
  func __left_(_ lhs: pointer, _ rhs: pointer)
}

extension TreeEndNodeProtocol {
  @usableFromInline
  typealias pointer = _Pointer
}

// 一般ノード相当の機能
@usableFromInline
protocol TreeNodeBaseProtocol: TreeEndNodeProtocol {
  func __right_(_: pointer) -> pointer
  func __right_(_ lhs: pointer, _ rhs: pointer)
  func __is_black_(_: pointer) -> Bool
  func __is_black_(_ lhs: pointer, _ rhs: Bool)
  func __parent_(_: pointer) -> pointer
  func __parent_(_ lhs: pointer, _ rhs: pointer)
  func __parent_unsafe(_: pointer) -> __parent_pointer
}

extension TreeNodeBaseProtocol {
  @usableFromInline
  typealias __parent_pointer = _Pointer
}

// 以下は、現在の設計に至る過程で、readハンドルとupdateハンドルに分けていた名残で、
// getとsetが分かれている

@usableFromInline
protocol MemberProtocol {
  func __left_(_: _NodePtr) -> _NodePtr
  func __right_(_: _NodePtr) -> _NodePtr
  func __is_black_(_: _NodePtr) -> Bool
  func __parent_(_: _NodePtr) -> _NodePtr
  func __parent_unsafe(_: _NodePtr) -> _NodePtr
}

@usableFromInline
protocol MemberSetProtocol: MemberProtocol {
  func __left_(_ lhs: _NodePtr, _ rhs: _NodePtr)
  func __right_(_ lhs: _NodePtr, _ rhs: _NodePtr)
  func __is_black_(_ lhs: _NodePtr, _ rhs: Bool)
  func __parent_(_ lhs: _NodePtr, _ rhs: _NodePtr)
}

@usableFromInline
protocol RefProtocol: MemberProtocol {
  func __left_ref(_: _NodePtr) -> _NodeRef
  func __right_ref(_: _NodePtr) -> _NodeRef
  func __ptr_(_ rhs: _NodeRef) -> _NodePtr
}

@usableFromInline
protocol RefSetProtocol: RefProtocol {
  func __ptr_(_ lhs: _NodeRef, _ rhs: _NodePtr)
}

@usableFromInline
protocol KeyProtocol {
  associatedtype _Key
  associatedtype Element
  func __key(_ e: Element) -> _Key
}

@usableFromInline
protocol ValueProtocol: MemberProtocol {

  associatedtype _Key
  func __value_(_: _NodePtr) -> _Key
  func value_comp(_: _Key, _: _Key) -> Bool
}

extension ValueProtocol {
  @inlinable
  @inline(__always)
  func ___value_equal(_ a: _Key, _ b: _Key) -> Bool {
    !value_comp(a, b) && !value_comp(b, a)
  }
  
  @inlinable @inline(__always)
  func ___comp(_ a: _Key, _ b: _Key) -> Bool {
    value_comp(a, b)
  }
}

@usableFromInline
protocol BeginNodeProtocol {
  var __begin_node: _NodePtr { get nonmutating set }
}

@usableFromInline
protocol BeginProtocol: BeginNodeProtocol {
  func begin() -> _NodePtr
}

extension BeginProtocol {
  @inlinable
  @inline(__always)
  func begin() -> _NodePtr { __begin_node }
}

@usableFromInline
protocol EndNodeProtocol {
  func __end_node() -> _NodePtr
}

extension EndNodeProtocol {
  @inlinable
  @inline(__always)
  func __end_node() -> _NodePtr { .end }
}

@usableFromInline
protocol EndProtocol: EndNodeProtocol {
  func end() -> _NodePtr
}

extension EndProtocol {
  @inlinable
  @inline(__always)
  func end() -> _NodePtr { __end_node() }
}

@usableFromInline
protocol RootProtocol: MemberProtocol & EndProtocol {
  func __root() -> _NodePtr
}

extension RootProtocol {
  @inlinable
  @inline(__always)
  func __root() -> _NodePtr { __left_(__end_node()) }
}

@usableFromInline
protocol RootPtrProrototol: RootProtocol {
  func __root_ptr() -> _NodeRef
}

extension RootPtrProrototol {
  @inlinable
  @inline(__always)
  func __root_ptr() -> _NodeRef { __left_ref(__end_node()) }
}

@usableFromInline
protocol SizeProtocol {
  var size: Int { get nonmutating set }
}

// MARK: -

@usableFromInline
protocol AllocatorProtocol {
  associatedtype Element
  func __construct_node(_ k: Element) -> _NodePtr
  func destroy(_ p: _NodePtr)
  func ___element(_ p: _NodePtr) -> Element
}

// MARK: common

public protocol ValueComparer {
  associatedtype _Key
  associatedtype Element
  static func __key(_: Element) -> _Key
  static func value_comp(_: _Key, _: _Key) -> Bool
}

extension ValueComparer where _Key: Comparable {

  @inlinable @inline(__always)
  public static func value_comp(_ a: _Key, _ b: _Key) -> Bool {
    a < b
  }
}

extension ValueComparer {
  
  @inlinable @inline(__always)
  static func ___value_equal(_ a: _Key, _ b: _Key) -> Bool {
    !value_comp(a, b) && !value_comp(b, a)
  }

  @inlinable @inline(__always)
  static func ___comp(_ a: _Key, _ b: _Key) -> Bool {
    value_comp(a,b)
  }
}

// MARK: key

public protocol ScalarValueComparer: ValueComparer where _Key == Element {}

extension ScalarValueComparer {

  @inlinable @inline(__always)
  public static func __key(_ e: Element) -> _Key { e }
}

// MARK: key value

public protocol KeyValueComparer: ValueComparer {
  associatedtype _Value
  static func __key(_ element: Element) -> _Key
}

extension KeyValueComparer {
  public typealias _KeyValueTuple = (key: _Key, value: _Value)
}

extension KeyValueComparer where Element == _KeyValueTuple {
  
  @inlinable @inline(__always)
  public static func __key(_ element: Element) -> _Key { element.key }

  @inlinable @inline(__always)
  static func __value(_ element: Element) -> _Value { element.value }
}

// MARK: key value

public
  protocol _KeyCustomProtocol
{
  associatedtype Parameters
  static func value_comp(_ a: Parameters, _ b: Parameters) -> Bool
}

protocol CustomKeyValueComparer: KeyValueComparer where _Key == Custom.Parameters {
  associatedtype Custom: _KeyCustomProtocol
}

extension CustomKeyValueComparer {
  
  @inlinable @inline(__always)
  public static func value_comp(_ a: _Key, _ b: _Key) -> Bool {
    Custom.value_comp(a, b)
  }
}
