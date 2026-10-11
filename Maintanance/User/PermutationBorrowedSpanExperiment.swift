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

  public init(_ n: Int) {
    _n = n
    payload = .allocate(capacity: n)
    payload.initialize(repeating: -1, count: n)
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
    if parent_or_size[a] < 0 {
      return a
    }
    parent_or_size[a] = _leader(parent_or_size[a])
    return parent_or_size[a]
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
}

// MARK: - Borrowed Next Permutations Experiment

/// Owns one mutable permutation buffer and lends each order as a temporary span.
/// The returned span cannot remain live across the next mutating call.
struct BorrowedNextPermutationsIterator<Element: Comparable>: ~Copyable {

  let elements: UnsafeMutablePointer<Element>
  let count: Int
  var initial = true
  var finished = false

  init(copying source: Span<Element>) {
    count = source.count
    elements = .allocate(capacity: count)
    for i in 0..<count {
      elements.advanced(by: i).initialize(to: source[i])
    }
  }

  deinit {
    elements.deinitialize(count: count)
    elements.deallocate()
  }

  @_lifetime(&self)
  mutating func next() -> Span<Element>? {
    if finished {
      return nil
    }

    if initial {
      initial = false
      return unsafe Span(_unsafeStart: elements, count: count)
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

    return unsafe Span(_unsafeStart: elements, count: count)
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
  var iterator = BorrowedNextPermutationsIterator(copying: useEdges.span)

  while let selected = iterator.next() {
    var uf = DSU(N)
    var costSum = 0
    var valid = true

    for i in 0..<M {
      guard selected[i] == 1 else {
        continue
      }

      let (u, v, cost) = (edges[i].first, edges[i].second, edges[i].third)

      if uf.same(u, v) {
        valid = false
        break
      }

      _ = uf.merge(u, v)
      costSum += cost
    }

    if valid {
      ans = min(ans, costSum % K)
    }
  }

  fastPrint(ans)
}

main()
