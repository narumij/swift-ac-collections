import Foundation

extension _RedBlackTree {
    
    @usableFromInline
    struct _Node: __tree_node {
        @inlinable @inline(__always)
        init() { __is_black_ = false }
        public var __value_: Element?
        public var __parent_: Int?
        public var __left_: Int?
        public var __right_: Int?
        public var __is_black_: Bool
    }
}

extension _RedBlackTree._Node: Equatable where Element: Equatable { }

@usableFromInline
protocol __tree_end_node {
    var __left_: Int? { get set }
}

@usableFromInline
protocol __tree_node_base: __tree_end_node {
    var __parent_: Int? { get set }
    var __right_: Int? { get set }
    var __is_black_: Bool { get set }
}

@usableFromInline
protocol __tree_node: __tree_node_base {
    associatedtype Element
    var __value_: Element? { get set }
}

@usableFromInline
enum _NodeKeyPath {
    case __self_
    case __left_
    case __right_
}

extension _BufferPointer where _Pointee: __tree_node {
    
    @inlinable @inline(__always)
    func pointer(_ n: Int?) -> Self? {
        guard let n else { return nil }
        return .init(elements: elements, offset: n)
    }
    @inlinable var __is_black_: Bool {
        @inline(__always) get { __raw_pointer.pointee.__is_black_ }
        nonmutating set { __raw_pointer.pointee.__is_black_ = newValue }
    }
    @inlinable var __parent_: Self! {
        @inline(__always) get { pointer(__raw_pointer.pointee.__parent_) }
        nonmutating set { __raw_pointer.pointee.__parent_ = newValue?.offset }
    }
    @inlinable var __left_: Self! {
        @inline(__always) get { pointer(__raw_pointer.pointee.__left_) }
        nonmutating set { __raw_pointer.pointee.__left_ = newValue?.offset }
    }
    @inlinable var __right_: Self! {
        @inline(__always) get { pointer(__raw_pointer.pointee.__right_) }
        nonmutating set { __raw_pointer.pointee.__right_ = newValue?.offset }
    }
    @inlinable var __value_: _Pointee.Element! {
        @inline(__always) get { __raw_pointer.pointee.__value_ }
        nonmutating set { __raw_pointer.pointee.__value_ = newValue }
    }
    
    @inlinable subscript(key: _NodeKeyPath) -> Self! {
        @inline(__always) get {
            switch key {
            case .__self_: return __parent_
            case .__left_  : return __left_
            case .__right_ : return __right_
            }
        }
        set {
            switch key {
            case .__self_: self = newValue
            case .__left_  : __left_   = newValue
            case .__right_ : __right_  = newValue
            }
        }
    }
}
