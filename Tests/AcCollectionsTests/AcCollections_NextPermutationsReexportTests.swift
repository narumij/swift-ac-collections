//
//  AcCollections_NextPermutationsReexportTests.swift
//  swift-ac-collections
//

// `import AcCollections`だけで、runtime-check版`nextPermutations()`が使えることの検査（PERM-056 G5）。
// このfileは`PermutationModule`を直接importしない。再公開が壊れればcompileできない。
// AtCoder 2025互換modeの再公開は`AcCollectionsTests.swift`の互換mode側で扱う。

#if !COMPATIBLE_ATCODER_2025
import AcCollections
import XCTest

final class AcCollections_NextPermutationsReexportTests: XCTestCase {

  func testImportAcCollectionsExposesRuntimeCheckedNextPermutations() throws {
    var permutations: NextPermutations<Int> = [1, 2].nextPermutations()
    var orders: [[Int]] = []
    while let permutation: NextPermutations<Int>.Permutation = permutations.next() {
      orders.append(Array(permutation))
    }
    XCTAssertEqual(orders, [[1, 2], [2, 1]])
  }
}

#endif
