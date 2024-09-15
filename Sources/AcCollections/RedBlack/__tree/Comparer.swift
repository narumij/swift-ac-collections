import Foundation

protocol ComparerProtocol {
    associatedtype Element
    static func value_comp(_: Element, _: Element) -> Bool
}

enum StandardComparer<Element>: ComparerProtocol
where Element: Comparable {
    static func value_comp(_ l: Element, _ r: Element) -> Bool {
        l < r
    }
}

