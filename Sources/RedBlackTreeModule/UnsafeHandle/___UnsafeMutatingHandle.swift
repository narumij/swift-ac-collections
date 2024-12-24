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

@frozen
@usableFromInline
struct ___UnsafeMutatingHandle<VC> where VC: ValueComparer {

  @inlinable @inline(__always)
  init(
    __header_ptr: UnsafeMutablePointer<___RedBlackTree.___Header>,
    __node_ptr: UnsafeMutablePointer<___RedBlackTree.___Node>,
    __value_ptr: UnsafeMutablePointer<Element>
  ) {
    self.__header_ptr = __header_ptr
    self.__node_ptr = __node_ptr
    self.__value_ptr = __value_ptr
  }
  @usableFromInline
  let __header_ptr: UnsafeMutablePointer<___RedBlackTree.___Header>
  @usableFromInline
  let __node_ptr: UnsafeMutablePointer<___RedBlackTree.___Node>
  @usableFromInline
  let __value_ptr: UnsafeMutablePointer<Element>
}

extension ___UnsafeMutatingHandle: ___UnsafeHandleBase {

  @inlinable @inline(__always)
  func __value_(_ p: _NodePtr) -> _Key {
    __value_(__value_ptr[p])
  }
}

extension ___UnsafeMutatingHandle: ___RedBlackTreeUpdateHandleImpl {}
extension ___UnsafeMutatingHandle: NodeFindProtocol & NodeFindEqualProtocol & FindLeafProtocol {}
extension ___UnsafeMutatingHandle: InsertNodeAtProtocol {}
extension ___UnsafeMutatingHandle: RemoveProtocol {}
extension ___UnsafeMutatingHandle: EraseProtocol {}
extension ___UnsafeMutatingHandle: EqualProtocol {}

extension ___UnsafeMutatingHandle {

  @inlinable
  func
  ___erase(_ ___destroy: (_NodePtr) -> Void,_ __f: _NodePtr,_ __l: _NodePtr,_ action: (Element) throws -> Void) rethrows
  {
    var __f = __f
    while __f != __l {
      try action(__value_(__f))
      __f = erase(___destroy, __f)
    }
  }

  @inlinable
  func
  ___erase<Result>(_ ___destroy: (_NodePtr) -> Void,_ __f: _NodePtr, _ __l: _NodePtr,_ initialResult: Result, _ nextPartialResult: (Result, Element) throws -> Result) rethrows -> Result
  {
    var result = initialResult
    var __f = __f
    while __f != __l {
      result = try nextPartialResult(result, __value_(__f))
      __f = erase(___destroy, __f)
    }
    return result
  }

  @inlinable
  func
  ___erase<Result>(_ ___destroy: (_NodePtr) -> Void,_ __f: _NodePtr, _ __l: _NodePtr, into initialResult: Result, _ updateAccumulatingResult: (inout Result, Element) throws -> ()) rethrows -> Result
  {
    var result = initialResult
    var __f = __f
    while __f != __l {
      try updateAccumulatingResult(&result, __value_(__f))
      __f = erase(___destroy, __f)
    }
    return result
  }
}
