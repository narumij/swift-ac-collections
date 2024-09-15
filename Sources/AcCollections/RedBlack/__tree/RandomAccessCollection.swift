import Foundation

protocol TreeTest3: TreeTest2, RandomAccessCollection { }

extension TreeTest3 {
    
    func index(before i: Index) -> Index {
        var i = i
        _ = i.prev()
        return i
    }
}
