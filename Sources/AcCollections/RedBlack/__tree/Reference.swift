import Foundation

protocol ___ref_protocol: Equatable, ExpressibleByNilLiteral {
    associatedtype __wrapped_type
    associatedtype __node_ref_type where __node_ref_type == Self
    var referencee: __wrapped_type { get nonmutating set }
    static var nullptr: Self { get }
}
