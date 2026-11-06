import AcCollections
import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#endif

/// `AcCollections` is a facade consisting only of `@_exported import` declarations, and its dedicated target had
/// never imported `AcCollections` (discovered 2026-10-03). If re-exporting broke,
/// other tests could not detect it, so this file performs minimal reachability checks.
final class AcCollectionsTests: XCTestCase {

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
    #if false
    func test_importAcCollections_exposesCurrentPermutationAPI() {
      let sequence: NextPermutationsSequence<[Int]> = [1, 2].nextPermutations()
      XCTAssertEqual(sequence.map { Array($0) }, [[1, 2], [2, 1]])
    }
    #endif
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

  #if ENABLE_OPTIONAL_ELEMENT_BUFFER
    func test_importAcCollections_exposesOptionalElementBuffer() {
      let array = OptionalElementBuffer<Int>(capacity: 2)
      array.setElement(7, at: 1)
      XCTAssertEqual(array.element(at: 1), 7)
    }
  #endif

  @available(macOS 27.0, *)
  func test_importAcCollections_exposesElementBuffer() {
    var array = ElementBuffer(repeating: 0, count: 2)
    array.setElement(7, at: 1)
    XCTAssertEqual(array.element(at: 1), 7)

    #if swift(>=6.4)
      var reference = array.reference(at: 1)
      reference.value = 8
      XCTAssertEqual(array.element(at: 1), 8)
    #endif
  }
}
