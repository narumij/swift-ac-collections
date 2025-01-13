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
    (_hits, _miss, nil, _cache.count)
  }

  @inlinable
  public mutating func clear(keepingCapacity keepCapacity: Bool = false) {
    (_hits, _miss) = (0, 0)
    _cache.removeAll(keepingCapacity: keepCapacity)
  }
}
