import Foundation

class RedBlackTree<Allocator, Comparer, Element>
where Allocator: AllocatorProtocol,
      Comparer: ComparerProtocol,
      Comparer.Element == Element
{
    var allocator: Allocator = .init()
    var header: TreeHeader = .init()
    var buffer: [Item] = []
    
    typealias __unsafe_tree = UnsafeTree<Allocator, Comparer, Item>
    typealias Item = _Item<Element>
    
    func _update<R>(_ body: (__unsafe_tree) throws -> R) rethrows -> R {
        try withUnsafeMutablePointer(to: &header) { header in
            try buffer.withUnsafeMutableBufferPointer { buffer in
                try body(__unsafe_tree(_allocator: allocator, _header: header, _buffer: buffer))
            }
        }
    }

    func ensureReserved(count: Int) {
        let current = allocator.reserved
        let add = max(0, count - current)
        for _ in 0..<add {
            allocator.reserve(contentsOf: [.node(buffer.count)])
            buffer.append(.init(isBlack: false, parent: nil, left: nil, right: nil))
        }
    }
}

