import Foundation

struct RedBlackDictionary<Key: Comparable, Value> {
    
    struct KeyValue: Comparable, __red_black_tree_compare {
        var key: Key
        var value: Value?
        static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.key < rhs.key
        }
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.key == rhs.key
        }
        typealias Element = Self
    }
    
    private var __tree = _RedBlackTree<KeyValue, KeyValue>()
    
    subscript(key: Key) -> Value? {
        get { __tree[.init(key: key)]?.value }
        set { __tree.insert(.init(key: key, value: newValue)) }
    }
    
    public var count: Int { __tree.count }
    
    var first: Value? { __tree.first?.value }
    
    var last: Value? { __tree.last?.value }

}
