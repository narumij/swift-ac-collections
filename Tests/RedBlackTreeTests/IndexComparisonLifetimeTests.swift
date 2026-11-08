// SPDX-License-Identifier: Apache-2.0

#if DEBUG && !COMPATIBLE_ATCODER_2025 && !USE_LAZY_DETACH
import XCTest
@testable import RedBlackTreeCollections

final class IndexComparisonLifetimeTests: XCTestCase {
  func testLiveIndicesKeepTreeOrderIncludingDuplicatesAndEnd() {
    let tree: RedBlackTreeMultiSet<Int> = [3, 1, 3, 2]
    var indices = [tree.startIndex]
    while indices.last! != tree.endIndex {
      indices.append(tree.index(after: indices.last!))
    }
    withExtendedLifetime(tree) {
      for i in indices.indices {
        for j in indices.indices {
          XCTAssertEqual(indices[i] < indices[j], i < j)
        }
      }
    }
  }

  func testStorageReleaseMarksOutstandingIndicesDetached() {
    var tree: RedBlackTreeSet<Int>? = [1, 2]
    let index = tree!.startIndex
    XCTAssertFalse(index.lazyDetach.isDetached)
    tree = nil
    XCTAssertTrue(index.lazyDetach.isDetached)
  }

  func testClearRetiresOldTieAndAllowsFreshIndices() {
    var tree: RedBlackTreeSet<Int> = [1, 2]
    let old = tree.startIndex
    tree.removeAll(keepingCapacity: true)
    XCTAssertTrue(old.lazyDetach.isDetached)
    tree.insert(3)
    withExtendedLifetime(tree) {
      XCTAssertFalse(tree.startIndex.lazyDetach.isDetached)
      XCTAssertTrue(tree.startIndex < tree.endIndex)
    }
  }
}
#endif
