
## GRAPH-001

タスクの範囲以外についてもアイデアが湧いたので、会話できている範囲について拡大解釈することにしました。

## Docc

以下はイニシャライザのところにあるが、Decodable適応なので別カテゴリに移す

```
init(from: Decoder) throws
Creates a new set by decoding from the given decoder.
```

## ABC328E

なんかAIのコードが長くて気になったので参考にどうぞ

https://atcoder.jp/contests/abc328/submissions/76866732

```swift
import AcCollections
import AcFoundation
import AtCoder
import Convenience

let N = Int.stdin
let M = Int.stdin
let K = Int.stdin
let edges: [(Int, Int, Int)] = M.rep {
  (Int.stdin - 1, Int.stdin - 1, Int.stdin)
}

var useEdges: [Bool] = [false] * M
([true] * (N - 1)).enumerated().forEach { i, v in
  useEdges[i] = v
}
useEdges.reverse()

var ans = K

for useEdges in useEdges.nextPermutations() {

  func mstCost() -> Int {
    var uf = DSU(N)
    var cost_sum = 0
    for i in 0..<M {
      guard useEdges[i] else { continue }
      let (u, v, cost) = edges[i]
      if uf.same(u, v) {
        return K
      }
      uf.merge(u, v)
      cost_sum += cost
    }
    return cost_sum % K
  }

  ans = min(ans, mstCost())
}

print(ans)

extension Bool: @retroactive Comparable {
  public static func < (lhs: Bool, rhs: Bool) -> Bool {
    lhs != rhs && !lhs
  }
}
```
