import Foundation

public
struct Container: ScalarValueComparer {
  @usableFromInline
  typealias _Key = Int
  @usableFromInline
  typealias Element = Int
  @usableFromInline
  var storage: ___RedBlackTree.___Storage<Self, Int>
  
  @inlinable
  public
  init(minimumCapacity: Int) {
    storage = .create(withCapacity: minimumCapacity)
  }
  
  @inlinable
  public
  mutating func insert(_ p: Int) {
    if !isKnownUniquelyReferenced(&storage) {
      fatalError()
    }
    _ = storage.__insert_unique(p)
  }
}
