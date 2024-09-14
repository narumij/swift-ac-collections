import Foundation

@usableFromInline
protocol __red_black_tree_compare {
    associatedtype Element
    static var value_comp: (Element, Element) -> Bool { get }
}

extension __red_black_tree_compare where Element: Comparable {
    static var value_comp: (Element, Element) -> Bool { (<) }
}

enum _red_brack_tree_comparable_compare<Element: Comparable>: __red_black_tree_compare { }

@usableFromInline
struct _RedBlackTree<Element, _Container: __red_black_tree_compare> where Element == _Container.Element {
    var storage: _Storage = .init(minimumCapacity: 1)
}

extension _RedBlackTree {
    
    var first: Element? {
        storage.__read{
            $0.__tree_min($0.__root).__value_
        }
    }
    
    var last: Element? {
        storage.__read{
            $0.__tree_max($0.__root).__value_
        }
    }
    
    mutating func insert(_ e: Element) {
        storage = storage.ensureCapacity(count: 1)
        storage.__update { $0.insert(e) }
    }
    
    mutating func remove(_ e: Element) where Element: Equatable {
        storage.__update { $0.erase(e) }
    }
    
//    func contains(_ e: Element) -> Bool {
//        storage.__read {
//            var __root = $0.__end_node.__left_
//            let result = $0.__find_equal(&__root, e)
//            return result.target != $0.__end_node
//        }
//    }
    
    var count: Int { storage.size }
    
    subscript(element: Element) -> Element? {
        get {
            storage.__read {
                var __root = $0.__end_node.__left_
                let result = $0.__find_equal(&__root, element)
                return result.target?.__value_
            }
        }
//        set {
//            storage.__update {
//                var __root = $0.__end_node.__left_
//                let result = $0.__find_equal(&__root, element)
//                result.target?.__value_ = newValue
//            }
//        }
    }
}

