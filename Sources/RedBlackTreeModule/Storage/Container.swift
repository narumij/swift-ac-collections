import Foundation

public
  struct Container: ScalarValueComparer
{

  public typealias _Key = Int
  public typealias Element = Int

  @usableFromInline
  var storage: Storage

  @usableFromInline
  typealias Storage = ___RedBlackTree.___Storage<Self, Int>

  @inlinable
  public
    init(minimumCapacity: Int)
  {
    storage = .create(withCapacity: minimumCapacity)
  }

  @inlinable
  public
    mutating func insert(_ p: Int)
  {
    ensureUniqueAndCapacity(minimumCapacity: storage.count + 1)
    _ = storage.__insert_unique(p)
  }

  @inlinable
  public
    mutating func remove(_ p: Int)
  {
    ensureUnique()
    _ = storage.___erase_unique(p)
  }

  @inlinable
  func lowerBound(_ __k: _Key) -> _NodePtr {
    storage.__lower_bound(__k, storage.__root(), .end)
  }

  @inlinable
  func upperBound(_ __k: _Key) -> _NodePtr {
    storage.__upper_bound(__k, storage.__root(), .end)
  }

  @inlinable
  mutating func
    ___erase(_ l: _NodePtr, _ r: _NodePtr, forEach action: (Element) throws -> Void) rethrows
  {
    try storage.___erase(l, r, action)
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

  @inlinable
  mutating func ensureUnique() {
    if !isKnownUniquelyReferenced(&storage) {
      storage = storage.copy(newCapacity: storage.header.capacity)
    }
  }

  @inlinable
  mutating func ensureUniqueAndCapacity(minimumCapacity: Int) {
    let shouldExpand = storage.header.capacity < minimumCapacity
    if shouldExpand || !isKnownUniquelyReferenced(&storage) {
      storage = storage.copy(newCapacity: recommendCapacity(minimumCapacity))
    }
  }

  @inlinable
  func recommendCapacity(_ minimumCapacity: Int) -> Int {
    var capacity = 256
    while capacity < minimumCapacity {
      capacity <<= 1
    }
    return capacity
  }
}
