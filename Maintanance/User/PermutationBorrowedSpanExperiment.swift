// https://atcoder.jp/contests/abc328/submissions/79989800

import AcFoundation
import Convenience
import IOUtil
import Pack

// MARK: - DSU

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

// MARK: - Runtime-checked Next Permutations

@usableFromInline
final class GateKeeper: ManagedBuffer<UInt, Void> {

  // TODO: 終了処理がない

  @inlinable
  var generation: UInt {
    unsafeAddress {
      UnsafePointer(withUnsafeMutablePointerToHeader { $0 })
    }
    unsafeMutableAddress {
      withUnsafeMutablePointerToHeader { $0 }
    }
  }

  @usableFromInline
  @inline(never)
  internal func closeCurrentView() {
    withUnsafeMutablePointerToHeader { generation in
      precondition(generation.pointee != .max, "Permutation view generation exhausted")
      generation.pointee += 1
    }
  }

  @inlinable
  func isClosed(generation: UInt) -> Bool {
    self.generation != generation
  }

  @usableFromInline
  internal static func create() -> GateKeeper {
    let storage = GateKeeper.create(minimumCapacity: 0) { _ in 0 }
    return unsafeDowncast(storage, to: GateKeeper.self)
  }
}

extension Collection where Element: Comparable {

  @inlinable
  func nextPermutations() -> NextPermutations<Element> {
    .init(copying: self)
  }
}

@usableFromInline
struct NextPermutations<Element: Comparable>: ~Copyable {

  @usableFromInline let elements: UnsafeMutablePointer<Element>
  @usableFromInline let count: Int
  @usableFromInline let gateKeeper: GateKeeper
  @usableFromInline var initial = true
  @usableFromInline var finished = false

  @inlinable
  init<Base: Collection>(copying source: Base) where Base.Element == Element {
    count = source.count
    elements = .allocate(capacity: max(count, 1))
    gateKeeper = GateKeeper.create()

    var destination = elements
    for element in source {
      destination.initialize(to: element)
      destination += 1
    }
  }

  deinit {
    gateKeeper.closeCurrentView()
    elements.deinitialize(count: count)
    elements.deallocate()
  }

  @inlinable
  mutating func next() -> Permutation? {
    gateKeeper.closeCurrentView()

    if finished {
      return nil
    }

    if initial {
      initial = false
      return makePermutation()
    }

    guard count >= 2 else {
      finished = true
      return nil
    }

    var i = count - 2
    while elements[i] >= elements[i + 1] {
      if i == 0 {
        finished = true
        return nil
      }
      i -= 1
    }

    var j = count - 1
    while elements[j] <= elements[i] {
      j -= 1
    }

    let buffer = UnsafeMutableBufferPointer(start: elements, count: count)
    buffer.swapAt(i, j)

    var lower = i + 1
    var upper = count - 1
    while lower < upper {
      buffer.swapAt(lower, upper)
      lower += 1
      upper -= 1
    }

    return makePermutation()
  }

  @inlinable
  mutating func makePermutation() -> Permutation {
    Permutation(
      elements: elements,
      count: count,
      gateKeeper: gateKeeper,
      generation: gateKeeper.generation)
  }

  @usableFromInline
  struct Permutation: RandomAccessCollection {

    @inlinable
    init(
      elements: UnsafeMutablePointer<Element>,
      count: Int,
      gateKeeper: GateKeeper,
      generation: UInt
    ) {
      self.elements = elements
      self._count = count
      self.gateKeeper = gateKeeper
      self.generation = generation
    }

    @usableFromInline typealias Index = Int

    @usableFromInline let elements: UnsafeMutablePointer<Element>
    @usableFromInline let _count: Int
    @usableFromInline let gateKeeper: GateKeeper
    @usableFromInline let generation: UInt

    @inlinable
    var startIndex: Int {
      precondition(!gateKeeper.isClosed(generation: generation), "Permutation view is no longer valid")
      return 0
    }

    @inlinable
    var endIndex: Int {
      precondition(!gateKeeper.isClosed(generation: generation), "Permutation view is no longer valid")
      return _count
    }

    @inlinable
    subscript(position: Int) -> Element {
      precondition(!gateKeeper.isClosed(generation: generation), "Permutation view is no longer valid")
      precondition(position >= 0 && position < _count, "Index out of range")
      return elements[position]
    }

  }
}

// MARK: - Main

func main() {

  let N = Int.stdin
  let M = Int.stdin
  let K = Int.stdin
  let edges: [Pack3<Int, Int, Int>] = M.rep {
    .init(.stdin - 1, .stdin - 1, .stdin)
  }

  var useEdges = [Int](repeating: 0, count: M)

  for i in (M - N + 1)..<M {
    useEdges[i] = 1
  }

  var ans = K
  var iterator = useEdges.nextPermutations()
  var uf = DSU(N)

  while let selected = iterator.next() {
    uf.reset()
    var costSum = 0
    var valid = true

    for i in 0..<M {
      guard selected[i] == 1 else {
        continue
      }

      let (u, v, cost) = (edges[i].first, edges[i].second, edges[i].third)

      if !uf.unite(u, v) {
        valid = false
        break
      }
      costSum += cost
    }

    if valid {
      ans = min(ans, costSum % K)
    }
  }

  fastPrint(ans)
}

main()
