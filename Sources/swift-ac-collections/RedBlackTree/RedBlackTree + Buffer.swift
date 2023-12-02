import Foundation

extension _RedBlackTree {
    
    @usableFromInline
    struct _BufferHeader {
        @inlinable @inline(__always)
        internal init(capacity: Int, count: Int, size: Int,__begin_node_: Int) {
            self.capacity = capacity
            self.count = count
            self.size = size
            self.__begin_node_ = __begin_node_
        }
        public let capacity: Int
        public var count: Int
        public var size: Int
        public var __begin_node_: Int
    }
    
    @usableFromInline
    class _Buffer: ManagedBuffer<_BufferHeader, _Node> {
        deinit {
            let count = count
            withUnsafeMutablePointers {
                (pointerToHeader, pointerToElements) -> Void in
                pointerToElements.deinitialize(count: count)
                pointerToHeader.deinitialize(count: 1)
            }
        }
        var count: Int { header.count }
    }
}
