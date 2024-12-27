import Foundation

public
  struct Container: ScalarValueComparer
{

  public typealias _Key = Int
  public typealias Element = Int

  @usableFromInline
  var tree: Tree

  @usableFromInline
  typealias Tree = ___RedBlackTree.___Buffer<Self, Int>

  @inlinable
  public
    init(minimumCapacity: Int)
  {
    tree = .create(withCapacity: minimumCapacity)
  }

  @inlinable
  public
    mutating func insert(_ p: Int)
  {
    ensureUniqueAndCapacity(minimumCapacity: tree.count + 1)
    _ = tree.__insert_unique(p)
  }

  @inlinable
  public
    mutating func remove(_ p: Int)
  {
    ensureUnique()
    _ = tree.___erase_unique(p)
  }

  @inlinable
  func lowerBound(_ __k: _Key) -> _NodePtr {
    tree.__lower_bound(__k, tree.__root(), .end)
  }

  @inlinable
  func upperBound(_ __k: _Key) -> _NodePtr {
    tree.__upper_bound(__k, tree.__root(), .end)
  }

  @inlinable
  mutating func
    ___erase(_ l: _NodePtr, _ r: _NodePtr, forEach action: (Element) throws -> Void) rethrows
  {
    ensureUnique()
    try tree.___erase(l, r, action)
  }

  @inlinable
  public mutating func removeAndForEach(
    _ range: Range<Element>,
    _ action: (Element) throws -> Void
  ) rethrows {
    try ___erase(
      lowerBound(range.lowerBound),
      upperBound(range.upperBound),
      forEach: action)
  }
}

extension Container {

  @inlinable
  mutating func ensureUnique() {
    if !isKnownUniquelyReferenced(&tree) {
      tree = tree.copy(newCapacity: tree.header.capacity)
    }
  }

  @inlinable
  mutating func ensureUniqueAndCapacity(minimumCapacity: Int) {
    let shouldExpand = tree.header.capacity < minimumCapacity
    if shouldExpand || !isKnownUniquelyReferenced(&tree) {
      tree = tree.copy(newCapacity: _growCapacity(to: minimumCapacity, linearly: false))
    }
  }

  @inlinable
  @inline(__always)
  internal static var growthFactor: Double { 1.75 }

  @inlinable
  var capacity: Int { tree.header.capacity }

  @usableFromInline
  internal func _growCapacity(
    to minimumCapacity: Int,
    linearly: Bool
  ) -> Int {
    if linearly { return Swift.max(capacity, minimumCapacity) }
    return Swift.max(
      Int((Self.growthFactor * Double(capacity)).rounded(.up)),
      minimumCapacity)
  }
}


