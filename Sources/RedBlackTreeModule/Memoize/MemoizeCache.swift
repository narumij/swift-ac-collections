import Foundation

public
  struct MemoizeCache<each T, Result>
{}

extension MemoizeCache {

  public
    final class Standard where repeat each T: Hashable
  {

    @nonobjc
    @inlinable
    @inline(__always)
    public init() {
      self.storage = .init()
    }

    @usableFromInline
    var storage: [MemoizePack<repeat each T>: Result] = .init()

    @nonobjc
    @inlinable
    public subscript(
      key: MemoizePack<repeat each T>,
      fallBacking _fallback: (repeat each T) -> Result
    ) -> Result
    {
      @inline(__always)
      get {
        if let result = storage[key] {
          return result
        }
        let r = _fallback(repeat each key.rawValue)
        storage[key] = r
        return r
      }
    }
  }
}

extension MemoizeCache {

  public
    final class Base where repeat each T: Comparable
  {

    @nonobjc
    @inlinable
    @inline(__always)
    public init() {
      self.storage = .init()
    }

    @usableFromInline
    var storage: _MemoizeCacheBase<MemoizePack<repeat each T>, Result> = .init()

    @nonobjc
    @inlinable
    public subscript(
      key: MemoizePack<repeat each T>,
      fallBacking _fallback: (repeat each T) -> Result
    ) -> Result
    {
      @inline(__always)
      get {
        if let result = storage[key] {
          return result
        }
        let r = _fallback(repeat each key.rawValue)
        storage[key] = r
        return r
      }
    }

    @inlinable
    public var info: (hits: Int, miss: Int, maxCount: Int?, currentCount: Int) {
      storage.___info
    }
  }
}

extension MemoizeCache {

  public
    final class LRU where repeat each T: Comparable
  {

    @nonobjc
    @inlinable
    @inline(__always)
    public init(maxCount: Int) {
      self.storage = .init(maxCount: maxCount)
    }

    @usableFromInline
    var storage: _MemoizeCacheLRU<MemoizePack<repeat each T>, Result> = .init()

    @nonobjc
    @inlinable
    public subscript(
      key: MemoizePack<repeat each T>,
      fallBacking _fallback: (repeat each T) -> Result
    ) -> Result
    {
      @inline(__always)
      get {
        if let result = storage[key] {
          return result
        }
        let r = _fallback(repeat each key.rawValue)
        storage[key] = r
        return r
      }
    }

    @inlinable
    public var info: (hits: Int, miss: Int, maxCount: Int?, currentCount: Int) {
      storage.___info
    }
  }
}

extension MemoizeCache {

  public
    final class CoW where repeat each T: Comparable
  {

    @nonobjc
    @inlinable
    @inline(__always)
    public init(maxCount: Int) {
      self.storage = .init(maxCount: maxCount)
    }

    @usableFromInline
    var storage: _MemoizeCacheCoW<MemoizePack<repeat each T>, Result> = .init()

    @nonobjc
    @inlinable
    public subscript(
      key: MemoizePack<repeat each T>,
      fallBacking _fallback: (repeat each T) -> Result
    ) -> Result
    {
      @inline(__always)
      get {
        if let result = storage[key] {
          return result
        }
        let r = _fallback(repeat each key.rawValue)
        storage[key] = r
        return r
      }
    }

    @inlinable
    public var info: (hits: Int, miss: Int, maxCount: Int?, currentCount: Int) {
      storage.___info
    }
  }
}
