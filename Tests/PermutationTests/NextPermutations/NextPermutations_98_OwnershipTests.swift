//
//  NextPermutations_98_OwnershipTests.swift
//  swift-ac-collections
//

// runtime-check版`NextPermutations`の所有と破棄の検査（PERM-055 G4）。公開契約の拡張ではなく、
// 所有bufferの寿命管理を確かめる内部仕様test。
// - ownerは元の要素を自分のstorageへコピーし、以後の元のCollectionの変更は現在の並びに影響しない
// - 一度も進めない、途中まで進めた、最後まで進めた、空、のどのownerも、各要素をちょうど1回解放する
// - 奇数長の後半反転を含む並べ替えでも、要素の同一性と寿命が保たれる
// - 持ち出された失効Viewは、ownerの要素storageを生かし続けない（Viewへのアクセスはしない。G2で扱う）
//
// 解放回数は、test関数ごとに作る`ReleaseCounter`で数える。グローバルな状態は持たない。

#if !COMPATIBLE_ATCODER_2025
import NextPermutationModule
import XCTest

private final class ReleaseCounter {
  var count = 0
}

private final class Probe: Comparable {
  let value: Int
  let counter: ReleaseCounter

  init(_ value: Int, _ counter: ReleaseCounter) {
    self.value = value
    self.counter = counter
  }

  deinit { counter.count += 1 }

  static func == (lhs: Probe, rhs: Probe) -> Bool { lhs.value == rhs.value }
  static func < (lhs: Probe, rhs: Probe) -> Bool { lhs.value < rhs.value }
}

private func probes(_ values: [Int], _ counter: ReleaseCounter) -> [Probe] {
  values.map { Probe($0, counter) }
}

final class NextPermutations_98_OwnershipTests: XCTestCase {

  // MARK: - 元のCollectionからの独立

  func testLaterSourceChangesDoNotAlterTheCurrentPermutation() throws {
    var source = [2, 1, 3]
    var permutations = source.nextPermutations()
    source[0] = 99
    source.append(100)
    let first = try XCTUnwrap(permutations.next())
    XCTAssertEqual(Array(first), [2, 1, 3])
    let second = try XCTUnwrap(permutations.next())
    XCTAssertEqual(Array(second), [2, 3, 1])
  }

  // MARK: - ちょうど1回の解放

  func testNeverStartedOwnerReleasesEachElementOnce() throws {
    let counter = ReleaseCounter()
    do {
      _ = probes([1, 2, 3], counter).nextPermutations()
    }
    XCTAssertEqual(counter.count, 3)
  }

  func testPartiallyConsumedOwnerReleasesEachElementOnce() throws {
    let counter = ReleaseCounter()
    do {
      var permutations = probes([1, 2, 3], counter).nextPermutations()
      _ = permutations.next()
      _ = permutations.next()
      XCTAssertEqual(counter.count, 0)
    }
    XCTAssertEqual(counter.count, 3)
  }

  func testFullyConsumedOwnerReleasesEachElementOnce() throws {
    let counter = ReleaseCounter()
    do {
      var permutations = probes([1, 2, 3], counter).nextPermutations()
      var steps = 0
      while permutations.next() != nil {
        steps += 1
      }
      XCTAssertEqual(steps, 6)
      XCTAssertEqual(counter.count, 0)
    }
    XCTAssertEqual(counter.count, 3)
  }

  func testEmptyOwnerIsDestroyedSafely() throws {
    do {
      var permutations = [Probe]().nextPermutations()
      let only = try XCTUnwrap(permutations.next())
      XCTAssertTrue(only.isEmpty)
      XCTAssertNil(permutations.next())
    }
    do {
      _ = [Probe]().nextPermutations()
    }
  }

  // MARK: - 奇数長の後半反転

  func testOddLengthSuffixReversalPreservesIdentityAndLifetime() throws {
    let counter = ReleaseCounter()
    do {
      let originals = probes([1, 4, 3, 2], counter)
      var permutations = originals.nextPermutations()
      _ = permutations.next()
      // [1, 4, 3, 2] → 先頭と2を交換して[2, 4, 3, 1]、長さ3の後半を反転して[2, 1, 3, 4]
      let next = try XCTUnwrap(permutations.next())
      XCTAssertEqual(next.map(\.value), [2, 1, 3, 4])
      for probe in next {
        XCTAssertTrue(originals.contains { $0 === probe })
      }
      XCTAssertEqual(Set(next.map { ObjectIdentifier($0) }).count, 4)
      XCTAssertEqual(counter.count, 0)
    }
    XCTAssertEqual(counter.count, 4)
  }

  // MARK: - 持ち出された失効View

  func testEscapedInvalidViewDoesNotKeepElementStorageAlive() throws {
    let counter = ReleaseCounter()
    func escapedView() -> NextPermutations<Probe>.Permutation? {
      var permutations = probes([1, 2, 3], counter).nextPermutations()
      return permutations.next()
    }
    let view = escapedView()
    XCTAssertNotNil(view)
    // ownerの破棄で要素は解放される。Viewが残っていても要素を生かし続けない
    XCTAssertEqual(counter.count, 3)
    withExtendedLifetime(view) {}
  }
}

#endif
