@usableFromInline
protocol UnsafeTreeAllocationHeader {
  var initializedCount: Int { get }
  var freshBucketCount: Int { get }
}

@usableFromInline
protocol UnsafeTreeAllcationBody {
  associatedtype Header: UnsafeTreeAllocationHeader
  associatedtype _Value
  var _header: Header { get }
  var freshPoolCapacity: Int { get }
  var count: Int { get }
}

extension UnsafeTree: UnsafeTreeAllcationBody {}
extension UnsafeTree.Header: UnsafeTreeAllocationHeader {}

// TODO: 確保サイズ毎所要時間をのアロケーションとデアロケーションの両方で測ること

#if ALLOCATION_DRILL
extension UnsafeTree: UnsafeTreeAllcationDrill {}
#else
//extension UnsafeTree: UnsafeTreeAllcation0 {}
//extension UnsafeTree: UnsafeTreeAllcation1 {}
extension UnsafeTree: UnsafeTreeAllcation2 {}
//extension UnsafeTree: UnsafeTreeAllcation3 {}
#endif

public nonisolated(unsafe) var allocationChunkSize: Int = 0

@usableFromInline
protocol UnsafeTreeAllcationDrill: UnsafeTreeAllcationBody {}

extension UnsafeTreeAllcationDrill {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {
    Swift.max(minimumCapacity, freshPoolCapacity + allocationChunkSize)
  }
}

@usableFromInline
protocol UnsafeTreeAllcation3: UnsafeTreeAllcationBody {}

extension UnsafeTreeAllcation3 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        _header.initializedCount,
        minimumCapacity)
    }

    let s0 = MemoryLayout<UnsafeNode>.stride
    let s1 = MemoryLayout<_Value>.stride
    let s2 = MemoryLayout<UnsafeNodeFreshBucket>.stride
    let a2 = 0 // MemoryLayout<UnsafeNodeFreshBucket<_Value>>.alignment

    if minimumCapacity <= 2 {
      return 3
    }

    if minimumCapacity <= 64 {
      return Swift.max(minimumCapacity, count + ((16 - 1) * (s0 + s1) - s2 - a2) / (s0 + s1))
    }
    
    var n = 1 << ((Int.bitWidth - minimumCapacity.leadingZeroBitCount) + 1)
    
    if minimumCapacity <= 100000 {
      n = n << 1
    }

    return Swift.max(minimumCapacity, count + ((n - 1) * (s0 + s1) - s2 - a2) / (s0 + s1))
  }
}

@usableFromInline
protocol UnsafeTreeAllcation2: UnsafeTreeAllcationBody {}

extension UnsafeTreeAllcation2 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        _header.initializedCount,
        minimumCapacity)
    }

    let s0 = MemoryLayout<UnsafeNode>.stride
    let s1 = MemoryLayout<_Value>.stride
    let s2 = MemoryLayout<UnsafeNodeFreshBucket>.stride
    let a2 = 0 // MemoryLayout<UnsafeNodeFreshBucket<_Value>>.alignment

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

@usableFromInline
protocol UnsafeTreeAllcation1: UnsafeTreeAllcationBody {}

extension UnsafeTreeAllcation1 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        _header.initializedCount,
        minimumCapacity)
    }

    if minimumCapacity <= 2 {
      return 3
    }

    let s0 = MemoryLayout<UnsafeNode>.stride
    let s1 = MemoryLayout<_Value>.stride
    let s2 = MemoryLayout<UnsafeNodeFreshBucket>.stride
    let a2 = MemoryLayout<UnsafeNodeFreshBucket>.alignment

    let (small, large) = _header.initializedCount < 2048 ? (31, 31) : (15, 15)

    if _header.freshBucketCount & 1 == 1 {
      return Swift.max(minimumCapacity, count + (small * (s0 + s1) - s2 - a2) / (s0 + s1))
    }

    return Swift.max(minimumCapacity, count + (large * (s0 + s1) - s2 - a2) / (s0 + s1))
  }
}

@usableFromInline
protocol UnsafeTreeAllcation0: UnsafeTreeAllcationBody {}

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
        _header.initializedCount,
        minimumCapacity)
    }

    if minimumCapacity <= 4 {
      return Swift.max(
        _header.initializedCount,
        minimumCapacity
      )
    }

    if minimumCapacity <= 12 {
      return Swift.max(
        _header.initializedCount,
        freshPoolCapacity + (minimumCapacity - freshPoolCapacity) * 2
      )
    }

    // 手元の環境だと、サイズ24まではピタリのサイズを確保することができる
    // 小さなサイズの成長を抑制すると、ABC385Dでの使用メモリが抑えられやすい
    // 実行時間も抑制されやすいが、なぜなのかはまだ不明

    // ABC385Dの場合、アロケータープールなんかで使いまわしが効きやすいからなのではと予想している。

    return Swift.max(
      _header.initializedCount,
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
