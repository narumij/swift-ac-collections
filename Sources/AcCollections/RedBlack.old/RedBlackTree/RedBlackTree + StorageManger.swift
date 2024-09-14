import Foundation
import Collections

extension _RedBlackTree {
    
    @usableFromInline
    final class _StorageManger {
        @inlinable @inline(__always)
        init(reserved: Deque<Int> = [], count: Int = 0) {
            self.reserved = reserved
        }
        // TODO: AtCoderがswift-collections 1.1対応になったら、Heapを試すこと。
        public  var reserved: Deque<Int> = []
        @inlinable @inline(__always)
        public func create() -> Int? {
            reserved.popFirst()
        }
        @inlinable @inline(__always)
        public func delete(_ newElement: Int) {
            reserved.prepend(newElement)
        }
        @inlinable @inline(__always)
        public func reserve<C: Collection>(contentsOf newElements: C) where C.Element == Int {
            reserved.append(contentsOf: newElements)
        }
    }
}
