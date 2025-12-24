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

@usableFromInline
protocol ___KeyOnlySequence: ___Base where _Value == Element {}

extension ___KeyOnlySequence {
  
  @inlinable
  @inline(__always)
  public static func ___pointee(_ __value: _Value) -> Element { __value }
}

extension ___KeyOnlySequence {

  @inlinable
  @inline(__always)
  func _makeIterator() -> Tree._Values {
    .init(tree: __tree_, start: _start, end: _end)
  }

  @inlinable
  @inline(__always)
  func _reversed() -> Tree._Values.Reversed {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension ___KeyOnlySequence {

  @inlinable
  @inline(__always)
  func _forEach(_ body: (_Value) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: _start, __l: _end) {
      try body(__tree_[$0])
    }
  }
}

extension ___KeyOnlySequence {

  @inlinable
  @inline(__always)
  func _forEach(_ body: (Index, _Value) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: _start, __l: _end) {
      try body(___index($0), __tree_[$0])
    }
  }
}

extension ___KeyOnlySequence {

  @inlinable
  @inline(__always)
  public func ___forEach(_ body: (_NodePtr, _Value) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: _start, __l: _end) {
      try body($0, __tree_[$0])
    }
  }
}

extension ___KeyOnlySequence {

  /// - Complexity: O(*n*)
  @inlinable
  @inline(__always)
  func _sorted() -> [_Value] {
    __tree_.___copy_to_array(_start, _end)
  }
}
