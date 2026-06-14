//
//  EDPC-L.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/06/08.
//

import OptionalArrayModule

func hoge(N: Int, A: [Int]) {

  nonisolated(unsafe) var ___dfs_cache: OptionalArray2D<Int> = .init(width: 3001, height: 3001)

  func dfs(_ l: Int, _ r: Int) -> Int {
    func dfs(_ l: Int, _ r: Int) -> Int {
      if let value = ___dfs_cache[l][r] {
        return value
      }
      let value = ___body(l, r)
      ___dfs_cache[l][r] = value
      return value
    }
    func ___body(_ l: Int, _ r: Int) -> Int {
      if l == r { return 0 }
      var res = Int.min
      res = max(res, -dfs(l + 1, r) + A[l])
      res = max(res, -dfs(l, r - 1) + A[r - 1])
      return res
    }
    return dfs(l, r)
  }

  print(dfs(0, N))
}

