//
//  NextPermutations_0_PublicSurfaceTests.swift
//  swift-ac-collections
//

// 公開表面のTest as Specification（runtime-check版`NextPermutations`、PERM-056 G0）。
// - 入口は`Collection.nextPermutations()`で、要素が`Comparable`なCollectionから呼べる
// - 返り値は`NextPermutations<Element>`、`next()`が返すViewは`NextPermutations<Element>.Permutation`
// - Array、Range、startIndexが0でないSlice、Int以外のIndexを持つCollectionから作れる
//
// 直接の公開初期化ができないこと、ownerが`~Copyable`であること、`Sequence`に適合しないことは
// 実行時testでは表せない。`Utilities/Maintenance/VerifyPermutationCompilerDiagnostics.sh`の
// compile-fail fixtureで検証する。

#if !COMPATIBLE_ATCODER_2025
import PermutationModule
import XCTest

final class NextPermutations_0_PublicSurfaceTests: XCTestCase {

  func testPublicTypeNames() throws {
    var permutations: NextPermutations<Int> = [1, 2].nextPermutations()
    let first: NextPermutations<Int>.Permutation? = permutations.next()
    XCTAssertEqual(first.map { Array($0) }, [1, 2])
  }

  func testConstructsFromArrayRangeSliceAndNonIntIndexedSources() throws {
    var fromArray: NextPermutations<Int> = [3, 1, 2].nextPermutations()
    XCTAssertEqual(fromArray.next().map { Array($0) }, [3, 1, 2])

    var fromRange: NextPermutations<Int> = (1..<4).nextPermutations()
    XCTAssertEqual(fromRange.next().map { Array($0) }, [1, 2, 3])

    let slice = [9, 3, 1, 2, 9][1..<4]
    XCTAssertEqual(slice.startIndex, 1)
    var fromSlice: NextPermutations<Int> = slice.nextPermutations()
    XCTAssertEqual(fromSlice.next().map { Array($0) }, [3, 1, 2])

    var fromString: NextPermutations<Character> = "ba".nextPermutations()
    XCTAssertEqual(fromString.next().map { Array($0) }, ["b", "a"])
  }
}

#endif
