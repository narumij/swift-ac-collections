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

extension ___RedBlackTreeContainerBase {

  @inlinable
  func ___equal_with(_ rhs: Self) -> Bool where Element: Equatable {
    ___count == rhs.___count && zip(___element_sequence__, rhs.___element_sequence__).allSatisfy(==)
  }

  @inlinable
  func ___equal_with<K, V>(_ rhs: Self) -> Bool
  where K: Equatable, V: Equatable, Element == (key: K, value: V) {
    ___count == rhs.___count && zip(___element_sequence__, rhs.___element_sequence__).allSatisfy(==)
  }
}