import XCTest

#if DEBUG
@testable import RedBlackTreeModule
#else
import RedBlackTreeModule
#endif

final class RedBlackTreeMultiSetSequenceTests: XCTestCase {

    /// makeIteratorで重複を含めた順序通りの列挙ができること
    func test_makeIterator() {
        // 事前条件: [3, 1, 2, 1, 3] のマルチセットを用意
        let multiset = RedBlackTreeMultiSet([3, 1, 2, 1, 3])
        
        // 事後条件:
        // - 要素は常にソート済みで [1, 1, 2, 3, 3]
        let collected = Array(multiset)
        XCTAssertEqual(collected, [1, 1, 2, 3, 3])
    }

    /// forEachで重複を含めた順序通りの列挙ができること
    func test_forEach() {
        // 事前条件: [3, 1, 2, 1, 3] のマルチセットを用意
        let multiset = RedBlackTreeMultiSet([3, 1, 2, 1, 3])
        
        // 事後条件:
        // - 要素は常にソート済みで [1, 1, 2, 3, 3]
        var collected: [Int] = []
        multiset.forEach { collected.append($0) }
        XCTAssertEqual(collected, [1, 1, 2, 3, 3])
    }
}
