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
protocol ___RedBlackTreeSubSequenceBase {
  associatedtype Base: ValueComparer
  var _subSequence: Base.Tree.SubSequence { get }
}

extension ___RedBlackTreeSubSequenceBase {
  @inlinable
  @inline(__always)
  internal var _tree: ___Tree { _subSequence._tree }
}

extension ___RedBlackTreeSubSequenceBase {
  
  @usableFromInline
  typealias ___Tree = Base.Tree
  @usableFromInline
  typealias ___Index = Base.Tree.Pointer
  @usableFromInline
  typealias ___SubSequence = Base.Tree.SubSequence
  @usableFromInline
  typealias ___Element = Base.Tree.SubSequence.Element
  
  @inlinable @inline(__always)
  internal var ___start_index: ___Index {
    ___Index(__tree: _tree, rawValue: _subSequence.startIndex)
  }

  @inlinable @inline(__always)
  internal var ___end_index: ___Index {
    ___Index(__tree: _tree, rawValue: _subSequence.endIndex)
  }

  @inlinable @inline(__always)
  internal var ___count: Int {
    _subSequence.count
  }

  @inlinable @inline(__always)
  internal func ___for_each(_ body: (___Element) throws -> Void) rethrows {
    try _subSequence.forEach(body)
  }

  @inlinable @inline(__always)
  internal func ___distance(from start: ___Index, to end: ___Index) -> Int {
    _subSequence.distance(from: start.rawValue, to: end.rawValue)
  }

  @inlinable @inline(__always)
  internal func ___index(after i: ___Index) -> ___Index {
    ___Index(__tree: _tree, rawValue: _subSequence.index(after: i.rawValue))
  }

  @inlinable @inline(__always)
  internal func ___form_index(after i: inout ___Index) {
    _subSequence.formIndex(after: &i.rawValue)
  }

  @inlinable @inline(__always)
  internal func ___index(before i: ___Index) -> ___Index {
    ___Index(__tree: _tree, rawValue: _subSequence.index(before: i.rawValue))
  }

  @inlinable @inline(__always)
  internal func ___form_index(before i: inout ___Index) {
    _subSequence.formIndex(before: &i.rawValue)
  }

  @inlinable @inline(__always)
  internal func ___index(_ i: ___Index, offsetBy distance: Int) -> ___Index {
    ___Index(__tree: _tree, rawValue: _subSequence.index(i.rawValue, offsetBy: distance))
  }

  @inlinable @inline(__always)
  internal func ___form_index(_ i: inout ___Index, offsetBy distance: Int) {
    _subSequence.formIndex(&i.rawValue, offsetBy: distance)
  }

  @inlinable @inline(__always)
  internal func ___index(_ i: ___Index, offsetBy distance: Int, limitedBy limit: ___Index) -> ___Index? {

    if let i = _subSequence.index(i.rawValue, offsetBy: distance, limitedBy: limit.rawValue) {
      return ___Index(__tree: _tree, rawValue: i)
    } else {
      return nil
    }
  }

  @inlinable @inline(__always)
  internal func ___form_index(_ i: inout ___Index, offsetBy distance: Int, limitedBy limit: ___Index)
    -> Bool
  {
    return _subSequence.formIndex(&i.rawValue, offsetBy: distance, limitedBy: limit.rawValue)
  }
}
