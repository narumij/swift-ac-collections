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

@usableFromInline
protocol RefImpl: MemberProtocol {}

extension RefImpl {

  @inlinable
  func __ref_(_ rhs: _NodeRef) -> _NodePtr {
    switch rhs {
    case .nullptr:
      return .nullptr
    case .__right_(let basePtr):
      return __right_(basePtr)
    case .__left_(let basePtr):
      return __left_(basePtr)
    }
  }

  @inlinable
  func __left_ref(_ p: _NodePtr) -> _NodeRef {
    .__left_(p)
  }

  @inlinable
  func __right_ref(_ p: _NodePtr) -> _NodeRef {
    .__right_(p)
  }
}

@usableFromInline
protocol RefSetImpl: MemberSetProtocol & RefImpl {}

extension RefSetImpl {

  @inlinable
  func __ref_(_ lhs: _NodeRef, _ rhs: _NodePtr) {
    switch lhs {
    case .nullptr:
      fatalError()
    case .__right_(let basePtr):
      return __right_(basePtr, rhs)
    case .__left_(let basePtr):
      return __left_(basePtr, rhs)
    }
  }

}

@usableFromInline
protocol RootImpl: MemberProtocol & EndNodeProtocol {}

extension RootImpl {
  @inlinable
  @inline(__always)
  func __root() -> _NodePtr { __left_(__end_node()) }
}

@usableFromInline
protocol RootPtrImpl: RefProtocol & EndNodeProtocol {}

extension RootPtrImpl {
  @inlinable
  func __root_ptr() -> _NodeRef { __left_ref(__end_node()) }
}
