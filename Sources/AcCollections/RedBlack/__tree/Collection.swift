import Foundation

protocol TreeTest2: TreeTest, Collection
where Index == BaseIterator<Storage>
{ }

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
