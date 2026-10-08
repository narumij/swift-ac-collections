struct DisjointSet {
  private var parent: [Int]
  private var rank: [Int]

  init(count: Int) {
    parent = Array(0..<count)
    rank = Array(repeating: 0, count: count)
  }

  mutating func find(_ value: Int) -> Int {
    var current = value
    while parent[current] != current {
      parent[current] = parent[parent[current]]
      current = parent[current]
    }
    return current
  }

  mutating func union(_ lhs: Int, _ rhs: Int) -> Bool {
    var lhsRoot = find(lhs)
    var rhsRoot = find(rhs)
    guard lhsRoot != rhsRoot else { return false }

    if rank[lhsRoot] < rank[rhsRoot] {
      swap(&lhsRoot, &rhsRoot)
    }
    parent[rhsRoot] = lhsRoot
    if rank[lhsRoot] == rank[rhsRoot] {
      rank[lhsRoot] += 1
    }
    return true
  }
}

let firstLine = readLine()!.split(separator: " ").map { Int($0)! }
let vertexCount = firstLine[0]
let edgeCount = firstLine[1]
let modulus = firstLine[2]
var edges: [(u: Int, v: Int, weight: Int)] = []

for _ in 0..<edgeCount {
  let values = readLine()!.split(separator: " ").map { Int($0)! }
  edges.append((values[0] - 1, values[1] - 1, values[2]))
}

var selection = Array(repeating: 0, count: edgeCount - (vertexCount - 1))
selection += Array(repeating: 1, count: vertexCount - 1)
var answer = Int.max

for selected in selection.unsafeNextPermutations() {
  var disjointSet = DisjointSet(count: vertexCount)
  var cost = 0
  var isTree = true

  for edgeIndex in edges.indices where selected[edgeIndex] == 1 {
    let edge = edges[edgeIndex]
    guard disjointSet.union(edge.u, edge.v) else {
      isTree = false
      break
    }
    cost = (cost + edge.weight) % modulus
  }

  if isTree {
    answer = min(answer, cost)
  }
}

print(answer)
