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

@usableFromInline
protocol ___RedBlackTreeEqualRangeUnique: ValueComparer {
  var _tree: Tree { get }
}

@usableFromInline
protocol ___RedBlackTreeEqualRangeMulti: ValueComparer {
  var _tree: Tree { get }
}

extension ___RedBlackTreeEqualRangeUnique {
  
  ///（重複なし）
  @inlinable
  @inline(__always)
  internal func ___equal_range(_ k: _Key) -> (lower: Tree.___Iterator, upper: Tree.___Iterator) {
    let (lo,hi) = _tree.__equal_range_unique(k)
//    return (.init(__tree: _tree, rawValue: lo), .init(__tree: _tree, rawValue: hi))
    return (_tree.makeIndex(rawValue: lo), _tree.makeIndex(rawValue: hi))
  }
}

extension ___RedBlackTreeEqualRangeMulti {

  /// （重複あり）
  @inlinable
  @inline(__always)
  internal func ___equal_range(_ k: _Key) -> (lower: Tree.___Iterator, upper: Tree.___Iterator) {
    let (lo,hi) = _tree.__equal_range_multi(k)
//    return (.init(__tree: _tree, rawValue: lo), .init(__tree: _tree, rawValue: hi))
    return (_tree.makeIndex(rawValue: lo), _tree.makeIndex(rawValue: hi))
  }
}

