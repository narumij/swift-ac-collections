// Copyright 2025 narumij
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

@usableFromInline
protocol MemoizeCacheMiscellaneous {
  var _hits: Int { get set }
  var _miss: Int { get set }
  var count: Int { get }
  mutating func ___removeAll(keepingCapacity keepCapacity: Bool)
}

extension MemoizeCacheMiscellaneous {
  
  @inlinable
  var ___info: (hits: Int, miss: Int, maxCount: Int?, currentCount: Int) {
    (_hits, _miss, nil, count)
  }

  @inlinable
  mutating func ___clear(keepingCapacity keepCapacity: Bool) {
    (_hits, _miss) = (0, 0)
    ___removeAll(keepingCapacity: keepCapacity)
  }
}

@usableFromInline
protocol _MemoizeCacheLRUMiscellaneous: ___RedBlackTreeBase {
  var _hits: Int { get set }
  var _miss: Int { get set }
  var maxCount: Int { get }
  var count: Int { get }
}

extension _MemoizeCacheLRUMiscellaneous {
  
  @inlinable
  var ___info: (hits: Int, miss: Int, maxCount: Int?, currentCount: Int) {
    (_hits, _miss, maxCount != Int.max ? maxCount : nil, count)
  }

  @inlinable
  mutating func ___clear(keepingCapacity keepCapacity: Bool) {
    (_hits, _miss) = (0, 0)
    ___removeAll(keepingCapacity: keepCapacity)
  }
}
