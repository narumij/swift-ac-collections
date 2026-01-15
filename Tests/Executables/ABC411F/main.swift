import AcFoundation
import IOUtil
import MT19937
import RedBlackTreeModule

var mt = mt19937_64(seed: 0)

let N = 3 * 100000
var m = 3 * 100000
let Q = 3 * 100000
//var (N,m,Q) = (3 * 100000, 3 * 100000, 3 * 100000)

// 制約 0 <= u < v < N
// if i != j then ([u[i],u[i]] != [u[j],v[j]])
var uvSource: [(Int, Int)] = []

var uvWork = Set<SIMD2<Int>>()
while uvWork.count < m {
  let u = (0..<N).randomElement()!
  let v = (u..<N).randomElement()!
  if !uvWork.contains([u, v]) {
    uvWork.insert([u, v])
  }
}
uvSource = uvWork.map { ($0.x, $0.y) }
var qSource: [Int] = []
while qSource.count < Q {
  qSource.append((0..<m).randomElement()!)
}

assert(uvSource.count == m)
assert(qSource.count == Q)

var uv = uvSource.makeIterator()
var q = qSource.makeIterator()

//var (N, m): (Int,Int) = stdin()
var p_rev = (0..<N) + []
var p = (0..<N).map { [$0] }
var _e: [RedBlackTreeSet<Int>] = .init(repeating: .init(), count: N)
let e = _e.withUnsafeMutableBufferPointer { $0.baseAddress! }
var u: [Int] = []
var v: [Int] = []
for (_u, _v) in uv {
  u.append(_u)
  v.append(_v)
  e[_u].insert(_v)
  e[_v].insert(_u)
}
//let Q = Int.stdin
for x in q {
  //  let x = Int.stdin - 1
  var vx = p_rev[u[x]]
  var vy = p_rev[v[x]]
  if vx != vy {
    let valx = (e[vx].count) + (p[vx].count)
    let valy = (e[vy].count) + (p[vy].count)
    if valx > valy { swap(&vx, &vy) }
    let sz = p[vx].count
    for j in 0..<sz {
      p[vy].append(p[vx][j])
      p_rev[p[vx][j]] = vy
    }
    p[vx].removeAll()
    for vz in e[vx] {
      if vz == vy {
        m -= 1
        e[vy].remove(vx)
      } else {
        if e[vy].contains(vz) {
          m -= 1
        } else {
          e[vy].insert(vz)
          e[vz].insert(vy)
        }
        e[vz].remove(vx)
      }
    }
    e[vx].removeAll()
  }
  fastPrint(m)
}
