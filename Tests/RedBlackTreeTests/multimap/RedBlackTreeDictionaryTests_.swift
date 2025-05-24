import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class RedBlackTreeMultiMapTests_: XCTestCase {

    func testRedBlackTreeDictionary_basic() {
        var dict = RedBlackTreeDictionary<String, Int>()
        dict["apple"] = 1
        dict["banana"] = 2
        dict["apple"] = 3 // 上書き

        XCTAssertEqual(dict["apple"], 3)
        XCTAssertEqual(dict["banana"], 2)
        XCTAssertEqual(dict.count, 2)
    }

    func testRedBlackTreeMultiDictionary_basic() {
        var multiDict = RedBlackTreeMultiMap<String, Int>()
        multiDict.insert(key: "apple", value: 1)
        multiDict.insert(key: "apple", value: 3)
        multiDict.insert(key: "banana", value: 2)

        let appleValues = multiDict.values(forKey: "apple")
        let bananaValues = multiDict.values(forKey: "banana")
        
        XCTAssertEqual(Set(appleValues), Set([1, 3]))
        XCTAssertEqual(bananaValues, [2])
        XCTAssertEqual(multiDict.count(forKey: "apple"), 2)
        XCTAssertEqual(multiDict.count(forKey: "banana"), 1)
    }

    func testRedBlackTreeMultiDictionary_equalRange() {
        var multiDict = RedBlackTreeMultiMap<String, Int>()
        multiDict.insert(key: "apple", value: 1)
        multiDict.insert(key: "apple", value: 3)
        multiDict.insert(key: "banana", value: 2)

        let (lower, upper) = multiDict.___equal_range("apple")
        var result: [Int] = []
        var it = lower
        while it != upper {
            if let val = multiDict.value(at: it) {
                result.append(val)
            }
            it = multiDict.index(after: it)
        }
        XCTAssertEqual(Set(result), Set([1, 3]))
    }
}
