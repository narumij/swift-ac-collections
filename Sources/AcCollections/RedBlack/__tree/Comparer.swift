import Foundation

public protocol ComparerProtocol {
    associatedtype Element
    static func value_comp(_: Element, _: Element) -> Bool
}

public enum StandardComparer<Element>: ComparerProtocol
where Element: Comparable {
    public static func value_comp(_ l: Element, _ r: Element) -> Bool {
        l < r
    }
}

