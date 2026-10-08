import AcCollections
import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#endif

/// `AcCollections`は`@_exported import`だけで構成されるfacadeで、専用ターゲットから
/// 一度も`import AcCollections`されていなかった(2026-10-03発見)。再公開が壊れても
/// 他のテストでは検出できないため、最小限の到達確認をここで行う。
final class AcCollectionsTests: XCTestCase {

  override func setUpWithError() throws {
    #if DEBUG
      // SKIP_DEBUG_LIFETIME_BALANCE_CHECKS(テスト専用trait)は釣り合い検査だけを省略する。
      // counterのresetは常に行う。
      #if !SKIP_DEBUG_LIFETIME_BALANCE_CHECKS && !SKIP_DEBUG_LIFETIME_SETUP_CHECKS
        XCTAssertEqual(deallocatedCount, 0)
        XCTAssertEqual(nodeDeinitializedCount, 0)
        XCTAssertEqual(payloadDeinitializedCount, 0)
      #endif
      _ = RedBlackTreeSet<Int>()
      allocatedCount = 0
      deallocatedCount = 0
      nodeInitializedCount = 0
      nodeDeinitializedCount = 0
      payloadInitializedCount = 0
      payloadDeinitializedCount = 0
    #endif
  }

  override func tearDownWithError() throws {
    #if DEBUG
      #if !SKIP_DEBUG_LIFETIME_BALANCE_CHECKS
        XCTAssertEqual(allocatedCount, deallocatedCount)
        XCTAssertEqual(nodeInitializedCount, nodeDeinitializedCount)
        XCTAssertEqual(payloadInitializedCount, payloadDeinitializedCount)
      #endif
      allocatedCount = 0
      deallocatedCount = 0
      nodeInitializedCount = 0
      nodeDeinitializedCount = 0
      payloadInitializedCount = 0
      payloadDeinitializedCount = 0
    #endif
  }

  func test_importAcCollections_exposesRedBlackTreeSet() {
    var set = RedBlackTreeSet<Int>()
    set.insert(3)
    set.insert(1)
    set.insert(2)

    XCTAssertEqual(Array(set), [1, 2, 3])
  }

  func test_importAcCollections_exposesRedBlackTreeDictionary() {
    var dict = RedBlackTreeDictionary<Int, String>()
    dict[1] = "a"

    XCTAssertEqual(dict[1], "a")
  }

  func test_importAcCollections_exposesRedBlackTreeMultiSetAndMultiMap() {
    let multiset: RedBlackTreeMultiSet = [1, 1, 2]
    XCTAssertEqual(multiset.count(of: 1), 2)

    let multimap: RedBlackTreeMultiMap<Int, String> = [(1, "a"), (1, "b")]
    XCTAssertEqual(multimap.count(forKey: 1), 2)
  }

  #if !COMPATIBLE_ATCODER_2025
    func test_importAcCollections_exposesCurrentPermutationAPI() {
      let sequence: NextPermutationsSequence<[Int]> = [1, 2].nextPermutations()
      XCTAssertEqual(sequence.map { Array($0) }, [[1, 2], [2, 1]])
    }
  #else
    func test_importAcCollections_exposesAtCoder2025PermutationAPI() {
      let nexts: Permutations<[Int]>.Nexts = [1, 2].nextPermutations()
      let all: Permutations<[Int]>.All = [1, 2].unsafePermutations()

      XCTAssertEqual(nexts.map { Array($0) }, [[1, 2], [2, 1]])
      XCTAssertEqual(all.map { Array($0) }, [[1, 2], [2, 1]])
      XCTAssertEqual(
        [1, 2].unsafeNextPermutations().map { Array($0) },
        [[1, 2], [2, 1]])
    }
  #endif

  func test_importAcCollections_exposesOptionalArray() {
    var array = OptionalArray1D<Int>(capacity: 2)
    array[1] = 7
    XCTAssertEqual(array[1], 7)
  }

  func test_importAcCollections_exposesBareArray() {
    var array = BareArray(repeating: 0, count: 2)
    array[1] = 7
    XCTAssertEqual(array[1], 7)
  }
}
