import RedBlackTreeModule
import MT19937

typealias SortedSet = RedBlackTreeSet<Int>

#if false
let count = 5_000_000
var xy: RedBlackTreeDictionary<Int,SortedSet> = [1: .init(0 ..< count)]
var c = count
for i in (0 ..< count).shuffled() {
  c -= 1
  xy[1]?.remove(i)
  assert(xy[1]?.count == c)
}
#elseif false
let count = 5_000_000
var xy: [Int: SortedSet] = [1: .init(0 ..< count)]
var c = count
for i in (0 ..< count).shuffled() {
  c -= 1
  xy[1]?.remove(i)
  assert(xy[1]?.count == c)
}
#elseif true
var mt = mt19937_64(seed: 0)
let count = 1_000_000
var xy: SortedSet = .init(0 ..< count)
var c = count
var ss = (0 ..< count).shuffled(using: &mt) + []
for i in ss {
  c -= 1
  xy.remove(i)
  assert(xy.count == c)
}
#elseif false
let count = 5_000_000
var xy: Set<Int> = .init(0 ..< count)
var c = count
for i in (0 ..< count).shuffled() {
  c -= 1
  xy.remove(i)
  assert(xy.count == c)
}
#else
let count = 100_000_000
var xy: RedBlackTreeDictionary<Int,SortedSet> = [1: .init(0 ..< count)]
print(xy.count)
#endif
