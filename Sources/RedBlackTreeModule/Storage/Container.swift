import Foundation

public
struct Container: ScalarValueComparer {
  @usableFromInline
  typealias _Key = Int
  @usableFromInline
  typealias Element = Int
  @usableFromInline
  var storage: Storage

  @usableFromInline
  typealias Storage = ___RedBlackTree.___Storage<Self, Int>

  @inlinable
  public
  init(minimumCapacity: Int) {
    storage = .create(withCapacity: minimumCapacity)
  }
  
  @inlinable
  public
  mutating func insert(_ p: Int) {
    ensureUniqueAndCapacity(minimumCapacity: storage.count + 1)
    _ = storage.__insert_unique(p)
  }
  
  @inlinable
  public
  mutating func erase(_ p: Int) {
    ensureUniqueAndCapacity(minimumCapacity: storage.count + 1)
    _ = storage.___erase_unique(p)
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
