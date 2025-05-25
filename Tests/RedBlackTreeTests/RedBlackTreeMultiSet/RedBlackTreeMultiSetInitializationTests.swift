import XCTest

#if DEBUG
@testable import RedBlackTreeModule
#else
import RedBlackTreeModule
#endif

final class RedBlackTreeMultiSetInitializationTests: XCTestCase {

    /// 空のマルチセットを初期化できること
    func test_init_empty() {
        // 事前条件: 空の初期化
        let multiset = RedBlackTreeMultiSet<Int>()

        // 事後条件:
        // - isEmptyがtrueであること
        // - countが0であること
        XCTAssertTrue(multiset.isEmpty)
        XCTAssertEqual(multiset.count, 0)
    }

    /// 指定容量で初期化できること
    func test_init_withCapacity() {
        // 事前条件: minimumCapacityを指定して初期化
        let multiset = RedBlackTreeMultiSet<Int>(minimumCapacity: 10)

        // 事後条件:
        // - isEmptyがtrueであること
        // - capacityが指定容量以上であること
        XCTAssertTrue(multiset.isEmpty)
        XCTAssertGreaterThanOrEqual(multiset.capacity, 10)
    }

    /// 配列（Sequence）から初期化できること
    func test_init_fromSequence() {
        // 事前条件: シーケンス [1,2,2,3] から初期化
        let multiset = RedBlackTreeMultiSet([1, 2, 2, 3])

        // 事後条件:
        // - 各要素の出現回数が正しいこと
        // - 全体のcountが正しいこと
        XCTAssertEqual(multiset.count(of: 1), 1)
        XCTAssertEqual(multiset.count(of: 2), 2)
        XCTAssertEqual(multiset.count(of: 3), 1)
        XCTAssertEqual(multiset.count, 4)
    }

    /// Range（範囲）から初期化できること
    func test_init_fromRange() {
        // 事前条件: 1...3の範囲から初期化
        let multiset = RedBlackTreeMultiSet(1...3)

        // 事後条件:
        // - 各要素が1回ずつ含まれていること
        XCTAssertEqual(multiset.count(of: 1), 1)
        XCTAssertEqual(multiset.count(of: 2), 1)
        XCTAssertEqual(multiset.count(of: 3), 1)
    }
}
