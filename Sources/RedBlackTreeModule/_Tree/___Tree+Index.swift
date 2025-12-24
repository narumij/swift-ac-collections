// Copyright 2024-2025 narumij
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

public protocol ___TreeIndex {
  associatedtype _Value
  associatedtype Pointee
  static func ___pointee(_ __value: _Value) -> Pointee
}

extension ___Tree where Base: ___TreeIndex {

  public typealias Index = RedBlackTreeIndex<Base>
  public typealias Pointee = Base.Pointee

  @nonobjc
  @inlinable
  @inline(__always)
  func makeIndex(rawValue: _NodePtr) -> Index {
    .init(tree: self, rawValue: rawValue)
  }
}

extension ___Tree where Base: ___TreeIndex {

  public typealias Indices = RedBlackTreeIndices<Base>

  @nonobjc
  @inlinable
  @inline(__always)
  func makeIndices(start: _NodePtr, end: _NodePtr) -> Indices {
    .init(tree: self, start: start, end: end)
  }
}

extension ___Tree where Base: ___TreeIndex {

  public typealias _Values = RedBlackTreeIterator<Base>.Values
}

extension ___Tree where Base: KeyValueComparer & ___TreeIndex {

  public typealias _KeyValues = RedBlackTreeIterator<Base>.KeyValues
}
