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

#if false
extension TreeNodeProtocol {

  @inlinable
  @inline(__always)
  func __ptr_(_ rhs: _NodeRef) -> _NodePtr {
    switch rhs {
    case .__right_(let basePtr):
      return __right_(basePtr)
    case .__left_(let basePtr):
      return __left_(basePtr)
    }
  }

  @inlinable
  @inline(__always)
  func __left_ref(_ p: _NodePtr) -> _NodeRef {
    assert(p != .nullptr)
    return .__left_(p)
  }

  @inlinable
  @inline(__always)
  func __right_ref(_ p: _NodePtr) -> _NodeRef {
    assert(p != .nullptr)
    return .__right_(p)
  }
}

extension TreeNodeProtocol {

  @inlinable
  @inline(__always)
  func __ptr_(_ lhs: _NodeRef, _ rhs: _NodePtr) {
    switch lhs {
    case .__right_(let basePtr):
      return __right_(basePtr, rhs)
    case .__left_(let basePtr):
      return __left_(basePtr, rhs)
    }
  }
}
#else
extension TreeNodeProtocol {

  @inlinable
  @inline(__always)
  func __ptr_(_ rhs: _NodeRef) -> _NodePtr {
    let l = _NodePtr(bitPattern: rhs)
    switch l {
    case .end:
      return __left_(.end)
    case 0...:
      return __left_(l)
    default:
      return __right_(l & ~(1 << (_NodeRef.bitWidth - 1)))
    }
  }

  @inlinable
  @inline(__always)
  func __left_ref(_ p: _NodePtr) -> _NodeRef {
    assert(p != .nullptr)
    return .init(bitPattern: p)
  }

  @inlinable
  @inline(__always)
  func __right_ref(_ p: _NodePtr) -> _NodeRef {
    assert(p != .nullptr)
    return .init(bitPattern: p) | (1 << (_NodeRef.bitWidth - 1))
  }
}

extension TreeNodeProtocol {

  @inlinable
  @inline(__always)
  func __ptr_(_ lhs: _NodeRef, _ rhs: _NodePtr) {
    let l = _NodePtr(bitPattern: lhs)
    switch l {
    case .end:
      return __left_(.end, rhs)
    case 0...:
      return __left_(l, rhs)
    default:
      return __right_(l & ~(1 << (_NodeRef.bitWidth - 1)), rhs)
    }
  }
}
#endif
