import RedBlackTreeCollections
import XCTest

final class RedBlackTreeDictionaryIntegerKeyTests: RedBlackTreeTestCase {

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

  private func checkReadAndWrite<Key: FixedWidthInteger, Value: Equatable>(
    entries: [(key: Key, value: Value)],
    replacement: Value
  ) {
    var dictionary = RedBlackTreeDictionary<Key, Value>()
    for entry in entries.reversed() {
      dictionary[entry.key] = entry.value
    }

    let expected = entries.sorted { $0.key < $1.key }
    XCTAssertEqual(dictionary.map(\.key), expected.map(\.key))
    for entry in expected {
      XCTAssertEqual(dictionary[entry.key], entry.value)
    }

    let original = dictionary
    let middleKey = expected[1].key
    dictionary[middleKey] = replacement
    XCTAssertEqual(dictionary[middleKey], replacement)
    XCTAssertEqual(original[middleKey], expected[1].value)

    let firstKey = expected[0].key
    XCTAssertEqual(dictionary.removeValue(forKey: firstKey), expected[0].value)
    XCTAssertNil(dictionary[firstKey])
    XCTAssertEqual(original[firstKey], expected[0].value)
  }
}
