import Foundation
import Collections

public protocol AllocatorProtocol {
    init()
    func create() -> BasePtr
    func delete(_ p: BasePtr)
    var reserved: Int { get }
    func reserve<C: Collection>(contentsOf newElements: C) where C.Element == BasePtr
}

public class TreeNodeAllocator: AllocatorProtocol {
    var __reserved: Deque<BasePtr> = []
    public var reserved: Int { __reserved.count }
    public required init() { }
    public func create() -> BasePtr {
        __reserved.popFirst()!
    }
    public func delete(_ p: BasePtr) {
        __reserved.prepend(p)
    }
    public func reserve<C: Collection>(contentsOf newElements: C) where C.Element == BasePtr {
        __reserved.append(contentsOf: newElements)
    }
}
