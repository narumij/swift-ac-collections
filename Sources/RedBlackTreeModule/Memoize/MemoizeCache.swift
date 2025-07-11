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
/// BaseはLRUへの過渡期のものです。
/// CoWはコピーオンライト付きです。
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
    @inline(__always)
    public init() {
      self.storage = .init()
    }

    @usableFromInline
    var storage: [MemoizePack<repeat each T>: Result]

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
    public func clear(keepingCapacity keepCapacity: Bool = false) {
      storage.removeAll(keepingCapacity: keepCapacity)
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
    var storage: _MemoizeCacheBase<MemoizePack<repeat each T>, Result>

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
    public func clear(keepingCapacity keepCapacity: Bool = false) {
      storage.clear(keepingCapacity: keepCapacity)
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
    var storage: _MemoizeCacheLRU<MemoizePack<repeat each T>, Result>

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
    public func clear(keepingCapacity keepCapacity: Bool = false) {
      storage.clear(keepingCapacity: keepCapacity)
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
    var storage: _MemoizeCacheCoW<MemoizePack<repeat each T>, Result>

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
    public func clear(keepingCapacity keepCapacity: Bool = false) {
      storage.clear(keepingCapacity: keepCapacity)
    }

    @inlinable
    public var info: (hits: Int, miss: Int, maxCount: Int?, currentCount: Int) {
      storage.___info
    }
  }
}
