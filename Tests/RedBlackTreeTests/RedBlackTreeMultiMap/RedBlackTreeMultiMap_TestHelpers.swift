import RedBlackTreeCollections
import XCTest

func keyValue<K, V>(_ k: K, _ v: V) -> (key: K, value: V) { (k, v) }
func keyValue<K, V>(_ kv: (K, V)) -> (key: K, value: V) {
  (kv.0, kv.1)
}
func __key<K, V>(_ kv: (key: K, value: V)) -> K {
  kv.key
}

func AssertEquenceEqual<A, B, C, D>(_ lhs: A, _ rhs: B, file: StaticString = #file, line: UInt = #line)
where
  A: Sequence, B: Sequence, A.Element == (key: C, value: D), A.Element == B.Element,
  C: Equatable, D: Equatable
{
  XCTAssertTrue(lhs.elementsEqual(rhs, by: ==), file: file, line: line)
}
