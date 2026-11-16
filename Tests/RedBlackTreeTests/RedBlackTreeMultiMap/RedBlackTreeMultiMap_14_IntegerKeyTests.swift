import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultiMapIntegerKeyTests: RedBlackTreeTestCase {

  func testInt32KeysSupportFullWidthValues() {
    let int32Values: [(key: Int32, value: Int32)] = [(.min, -32), (0, 0), (.max, 32)]
    checkReadAndWrite(entries: int32Values, replacement: 320)

    let intValues: [(key: Int32, value: Int)] = [(.min, -64), (0, 0), (.max, 64)]
    checkReadAndWrite(entries: intValues, replacement: 640)
  }

  @available(macOS 15.0, *)
  func testInt32KeysSupportInt128Values() {
    let int128Values: [(key: Int32, value: Int128)] = [(.min, .min), (0, 0), (.max, .max)]
    checkReadAndWrite(entries: int128Values, replacement: Int128(1) << 100)
  }

  @available(macOS 15.0, *)
  func testInt128KeysSupportValuesBeyondInt64() {
    let intValues: [(key: Int128, value: Int)] = [(.min, -64), (0, 0), (.max, 64)]
    checkReadAndWrite(entries: intValues, replacement: 640)

    let int128Values: [(key: Int128, value: Int128)] = [(.min, .min), (0, 0), (.max, .max)]
    checkReadAndWrite(entries: int128Values, replacement: Int128(1) << 100)
  }

  private func eraseAll<Key: FixedWidthInteger, Value>(
    _ key: Key, from map: inout RedBlackTreeMultiMap<Key, Value>
  ) -> Int {
    #if COMPATIBLE_ATCODER_2025
      return map.removeAll(forKey: key)
    #else
      return map.eraseMulti(key)
    #endif
  }

  private func checkReadAndWrite<Key: FixedWidthInteger, Value: Equatable>(
    entries: [(key: Key, value: Value)],
    replacement: Value
  ) {
    var map = RedBlackTreeMultiMap<Key, Value>()
    for entry in entries.reversed() {
      map.insert(key: entry.key, value: entry.value)
    }

    let expected = entries.sorted { $0.key < $1.key }
    XCTAssertEqual(map.map(\.key), expected.map(\.key))
    for entry in expected {
      let index = map.firstIndex(of: entry.key)
      XCTAssertEqual(index.map { map[$0].value }, entry.value)
    }

    let original = map
    let middleKey = expected[1].key
    _ = eraseAll(middleKey, from: &map)
    map.insert(key: middleKey, value: replacement)
    XCTAssertEqual(map.firstIndex(of: middleKey).map { map[$0].value }, replacement)
    XCTAssertEqual(original.firstIndex(of: middleKey).map { original[$0].value }, expected[1].value)

    let firstKey = expected[0].key
    XCTAssertEqual(eraseAll(firstKey, from: &map), 1)
    XCTAssertNil(map.firstIndex(of: firstKey))
    XCTAssertEqual(original.firstIndex(of: firstKey).map { original[$0].value }, expected[0].value)
  }
}
