import Foundation

extension _RedBlackTree {
    
    @usableFromInline
    struct _UnsafeHandle {
        
        @inlinable @inline(__always)
        init(_header: UnsafeMutablePointer<_BufferHeader>,
             storage: UnsafeMutablePointer<_Node>,
             storageManager: _StorageManger) {
            self._header = _header
            self._elements = storage
            self._storageManager = storageManager
        }
        
        public var value_comp: (Element,Element) -> Bool { _Container.value_comp }
        public var _header: UnsafeMutablePointer<_BufferHeader>
        public var _elements: UnsafeMutablePointer<_Node>
        public var _storageManager: _StorageManger
        
        public typealias _Buffer  = _RedBlackTree._Buffer
        public typealias _Storage = _RedBlackTree._Storage
    }
}


extension _RedBlackTree._UnsafeHandle {
    
    @usableFromInline
    struct _Pointer: _BufferPointer {
        public typealias Node = _RedBlackTree._Node
        public typealias _Pointee = _RedBlackTree._Node
        @inlinable @inline(__always)
        init(elements: UnsafeMutablePointer<Node>, offset: Int) {
            self.elements = elements
            self.offset = offset
        }
        public var elements: UnsafeMutablePointer<Node>
        public var offset: Int
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.offset == rhs.offset
        }
    }
    
    @usableFromInline
    struct _Reference {
        @inlinable @inline(__always)
        public init(ref target: _Pointer? = nil, _ member: _NodeKeyPath) {
            self.target = target
            self.member = member
        }
        public var target: _Pointer?
        public let member: _NodeKeyPath
        
        @inlinable
        public var reference: _Pointer? {
            @inline(__always) get { target?[member] }
            set { target?[member] = newValue }
        }
    }
    
    public func pointer(_ n: Int) -> _Pointer! {
        .init(elements: _elements, offset: n)
    }
    
    var __root: _Pointer! {
        @inline(__always) get { __end_node.__left_ }
        nonmutating set { __end_node.__raw_pointer.pointee.__left_ = newValue.offset }
    }
    
    var __begin_node: _Pointer! {
        @inline(__always) get { pointer(_header.pointee.__begin_node_) }
        nonmutating set { _header.pointee.__begin_node_ = newValue.offset }
    }

    var __end_node: _Pointer! {
        @inline(__always) get { pointer(0) }
        nonmutating set { }
    }
    
    func create() -> _Pointer! {
        let pos = _storageManager.create()!
        if pos == storageCount {
            (_elements + storageCount).initialize(to: .init())
            storageCount += 1
        }
        assert(_elements[pos].__parent_ == nil)
        assert(_elements[pos].__left_ == nil)
        assert(_elements[pos].__right_ == nil)
        assert(_elements[pos].__value_ == nil)
        return pointer(pos)
    }
    
    func destroy(_ p: _Pointer) {
#if DEBUG
        let p = p
        p.__value_ = nil
        p.__parent_ = nil
        p.__left_ = nil
        p.__right_ = nil
#endif
        _storageManager.delete(p.offset)
    }
    
    func newNode(_ e: Element) -> _Pointer! {
        let n = create()
        n?.__value_ = e
        return n
    }
    
    var storageCount: Int {
        get { _header.pointee.count }
        nonmutating set { _header.pointee.count = newValue }
    }
    
    var size: Int {
        get { _header.pointee.size }
        nonmutating set { _header.pointee.size = newValue }
    }
}

extension _RedBlackTree._UnsafeHandle {

    func insert(_ x: Element) {
        __insert_unique(x)
    }
    
    func erase(_ x: Element) where Element: Equatable {
        var __root = __end_node.__left_
        let __child = __find_equal(&__root, x)
        if let __child = __child.target, __child.__value_ == x {
            __remove_node_pointer(__child)
            destroy(__child)
        }
    }
    
    func isValid() -> Bool {
        func isValide(_ n: _Pointer!) -> Bool {
            func check(aNode n: _Pointer!) -> Bool {
                if n == nil { return true }
                guard let left = n?.__left_, let right = n?.__right_ else { return true }
                return value_comp(left.__value_!, right.__value_!)
            }
            if n == nil { return true }
            if !check(aNode: n) { return false }
            if !isValide(n.__left_) { return false }
            if !isValide(n.__right_) { return false }
            return true
        }
        return isValide(__root) && __tree_invariant(__root)
    }
}


extension _RedBlackTree._UnsafeHandle {

    public func moveElements(minimumCapacity: Int) -> _Storage {
        let count = _header.pointee.count
        let size = _header.pointee.size
        let __begin_node_ = _header.pointee.__begin_node_
        
        let object = _Buffer.create(
            minimumCapacity: minimumCapacity) {
                .init(capacity: $0.capacity, count: count, size: size, __begin_node_: __begin_node_)
            }
        
        let result = _Storage (
            _buffer: ManagedBufferPointer(unsafeBufferObject: object),
            storageManager: _storageManager)
        
        guard minimumCapacity > 0 else { return result }
        result._buffer.withUnsafeMutablePointerToElements { target in
            target.moveInitialize(from: _elements, count: count)
        }
        
        return result
    }
}
