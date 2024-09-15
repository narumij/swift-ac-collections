import Foundation

protocol SequenceTree {
    associatedtype Element
    func value(_ p: BasePtr) -> Element
    func next(_ p: BasePtr) -> BasePtr
    func prev(_ p: BasePtr) -> BasePtr
    func begin() -> BasePtr
    func end() -> BasePtr
}

extension RedBlackTree: SequenceTree {
    
    func value(_ p: BasePtr) -> Element {
        if case .node(let int) = p {
            return buffer[int].__value_
        }
        fatalError()
    }
    
    func next(_ p: BasePtr) -> BasePtr {
        _update{ __unsafe_tree.__tree_next_iter(p.handlePtr($0.handle)).basePtr }
    }
    
    func prev(_ p: BasePtr) -> BasePtr {
        _update{ __unsafe_tree.__tree_prev_iter(p.handlePtr($0.handle)).basePtr }
    }
    
    func begin() -> BasePtr {
        header.begin_ptr
    }
    
    func end() -> BasePtr {
        .end
    }
}

struct BaseIterator<Tree>: Comparable, IteratorProtocol where Tree: SequenceTree {
    nonmutating func current() -> Tree.Element? {
        return __ptr_ != __tree_.end() ? __tree_.value(__ptr_) : nil
    }
    mutating func next() -> Tree.Element? {
        defer {
            if __ptr_ != __end_ {
                __ptr_ = __tree_.next(__ptr_)
            }
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
        fatalError("not implemented yet")
    }
}

#if true
protocol TreeTest: Sequence where Iterator == BaseIterator<Storage> {
    associatedtype Element
    associatedtype Storage: SequenceTree where Element == Storage.Element
    var storage: Storage { get }
}

extension TreeTest {
    
}

extension TreeTest {
    func makeIterator(_ __ptr_: BasePtr) -> Iterator {
        .init(__tree_: storage, __ptr_: __ptr_,  __begin: storage.begin(),__end_: storage.end())
    }
    func makeIterator() -> Iterator {
        makeIterator(storage.begin())
    }
}
#endif
