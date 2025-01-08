import RedBlackTreeModule

@usableFromInline
struct MemoizeCache1<A, B>
where A: Comparable, B: Comparable {
  @usableFromInline
  enum Key: KeyCustomProtocol {
    @inlinable
    static func value_comp(_ a: A, _ b: A) -> Bool {
      a < b
    }
  }
  @usableFromInline
  init(__memo: MemoizeCacheBase<Key, B> = .init()) {
    self.__memo = __memo
  }
  @usableFromInline
  var __memo: MemoizeCacheBase<Key, B> = .init()
  @inlinable
  subscript(a: A) -> B? {
    get { __memo[a] }
    _modify { yield &__memo[a] }
  }
}

@usableFromInline
struct MemoizeCache2<A, B, C>
where A: Comparable, B: Comparable {
  @usableFromInline
  enum Key: KeyCustomProtocol {
    @inlinable
    static func value_comp(_ a: (A, B), _ b: (A, B)) -> Bool {
      a < b
    }
  }
  @usableFromInline
  init(__memo: MemoizeCacheBase<Key, C> = .init()) {
    self.__memo = __memo
  }
  @usableFromInline
  var __memo: MemoizeCacheBase<Key, C> = .init()
  @inlinable
  subscript(a: A, b: B) -> C? {
    get { __memo[(a, b)] }
    _modify { yield &__memo[(a, b)] }
  }
}

@usableFromInline
struct MemoizeCache3<A, B, C, D>
where A: Comparable, B: Comparable, C: Comparable {
  @usableFromInline
  enum Key: KeyCustomProtocol {
    @inlinable
    static func value_comp(_ a: (A, B, C), _ b: (A, B, C)) -> Bool {
      a < b
    }
  }
  @usableFromInline
  init(__memo: MemoizeCacheBase<Key, D> = .init()) {
    self.__memo = __memo
  }
  @usableFromInline
  var __memo: MemoizeCacheBase<Key, D> = .init()
  @inlinable
  subscript(a: A, b: B, c: C) -> D? {
    get { __memo[(a, b, c)] }
    _modify { yield &__memo[(a, b, c)] }
  }
}

@usableFromInline
struct MemoizeCache4<A, B, C, D, E>
where A: Comparable, B: Comparable, C: Comparable, D: Comparable {
  @usableFromInline
  enum Key: KeyCustomProtocol {
    @inlinable
    static func value_comp(_ a: (A, B, C, D), _ b: (A, B, C, D)) -> Bool {
      a < b
    }
  }
  @usableFromInline
  init(__memo: MemoizeCacheBase<Key, E> = .init()) {
    self.__memo = __memo
  }
  @usableFromInline
  var __memo: MemoizeCacheBase<Key, E> = .init()
  @inlinable
  subscript(a: A, b: B, c: C, d: D) -> E? {
    get { __memo[(a, b, c, d)] }
    _modify { yield &__memo[(a, b, c, d)] }
  }
}

// MARK: -

enum Naive {
  static
    func tarai(_ x: Int, y: Int, z: Int) -> Int
  {
    if x <= y {
      return y
    } else {
      return tarai(
        tarai(x - 1, y: y, z: z),
        y: tarai(y - 1, y: z, z: x),
        z: tarai(z - 1, y: x, z: y))
    }
  }
}
// ↑を↓に変換するマクロがあれば、メモ化が楽になる
// できました。 https://github.com/narumij/swift-ac-memoize
enum Memoized_Ver1 {

  static func tarai(x: Int, y: Int, z: Int) -> Int {

    typealias Key = (x: Int, y: Int, z: Int)

    enum KeyCustom: KeyCustomProtocol {
      @inlinable @inline(__always)
      static func value_comp(_ a: Key, _ b: Key) -> Bool { a < b }
    }

    var storage: MemoizeCacheBase<KeyCustom, Int> = .init()

    func tarai(x: Int, y: Int, z: Int) -> Int {
      let args = (x, y, z)
      if let result = storage[args] {
        return result
      }
      let r = body(x: x, y: y, z: z)
      storage[args] = r
      return r
    }

    func body(x: Int, y: Int, z: Int) -> Int {
      if x <= y {
        return y
      } else {
        return tarai(
          x: tarai(x: x - 1, y: z, z: z),
          y: tarai(x: y - 1, y: z, z: x),
          z: tarai(x: z - 1, y: x, z: y))
      }
    }

    return tarai(x: x, y: y, z: z)
  }
}

enum Memoized_Ver2 {

  static func tarai(x: Int, y: Int, z: Int) -> Int {

    // この方式はユーザーにとって非直感的となり、pythonと比べても不便さが残るので、
    // swift-ac-memoizeとしてはキャンセル
    // デコレータ版が優先するので、参考実装にとどまる
    class GlobalCache {
      enum Memoize: MemoizationProtocol {
        typealias Parameter = (x: Int, y: Int, z: Int)
        typealias Return = Int
        @inlinable @inline(__always)
        static func value_comp(_ a: Parameter, _ b: Parameter) -> Bool { a < b }
      }
      nonisolated(unsafe) static var cache: Memoize.Tree = .init()
      var memo: Memoize.Tree {
        get { Self.cache }
        _modify { yield &Self.cache }
      }
    }

    class Cache {
      enum Memoize: MemoizationProtocol {
        typealias Parameter = (x: Int, y: Int, z: Int)
        typealias Return = Int
        @inlinable @inline(__always)
        static func value_comp(_ a: Parameter, _ b: Parameter) -> Bool { a < b }
      }
      var memo: Memoize.Tree = .init()
    }

    let cache = Cache()

    func tarai(x: Int, y: Int, z: Int) -> Int {
      let args = (x, y, z)
      if let result = cache.memo[args] {
        return result
      }
      let r = body(x: x, y: y, z: z)
      cache.memo[args] = r
      return r
    }

    func body(x: Int, y: Int, z: Int) -> Int {
      if x <= y {
        return y
      } else {
        return tarai(
          x: tarai(x: x - 1, y: z, z: z),
          y: tarai(x: y - 1, y: z, z: x),
          z: tarai(x: z - 1, y: x, z: y))
      }
    }

    return tarai(x: x, y: y, z: z)
  }
}

// 参考: https://docs.python.org/ja/3/library/functools.html#functools.lru_cache

struct Memoized_Ver3 {
  // ヒューで欲しくなる可能性はある。

  // ユーザーコードと衝突しない名前を生成する工夫が必要そう
  private class LocalCache_Memoized_Ver3_tarai {
    enum Memoize: MemoizationProtocol {
      typealias Parameter = (x: Int, y: Int, z: Int)
      typealias Return = Int
      @inlinable @inline(__always)
      static func value_comp(_ a: Parameter, _ b: Parameter) -> Bool { a < b }
    }
    var memo: Memoize.Tree = .init()
  }

  // ユーザーコードと衝突しない名前を生成する工夫が必要そう
  private let _memoized_ver3_tarai_cache = LocalCache_Memoized_Ver3_tarai()

  func tarai(x: Int, y: Int, z: Int) -> Int {

    func tarai(x: Int, y: Int, z: Int) -> Int {
      let args = (x, y, z)
      if let result = _memoized_ver3_tarai_cache.memo[args] {
        return result
      }
      let r = body(x: x, y: y, z: z)
      _memoized_ver3_tarai_cache.memo[args] = r
      return r
    }

    func body(x: Int, y: Int, z: Int) -> Int {
      if x <= y {
        return y
      } else {
        return tarai(
          x: tarai(x: x - 1, y: z, z: z),
          y: tarai(x: y - 1, y: z, z: x),
          z: tarai(x: z - 1, y: x, z: y))
      }
    }

    return tarai(x: x, y: y, z: z)
  }
}

enum Memoized_Ver4 {

  static var tarai: Decorate { .init() }

  // こちらは将来的に欲しいが、未可決課題が多いことと仕様未考慮が多いこともあり、
  // swift-ac-memoizeとしては、一旦キャンセル
  @dynamicCallable
  class Decorate: MemoizationProtocol {

    func dynamicallyCall(withKeywordArguments args: KeyValuePairs<String, Int>) -> Int {
      tarai(x: args[0].value, y: args[1].value, z: args[2].value)
    }

    typealias Parameter = (x: Int, y: Int, z: Int)
    typealias Return = Int
    static func value_comp(_ a: Parameter, _ b: Parameter) -> Bool { a < b }

    var memo: Tree = .init()

    func tarai(x: Int, y: Int, z: Int) -> Int {

      func tarai(x: Int, y: Int, z: Int) -> Int {
        let args = (x, y, z)
        if let result = memo[args] {
          return result
        }
        let r = body(x: x, y: y, z: z)
        memo[args] = r
        return r
      }

      func body(x: Int, y: Int, z: Int) -> Int {
        if x <= y {
          return y
        } else {
          return tarai(
            x: tarai(x: x - 1, y: z, z: z),
            y: tarai(x: y - 1, y: z, z: x),
            z: tarai(x: z - 1, y: x, z: y))
        }
      }

      return tarai(x: x, y: y, z: z)
    }

    func cachClear() {
      memo.clear()
    }

    func cacheInfo() -> [String:Any] {
      [:]
    }
  }
}
