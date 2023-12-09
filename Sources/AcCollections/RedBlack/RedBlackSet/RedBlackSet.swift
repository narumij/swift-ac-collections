import Foundation

struct RedBlackSet<Element: Comparable> {

    private var __tree = _RedBlackTree<Element, _red_brack_tree_comparable_compare<Element>>()
    
    var first: Element? { __tree.first }
    
    var last: Element? { __tree.last }

    mutating func insert(_ e: Element) {
        __tree.insert(e)
    }
    
    mutating func remove(_ e: Element) {
        __tree.remove(e)
    }
    
    func contains(_ e: Element) -> Bool {
        __tree.storage.__read {
            var __root = $0.__end_node.__left_
            let result = $0.__find_equal(&__root, e)
            return result.target?.__value_ == e
        }
    }
    
    var count: Int { __tree.count }
}

extension RedBlackSet {
    
    func prev(_ e: Element) -> Element {
        __tree.storage.__read {
            var __root = $0.__end_node.__left_
            let it = $0.__find_equal(&__root, e)
            return $0.__tree_prev_iter(it.target).__value_
        }
    }
    
    func next(_ e: Element) -> Element {
        __tree.storage.__read {
            var __root = $0.__end_node.__left_
            let it = $0.__find_equal(&__root, e)
            return $0.__tree_next_iter(it.target).__value_
        }
    }
}
