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
        __tree[e] != nil
    }
    
    var count: Int { __tree.count }
}
