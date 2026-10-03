import AcCollections
import CppBehaviorReference
import XCTest

final class MultiMapBehaviorComparisonTests: CppBehaviorReferenceTestCase {}

/// Each case pairs one Swift API with the `std::multimap` operation that has the
/// same observable contract:
///
/// | Case | Swift | C++ |
/// | --- | --- | --- |
/// | `insert` | `insert(key:value:)` | `insert({k, v})` |
/// | `insertHint` | `insert(_:hint:)` | `insert(hint, {k, v})` |
/// | `find` | `find(_:)`, `count(forKey:)` | `find(k)`, `count(k)` |
/// | `lowerBound` / `upperBound` | `lowerBound(_:)` / `upperBound(_:)` | `lower_bound(k)` / `upper_bound(k)` |
/// | `equalRange` | `multimap[equalRange(_:)]` | `equal_range(k)` |
/// | `eraseKey` | `eraseMulti(_:)` | `erase(k)` |
/// | `eraseAt` | `erase(_:)` | `erase(it)` |
/// | `removeAt` | `remove(at:)` | copy `*it`, then `erase(it)` |
/// | `assignAt` | `updateValue(_:at:)` | copy `it->second`, then `it->second = v` |
///
/// Mapped values are occurrence identities: traces use distinct values so the
/// placement of each occurrence inside an equivalent-key group is observable in
/// the complete key/value contents.
private enum MultiMapOperation: Equatable {
    case insert(Int64, Int64)
    case insertHint(Int64, Int64, at: Int)
    case find(Int64)
    case lowerBound(Int64)
    case upperBound(Int64)
    case equalRange(Int64)
    case eraseKey(Int64)
    case eraseAt(Int)
    case removeAt(Int)
    case assignAt(Int, Int64)

    var cOperation: CppMultiMapOperation {
        var result = CppMultiMapOperation()
        result.position = -1
        switch self {
        case .insert(let key, let value):
            result.kind = Int32(CPP_MULTIMAP_OPERATION_INSERT)
            (result.key, result.value) = (key, value)
        case .insertHint(let key, let value, let position):
            result.kind = Int32(CPP_MULTIMAP_OPERATION_INSERT_HINT)
            (result.key, result.value, result.position) = (key, value, Int64(position))
        case .find(let key):
            result.kind = Int32(CPP_MULTIMAP_OPERATION_FIND)
            result.key = key
        case .lowerBound(let key):
            result.kind = Int32(CPP_MULTIMAP_OPERATION_LOWER_BOUND)
            result.key = key
        case .upperBound(let key):
            result.kind = Int32(CPP_MULTIMAP_OPERATION_UPPER_BOUND)
            result.key = key
        case .equalRange(let key):
            result.kind = Int32(CPP_MULTIMAP_OPERATION_EQUAL_RANGE)
            result.key = key
        case .eraseKey(let key):
            result.kind = Int32(CPP_MULTIMAP_OPERATION_ERASE_KEY)
            result.key = key
        case .eraseAt(let position):
            result.kind = Int32(CPP_MULTIMAP_OPERATION_ERASE_AT)
            result.position = Int64(position)
        case .removeAt(let position):
            result.kind = Int32(CPP_MULTIMAP_OPERATION_REMOVE_AT)
            result.position = Int64(position)
        case .assignAt(let position, let value):
            result.kind = Int32(CPP_MULTIMAP_OPERATION_ASSIGN_AT)
            (result.value, result.position) = (value, Int64(position))
        }
        return result
    }
}

private struct MultiMapEntry: Equatable, CustomStringConvertible {
    let key: Int64
    let value: Int64

    var description: String { "\(key):\(value)" }
}

/// Unreported facts are `nil`.
private struct MultiMapObservation: Equatable {
    let operation: MultiMapOperation
    let entry: MultiMapEntry?
    let rank: Int?
    let upperRank: Int?
    let previous: Int64?
    let count: Int?
    let range: [MultiMapEntry]
    let contents: [MultiMapEntry]
}

private enum MultiMapTraceError: Error {
    case cppExecutorFailed(Int32)
    case invalidPosition(Int)
}

private func executeSwiftTrace(_ operations: [MultiMapOperation]) throws -> [MultiMapObservation] {
    typealias Index = RedBlackTreeMultiMap<Int64, Int64>.Index
    var multimap = RedBlackTreeMultiMap<Int64, Int64>()

    func rank(_ index: Index) -> Int {
        multimap.distance(from: multimap.startIndex, to: index)
    }

    /// Resolves a rank in `0...count`; the result must be an element or `endIndex`.
    func hint(at position: Int) throws -> Index {
        guard position >= 0 && position <= multimap.count else {
            throw MultiMapTraceError.invalidPosition(position)
        }
        let index = multimap.index(multimap.startIndex, offsetBy: position)
        guard multimap.isElement(at: index) || multimap.isEnd(index) else {
            throw MultiMapTraceError.invalidPosition(position)
        }
        return index
    }

    /// Resolves a rank in `0..<count`; the result must be an element.
    func element(at position: Int) throws -> Index {
        guard position >= 0 && position < multimap.count else {
            throw MultiMapTraceError.invalidPosition(position)
        }
        let index = multimap.index(multimap.startIndex, offsetBy: position)
        guard multimap.isElement(at: index) else {
            throw MultiMapTraceError.invalidPosition(position)
        }
        return index
    }

    func entry(at index: Index) -> MultiMapEntry? {
        guard index != multimap.endIndex else { return nil }
        let element = multimap[index]
        return MultiMapEntry(key: element.key, value: element.value)
    }

    return try operations.map { operation in
        var entryResult: MultiMapEntry?
        var rankResult: Int?
        var upperRank: Int?
        var previous: Int64?
        var count: Int?
        var range: [MultiMapEntry] = []

        switch operation {
        case .insert(let key, let value):
            // Neither side's result exposes a rank comparable without an extra
            // lookup; placement is compared through the complete contents.
            multimap.insert(key: key, value: value)
        case .insertHint(let key, let value, let position):
            let index = multimap.insert((key, value), hint: try hint(at: position))
            entryResult = entry(at: index)
            rankResult = rank(index)
        case .find(let key):
            let index = multimap.find(key)
            entryResult = entry(at: index)
            rankResult = rank(index)
            count = multimap.count(forKey: key)
        case .lowerBound(let key), .upperBound(let key):
            let index: Index
            if case .lowerBound = operation {
                index = multimap.lowerBound(key)
            } else {
                index = multimap.upperBound(key)
            }
            entryResult = entry(at: index)
            rankResult = rank(index)
        case .equalRange(let key):
            let view = multimap[multimap.equalRange(key)]
            rankResult = rank(view.startIndex)
            upperRank = rank(view.endIndex)
            range = view.map { MultiMapEntry(key: $0.key, value: $0.value) }
        case .eraseKey(let key):
            count = multimap.eraseMulti(key)
        case .eraseAt(let position):
            rankResult = rank(multimap.erase(try element(at: position)))
        case .removeAt(let position):
            let removed = multimap.remove(at: try element(at: position))
            entryResult = MultiMapEntry(key: removed.key, value: removed.value)
        case .assignAt(let position, let value):
            previous = multimap.updateValue(value, at: try element(at: position))
        }

        return MultiMapObservation(
            operation: operation,
            entry: entryResult,
            rank: rankResult,
            upperRank: upperRank,
            previous: previous,
            count: count,
            range: range,
            contents: multimap.map { MultiMapEntry(key: $0.key, value: $0.value) }
        )
    }
}

private func executeCppTrace(_ operations: [MultiMapOperation]) throws -> [MultiMapObservation] {
    let cOperations = operations.map(\.cOperation)
    var observations = Array(repeating: CppMultiMapObservation(), count: operations.count)
    // Each operation appends at most one equal range and one full snapshot, and
    // neither can exceed the number of operations performed so far.
    var contents = Array(repeating: CppMapEntry(), count: 2 * operations.count * operations.count)

    let status = cOperations.withUnsafeBufferPointer { operationBuffer in
        observations.withUnsafeMutableBufferPointer { observationBuffer in
            contents.withUnsafeMutableBufferPointer { contentsBuffer in
                cpp_multimap_execute_trace(
                    operationBuffer.baseAddress,
                    operationBuffer.count,
                    observationBuffer.baseAddress,
                    observationBuffer.count,
                    contentsBuffer.baseAddress,
                    contentsBuffer.count
                )
            }
        }
    }
    guard status == CPP_MULTIMAP_TRACE_SUCCESS else {
        throw MultiMapTraceError.cppExecutorFailed(status)
    }

    func slice(offset: Int, count: Int) -> [MultiMapEntry] {
        contents[offset..<(offset + count)].map { MultiMapEntry(key: $0.key, value: $0.value) }
    }

    return zip(operations, observations).map { operation, observation in
        MultiMapObservation(
            operation: operation,
            entry: observation.has_entry
                ? MultiMapEntry(key: observation.entry.key, value: observation.entry.value) : nil,
            rank: observation.rank < 0 ? nil : Int(observation.rank),
            upperRank: observation.upper_rank < 0 ? nil : Int(observation.upper_rank),
            previous: observation.has_previous ? observation.previous_value : nil,
            count: observation.count < 0 ? nil : Int(observation.count),
            range: slice(offset: Int(observation.range_offset), count: Int(observation.range_count)),
            contents: slice(offset: Int(observation.contents_offset), count: Int(observation.contents_count))
        )
    }
}

private func firstMismatch(
    container: String,
    swift: [MultiMapObservation],
    cpp: [MultiMapObservation]
) -> String? {
    for operationIndex in 0..<min(swift.count, cpp.count) where swift[operationIndex] != cpp[operationIndex] {
        return "container=\(container), operation=\(operationIndex), input=\(swift[operationIndex].operation), swift=\(swift[operationIndex]), cpp=\(cpp[operationIndex])"
    }
    guard swift.count == cpp.count else {
        return "container=\(container), observation-count, swift=\(swift.count), cpp=\(cpp.count)"
    }
    return nil
}

private let multiMapContainer = "RedBlackTreeMultiMap/std::multimap"

extension MultiMapBehaviorComparisonTests {
    /// RedBlackTreeMultiMap matches std::multimap for insertion, bounds, equal ranges, and erasure
    func test_multiMapCuratedTraceMatchesCpp() throws {
        let operations: [MultiMapOperation] = [
            .insert(20, 201),
            .insert(10, 101),
            .insert(20, 202), // Duplicate key; placed after 20:201.
            .insert(30, 301),
            .insert(20, 203), // Duplicate key; placed after 20:202.
            // [10:101, 20:201, 20:202, 20:203, 30:301]
            .find(20),
            .find(25),
            .lowerBound(5),  // Before.
            .lowerBound(20), // At.
            .lowerBound(25), // Between.
            .lowerBound(35), // After.
            .upperBound(5),
            .upperBound(20),
            .upperBound(25),
            .upperBound(30),
            .equalRange(5),
            .equalRange(20),
            .equalRange(25),
            .equalRange(35),
            .eraseKey(20), // Removes every occurrence.
            .eraseKey(20), // Absent.
            .equalRange(20),
            .eraseKey(10),
        ]

        let swift = try executeSwiftTrace(operations)
        let cpp = try executeCppTrace(operations)
        XCTAssertNil(firstMismatch(container: multiMapContainer, swift: swift, cpp: cpp))
    }
}

extension MultiMapBehaviorComparisonTests {
    /// RedBlackTreeMultiMap positional erase and update match std::multimap
    func test_multiMapPositionalOperationsMatchCpp() throws {
        let operations: [MultiMapOperation] = [
            .insert(10, 101),
            .insert(20, 201),
            .insert(20, 202),
            .insert(20, 203),
            .insert(30, 301),
            // [10:101, 20:201, 20:202, 20:203, 30:301]
            .assignAt(2, 999), // Middle of the group; previous value 202.
            .assignAt(0, 100), // First element.
            .eraseAt(2),       // Middle of the group; next is 20:203.
            .eraseAt(3),       // Last element; next is endIndex.
            .removeAt(1),      // First of the group.
            .removeAt(0),      // First element.
            .eraseAt(0),       // Only element; next is endIndex of an empty multimap.
        ]

        let swift = try executeSwiftTrace(operations)
        let cpp = try executeCppTrace(operations)
        XCTAssertNil(firstMismatch(container: multiMapContainer, swift: swift, cpp: cpp))
    }
}

extension MultiMapBehaviorComparisonTests {
    /// RedBlackTreeMultiMap hinted insertion places occurrences like std::multimap
    func test_multiMapHintedInsertionMatchesCpp() throws {
        let operations: [MultiMapOperation] = [
            .insertHint(20, 201, at: 0), // Empty multimap: startIndex == endIndex.
            .insertHint(20, 202, at: 1), // endIndex, after the group.
            .insertHint(20, 203, at: 0), // startIndex, exact hint before the group.
            // [20:203, 20:201, 20:202]
            .insertHint(10, 101, at: 0), // startIndex; exact for a new least key.
            .insertHint(30, 301, at: 4), // endIndex; exact for a new greatest key.
            // [10:101, 20:203, 20:201, 20:202, 30:301]
            .insertHint(20, 204, at: 1), // Exact hint before the group (first 20).
            .insertHint(20, 205, at: 5), // Exact hint after the group (hint is 30).
            .insertHint(20, 206, at: 3), // Inside the group.
            .insertHint(20, 207, at: 0), // Poor hint before the group (hint is 10).
            .insertHint(20, 208, at: 9), // endIndex; poor hint after the group.
            .insertHint(10, 102, at: 10), // endIndex; poor for an existing least key.
            .insertHint(30, 302, at: 0),  // startIndex; poor for an existing greatest key.
            .equalRange(20),
            .eraseAt(4),                  // Erase one occurrence inside the group.
            .insertHint(20, 209, at: 4),  // Reinsert at the vacated position.
            .eraseKey(20),
            .insertHint(20, 210, at: 2),  // Reinsertion after erasing the group (hint is 30).
            .insertHint(20, 211, at: 2),  // Exact hint before the reinserted group.
        ]

        let swift = try executeSwiftTrace(operations)
        let cpp = try executeCppTrace(operations)
        XCTAssertNil(firstMismatch(container: multiMapContainer, swift: swift, cpp: cpp))
    }
}

extension MultiMapBehaviorComparisonTests {
    /// RedBlackTreeMultiMap erase-then-reinsert at boundaries matches std::multimap
    func test_multiMapBoundaryReinsertionMatchesCpp() throws {
        let operations: [MultiMapOperation] = [
            .insert(10, 101),
            .insert(10, 102),
            .insert(20, 201),
            .insert(30, 301),
            .insert(30, 302),
            // [10:101, 10:102, 20:201, 30:301, 30:302]
            .eraseAt(0),                  // First element (first of the least group).
            .insertHint(10, 103, at: 0),  // Reinsert at startIndex, before 10:102.
            .eraseAt(4),                  // Last element (last of the greatest group).
            .insertHint(30, 303, at: 4),  // Reinsert at endIndex, after 30:301.
            // [10:103, 10:102, 20:201, 30:301, 30:303]
            .eraseKey(10),                // Erase the least group.
            .insertHint(10, 104, at: 0),  // Reinsert at startIndex.
            .insertHint(10, 105, at: 4),  // endIndex; poor reinsertion into the least group.
            .eraseKey(30),                // Erase the greatest group.
            .insertHint(30, 304, at: 3),  // Reinsert at endIndex.
            .insertHint(30, 305, at: 0),  // startIndex; poor reinsertion into the greatest group.
            .removeAt(0),
            .removeAt(0),
            .removeAt(0),
            .eraseAt(0),
            .eraseAt(0),                  // Now empty.
            .insertHint(20, 202, at: 0),  // Reinsert into the emptied multimap.
            .insertHint(20, 203, at: 0),  // startIndex, before a one-element group.
            .insertHint(20, 204, at: 2),  // endIndex, after the same group.
            .equalRange(20),
        ]

        let swift = try executeSwiftTrace(operations)
        let cpp = try executeCppTrace(operations)
        XCTAssertNil(firstMismatch(container: multiMapContainer, swift: swift, cpp: cpp))
    }
}

extension MultiMapBehaviorComparisonTests {
    /// A MultiMap mismatch report identifies both observations and the operation
    func test_multiMapMismatchReportContainsRequiredContext() {
        let operation = MultiMapOperation.insertHint(20, 202, at: 1)
        func observation(rank: Int, contents: [MultiMapEntry]) -> MultiMapObservation {
            MultiMapObservation(
                operation: operation, entry: MultiMapEntry(key: 20, value: 202), rank: rank,
                upperRank: nil, previous: nil, count: nil, range: [], contents: contents)
        }
        let swift = [observation(
            rank: 1, contents: [MultiMapEntry(key: 20, value: 202), MultiMapEntry(key: 20, value: 201)])]
        let cpp = [observation(
            rank: 2, contents: [MultiMapEntry(key: 20, value: 201), MultiMapEntry(key: 20, value: 202)])]

        let message = firstMismatch(container: multiMapContainer, swift: swift, cpp: cpp)
        XCTAssertEqual(message?.contains("container=RedBlackTreeMultiMap/std::multimap"), true)
        XCTAssertEqual(message?.contains("operation=0"), true)
        XCTAssertEqual(message?.contains("input=insertHint(20, 202, at: 1)"), true)
        XCTAssertEqual(message?.contains("swift="), true)
        XCTAssertEqual(message?.contains("rank: Optional(1)"), true)
        XCTAssertEqual(message?.contains("[20:202, 20:201]"), true)
        XCTAssertEqual(message?.contains("cpp="), true)
        XCTAssertEqual(message?.contains("rank: Optional(2)"), true)
        XCTAssertEqual(message?.contains("[20:201, 20:202]"), true)
    }
}
