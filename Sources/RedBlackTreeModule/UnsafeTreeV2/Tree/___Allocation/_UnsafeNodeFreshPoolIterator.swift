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

/// 使用済みから初期化済みまでを列挙するイテレータ
@usableFromInline
struct _UnsafeNodeFreshPoolIterator<_Value>: IteratorProtocol, Sequence {

  @usableFromInline
  typealias Bucket = _UnsafeNodeFreshBucket

  @usableFromInline
  typealias BucketPointer = UnsafeMutablePointer<Bucket>

  @usableFromInline
  typealias ElementPointer = UnsafeMutablePointer<UnsafeNode>

  @inlinable
  @inline(__always)
  internal init(bucket: BucketPointer?, nullptr: UnsafeMutablePointer<UnsafeNode>) {
    self.bucket = bucket
    self.it = nullptr
    self.end = nullptr
  }

  @usableFromInline
  var bucket: BucketPointer?

  @usableFromInline
  var it, end: UnsafeMutablePointer<UnsafeNode>

  @inlinable
  @inline(__always)
  mutating func next() -> ElementPointer? {

    while it == end, let bucket {
      self.bucket = bucket.pointee.next
      it = bucket.pointee.start
      end = UnsafePair<_Value>.advance(bucket.pointee.start, bucket.pointee.count)
    }
    
    guard it != end else { return .none }

    let p = it
    self.it = UnsafePair<_Value>.advance(it)
    return p
  }
}
