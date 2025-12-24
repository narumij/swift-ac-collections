//
//  ___StorageProvider.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/12/24.
//

@usableFromInline
protocol ___StorageProvider: ___RedBlackTree___
where
  Base: ___TreeBase,
  Storage == ___Storage<Base>,
  Tree == ___Tree<Base>,
  _Value == Tree._Value
{
  associatedtype Storage
  associatedtype _Value
  var _storage: Storage { get set }
}

extension ___StorageProvider {

  @inlinable
  var __tree_: Tree {
    @inline(__always) _read {
      yield _storage.tree
    }
  }

  @inlinable
  @inline(__always)
  var _start: _NodePtr {
    __tree_.__begin_node_
  }

  @inlinable
  @inline(__always)
  var _end: _NodePtr {
    __tree_.__end_node()
  }

  @inlinable
  @inline(__always)
  var ___count: Int {
    __tree_.count
  }

  @inlinable
  @inline(__always)
  var ___capacity: Int {
    __tree_.___capacity
  }
}

// MARK: - Remove

extension ___StorageProvider {

  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func ___remove(at ptr: _NodePtr) -> _Value? {
    guard !__tree_.___is_subscript_null(ptr) else {
      return nil
    }
    let e = __tree_[ptr]
    _ = __tree_.erase(ptr)
    return e
  }

  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func ___remove(from: _NodePtr, to: _NodePtr) -> _NodePtr {
    guard !__tree_.___is_end(from) else {
      return .end
    }
    __tree_.___ensureValid(begin: from, end: to)
    return __tree_.erase(from, to)
  }

  @inlinable
  @inline(__always)
  public mutating func ___remove(
    from: _NodePtr, to: _NodePtr, forEach action: (_Value) throws -> Void
  )
    rethrows
  {
    guard !__tree_.___is_end(from) else {
      return
    }
    __tree_.___ensureValid(begin: from, end: to)
    return try __tree_.___erase(from, to, action)
  }

  @inlinable
  @inline(__always)
  public mutating func ___remove<Result>(
    from: _NodePtr, to: _NodePtr,
    into initialResult: Result,
    _ updateAccumulatingResult: (inout Result, _Value) throws -> Void
  ) rethrows -> Result {
    guard !__tree_.___is_end(from) else {
      return initialResult
    }
    __tree_.___ensureValid(begin: from, end: to)
    return try __tree_.___erase(from, to, into: initialResult, updateAccumulatingResult)
  }

  @inlinable
  @inline(__always)
  public mutating func ___remove<Result>(
    from: _NodePtr, to: _NodePtr,
    _ initialResult: Result,
    _ nextPartialResult: (Result, _Value) throws -> Result
  ) rethrows -> Result {
    guard !__tree_.___is_end(from) else {
      return initialResult
    }
    __tree_.___ensureValid(begin: from, end: to)
    return try __tree_.___erase(from, to, initialResult, nextPartialResult)
  }
}

extension ___StorageProvider {

  @inlinable
  @inline(__always)
  mutating func ___removeAll(keepingCapacity keepCapacity: Bool = false) {

    if keepCapacity {
      __tree_.__eraseAll()
    } else {
      _storage = .create(withCapacity: 0)
    }
  }
}
