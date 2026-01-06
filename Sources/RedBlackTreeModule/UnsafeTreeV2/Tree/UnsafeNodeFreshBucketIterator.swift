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
struct UnsafeNodeFreshBucketIterator<_Value>: IteratorProtocol, Sequence {

  @usableFromInline
  typealias Bucket = UnsafeNodeFreshBucket

  @usableFromInline
  typealias BucketPointer = UnsafeMutablePointer<Bucket>

  @inlinable
  @inline(__always)
  internal init(bucket: BucketPointer?) {
    self.bucket = bucket
  }

  @usableFromInline
  var bucket: BucketPointer?

  @inlinable
  @inline(__always)
  mutating func next() -> BucketPointer? {
    defer { bucket = bucket?.pointee.next }
    return bucket
  }
}
