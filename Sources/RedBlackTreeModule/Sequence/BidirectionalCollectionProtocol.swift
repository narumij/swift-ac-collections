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
protocol NodeValidationProtocol {

  func ___is_valid(_ p: _NodePtr) -> Bool
  func ___is_valid_index(_ i: _NodePtr) -> Bool
}

@usableFromInline
protocol CollectionProtocol {
  // この実装がないと、迷子になる?
  func ___distance(from start: _NodePtr, to end: _NodePtr) -> Int
  
  func ___index(after i: _NodePtr) -> _NodePtr
}

@usableFromInline
protocol BidirectionalCollectionProtocol: CollectionProtocol {
  // この実装がないと、迷子になる?
  func ___distance(from start: _NodePtr, to end: _NodePtr) -> Int
  
  func ___index(after i: _NodePtr) -> _NodePtr
  func ___index(before i: _NodePtr) -> _NodePtr
  
  func ___formIndex(after i: inout _NodePtr)
  func ___formIndex(before i: inout _NodePtr)

  func ___index(_ i: _NodePtr, offsetBy distance: Int) -> _NodePtr
  func ___index(_ i: _NodePtr, offsetBy distance: Int, limitedBy limit: _NodePtr) -> _NodePtr?

  func ___formIndex(_ i: inout _NodePtr, offsetBy distance: Int)
  func ___formIndex(_ i: inout _NodePtr, offsetBy distance: Int, limitedBy limit: _NodePtr) -> Bool
}
