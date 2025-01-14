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

public protocol _MemoizationCacheProtocol {
  associatedtype Parameters
  associatedtype Return
}

public protocol _HashableMemoizationCacheProtocol: _MemoizationCacheProtocol
where Parameters: Hashable {}

extension _HashableMemoizationCacheProtocol {
  public typealias Standard = _MemoizeCacheStandard<Parameters, Return>
}

public
  struct _MemoizeCacheStandard<Parameters: Hashable, Return>
{

  @inlinable @inline(__always)
  public init() {}

  @inlinable
  public subscript(key: Parameters) -> Return? {
    @inline(__always)
    mutating get {
      if let r = _cache[key] {
        _hits += 1
        return r
      }
      _miss += 1
      return nil
    }
    @inline(__always)
    set {
      _cache[key] = newValue
    }
  }

  @usableFromInline
  var _cache: [Parameters: Return] = [:]

  @usableFromInline
  var _hits: Int = 0

  @usableFromInline
  var _miss: Int = 0

  @inlinable
  public var info: (hits: Int, miss: Int, maxCount: Int?, currentCount: Int) {
    ___info
  }

  @inlinable
  public mutating func clear(keepingCapacity keepCapacity: Bool = false) {
    ___clear(keepingCapacity: keepCapacity)
  }
}

extension _MemoizeCacheStandard: MemoizeCacheMiscellaneous {
  
  @usableFromInline
  var count: Int { _cache.count }
  
  @usableFromInline
  mutating func ___removeAll(keepingCapacity keepCapacity: Bool) {
    _cache.removeAll(keepingCapacity: keepCapacity)
  }
}
