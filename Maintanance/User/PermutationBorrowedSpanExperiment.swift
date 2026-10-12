import AcFoundation
import Convenience
import IOUtil
import Pack

// MARK: - DSU

@frozen
public struct DSU: ~Copyable {

  @usableFromInline
  let payload: UnsafeMutablePointer<Int>

  @usableFromInline
  let _n: Int

  @inlinable
  public init(_ n: Int) {
    _n = n
    payload = .allocate(capacity: n)
    payload.initialize(repeating: -1, count: n)
  }

  @inlinable
  public mutating func reset() {
    parent_or_size.update(repeating: -1)
  }

  deinit {
    payload.deinitialize(count: _n)
    payload.deallocate()
  }

  @inlinable
  var parent_or_size: UnsafeMutableBufferPointer<Int> {
    .init(start: payload, count: _n)
  }

  @inlinable
  public mutating func leader(_ a: Int) -> Int {
    assert(0 <= a && a < _n)
    return _leader(a)
  }

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

  @inlinable
  public mutating func same(_ a: Int, _ b: Int) -> Bool {
    leader(a) == leader(b)
  }

  @inlinable
  public mutating func merge(_ a: Int, _ b: Int) -> Int {
    var (x, y) = (leader(a), leader(b))

    if x == y {
      return x
    }

    if -parent_or_size[x] < -parent_or_size[y] {
      swap(&x, &y)
    }

    parent_or_size[x] += parent_or_size[y]
    parent_or_size[y] = x

    return x
  }

  @inlinable
  public mutating func unite(_ a: Int, _ b: Int) -> Bool {
    var (x, y) = (leader(a), leader(b))

    if x == y {
      return false
    }

    if -parent_or_size[x] < -parent_or_size[y] {
      swap(&x, &y)
    }

    parent_or_size[x] += parent_or_size[y]
    parent_or_size[y] = x
    return true
  }
}

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

  @inlinable // ちょっと試し
//  @inline(never)
  func closeCurrentView() {
    withUnsafeMutablePointerToHeader { generation in
      precondition(generation.pointee != .max, "Permutation view generation exhausted")
      generation.pointee += 1
    }
  }

  @inlinable
  func isClosed(generation: UInt) -> Bool {
    self.generation != generation
  }

  @inlinable
  static func make() -> GateKeeper {
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
    gateKeeper = GateKeeper.make()

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
  @inline(__always)
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
      count: count)
  }

  @usableFromInline
  struct Permutation: RandomAccessCollection {

    @inlinable
    init(elements: UnsafeMutablePointer<Element>, count: Int) {
      self.elements = elements
      self.count = count
    }

    @usableFromInline typealias Index = Int

    @usableFromInline let elements: UnsafeMutablePointer<Element>
    @usableFromInline let count: Int

    @inlinable
    var startIndex: Int {
      return 0
    }

    @inlinable
    var endIndex: Int {
      return count
    }

    @inlinable
    subscript(position: Int) -> Element {
      precondition(position >= 0 && position < count)
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
      guard selected.elements[i] == 1 else {
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
