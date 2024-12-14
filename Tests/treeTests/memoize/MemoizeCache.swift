import RedBlackTreeModule

@usableFromInline
struct MemoizeCache1<A, B>
where A: Comparable, B: Comparable {
  @usableFromInline
  enum Key: RedBlackTree.KeyProtocol
  where A: Comparable {
    @inlinable
    static func value_comp(_ a: A, _ b: A) -> Bool {
      a < b
    }
  }
  @usableFromInline
  init(__memo: RedBlackTree.__MapBase<Key, B> = .init()) {
    self.__memo = __memo
  }
  @usableFromInline
  var __memo: RedBlackTree.__MapBase<Key, B> = .init()
  @inlinable
  subscript(a: A) -> B? {
    get { __memo[a] }
    mutating set { __memo[a] = newValue }
  }
}

@usableFromInline
struct MemoizeCache2<A, B, C>
where A: Comparable, B: Comparable {
  @usableFromInline
  enum Key: RedBlackTree.KeyProtocol
  where A: Comparable, B: Comparable {
    @inlinable
    static func value_comp(_ a: (A, B), _ b: (A, B)) -> Bool {
      a < b
    }
  }
  @usableFromInline
  init(__memo: RedBlackTree.__MapBase<Key, C> = .init()) {
    self.__memo = __memo
  }
  @usableFromInline
  var __memo: RedBlackTree.__MapBase<Key, C> = .init()
  @inlinable
  subscript(a: A, b: B) -> C? {
    get { __memo[(a, b)] }
    mutating set { __memo[(a, b)] = newValue }
  }
}

@usableFromInline
struct MemoizeCache3<A, B, C, D>
where A: Comparable, B: Comparable, C: Comparable {
  @usableFromInline
  enum Key: RedBlackTree.KeyProtocol
  where A: Comparable, B: Comparable, C: Comparable {
    @inlinable
    static func value_comp(_ a: (A, B, C), _ b: (A, B, C)) -> Bool {
      a < b
    }
  }
  @usableFromInline
  init(__memo: RedBlackTree.__MapBase<Key, D> = .init()) {
    self.__memo = __memo
  }
  @usableFromInline
  var __memo: RedBlackTree.__MapBase<Key, D> = .init()
  @inlinable
  subscript(a: A, b: B, c: C) -> D? {
    get { __memo[(a, b, c)] }
    mutating set { __memo[(a, b, c)] = newValue }
  }
}

@usableFromInline
struct MemoizeCache4<A, B, C, D, E>
where A: Comparable, B: Comparable, C: Comparable, D: Comparable {
  @usableFromInline
  enum Key: RedBlackTree.KeyProtocol
  where A: Comparable, B: Comparable, C: Comparable, D: Comparable {
    @inlinable
    static func value_comp(_ a: (A, B, C, D), _ b: (A, B, C, D)) -> Bool {
      a < b
    }
  }
  @usableFromInline
  init(__memo: RedBlackTree.__MapBase<Key, E> = .init()) {
    self.__memo = __memo
  }
  @usableFromInline
  var __memo: RedBlackTree.__MapBase<Key, E> = .init()
  @inlinable
  subscript(a: A, b: B, c: C, d: D) -> E? {
    get { __memo[(a, b, c, d)] }
    mutating set { __memo[(a, b, c, d)] = newValue }
  }
}
