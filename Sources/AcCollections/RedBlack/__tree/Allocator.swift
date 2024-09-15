import Foundation
import Collections

protocol AllocatorProtocol {
    init()
    func create() -> BasePtr
    func delete(_ p: BasePtr)
    var reserved: Int { get }
    func reserve<C: Collection>(contentsOf newElements: C) where C.Element == BasePtr
}

class TreeNodeAllocator: AllocatorProtocol {
    var __reserved: Deque<BasePtr> = []
    var reserved: Int { __reserved.count }
    required init() { }
    func create() -> BasePtr {
        __reserved.popFirst()!
    }
    func delete(_ p: BasePtr) {
        __reserved.prepend(p)
    }
    func reserve<C: Collection>(contentsOf newElements: C) where C.Element == BasePtr {
        __reserved.append(contentsOf: newElements)
    }
}
