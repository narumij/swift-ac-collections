// TODO: FIXME!!!
// TODO: FIXME!!!
// TODO: FIXME!!!
// TODO: FIXME!!!
// TODO: FIXME!!!
// TODO: FIXME!!!
// TODO: FIXME!!!
// TODO: FIXME!!!
// TODO: FIXME!!!
// TODO: FIXME!!!
// TODO: FIXME!!!
// TODO: FIXME!!!
// TODO: FIXME!!!
// TODO: FIXME!!!

@usableFromInline
protocol UnsafeTreeAllocationHeader {
  #if DEBUG
    var freshBucketCount: Int { get }
  #endif
}

@usableFromInline
protocol UnsafeTreeAllcationBodyV2: _ValueProtocol {
  associatedtype Header: UnsafeTreeAllocationHeader
  var _buffer: ManagedBufferPointer<Header, UnsafeTreeV2Origin> { get }
  var capacity: Int { get }
  var count: Int { get }
  var initializedCount: Int { get }
}

extension UnsafeTreeV2: UnsafeTreeAllcationBodyV2 {}
extension UnsafeTreeV2Buffer.Header: UnsafeTreeAllocationHeader {}

// TODO: 確保サイズ毎所要時間をのアロケーションとデアロケーションの両方で測ること

#if ALLOCATION_DRILL
  extension UnsafeTreeV2 {
    @inlinable
    @inline(__always)
    internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {
      fatalError()
    }
  }
  extension RedBlackTreeSet {
    @inlinable
    public static func allocationDrill() -> RedBlackTreeSet {
      .init(__tree_: .___create(minimumCapacity: 0))
    }
  }
#else
  //#if USE_FRESH_POOL_V1
  #if !USE_FRESH_POOL_V2
    //extension UnsafeTreeV2: UnsafeTreeAllcation2 {}
    // extension UnsafeTreeV2: UnsafeTreeAllcation3 {}
    // extension UnsafeTreeV2: UnsafeTreeAllcation4 {}
    //extension UnsafeTreeV2: UnsafeTreeAllcation5 {}
    //extension UnsafeTreeV2: UnsafeTreeAllcation6 {} // 1.5
    //extension UnsafeTreeV2: UnsafeTreeAllcation6_7 { // 1.125
    //  // https://atcoder.jp/contests/abc411/submissions/72291000
    //}
    extension UnsafeTreeV2: UnsafeTreeAllcation6_9 {
      // https://atcoder.jp/contests/abc411/submissions/72391453
    }  // 1.25
  //extension UnsafeTreeV2: UnsafeTreeAllcation6_8 {}
  //extension UnsafeTreeV2: UnsafeTreeAllcation7 {}
  #else
    extension UnsafeTreeV2: UnsafeTreeAllcation6_9 {}
  // extension UnsafeTreeV2: UnsafeTreeAllcation6_7 {}
  #endif
#endif

#if ALLOCATION_DRILL
  extension RedBlackTreeSet {
    public mutating func pushFreshBucket(capacity: Int) {
      __tree_._buffer.header.pushFreshBucket(capacity: capacity)
    }
  }
#endif

@usableFromInline
protocol UnsafeTreeAllcation7: UnsafeTreeAllcationBodyV2 {
  var capacity: Int { get }
}

extension UnsafeTreeAllcation7 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        capacity,
        minimumCapacity)
    }

    if minimumCapacity <= 2 {
      return Swift.max(minimumCapacity, 2)
    }

    if minimumCapacity <= 4 {
      return Swift.max(minimumCapacity, 4)
    }

    // 若干計算は適当だが、スモールアロケーションの速度で出来ることをやり尽くすように制限している
    let limit1024 =
      (1024 - MemoryLayout<_UnsafeNodeFreshBucket>.stride)
      / (MemoryLayout<UnsafeNode>.stride + MemoryLayout<_Value>.stride)

    if minimumCapacity <= limit1024 {
      // バグってて速かった
      // return Swift.min(capacity + capacity / 8, limit1024)
      return Swift.max(minimumCapacity, Swift.min(capacity + Swift.max(2, capacity / 8), limit1024))
    }

    // L1目一杯で出来ることをやり尽くすようにする
    // 4096のマージンはアロケータ補正に対する分
    let limit32k =
      (1024 * 32 - 4096) / (MemoryLayout<UnsafeNode>.stride + MemoryLayout<_Value>.stride)

    if minimumCapacity <= limit32k {
      return Swift.max(minimumCapacity, Swift.min(capacity + capacity / 8, limit32k))
    }

    // L2目一杯で出来ることをやり尽くすようにする
    // 4096のマージンはアロケータ補正に対する分
    let limit512k =
      (1024 * 512 - 4096) / (MemoryLayout<UnsafeNode>.stride + MemoryLayout<_Value>.stride)

    if minimumCapacity <= limit512k {
      return Swift.max(minimumCapacity, Swift.min(capacity + capacity / 8, limit512k))
    }

    return Swift.max(minimumCapacity, capacity + max(capacity / 8, 1))
  }
}

@usableFromInline
protocol UnsafeTreeAllcation6_10 {
  var capacity: Int { get }
}

extension UnsafeTreeAllcation6_10 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        capacity,
        minimumCapacity)
    }

    return Swift.max(minimumCapacity, capacity + max(capacity * 3 / 16, 2))
  }
}

@usableFromInline
protocol UnsafeTreeAllcation6_8 {
  var capacity: Int { get }
}

extension UnsafeTreeAllcation6_8 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        capacity,
        minimumCapacity)
    }

    return Swift.max(minimumCapacity, capacity + max(capacity / 16, 1))
  }
}

@usableFromInline
protocol UnsafeTreeAllcation6_7 {
  var capacity: Int { get }
}

extension UnsafeTreeAllcation6_7 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        capacity,
        minimumCapacity)
    }

    //    if minimumCapacity <= 2 {
    //      return Swift.max(minimumCapacity, 2)
    //    }
    //
    //    if minimumCapacity <= 4 {
    //      return Swift.max(minimumCapacity, 4)
    //    }

    return Swift.max(minimumCapacity, capacity + max(capacity / 8, 1))
  }
}

@usableFromInline
protocol UnsafeTreeAllcation6_9 {
  var capacity: Int { get }
}

extension UnsafeTreeAllcation6_9 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        capacity,
        minimumCapacity)
    }

    //    if minimumCapacity <= 2 {
    //      return Swift.max(minimumCapacity, 2)
    //    }
    //
    //    if minimumCapacity <= 4 {
    //      return Swift.max(minimumCapacity, 4)
    //    }

    return Swift.max(minimumCapacity, capacity + max(capacity / 4, 2))
  }
}

@usableFromInline
protocol UnsafeTreeAllcation6 {
  var capacity: Int { get }
}

extension UnsafeTreeAllcation6 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        capacity,
        minimumCapacity)
    }

    return Swift.max(minimumCapacity, capacity + max(capacity / 2, 1))
  }
}

@usableFromInline
protocol UnsafeTreeAllcation6_2 {
  var capacity: Int { get }
}

extension UnsafeTreeAllcation6_2 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        capacity,
        minimumCapacity)
    }

    return Swift.max(minimumCapacity, capacity + max(capacity * 3 / 4, 2))
  }
}

@usableFromInline
protocol UnsafeTreeAllcation6_3 {
  var capacity: Int { get }
}

extension UnsafeTreeAllcation6_3 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        capacity,
        minimumCapacity)
    }

    return Swift.max(minimumCapacity, capacity + max(capacity, 2))
  }
}

@usableFromInline
protocol UnsafeTreeAllcation6_4 {
  var capacity: Int { get }
}

extension UnsafeTreeAllcation6_4 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        capacity,
        minimumCapacity)
    }

    return Swift.max(minimumCapacity, capacity + max(capacity * 2, 2))
  }
}

@usableFromInline
protocol UnsafeTreeAllcation6_5 {
  var capacity: Int { get }
}

extension UnsafeTreeAllcation6_5 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        capacity,
        minimumCapacity)
    }

    return Swift.max(minimumCapacity, capacity + max(capacity * 3, 2))
  }
}

@usableFromInline
protocol UnsafeTreeAllcation6_6 {
  var capacity: Int { get }
}

extension UnsafeTreeAllcation6_6 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        capacity,
        minimumCapacity)
    }

    return Swift.max(minimumCapacity, capacity + max(capacity * 4, 2))
  }
}

@usableFromInline
protocol UnsafeTreeAllcation5 {
  var capacity: Int { get }
}

extension UnsafeTreeAllcation5 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        capacity,
        minimumCapacity)
    }

    let recommendCapacity = 1 << (Int.bitWidth - capacity.leadingZeroBitCount)
    return Swift.max(minimumCapacity, recommendCapacity)
  }
}

@usableFromInline
protocol UnsafeTreeAllcation4 {
  var capacity: Int { get }
}

extension UnsafeTreeAllcation4 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        capacity,
        minimumCapacity)
    }

    if minimumCapacity <= 256 {
      let recommendCapacity = 1 << (Int.bitWidth - capacity.leadingZeroBitCount)
      return Swift.max(minimumCapacity, recommendCapacity)
    }

    //    if minimumCapacity <= 8192 {
    //      let increaseCapacity =
    //        // 1/1
    //        (1 << (Int.bitWidth - capacity.leadingZeroBitCount - 1))
    //      let recommendCapacity = capacity + increaseCapacity
    //      return Swift.max(minimumCapacity, recommendCapacity)
    //    }

    //    if minimumCapacity <= 2048 {
    let increaseCapacity =
      // 3/4
      (1 << (Int.bitWidth - capacity.leadingZeroBitCount - 2))
      | (1 << (Int.bitWidth - capacity.leadingZeroBitCount - 3))
    let recommendCapacity = capacity + increaseCapacity
    return Swift.max(minimumCapacity, recommendCapacity)
    //    }
    //    if minimumCapacity <= 8196 {
    //      let increaseCapacity =
    //        // つまり5/8
    //        (1 << (Int.bitWidth - capacity.leadingZeroBitCount - 2))
    //        | (1 << (Int.bitWidth - capacity.leadingZeroBitCount - 4))
    //      let recommendCapacity = capacity + increaseCapacity
    //      return Swift.max(minimumCapacity, recommendCapacity)
    //    }
    //
    //    if minimumCapacity <= 1024 * 16 {
    //      let increaseCapacity =
    //        // つまり1/2
    //        (1 << (Int.bitWidth - capacity.leadingZeroBitCount - 2))
    //      let recommendCapacity = capacity + increaseCapacity
    //      return Swift.max(minimumCapacity, recommendCapacity)
    //    }
    //
    //    let increaseCapacity =
    //      // つまり1/4
    //      (1 << (Int.bitWidth - capacity.leadingZeroBitCount - 3))
    //    let recommendCapacity = capacity + increaseCapacity
    //    return Swift.max(minimumCapacity, recommendCapacity)
  }
}

@usableFromInline
protocol UnsafeTreeAllcation3: UnsafeTreeAllcationBodyV2 {}

extension UnsafeTreeAllcation3 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        initializedCount,
        minimumCapacity)
    }

    if minimumCapacity <= 6 {
      return Swift.max(minimumCapacity, count + count)
    }

    if minimumCapacity <= 8192 {
      return Swift.max(minimumCapacity, count + Swift.min(count / 2, 14))
    }

    return Swift.max(minimumCapacity, count + Swift.min(count / 2, 510))
  }
}

@usableFromInline
protocol UnsafeTreeAllcation2: UnsafeTreeAllcationBodyV2 {}

extension UnsafeTreeAllcation2 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        initializedCount,
        minimumCapacity)
    }

    let s0 = MemoryLayout<UnsafeNode>.stride
    let s1 = MemoryLayout<_Value>.stride
    let s2 = MemoryLayout<_UnsafeNodeFreshBucket>.stride
    let a2 = 0  // MemoryLayout<UnsafeNodeFreshBucket<_Value>>.alignment

    if minimumCapacity <= 2 {
      return 3
    }

    if minimumCapacity <= 64 {
      return Swift.max(minimumCapacity, count + ((16 - 1) * (s0 + s1) - s2 - a2) / (s0 + s1))
    }

    if minimumCapacity < 4096 {
      return Swift.max(minimumCapacity, count + ((32 - 1) * (s0 + s1) - s2 - a2) / (s0 + s1))
    }

    if minimumCapacity <= 8192 {
      return Swift.max(minimumCapacity, count + ((16 - 1) * (s0 + s1) - s2 - a2) / (s0 + s1))
    }

    if minimumCapacity <= 100000 {
      return Swift.max(minimumCapacity, count + ((512 - 1) * (s0 + s1) - s2 - a2) / (s0 + s1))
    }

    return Swift.max(minimumCapacity, count + ((1024 * 2 - 1) * (s0 + s1) - s2 - a2) / (s0 + s1))
  }
}

// MARK: -

@usableFromInline
protocol UnsafeTreeAllcation1: UnsafeTreeAllcationBodyV2 {}

extension UnsafeTreeAllcation1 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        initializedCount,
        minimumCapacity)
    }

    if minimumCapacity <= 2 {
      return 3
    }

    let s0 = MemoryLayout<UnsafeNode>.stride
    let s1 = MemoryLayout<_Value>.stride
    let s2 = MemoryLayout<_UnsafeNodeFreshBucket>.stride
    let a2 = MemoryLayout<_UnsafeNodeFreshBucket>.alignment

    let (small, large) = initializedCount < 2048 ? (31, 31) : (15, 15)

    #if DEBUG
      if _buffer.header.freshBucketCount & 1 == 1 {
        return Swift.max(minimumCapacity, count + (small * (s0 + s1) - s2 - a2) / (s0 + s1))
      }
    #endif

    return Swift.max(minimumCapacity, count + (large * (s0 + s1) - s2 - a2) / (s0 + s1))
  }
}

@usableFromInline
protocol UnsafeTreeAllcation0: UnsafeTreeAllcationBodyV2 {}

extension UnsafeTreeAllcation0 {

  @inlinable
  @inline(__always)
  internal func bitCeil(_ n: Int) -> Int {
    n <= 1 ? 1 : 1 << (Int.bitWidth - (n - 1).leadingZeroBitCount)
  }

  @inlinable
  @inline(__always)
  internal func growthFormula(count: Int) -> Int {
    #if true
      // アロケーターにとって負担が軽そうな、2のべき付近を要求することにした。
      // ヘッダー込みで確保するべきかどうかは、ManagedBufferのソースをみておらず不明。
      // はみ出して大量に無駄にするよりはましなので、ヘッダー込みでサイズ計算することにしている。
      let rawSize = bitCeil(MemoryLayout<UnsafeNode>.stride * count)
      return rawSize / MemoryLayout<UnsafeNode>.stride
    #else
      // メモリ使用量の多さが気になったので、標準Setと同じものに変更
      return Self.capacity(forScale: Self.scale(forCapacity: count))
    #endif
  }

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        initializedCount,
        minimumCapacity)
    }

    if minimumCapacity <= 4 {
      return Swift.max(
        initializedCount,
        minimumCapacity
      )
    }

    if minimumCapacity <= 12 {
      return Swift.max(
        initializedCount,
        capacity + (minimumCapacity - capacity) * 2
      )
    }

    // 手元の環境だと、サイズ24まではピタリのサイズを確保することができる
    // 小さなサイズの成長を抑制すると、ABC385Dでの使用メモリが抑えられやすい
    // 実行時間も抑制されやすいが、なぜなのかはまだ不明

    // ABC385Dの場合、アロケータープールなんかで使いまわしが効きやすいからなのではと予想している。

    return Swift.max(
      initializedCount,
      growthFormula(count: minimumCapacity))
  }
}

// from https://github.com/swiftlang/swift/blob/main/stdlib/public/core/Integers.swift
// LICENCE: https://github.com/swiftlang/swift/blob/main/LICENSE.txt
// Apache License 2.0 LLVM exception

#if UNSAFE_TREE_PROJECT
  extension FixedWidthInteger {

    @inlinable
    internal func _binaryLogarithm() -> Int {
      return Self.bitWidth &- (leadingZeroBitCount &+ 1)
    }
  }
#endif

// from https://github.com/swiftlang/swift/blob/main/stdlib/public/core/HashTable.swift
// LICENCE: https://github.com/swiftlang/swift/blob/main/LICENSE.txt
// Apache License 2.0 LLVM exception

extension UnsafeTreeAllcation0 {

  /// The inverse of the maximum hash table load factor.
  @inlinable
  internal static var maxLoadFactor: Double {
    return 3 / 4
  }

  @inlinable
  internal static func capacity(forScale scale: Int8) -> Int {
    let bucketCount = (1 as Int) &<< scale
    return Int(Double(bucketCount) * maxLoadFactor)
  }

  @inlinable
  internal static func scale(forCapacity capacity: Int) -> Int8 {
    let capacity = Swift.max(capacity, 1)
    // Calculate the minimum number of entries we need to allocate to satisfy
    // the maximum load factor. `capacity + 1` below ensures that we always
    // leave at least one hole.
    let minimumEntries = Swift.max(
      Int((Double(capacity) / maxLoadFactor).rounded(.up)),
      capacity + 1)
    // The actual number of entries we need to allocate is the lowest power of
    // two greater than or equal to the minimum entry count. Calculate its
    // exponent.
    let exponent = (Swift.max(minimumEntries, 2) - 1)._binaryLogarithm() + 1
    //    _internalInvariant(exponent >= 0 && exponent < Int.bitWidth)
    // The scale is the exponent corresponding to the bucket count.
    let scale = Int8(truncatingIfNeeded: exponent)
    //    unsafe _internalInvariant(self.capacity(forScale: scale) >= capacity)
    return scale
  }
}
