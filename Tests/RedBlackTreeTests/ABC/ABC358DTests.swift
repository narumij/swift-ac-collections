//
//  ABC385DTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/06/01.
//

import RedBlackTreeCollections
import XCTest

final class ABC358DTests: RedBlackTreeTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    try super.setUpWithError()
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    try super.tearDownWithError()
  }

  #if !COMPATIBLE_ATCODER_2025
    func testABC358D(N: Int, M: Int, _A: [Int], B: [Int]) throws {
      var A = RedBlackTreeMultiSet(_A)
      var ans = 0
      for b in B {
        guard let i = A.erase(lowerBound(b)) else {
          ans = -1
          break
        }
        ans += i
      }
      print(ans)
    }
  #else
    func testABC358D(N: Int, M: Int, _A: [Int], B: [Int]) throws {
      var A = RedBlackTreeMultiSet(_A)
      var ans = 0
      for b in B {
        let i = A.lowerBound(b)
        guard i != A.endIndex else {
          ans = -1
          break
        }
        ans += A.remove(at: i)
      }
      print(ans)
    }
  #endif

  func testExample2() throws {
    try testABC358D(
      N: 4, M: 2,
      _A: [3, 4, 5, 4],
      B: [1, 4])
    try testABC358D(
      N: 3, M: 3,
      _A: [1, 1, 1],
      B: [1_000_000_000, 1_000_000_000, 1_000_000_000])
    try testABC358D(
      N: 7, M: 3,
      _A: [2, 6, 8, 9, 5, 1, 11],
      B: [3, 5, 7])
  }

  func testCrash() throws {
    for n in 0..<100 {
      print("iteration", n)
      try testExample2()
    }
  }

  func testCrash2() throws {
    for n in 0..<100 {
      print("iteration", n)

      try testABC358D(
        N: 7, M: 3,
        _A: [2, 6, 8, 9, 5, 1, 11],
        B: [3, 5, 7])
    }
  }

  #if ENABLE_PERFORMANCE_TESTING && !COMPATIBLE_ATCODER_2025
    // Linux CIの互換モードでは、XCTestのmeasure実行中にテストプロセスが異常終了した。
    // 同じ処理を通常のループで100回実行しても再現しないため、メモリ管理の不具合とは
    // 断定できず、標準出力を伴う処理とLinux版XCTestの性能計測経路との組み合わせを
    // 疑って除外している。
    func testPerformanceExample2() throws {
      // This is an example of a performance test case.
      _ = 3

      self.measure {
        // Put the code you want to measure the time of here.
        try! testExample2()
      }
    }
  #endif
}
