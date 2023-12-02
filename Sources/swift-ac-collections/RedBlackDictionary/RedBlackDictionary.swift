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
        get { __tree[.init(key: key,value: nil)]?.value }
        set {
            // 未テスト。コンパイルは通っているが実際に動作するか不明
            __tree[.init(key: key,value: nil)]?.value = newValue
        }
    }
}
