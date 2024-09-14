import Foundation

public struct RedBlackSet<Element: Comparable> {
    public init() { }

    private var __tree = _RedBlackTree<Element, _red_brack_tree_comparable_compare<Element>>()
    
    var first: Element? { __tree.first }
    
    var last: Element? { __tree.last }

    public mutating func insert(_ e: Element) {
        __tree.insert(e)
    }
    
    public mutating func remove(_ e: Element) {
        __tree.remove(e)
    }
    
    public func contains(_ e: Element) -> Bool {
        __tree.storage.__read {
            var __root = $0.__end_node.__left_
            let result = $0.__find_equal(&__root, e)
            return result.target?.__value_ == e
        }
    }
    
    public var count: Int { __tree.count }
}

extension RedBlackSet {
    
    public func prev(_ e: Element) -> Element? {
        __tree.storage.__read {
            let __root = $0.__end_node.__left_
            let p = $0.__lower_bound(e, __root, __root)
            return $0.__tree_prev_iter(p)?.__value_
        }
    }
    
    public func next(_ e: Element) -> Element? {
        __tree.storage.__read {
            let __root = $0.__end_node.__left_
            let p = $0.__upper_bound(e, __root, __root)
            guard let value = p?.__value_ else { return nil }
            return value > e ? value : nil
        }
    }
}
