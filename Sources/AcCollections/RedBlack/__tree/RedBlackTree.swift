import Foundation

public class RedBlackTree<Allocator, Comparer, Element>
where Allocator: AllocatorProtocol,
      Comparer: ComparerProtocol,
      Comparer.Element == Element
{
    var allocator: Allocator = .init()
    var header: TreeHeader = .init()
    var buffer: [Item] = []
    
    typealias __unsafe_tree = UnsafeTree<Allocator, Comparer, Item>
    typealias Item = _Item<Element>

    func __update(_ body: (__unsafe_tree) throws -> __unsafe_tree._NodePtr) rethrows -> BasePtr {
        try _update(body).basePtr
    }

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
    
    func removeAll(keepingCapacity keepCapacity: Bool = false) {
        header = .init()
        if keepCapacity {
            buffer.withUnsafeMutableBufferPointer { buffer in
                buffer.update(repeating: .init(isBlack: false, parent: nil, left: nil, right: nil))
            }
            allocator.reserve(contentsOf: buffer.indices.map{ BasePtr.node($0) })
        } else {
            buffer = []
        }
    }

    var size: Int { header.size }
    var capacity: Int { header.size + allocator.reserved }
}

extension RedBlackTree: SequenceTree {
    
    public func value(_ p: BasePtr) -> Element {
        if case .node(let int) = p {
            return buffer[int].__value_
        }
        fatalError()
    }
    
    public func next(_ p: BasePtr) -> BasePtr {
        _update{ __unsafe_tree.__tree_next_iter(p.handlePtr($0.handle)).basePtr }
    }
    
    public func prev(_ p: BasePtr) -> BasePtr {
        _update{ __unsafe_tree.__tree_prev_iter(p.handlePtr($0.handle)).basePtr }
    }
    
    public func begin() -> BasePtr {
        header.begin_ptr
    }
    
    public func end() -> BasePtr {
        .end
    }
}

