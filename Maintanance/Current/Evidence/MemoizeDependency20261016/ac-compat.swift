import RedBlackTreeModule
import Foundation

public struct MemoizePack<each T> {

  public
    typealias RawValue = (repeat each T)

  public
    var rawValue: RawValue

  @inlinable
  public init(rawValue: (repeat each T)) {
    self.rawValue = (repeat each rawValue)
  }

  @inlinable
  public init(_ rawValue: repeat each T) {
    self.rawValue = (repeat each rawValue)
  }
}

extension MemoizePack: Equatable where repeat each T: Equatable {

  @inlinable
  public static func == (lhs: MemoizePack<repeat each T>, rhs: MemoizePack<repeat each T>) -> Bool {
    for (l, r) in repeat (each lhs.rawValue, each rhs.rawValue) {
      if l != r {
        return false
      }
    }
    return true
  }
}

extension MemoizePack: Comparable where repeat each T: Comparable {

  @inlinable
  public static func < (lhs: MemoizePack<repeat each T>, rhs: MemoizePack<repeat each T>) -> Bool {
    for (l, r) in repeat (each lhs.rawValue, each rhs.rawValue) {
      if l != r {
        return l < r
      }
    }
    return false
  }
}

extension MemoizePack: Hashable where repeat each T: Hashable {

  @inlinable
  public func hash(into hasher: inout Hasher) {
    for l in repeat (each rawValue) {
      hasher.combine(l)
    }
  }
}

extension MemoizePack: Sendable where repeat each T: Sendable { }

import Foundation

/// 辞書による再帰メモ化用のキャッシュ
///
/// 以下のような再帰関数に用いる場合
/// ```
/// func tarai(x: Int, y: Int, z: Int) -> Int {
///   if x <= y {
///     return y
///   } else {
///     return tarai(
///       x: tarai(x: x - 1, y: y, z: z),
///       y: tarai(x: y - 1, y: z, z: x),
///       z: tarai(x: z - 1, y: x, z: y))
///   }
/// }
/// ```
///
/// 以下のようにキャッシュを定義及び初期化します。
/// ```
/// nonisolated(unsafe) let ___tarai_memo: MemoizeCache<Int, Int, Int, Int>.Standard = .init()
/// ```
///
/// 実装を以下のように書き換えることでメモ化再帰となります。
/// ```
/// func tarai(x: Int, y: Int, z: Int) -> Int {
///   func tarai(x: Int, y: Int, z: Int) -> Int {
///     ___tarai_memo[.init(x,y,z), fallBacking: ___body]
///   }
///   func ___body(x: Int, y: Int, z: Int) -> Int {
///     if x <= y {
///       return y
///     } else {
///       return tarai(
///         x: tarai(x: x - 1, y: z, z: z),
///         y: tarai(x: y - 1, y: z, z: x),
///         z: tarai(x: z - 1, y: x, z: y))
///     }
///   }
///   return tarai(x: x, y: y, z: z)
/// }
/// ```
/// ボディに元の内容が入り、内部同名メソッドでキャッシュを使い、末尾で内部同名メソッドを呼んでいます。
///
/// Standardは標準辞書を用いています。
/// LRUは赤黒木を用いていて、保持量を制限できます。
///
/// DP問題では、辞書でのメモ化ではTLEになりがちです。どちらかというと素数や階乗やフィボナッチ数列みたいな類いのものをどうしても使いたい場合の予備といった位置づけです。
///
///
public
  struct MemoizeCache<each T, Result>
{}

extension MemoizeCache {

  public
    final class Standard where repeat each T: Hashable
  {

    @nonobjc
    @inlinable
    public init() {
      self.storage = .init()
    }

    @usableFromInline
    var storage: [MemoizePack<repeat each T>: Result]

    @usableFromInline
    var _hits: Int = 0

    @usableFromInline
    var _miss: Int = 0

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
          _hits &+= 1
          return result
        }
        _miss &+= 1
        let r = _fallback(repeat each key.rawValue)
        storage[key] = r
        return r
      }
    }

    @inlinable
    public func clear(keepingCapacity keepCapacity: Bool = false) {
      (_hits, _miss) = (0, 0)
      storage.removeAll(keepingCapacity: keepCapacity)
    }

    @inlinable
    public var info: (hits: Int, miss: Int, maxCount: Int?, currentCount: Int) {
      (_hits, _miss, nil, storage.count)
    }
  }
}

extension MemoizeCache {

  public
    final class LRU where repeat each T: Comparable
  {
    @nonobjc
    @inlinable
    public init(maxCount: Int) {
      self.storage = .init(maxCount: maxCount)
    }

    @usableFromInline
    var storage: ___LRUMemoizeStorage<MemoizePack<repeat each T>, Result>

    @usableFromInline
    var _hits: Int = 0

    @usableFromInline
    var _miss: Int = 0

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
          _hits &+= 1
          return result
        }
        _miss &+= 1
        let r = _fallback(repeat each key.rawValue)
        storage[key] = r
        return r
      }
    }

    @inlinable
    public func clear(keepingCapacity keepCapacity: Bool = false) {
      (_hits, _miss) = (0, 0)
      storage.removeAll(keepingCapacity: keepCapacity)
    }

    @inlinable
    public var info: (hits: Int, miss: Int, maxCount: Int?, currentCount: Int) {
      (_hits, _miss, storage.maxCount, storage.count)
    }
  }
}


public
  struct MemoizeCacheV2<each T, Result>
{}

extension MemoizeCacheV2 {

  public
    struct Standard: ~Copyable where repeat each T: Hashable
  {

    @nonobjc
    @inlinable
    public init() {
      self.storage = .init()
    }

    @usableFromInline
    var storage: [MemoizePack<repeat each T>: Result]

    @usableFromInline
    var _hits: Int = 0

    @usableFromInline
    var _miss: Int = 0

    @nonobjc
    @inlinable
    public subscript(key: MemoizePack<repeat each T>) -> Result? {
      @inline(__always)
      mutating get {
        if let result = storage[key] {
          _hits &+= 1
          return result
        }
        _miss &+= 1
        return nil
      }
      set {
        storage[key] = newValue
      }
    }

    @nonobjc
    @inlinable
    public subscript(
      key: MemoizePack<repeat each T>,
      fallBacking _fallback: (repeat each T) -> Result
    ) -> Result
    {
      @inline(__always)
      mutating get {
        if let result = storage[key] {
          _hits &+= 1
          return result
        }
        _miss &+= 1
        let r = _fallback(repeat each key.rawValue)
        storage[key] = r
        return r
      }
    }

    @inlinable
    public mutating func clear(keepingCapacity keepCapacity: Bool = false) {
      (_hits, _miss) = (0, 0)
      storage.removeAll(keepingCapacity: keepCapacity)
    }

    @inlinable
    public var info: (hits: Int, miss: Int, maxCount: Int?, currentCount: Int) {
      (_hits, _miss, nil, storage.count)
    }
  }
}

extension MemoizeCacheV2 {

  public
    struct LRU: ~Copyable where repeat each T: Comparable
  {
    @nonobjc
    @inlinable
    public init(maxCount: Int) {
      self.storage = .init(maxCount: maxCount)
    }

    @usableFromInline
    var storage: ___LRUMemoizeStorage<MemoizePack<repeat each T>, Result>

    @usableFromInline
    var _hits: Int = 0

    @usableFromInline
    var _miss: Int = 0

    @nonobjc
    @inlinable
    public subscript(key: MemoizePack<repeat each T>) -> Result? {
      @inline(__always)
      mutating get {
        if let result = storage[key] {
          _hits &+= 1
          return result
        }
        _miss &+= 1
        return nil
      }
      set {
        storage[key] = newValue
      }
    }

    @nonobjc
    @inlinable
    public subscript(
      key: MemoizePack<repeat each T>,
      fallBacking _fallback: (repeat each T) -> Result
    ) -> Result
    {
      @inline(__always)
      mutating get {
        if let result = storage[key] {
          _hits &+= 1
          return result
        }
        _miss &+= 1
        let r = _fallback(repeat each key.rawValue)
        storage[key] = r
        return r
      }
    }

    @inlinable
    public mutating func clear(keepingCapacity keepCapacity: Bool = false) {
      (_hits, _miss) = (0, 0)
      storage.removeAll(keepingCapacity: keepCapacity)
    }

    @inlinable
    public var info: (hits: Int, miss: Int, maxCount: Int?, currentCount: Int) {
      (_hits, _miss, storage.maxCount, storage.count)
    }
  }
}
