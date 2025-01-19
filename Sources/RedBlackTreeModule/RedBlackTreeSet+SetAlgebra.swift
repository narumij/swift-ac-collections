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

extension RedBlackTreeSet: SetAlgebra {

  @inlinable
  public func union(_ other: __owned RedBlackTreeSet<Element>)
    -> RedBlackTreeSet<Element>
  {
    var result = self
    result.formUnion(other)
    return result
  }

  @inlinable
  public func intersection(_ other: RedBlackTreeSet<Element>)
    -> RedBlackTreeSet<Element>
  {
    var result = self
    result.formIntersection(other)
    return result
  }

  @inlinable
  public func symmetricDifference(_ other: __owned RedBlackTreeSet<Element>)
    -> RedBlackTreeSet<Element>
  {
    var result = self
    result.formSymmetricDifference(other)
    return result
  }
  
  @inlinable
  func ___set_result(_ f: inout Index, _ l: Index, _ r: inout Tree.___MutablePointer) {
    while f != l {
      r.pointee = f.___pointee
      r.___next()
      f.___next()
    }
  }
  
  @inlinable
  public mutating func formUnion(_ other: __owned RedBlackTreeSet<Element>) {
    let ___storage: Tree.Storage = .create(withCapacity: 0)
    var __result: Tree.___MutablePointer = .init(_storage: ___storage)
    var (__first1, __last1) = (___index_start(), ___index_end())
    var (__first2, __last2) = (other.___index_start(), other.___index_end())
    while __first1 != __last1 {
      if __first2 == __last2 {
        ___set_result(&__first1, __last1, &__result)
        _storage = ___storage
        return
      }
      defer { __result.___next() }
      if _tree.___comp(__first2.___pointee, __first1.___pointee) {
        __result.pointee = __first2.___pointee
        __first2.___next()
      } else {
        if !_tree.___comp(__first1.___pointee, __first2.___pointee) {
          __first2.___next()
        }
        __result.pointee = __first1.___pointee
        __first1.___next()
      }
    }
    ___set_result(&__first2, __last2, &__result)
    _storage = ___storage
  }

  @inlinable
  public mutating func formIntersection(_ other: RedBlackTreeSet<Element>) {
    // lower_boundを使う方法があるが、一旦楽に実装できそうな方からにしている
    let ___storage: Tree.Storage = .create(withCapacity: 0)
    var __result: Tree.___MutablePointer = .init(_storage: ___storage)
    var (__first1, __last1) = (___index_start(), ___index_end())
    var (__first2, __last2) = (other.___index_start(), other.___index_end())
    while __first1 != __last1, __first2 != __last2 {
      if _tree.___comp(__first1.___pointee, __first2.___pointee) {
        __first1.___next()
      } else {
        if !_tree.___comp(__first2.___pointee, __first1.___pointee) {
          __result.pointee = __first1.___pointee
          __result.___next()
          __first1.___next()
        }
        __first2.___next()
      }
    }
    _storage = ___storage
  }

  @inlinable
  public mutating func formSymmetricDifference(_ other: __owned RedBlackTreeSet<Element>) {
    let ___storage: Tree.Storage = .create(withCapacity: 0)
    var __result: Tree.___MutablePointer = .init(_storage: ___storage)
    var (__first1, __last1) = (___index_start(), ___index_end())
    var (__first2, __last2) = (other.___index_start(), other.___index_end())
    while __first1 != __last1 {
      if __first2 == __last2 {
        ___set_result(&__first1, __last1, &__result)
        _storage = ___storage
        return
      }
      if Self.___comp(__first1.___pointee, __first2.___pointee) {
        __result.pointee = __first1.___pointee
        __result.___next()
        __first1.___next()
      } else {
        if Self.___comp(__first2.___pointee, __first1.___pointee) {
          __result.pointee = __first2.___pointee
          __result.___next()
        } else {
          let i: Tree.RawPointer = Tree.RawPointer(__first1.rawValue)
          __first1.___next()
          remove(at: i)
        }
        __first2.___next()
      }
    }
    ___set_result(&__first2, __last2, &__result)
    _storage = ___storage
  }
}
