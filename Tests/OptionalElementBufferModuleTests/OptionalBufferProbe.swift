import OptionalElementBufferModule

// Test-only adapter (OPT-074). It gives the 1D–4D buffers one coordinate-array interface so that
// the same observable scenario can be checked in every dimension. Each witness forwards to the
// public API without adding behavior; coordinates are ordered innermost axis first.
protocol OptionalBufferProbe<Value>: ~Copyable {
  associatedtype Value
  var indices: Range<Int> { get }
  func probeElement(at coordinate: [Int]) -> Value?
  func probeSetElement(_ newValue: consuming Value?, at coordinate: [Int])
  func removeAll()
}

extension OptionalElementBuffer: OptionalBufferProbe {
  func probeElement(at c: [Int]) -> Element? { element(at: c[0]) }
  func probeSetElement(_ newValue: consuming Element?, at c: [Int]) { setElement(newValue, at: c[0]) }
}

extension OptionalElementBuffer2D: OptionalBufferProbe {
  func probeElement(at c: [Int]) -> Element? { element(at: c[0], c[1]) }
  func probeSetElement(_ newValue: consuming Element?, at c: [Int]) {
    setElement(newValue, at: c[0], c[1])
  }
}

extension OptionalElementBuffer3D: OptionalBufferProbe {
  func probeElement(at c: [Int]) -> Element? { element(at: c[0], c[1], c[2]) }
  func probeSetElement(_ newValue: consuming Element?, at c: [Int]) {
    setElement(newValue, at: c[0], c[1], c[2])
  }
}

extension OptionalElementBuffer4D: OptionalBufferProbe {
  func probeElement(at c: [Int]) -> Element? { element(at: c[0], c[1], c[2], c[3]) }
  func probeSetElement(_ newValue: consuming Element?, at c: [Int]) {
    setElement(newValue, at: c[0], c[1], c[2], c[3])
  }
}

/// Every coordinate of `shape` (innermost axis first), with the innermost axis varying fastest.
func allCoordinates(_ shape: [Int]) -> [[Int]] {
  var result: [[Int]] = [[]]
  for extent in shape {
    result = (0..<extent).flatMap { i in result.map { $0 + [i] } }
  }
  return shape.contains(0) ? [] : result
}

/// A reference element whose destruction is recorded by identifier.
final class TrackedBox {
  let id: Int
  private let onDeinit: (Int) -> Void
  init(_ id: Int, onDeinit: @escaping (Int) -> Void) {
    self.id = id
    self.onDeinit = onDeinit
  }
  deinit { onDeinit(id) }
}
