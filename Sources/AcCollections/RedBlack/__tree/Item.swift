import Foundation

protocol NodeItemProtocol {
    var isBlack: Bool { get set }
    var parent: BasePtr { get set }
    var left: BasePtr { get set }
    var right: BasePtr { get set }
    
    associatedtype Element
    var __value_: Element { get set }
    
    var isNil: Bool { get }
    mutating func clear()
}

struct _Item<Element>: NodeItemProtocol {
    var isBlack: Bool
    var parent: BasePtr
    var left: BasePtr
    var right: BasePtr
    var ___value_: Element?
    var __value_: Element {
        get { ___value_! }
        set { ___value_ = newValue }
    }
    var isNil: Bool { ___value_ == nil }
    mutating func clear() {
        isBlack = false
        parent = nil
        left = nil
        right = nil
        ___value_ = nil
    }
}

extension _Item: Equatable where Element: Equatable { }

