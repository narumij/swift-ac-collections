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
// Copyright © [年] The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

import Foundation

public
  typealias _NodePtr = Int

extension _NodePtr {
  @inlinable
  static var nullptr: Self { -2 }
  @inlinable
  static var end: Self { -1 }
  @inlinable
  static func node(_ p: Int) -> Self { p }
}

public
  enum _NodeRef: Equatable
{
  case nullptr
  case __right_(_NodePtr)
  case __left_(_NodePtr)
}

@usableFromInline
protocol MemberProtocol {
  func __parent_(_: _NodePtr) -> _NodePtr
  func __left_(_: _NodePtr) -> _NodePtr
  func __right_(_: _NodePtr) -> _NodePtr
  func __is_black_(_: _NodePtr) -> Bool
  func __parent_unsafe(_: _NodePtr) -> _NodePtr
}

@usableFromInline
protocol MemberSetProtocol: MemberProtocol {
  func __is_black_(_ lhs: _NodePtr, _ rhs: Bool)
  func __parent_(_ lhs: _NodePtr, _ rhs: _NodePtr)
  func __left_(_ lhs: _NodePtr, _ rhs: _NodePtr)
  func __right_(_ lhs: _NodePtr, _ rhs: _NodePtr)
}

@usableFromInline
protocol RefProtocol: MemberProtocol {
  func __left_ref(_: _NodePtr) -> _NodeRef
  func __right_ref(_: _NodePtr) -> _NodeRef
  func __ref_(_ rhs: _NodeRef) -> _NodePtr
}

@usableFromInline
protocol RefSetProtocol: RefProtocol {
  func __ref_(_ lhs: _NodeRef, _ rhs: _NodePtr)
}

@usableFromInline
protocol ValueProtocol: MemberProtocol {

  associatedtype _Key
  func __value_(_: _NodePtr) -> _Key
  func value_comp(_: _Key, _: _Key) -> Bool
}

@usableFromInline
protocol BeginNodeProtocol {
  var __begin_node: _NodePtr { get nonmutating set }
}

@usableFromInline
protocol RootProtocol {
  func __root() -> _NodePtr
}

@usableFromInline
protocol RootPtrProrototol {
  func __root_ptr() -> _NodeRef
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
protocol EndProtocol {
  func end() -> _NodePtr
}

extension EndProtocol {
  @inlinable
  @inline(__always)
  func end() -> _NodePtr { .end }
}

@usableFromInline
protocol SizeProtocol {
  var size: Int { get nonmutating set }
}

@usableFromInline
protocol EqualProtocol: ValueProtocol, RootProtocol, EndNodeProtocol { }
