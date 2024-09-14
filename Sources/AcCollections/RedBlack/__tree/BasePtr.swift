import Foundation

enum BasePtr: Equatable {
    case none
    case end
    case node(Int)
}

extension BasePtr: ExpressibleByNilLiteral {
    init(nilLiteral: ()) {
        self = .none
    }
}

extension BasePtr: ExpressibleByIntegerLiteral {
    init(integerLiteral value: Int) {
        self = .node(value)
    }
}

extension BasePtr {
    func handlePtr<Handle>(_ handle: Handle) -> HandlePtr<Handle> {
        switch self {
        case .node(let offset):
            return .node(handle, offset)
        case .end:
            return .end(handle)
        case .none:
            return .none
        }
    }
}

extension BasePtr {
    var index: Int? {
        switch self {
        case .node(let offset):
            return offset
        case .none:
            return nil
        case .end:
            return nil
        }
    }
}

extension BasePtr: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .none:
            return ".none"
        case .end:
            return ".end"
        case .node(let int):
            return ".node(\(int))"
        }
    }
}

protocol SequenceTree {
    associatedtype Element
    func value(_ p: BasePtr) -> Element
    func next(_ p: BasePtr) -> BasePtr
    func prev(_ p: BasePtr) -> BasePtr
    func begin() -> BasePtr
    func end() -> BasePtr
}

struct BaseIterator<Tree>: Comparable, IteratorProtocol where Tree: SequenceTree {
    nonmutating func current() -> Tree.Element? {
        return __ptr_ != __tree_.end() ? __tree_.value(__ptr_) : nil
    }
    mutating func next() -> Tree.Element? {
        if __ptr_ != __end_ {
            __ptr_ = __tree_.next(__ptr_)
        }
        return current()
    }
    mutating func prev() -> Tree.Element? {
        if __ptr_ != __begin {
            __ptr_ = __tree_.prev(__ptr_)
        }
        return current()
    }
    var __tree_: Tree
    var __ptr_: BasePtr
    var __begin: BasePtr
    var __end_: BasePtr
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.__ptr_ == rhs.__ptr_
    }
    static func < (lhs: Self, rhs: Self) -> Bool {
        fatalError()
    }
}

protocol TreeTest: Sequence where Iterator == BaseIterator<Storage> {
    associatedtype Element
    associatedtype Storage: SequenceTree where Element == Storage.Element
    var storage: Storage { get }
}

extension TreeTest {
    func makeIterator(_ __ptr_: BasePtr) -> Iterator {
        .init(__tree_: storage, __ptr_: __ptr_,  __begin: storage.begin(),__end_: storage.end())
    }
    func makeIterator() -> Iterator {
        makeIterator(storage.begin())
    }
}

protocol TreeTest2: TreeTest, Collection where Index == BaseIterator<Storage> { }

extension TreeTest2 {
    
    func index(after i: Index) -> Index {
        var i = i
        _ = i.next()
        return i
    }
    
    subscript(position: Index) -> Element {
        get {
            return position.current()!
        }
    }
    
    var startIndex: Index {
        makeIterator(storage.begin())
    }
    
    var endIndex: Index {
        makeIterator(storage.end())
    }
}

protocol TreeTest3: TreeTest2, RandomAccessCollection { }

extension TreeTest3 {
    
    func index(before i: Index) -> Index {
        var i = i
        _ = i.prev()
        return i
    }
}
