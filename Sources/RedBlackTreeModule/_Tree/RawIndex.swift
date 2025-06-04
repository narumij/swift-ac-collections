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

/// 赤黒木のノードへの軽量なポインタ
///
/// 各データ構造では軽量インデックスとして用いられる
///
/// nullptrはオプショナルで表現する想定で、nullptrを保持しない
///
/// 本当の生ポインタはIntのtypealiasだが、それを晒すと間違いのもとなので、ラップしてある
@frozen
public
  enum RawIndex: Equatable
{
  case node(_NodePtr)
  case end

  @usableFromInline
  init(_ node: _NodePtr) {
    guard node != .nullptr else {
      preconditionFailure("_NodePtr is nullptr")
    }
    self = node == .end ? .end : .node(node)
  }

  @usableFromInline
  var rawValue: _NodePtr {
    switch self {
    case .node(let _NodePtr):
      return _NodePtr
    case .end:
      return .end
    }
  }
}

extension Optional where Wrapped == RawIndex {

  @inlinable
  init(_ ptr: _NodePtr) {
    self = ptr == .nullptr ? .none : .some(RawIndex(ptr))
  }

  @usableFromInline
  var _pointer: _NodePtr {
    switch self {
    case .none:
      return .nullptr
    case .some(let ptr):
      return ptr.rawValue
    }
  }
}

#if swift(>=5.5)
  extension RawIndex: @unchecked Sendable {}
#endif

#if DEBUG
  extension RawIndex {
    static func unsafe(_ node: _NodePtr) -> Self {
      node == .end ? .end : .node(node)
    }
  }
#endif

