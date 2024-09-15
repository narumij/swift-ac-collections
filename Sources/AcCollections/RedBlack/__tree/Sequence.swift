import Foundation

#if true
protocol TreeTest: Sequence where Iterator == BaseIterator<Storage> {
    associatedtype Element
    associatedtype Storage: SequenceTree where Element == Storage.Element
    var storage: Storage { get }
}

extension TreeTest {
    
}

extension TreeTest {
    func makeIterator(_ __ptr_: BasePtr) -> Iterator {
        .init(__tree_: storage, __ptr_: __ptr_,  __begin: storage.begin(),__end_: storage.end())
    }
    func makeIterator() -> Iterator {
        makeIterator(storage.begin())
    }
}
#endif
