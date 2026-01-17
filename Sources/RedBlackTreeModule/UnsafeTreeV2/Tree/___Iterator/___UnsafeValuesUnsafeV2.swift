// Copyright 2024-2026 narumij
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
// Copyright © 2003-2025 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

// TODO: 利用時の寿命管理の確認
// 寿命延長を行わないので、利用側で寿命安全を守る必要がある

@usableFromInline
struct ___UnsafeValueWrapper<Base: ___TreeBase, Source: IteratorProtocol>:
  UnsafeTreePointer,
  IteratorProtocol,
  Sequence
where
  Source.Element == UnsafeMutablePointer<UnsafeNode>
{
  var iterator: Source

  internal init(iterator: Source) {
    self.iterator = iterator
  }

  @usableFromInline
  mutating func next() -> Base._Value? {
    return iterator.next().map {
      $0.__value_().pointee
    }
  }
}

@usableFromInline
struct ___UnsafeKeyWrapper<Base: ___TreeBase, Source: IteratorProtocol>:
  UnsafeTreePointer,
  IteratorProtocol,
  Sequence
where
  Source.Element == UnsafeMutablePointer<UnsafeNode>
{
  var iterator: Source

  internal init(iterator: Source) {
    self.iterator = iterator
  }

  @usableFromInline
  mutating func next() -> Base._Key? {
    return iterator.next().map {
      Base.__key($0.__value_().pointee)
    }
  }
}

@usableFromInline
struct ___UnsafeMappedValueWrapper<Base: ___TreeBase & KeyValueComparer, Source: IteratorProtocol>:
  UnsafeTreePointer,
  IteratorProtocol,
  Sequence
where
  Source.Element == UnsafeMutablePointer<UnsafeNode>
{
  var iterator: Source

  internal init(iterator: Source) {
    self.iterator = iterator
  }

  @usableFromInline
  mutating func next() -> Base._MappedValue? {
    return iterator.next().map {
      Base.___mapped_value($0.__value_().pointee)
    }
  }
}

@frozen
@usableFromInline
package struct ___UnsafeValuesUnsafeV2<Base>: Sequence, IteratorProtocol, UnsafeTreeProtocol
where Base: ___TreeBase {

  @usableFromInline
  var source: ___UnsafeNaiveIterator

  @inlinable
  @inline(__always)
  internal init(source: ___UnsafeNaiveIterator) {
    self.source = source
  }

  @inlinable
  @inline(__always)
  internal init(tree: Tree, __first: _NodePtr, __last: _NodePtr) {
    self.init(
      source: .init(
        __first: __first,
        __last: __last))
  }

  @inlinable
  @inline(__always)
  internal init(__tree_: ImmutableTree, __first: _NodePtr, __last: _NodePtr) {
    self.init(
      source: .init(
        __first: __first,
        __last: __last))
  }

  @inlinable
  @inline(__always)
  package mutating func next() -> Tree._Value? {
    return source.next().map { $0.__value_().pointee }
  }
}
