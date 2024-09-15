//
//  File.swift
//  swift-ac-collections
//
//  Created by narumij on 2024/09/14.
//

import Foundation

struct RedBlackSet<Element> where Element: Comparable {
    typealias Storage = RedBlackTree<TreeNodeAllocator, StandardComparer<Element>, Element>
    let storage: Storage = .init()
}

extension RedBlackSet: Sequence {
    func makeIterator(_ __ptr_: BasePtr) -> Iterator {
        .init(__tree_: storage, __ptr_: __ptr_,  __begin: storage.begin(),__end_: storage.end())
    }
    func makeIterator() -> Iterator {
        makeIterator(storage.begin())
    }
    typealias Iterator = BaseIterator<Storage>
    typealias Index = BaseIterator<Storage>
}

extension RedBlackSet {
    init(minimumCapacity: Int) {
        self.init()
        storage.ensureReserved(count: minimumCapacity)
    }
    init<Source>(_ sequence: Source) where Element == Source.Element, Source : Sequence {
        self.init()
        for s in sequence {
            insert(s)
        }
    }
}

extension RedBlackSet {
    var isEmpty: Bool { count == 0 }
    var count: Int { storage.size }
    var capacity: Int { storage.capacity }
}

extension RedBlackSet {
    func contains(_ element: Element) -> Bool {
        storage._update{ $0.find(element) }.basePtr.isNode
    }
}

extension RedBlackSet {
    @discardableResult
    mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element) {
        storage.ensureReserved(count: 1)
        return storage._update {
            let (__r, __inserted) = $0.__insert_unique(newMember)
            return (inserted: __inserted, memberAfterInsert: __r.referencee.__value_)
        }
    }
    @discardableResult
    mutating func update(with newMember: Element) -> Element? {
        let result = insert(newMember)
        return result.inserted ? newMember : nil
    }
    mutating func reserveCapacity(_ minimumCapacity: Int) {
        let count = Swift.max(0, minimumCapacity - storage.size)
        storage.ensureReserved(count: count)
        assert(capacity >= minimumCapacity)
    }
}

extension RedBlackSet {
    
    @discardableResult
    mutating func remove(_ member: Element) -> Element? {
        let result = storage._update { $0.__erase_unique(member) }
        return result == 0 ? nil : member
    }
    
    @discardableResult
    mutating func removeFirst() -> Element {
        storage._update {
            let element = $0.__begin_node.__value_
            _ = $0.__remove_node_pointer($0.__begin_node)
            return element
        }
    }
    
    @discardableResult
    mutating func remove(at position: Index) -> Element {
        let current = position.current()
        _ = storage._update {
            $0.__remove_node_pointer(position.__ptr_.handlePtr($0.handle))
        }
        return current!
    }
    
    mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        storage.removeAll(keepingCapacity: keepCapacity)
    }
}

extension RedBlackSet: Equatable {
    static func == (lhs: RedBlackSet<Element>, rhs: RedBlackSet<Element>) -> Bool {
        
        if lhs.storage.header != rhs.storage.header {
            return false
        }
        
        var l = lhs.makeIterator()
        var r = rhs.makeIterator()
        
        while let ll = l.next(),
              let rr = r.next(),
              ll == rr { }
        
        return l.__ptr_ == .end && r.__ptr_ == .end
    }
#if false
    static func == <S>(lhs: RedBlackSet<Element>, rhs: S) -> Bool where S: Sequence, S.Element == Self.Element {
        
        var l = lhs.makeIterator()
        var r = rhs.makeIterator()
        
        while let ll = l.next(),
              let rr = r.next(),
              ll == rr { }
        
        return l.__ptr_ == .end && r.next() == nil
    }

    static func == <S>(lhs: S, rhs: RedBlackSet<Element>) -> Bool where S: Sequence, S.Element == Self.Element {
        return rhs == lhs
    }
#endif
}

extension RedBlackSet {
    func lower_bound(_ __v: Element) -> Index {
        let __lower_bound = storage._update {
            $0.__lower_bound(__v, $0.__root, $0.__none()).basePtr
        }
        return makeIterator(__lower_bound)
    }
    func upper_bound(_ __v: Element) -> Index {
        let __upper_bound = storage._update {
            $0.__upper_bound(__v, $0.__root, $0.__none()).basePtr
        }
        return makeIterator(__upper_bound)
    }
}

extension RedBlackSet {
    
    @warn_unqualified_access
    func min() -> Self.Element? {
        if isEmpty { return nil }
        return storage._update {
            $0.__begin_node.__value_
        }
    }
    
    @warn_unqualified_access
    func max() -> Self.Element? {
        if isEmpty { return nil }
        return storage._update {
            Storage.__unsafe_tree.__tree_max($0.__root).__value_
        }
    }
}

extension RedBlackSet {
    var first: Element? {
        if isEmpty { return nil }
        return storage._update {
            $0.__begin_node.__value_
        }
    }
    var last: Element? {
        if isEmpty { return nil }
        return storage._update {
            Storage.__unsafe_tree.__tree_max($0.__root).__value_
        }
    }
}

#if false
extension RedBlackSet: Collection
{
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

    typealias Index = BaseIterator<Storage>
}
#endif
