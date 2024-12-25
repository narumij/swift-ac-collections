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

import Collections

@usableFromInline
protocol ___RedBlackTreeContainer: ___RedBlackTreeContainerBase, ___RedBlackTreeDefaultAllocator { }

extension ___RedBlackTreeContainer {

  @inlinable static func ___initialize<S>(
    _sequence: __owned S,
    _to_elements: (S) -> [Element],
    _insert: (
      ___UnsafeMutatingHandle<Self>,
      Element,
      UnsafeMutableBufferPointer<Element>,
      (Element) -> _NodePtr
    ) throws -> Void
  ) rethrows -> (
    _header: ___RedBlackTree.___Header,
    _nodes: [___RedBlackTree.___Node],
    _values: [Element],
    _stock: Heap<_NodePtr>
  )
  where S: Sequence {
    // valuesは一旦全部の分を確保する
    var _values: [Element] = _to_elements(_sequence)
    var _header: ___RedBlackTree.___Header = .zero
    let _nodes = try [___RedBlackTree.___Node](
      unsafeUninitializedCapacity: _values.count
    ) { _nodes, initializedCount in
      try withUnsafeMutablePointer(to: &_header) { _header in
        var count = 0
        try _values.withUnsafeMutableBufferPointer { _values in
          func ___construct_node(_ __k: Element) -> _NodePtr {
            _nodes[count] = .zero
            // 前方から詰め直している
            _values[count] = __k
            defer { count += 1 }
            return count
          }
          let tree = ___UnsafeMutatingHandle<Self>(
            __header_ptr: _header,
            __node_ptr: _nodes.baseAddress!,
            __element_ptr: _values.baseAddress!)
          var i = 0
          while i < _values.count {
            let __k = _values[i]
            i += 1
            try _insert(tree, __k, _values, ___construct_node)
          }
          initializedCount = count
        }
        // 詰め終わった残りの部分を削除する
        _values.removeLast(_values.count - count)
      }
    }
    return (_header, _nodes, _values, [])
  }
  
  public mutating func ___removeAll(keepingCapacity keepCapacity: Bool = false) {
    ___header = .zero
    ___nodes.removeAll(keepingCapacity: keepCapacity)
    ___elements.removeAll(keepingCapacity: keepCapacity)
    ___recycle = []
  }
}
