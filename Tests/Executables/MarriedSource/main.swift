import Foundation

// https://github.com/narumij/swift-ac-collections/

import AcFoundation
import IOUtil



// ----

#if false
var (N, m): (Int,Int) = stdin()
var p_rev = (0..<N) + []
var p = (0..<N).map { [$0] }
var _e: [RedBlackTreeSet<Int>] = .init(repeating: .init(), count: N)
let e = _e.withUnsafeMutableBufferPointer { $0.baseAddress! }
var u: [Int] = []
var v: [Int] = []
for _ in 0..<m {
  let (_u,_v) = (Int.stdin - 1, Int.stdin - 1)
  u.append(_u)
  v.append(_v)
  e[_u].insert(_v)
  e[_v].insert(_u)
}
let Q = Int.stdin
for _ in 0..<Q {
  let x = Int.stdin - 1
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
#endif

#if false
var (N, M, x, y) = (Int.stdin, Int.stdin, Int.stdin, Int.stdin)
var xy: [Int: RedBlackTreeSet<Int>] = [:]
var yx: [Int: RedBlackTreeSet<Int>] = [:]
for _ in 0..<N {
  let (xx, yy) = (Int.stdin, Int.stdin)
  xy[xx, default: []].insert(yy)
  yx[yy, default: []].insert(xx)
}
var ans = 0
for _ in 0 ..< M {
  let (c, d) = (Character.stdin, Int.stdin)
  switch c {
  case "U":
    let new_y = y + d
    xy[x]?.removeBounds(lowerBound(y)..<upperBound(new_y)) { v in
      ans += 1
      yx[v]?.remove(x)
      return true
    }
    y = new_y
  case "D":
    let new_y = y - d
    xy[x]?.removeBounds(lowerBound(new_y)..<upperBound(y)) { v in
      ans += 1
      yx[v]?.remove(x)
      return true
    }
    y = new_y
  case "L":
    let new_x = x - d
    yx[y]?.removeBounds(lowerBound(new_x)..<upperBound(x)) { v in
      ans += 1
      xy[v]?.remove(y)
      return true
    }
    x = new_x
  case "R":
    let new_x = x + d
    yx[y]?.removeBounds(lowerBound(x)..<upperBound(new_x)) { v in
      ans += 1
      xy[v]?.remove(y)
      return true
    }
    x = new_x
  default:
    break
  }
}
print(x, y, ans)
#endif

#if false

var (N, M, x, y) = (Int.stdin, Int.stdin, Int.stdin, Int.stdin)
var xy: [Int:RedBlackTreeSet<Int>] = [:]
var yx: [Int:RedBlackTreeSet<Int>] = [:]
var _xy: [Int:[Int]] = [:]
var _yx: [Int:[Int]] = [:]
for _ in 0..<N {
  let (xx, yy) = (Int.stdin, Int.stdin)
  _xy[xx, default: []].append(yy)
  _yx[yy, default: []].append(xx)
}
for (k,v) in _xy {
  xy[k] = .init(v)
}
for (k,v) in _yx {
  yx[k] = .init(v)
}

var ans = 0
for _ in 0 ..< M {
  let (c, d) = (Character.stdin, Int.stdin)
  switch c {
  case "U":
    let new_y = y + d
      xy[x]?.sequence(from: y, through: new_y).forEach { i, v in
      ans += 1
      yx[v]?.remove(x)
      xy[x]?.remove(at: i)
    }
    y = new_y
  case "D":
    let new_y = y - d
    xy[x]?.sequence(from: new_y, through: y).forEach { i, v in
      ans += 1
      yx[v]?.remove(x)
      xy[x]?.remove(at: i)
    }
    y = new_y
  case "L":
    let new_x = x - d
    yx[y]?.sequence(from: new_x, through: x).forEach { i, v in
      ans += 1
      xy[v]?.remove(y)
      yx[y]?.remove(at: i)
    }
    x = new_x
  case "R":
    let new_x = x + d
    yx[y]?.sequence(from: x, through: new_x).forEach { i, v in
      ans += 1
      xy[v]?.remove(y)
      yx[y]?.remove(at: i)
    }
    x = new_x
  default:
    break
  }
}

print(x, y, ans)

extension RedBlackTreeSet {
  public func sequence(from start: Element, to end: Element) -> SubSequence {
    self[lowerBound(start)..<lowerBound(end)]
  }
}
extension RedBlackTreeSet {
  public func sequence(from start: Element, through end: Element) -> SubSequence {
    self[lowerBound(start)..<upperBound(end)]
  }
}
#endif

