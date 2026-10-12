/// Implement (union by size) + (path compression)
/// Reference:
/// Zvi Galil and Giuseppe F. Italiano,
/// Data structures and algorithms for disjoint set union problems
@frozen
public struct DSU: ~Copyable {

  @usableFromInline let payload: UnsafeMutablePointer<Int>
  @usableFromInline let _n: Int

  deinit {
    payload.deinitialize(count: _n)
    payload.deallocate()
  }
}

extension DSU {

  @inlinable
  var parent_or_size: UnsafeMutableBufferPointer<Int> {
    .init(start: payload, count: _n)
  }
}

extension DSU {

  public init() {
    self.init(0)
  }

  public init(_ n: Int) {
    _n = n
    payload = .allocate(capacity: n)
    payload.initialize(repeating: -1, count: n)
  }
}

extension DSU {

  @inlinable
  public mutating func merge(_ a: Int, _ b: Int) -> Int {
    assert(0 <= a && a < _n)
    assert(0 <= b && b < _n)
    var (x, y) = (leader(a), leader(b))
    if x == y { return x }
    if -parent_or_size[x] < -parent_or_size[y] { swap(&x, &y) }
    parent_or_size[x] += parent_or_size[y]
    parent_or_size[y] = x
    return x
  }

  @inlinable
  public mutating func unite(_ a: Int, _ b: Int) -> Bool {
    assert(0 <= a && a < _n)
    assert(0 <= b && b < _n)
    var (x, y) = (leader(a), leader(b))
    if x == y { return false }
    if -parent_or_size[x] < -parent_or_size[y] { swap(&x, &y) }
    parent_or_size[x] += parent_or_size[y]
    parent_or_size[y] = x
    return true
  }

  @inlinable
  public mutating func same(_ a: Int, _ b: Int) -> Bool {
    assert(0 <= a && a < _n)
    assert(0 <= b && b < _n)
    return leader(a) == leader(b)
  }

  @inlinable
  public mutating func leader(_ a: Int) -> Int {
    assert(0 <= a && a < _n)
    return _leader(a)
  }

  @inlinable
  public mutating func size(_ a: Int) -> Int {
    assert(0 <= a && a < _n)
    return -parent_or_size[leader(a)]
  }

  @inlinable
  public mutating func groups() -> [[Int]] {
    var leader_buf = [Int](repeating: -1, count: _n)
    var group_size = [Int](repeating: -1, count: _n)
    for i in 0..<_n {
      leader_buf[i] = leader(i)
      group_size[leader_buf[i]] += 1
    }
    var result: [[Int]] = [[Int]](repeating: [], count: _n)
    for i in 0..<_n {
      result[i].reserveCapacity(group_size[i])
    }
    for i in 0..<_n {
      result[leader_buf[i]].append(i)
    }
    result.removeAll { $0.isEmpty }
    return result
  }
}

extension DSU {

  @inlinable
  mutating func _leader(_ a: Int) -> Int {
    var current = a
    while parent_or_size[current] >= 0 {
      let parent = parent_or_size[current]
      if parent_or_size[parent] >= 0 {
        parent_or_size[current] = parent_or_size[parent]
      }
      current = parent
    }
    return current
  }
}

extension DSU {

  @inlinable
  internal init(other: borrowing Self) {
    payload = UnsafeMutablePointer<Int>.allocate(capacity: other._n)
    payload.initialize(from: other.payload, count: other._n)
    _n = other._n
  }

  @inlinable
  public func clone() -> Self {
    return .init(other: self)
  }
}

extension DSU {

  @inlinable
  public mutating func reset() {
    parent_or_size.update(repeating: -1)
  }
}

extension DSU: @unchecked Sendable {}
