import Foundation
@testable import AcCollections

protocol TreeTest2: Sequence, Collection
where Index == BaseIterator<Storage>,
      Iterator == BaseIterator<Storage>
{
    associatedtype Element
    associatedtype Storage: SequenceTree where Element == Storage.Element
    func makeIterator(_ __ptr_: BasePtr) -> Iterator
    var storage: Storage { get }
}

extension TreeTest2 {
    
    func index(after i: Index) -> Index {
        var i = i
        _ = i.next()
        return i
    }
    
    subscript(position: Index) -> Element {
        get {
            return position.current()!
        }
    }
    
    var startIndex: Index {
        makeIterator(storage.begin())
    }
    
    var endIndex: Index {
        makeIterator(storage.end())
    }
}
