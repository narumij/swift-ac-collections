import Foundation
import Collections

extension _RedBlackTree {
    
    @usableFromInline
    struct _Storage {
        
        public typealias _BufferPointer = ManagedBufferPointer<_BufferHeader, _Node>
        public var _buffer: _BufferPointer
        public var _manager: _StorageManger
        
        @inlinable @inline(__always)
        init(_buffer: _BufferPointer, storageManager: _StorageManger) {
            self._buffer = _buffer
            self._manager = storageManager
        }
        
        @inlinable @inline(__always)
        init(_ object: _Buffer, storageManager: _StorageManger) {
            self.init(_buffer: _BufferPointer(unsafeBufferObject: object), storageManager: storageManager)
        }
        
        @inlinable @inline(__always)
        init(minimumCapacity: Int) {
            let object = _Buffer.create(minimumCapacity: minimumCapacity) {
                _BufferHeader(capacity: $0.capacity, count: 0, size: 0, __begin_node_: 0) }
            self.init(_buffer: _BufferPointer(unsafeBufferObject: object), storageManager: .init())
            _buffer.withUnsafeMutablePointerToElements { elements in
                elements.initialize(to: .init())
            }
            count += 1
        }
        
        @inlinable @inline(__always)
        public var capacity: Int {
            _buffer.header.capacity
        }
        
        @inlinable
        public var count: Int {
            @inline(__always) get { _buffer.header.count }
            set { _buffer.header.count = newValue }
        }
        
        public var size: Int {
            _buffer.header.size
        }
        
        @inlinable @inline(__always)
        public mutating func ensureCapacity(count n: Int) -> Self {
            guard _manager.reserved.count < n else { return self }
            // シーケンスからの要素追加を実装する際には不十分なので注意が必要。
            return ensureCapacity(minimumCapacity: capacity * 2)
        }
        
        @inlinable @inline(__always)
        public mutating func ensureCapacity(minimumCapacity: Int) -> Self {
            assert(minimumCapacity >= 1)
            guard capacity < minimumCapacity else { return self }
            _manager.reserve(contentsOf: count..<minimumCapacity)
            return __update{ $0.moveElements(minimumCapacity: minimumCapacity ) }
        }
        
        @inlinable @inline(__always)
        public func __read<R>(_ body: (_UnsafeHandle) -> R) -> R {
            _buffer.withUnsafeMutablePointers{ _header, _elements in
                let handle = _UnsafeHandle(_header: _header, storage: _elements, storageManager: _manager)
                return body(handle)
            }
        }
        
        @inlinable @inline(__always)
        public mutating func __update<R>(_ body: (_UnsafeHandle) -> R) -> R {
            _buffer.withUnsafeMutablePointers{ _header, _elements in
                let handle = _UnsafeHandle(_header: _header, storage: _elements, storageManager: _manager)
                return body(handle)
            }
        }
    }
}

extension _RedBlackTree._Storage {
    
    var array: [_RedBlackTree._Node] {
        (0..<count).map{ self[$0] }
    }
    
    subscript(index: Int) -> _RedBlackTree._Node {
        get { _buffer.withUnsafeMutablePointerToElements{ $0[index] } }
        nonmutating set { _buffer.withUnsafeMutablePointerToElements{ $0[index] = newValue } }
    }

    func isValid() -> Bool {
        __read { $0.isValid() }
    }
}
