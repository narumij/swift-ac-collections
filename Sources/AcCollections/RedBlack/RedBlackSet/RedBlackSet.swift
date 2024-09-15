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
    mutating func insert(_ e: Element) {
        storage.ensureReserved(count: 1)
        _ = storage._update { $0.__insert_unique(e) }
    }
    mutating func remove(_ e: Element) {
        _ = storage._update { $0.__erase_unique(e) }
    }
    func contains(_ element: Element) -> Bool {
        let f = storage._update{ $0.find(element) }.basePtr
        if f == .none { return false }
        if f == .end { return false }
        return true
    }
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
