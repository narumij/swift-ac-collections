//
//  EDPC-J.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/06/08.
//

import OptionalArrayModule

func EDPC_J(N: Int) {

  nonisolated(unsafe) var ___rec_cache: OptionalArray3D<Double> = .init(
    width: 310, height: 310, depth: 310)

  func rec(_ i: Int, _ j: Int, _ k: Int) -> Double {
    func rec(_ i: Int, _ j: Int, _ k: Int) -> Double {
      if let value = ___rec_cache[i][j][k] {
        return value
      }
      let value = ___body(i, j, k)
      ___rec_cache[i][j][k] = value
      return value
    }
    func ___body(_ i: Int, _ j: Int, _ k: Int) -> Double {
      if i == 0, j == 0, k == 0 { return 0.0 }
      var res = 0.0
      if i > 0 { res += rec(i - 1, j, k) * Double(i) }
      if j > 0 { res += rec(i + 1, j - 1, k) * Double(j) }
      if k > 0 { res += rec(i, j + 1, k - 1) * Double(k) }
      res += Double(N)
      res *= 1.0 / Double(i + j + k)
      return res
    }
    return rec(i, j, k)
  }

  #if false
    var (one, two, three) = (0, 0, 0)
    for _ in 0..<N {
      switch Int.stdin {
      case 1: one += 1
      case 2: two += 1
      default: three += 1
      }
    }

    print(rec(one, two, three))
  #endif
}
