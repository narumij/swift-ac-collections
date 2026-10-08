/// SplitMix64 (Steele, Lea, and Flood, 2014). Repository-local, so a seed reproduces
/// the same trace regardless of platform or standard-library random generators.
struct SplitMix64 {
    var state: UInt64

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }

    /// A value in `0..<upperBound`; modulo bias does not matter for trace generation.
    mutating func next(below upperBound: Int) -> Int {
        Int(next() % UInt64(upperBound))
    }
}

/// The names of the integer counters in `coverage` that are still zero.
func missingCoverage(_ coverage: some Any) -> [String] {
    Mirror(reflecting: coverage).children.compactMap { child in
        (child.value as? Int) == 0 ? child.label : nil
    }
}

/// Reports the first mismatch with the seed and the complete trace through it.
func firstRandomizedMismatch<Operation, Observation: Equatable>(
    container: String,
    seed: UInt64,
    operations: [Operation],
    swift: [Observation],
    cpp: [Observation]
) -> String? {
    func trace(through last: Int) -> String {
        operations[...last].enumerated()
            .map { "  \($0.offset): \($0.element)" }
            .joined(separator: "\n")
    }

    for operationIndex in 0..<min(swift.count, cpp.count) where swift[operationIndex] != cpp[operationIndex] {
        return """
            container=\(container), seed=\(seed), operation=\(operationIndex), \
            input=\(operations[operationIndex]), swift=\(swift[operationIndex]), \
            cpp=\(cpp[operationIndex])
            trace through failure:
            \(trace(through: operationIndex))
            """
    }
    guard swift.count == cpp.count, swift.count == operations.count else {
        return """
            container=\(container), seed=\(seed), observation-count, \
            operations=\(operations.count), swift=\(swift.count), cpp=\(cpp.count)
            trace:
            \(operations.isEmpty ? "" : trace(through: operations.count - 1))
            """
    }
    return nil
}
