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
/// the complete key/value contents. `find`, however, does not use the mapped value
/// or rank as a returned fact because C++ does not specify which equivalent
/// occurrence `std::multimap::find` returns.
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
            // std::multimap::find may return any equivalent occurrence. Preserve
            // presence and the returned key, but deliberately erase occurrence
            // identity and rank from the common observable contract.
            entryResult = entry(at: index).map { MultiMapEntry(key: $0.key, value: 0) }
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
        let entry: MultiMapEntry? = observation.has_entry
            ? MultiMapEntry(key: observation.entry.key, value: observation.entry.value) : nil
        let comparableEntry: MultiMapEntry?
        let comparableRank: Int?
        if case .find = operation {
            // libstdc++, MSVC STL, libc++, and Swift need not choose the same
            // occurrence inside an equivalent-key group.
            comparableEntry = entry.map { MultiMapEntry(key: $0.key, value: 0) }
            comparableRank = nil
        } else {
            comparableEntry = entry
            comparableRank = observation.rank < 0 ? nil : Int(observation.rank)
        }
        return MultiMapObservation(
            operation: operation,
            entry: comparableEntry,
            rank: comparableRank,
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

// MARK: - Seeded randomized traces

// `SplitMix64` and `firstRandomizedMismatch` are shared in `SeededTraceSupport.swift`;
// the seeds, operation count, and phase length match the Set, MultiSet, and
// Dictionary traces.

private let multiMapRandomizedSeeds: [UInt64] = [1, 2, 3, 0x5EED, 0xC0FFEE]
private let multiMapRandomizedOperationCount = 300
/// Operations alternate between growing and shrinking phases of this length so each
/// trace repeatedly passes through dense, sparse, and empty states.
private let multiMapRandomizedPhaseLength = 40
/// Eight ordinary keys keep equivalent-key groups frequent and large.
private let multiMapRandomizedKeyDomain: ClosedRange<Int64> = 0...7
/// Occasional keys below and above every ordinary key.
private let multiMapRandomizedExtremeKeys: [Int64] = [.min, .max]

/// Generation-policy events, counted from the model state before each operation.
///
/// For a key whose equivalent group occupies ranks `lower..<upper`, every hint in
/// `lower...upper` is exact; the group-relative counters apply only when the group
/// is non-empty.
private struct MultiMapTraceCoverage: Equatable {
    var insertIntoEmpty = 0
    var insertIntoNonEmpty = 0
    var duplicateInsert = 0
    /// Insertion into a group that already holds at least two occurrences.
    var largeGroupInsert = 0
    var hintOnEmpty = 0
    var hintAtStart = 0
    var hintAtEnd = 0
    var exactHint = 0
    var poorHint = 0
    var hintBeforeGroup = 0
    var hintAtGroupStart = 0
    var hintInsideGroup = 0
    var hintAtGroupEnd = 0
    var hintAfterGroup = 0
    var extremeKey = 0
    var presentLookup = 0
    var absentLookup = 0
    var presentEraseKey = 0
    /// Erasure by key that removes at least two occurrences.
    var multiEraseKey = 0
    var absentEraseKey = 0
    var eraseAtFirst = 0
    var eraseAtLast = 0
    var eraseAtInterior = 0
    var removeAtFirst = 0
    var removeAtLast = 0
    var removeAtInterior = 0
    var assignAtFirst = 0
    var assignAtLast = 0
    var assignAtInterior = 0
    /// Mapped-value update of an occurrence whose group holds at least two occurrences.
    var assignInGroup = 0
    /// Positional erasure of an occurrence whose group holds at least two occurrences.
    var positionalInGroup = 0
    var emptiedByErase = 0
    /// Insertion into a multimap that an erasure had emptied.
    var reinsertAfterEmptied = 0
    /// Insertion of an absent key whose group an earlier erasure removed.
    var reinsertErasedKey = 0

    /// The names of events that never occurred.
    var missing: [String] { missingCoverage(self) }
}

/// Generates a valid stateful trace for `seed` from an independent ordered
/// `(key, mappedValue)` model.
///
/// Every value-bearing operation uses the distinct mapped value
/// `1_000 + operation number`, so each occurrence keeps an identity. Hints are current
/// zero-based ranks in `0...count`: the start or end of the key's equivalent group,
/// inside it, `startIndex`, `endIndex`, a poor rank before or after the group, or a
/// random rank. Positional operations use ranks in `0..<count`: the first, the last, a
/// random element, or an occurrence inside a present key's group.
///
/// The model places a hinted insertion as close as possible before the hint, as the
/// standard specifies; only counts and keys feed later generation, and Swift and C++
/// are compared with each other, not with the model.
private func generateMultiMapTrace(
    seed: UInt64,
    count operationCount: Int
) -> (operations: [MultiMapOperation], coverage: MultiMapTraceCoverage) {
    var random = SplitMix64(state: seed)
    var model: [MultiMapEntry] = []
    var coverage = MultiMapTraceCoverage()
    var operations: [MultiMapOperation] = []
    var erasedKeys: Set<Int64> = []
    var emptiedByErase = false

    func lowerRank(_ key: Int64) -> Int {
        model.firstIndex { $0.key >= key } ?? model.count
    }

    func upperRank(_ key: Int64) -> Int {
        model.firstIndex { $0.key > key } ?? model.count
    }

    func randomKey() -> Int64 {
        if random.next(below: 16) == 0 {
            return multiMapRandomizedExtremeKeys[random.next(below: multiMapRandomizedExtremeKeys.count)]
        }
        return multiMapRandomizedKeyDomain.lowerBound
            + Int64(random.next(below: multiMapRandomizedKeyDomain.count))
    }

    /// A present key with probability `percent`% when the model is non-empty.
    func key(presentPercent percent: Int) -> Int64 {
        if !model.isEmpty && random.next(below: 100) < percent {
            return model[random.next(below: model.count)].key
        }
        return randomKey()
    }

    func hintRank(for key: Int64) -> Int {
        let lower = lowerRank(key)
        let upper = upperRank(key)
        switch random.next(below: 8) {
        case 0: return lower
        case 1: return upper
        case 2: return upper - lower >= 2 ? lower + 1 + random.next(below: upper - lower - 1) : lower
        case 3: return 0
        case 4: return model.count
        case 5: return lower > 0 ? random.next(below: lower) : 0
        case 6: return upper < model.count ? upper + 1 + random.next(below: model.count - upper) : model.count
        default: return random.next(below: model.count + 1)
        }
    }

    func elementRank() -> Int {
        switch random.next(below: 4) {
        case 0: return 0
        case 1: return model.count - 1
        case 2: return random.next(below: model.count)
        default:
            let key = model[random.next(below: model.count)].key
            let lower = lowerRank(key)
            return lower + random.next(below: upperRank(key) - lower)
        }
    }

    for operationIndex in 0..<operationCount {
        let growing = (operationIndex / multiMapRandomizedPhaseLength) % 2 == 0
        let value = 1_000 + Int64(operationIndex)
        // Cumulative weights: insert, insertHint, find, lowerBound, upperBound,
        // equalRange, eraseKey, eraseAt, removeAt, assignAt.
        let weights = growing
            ? [18, 46, 52, 57, 62, 67, 74, 82, 90, 100]
            : [7, 18, 23, 27, 31, 35, 55, 72, 89, 100]
        let choice = random.next(below: 100)
        var operation: MultiMapOperation

        switch weights.firstIndex(where: { choice < $0 })! {
        case 0:
            operation = .insert(key(presentPercent: 50), value)
        case 1:
            let key = key(presentPercent: 50)
            operation = .insertHint(key, value, at: hintRank(for: key))
        case 2:
            operation = .find(key(presentPercent: 50))
        case 3:
            operation = .lowerBound(key(presentPercent: 50))
        case 4:
            operation = .upperBound(key(presentPercent: 50))
        case 5:
            operation = .equalRange(key(presentPercent: 50))
        case 6:
            operation = .eraseKey(key(presentPercent: growing ? 50 : 90))
        case 7:
            operation = model.isEmpty ? .insert(randomKey(), value) : .eraseAt(elementRank())
        case 8:
            operation = model.isEmpty ? .insert(randomKey(), value) : .removeAt(elementRank())
        default:
            operation = model.isEmpty ? .insert(randomKey(), value) : .assignAt(elementRank(), value)
        }

        let wasNonEmpty = !model.isEmpty
        switch operation {
        case .insert(let key, let value), .insertHint(let key, let value, _):
            let lower = lowerRank(key)
            let upper = upperRank(key)
            let groupCount = upper - lower
            if model.isEmpty {
                coverage.insertIntoEmpty += 1
                if emptiedByErase {
                    coverage.reinsertAfterEmptied += 1
                    emptiedByErase = false
                }
            } else {
                coverage.insertIntoNonEmpty += 1
            }
            if groupCount > 0 { coverage.duplicateInsert += 1 }
            if groupCount >= 2 { coverage.largeGroupInsert += 1 }
            if groupCount == 0 && erasedKeys.contains(key) { coverage.reinsertErasedKey += 1 }
            if multiMapRandomizedExtremeKeys.contains(key) { coverage.extremeKey += 1 }

            var placement = upper
            if case .insertHint(_, _, let position) = operation {
                if model.isEmpty {
                    coverage.hintOnEmpty += 1
                } else {
                    if position == 0 { coverage.hintAtStart += 1 }
                    if position == model.count { coverage.hintAtEnd += 1 }
                }
                if (lower...upper).contains(position) {
                    coverage.exactHint += 1
                } else {
                    coverage.poorHint += 1
                }
                if groupCount > 0 {
                    if position < lower { coverage.hintBeforeGroup += 1 }
                    if position == lower { coverage.hintAtGroupStart += 1 }
                    if position > lower && position < upper { coverage.hintInsideGroup += 1 }
                    if position == upper { coverage.hintAtGroupEnd += 1 }
                    if position > upper { coverage.hintAfterGroup += 1 }
                }
                placement = min(max(position, lower), upper)
            }
            model.insert(MultiMapEntry(key: key, value: value), at: placement)

        case .find(let key), .lowerBound(let key), .upperBound(let key),
             .equalRange(let key):
            if multiMapRandomizedExtremeKeys.contains(key) { coverage.extremeKey += 1 }
            if lowerRank(key) < upperRank(key) {
                coverage.presentLookup += 1
            } else {
                coverage.absentLookup += 1
            }

        case .eraseKey(let key):
            if multiMapRandomizedExtremeKeys.contains(key) { coverage.extremeKey += 1 }
            let lower = lowerRank(key)
            let upper = upperRank(key)
            if lower < upper {
                coverage.presentEraseKey += 1
                if upper - lower >= 2 { coverage.multiEraseKey += 1 }
                model.removeSubrange(lower..<upper)
                erasedKeys.insert(key)
            } else {
                coverage.absentEraseKey += 1
            }

        case .eraseAt(let position), .removeAt(let position):
            let key = model[position].key
            let isErase = if case .eraseAt = operation { true } else { false }
            let isFirst = position == 0
            let isLast = position == model.count - 1
            switch (isErase, isFirst, isLast) {
            case (true, true, _): coverage.eraseAtFirst += 1
            case (true, false, false): coverage.eraseAtInterior += 1
            case (false, true, _): coverage.removeAtFirst += 1
            case (false, false, false): coverage.removeAtInterior += 1
            default: break
            }
            if isLast {
                if isErase { coverage.eraseAtLast += 1 } else { coverage.removeAtLast += 1 }
            }
            if upperRank(key) - lowerRank(key) >= 2 { coverage.positionalInGroup += 1 }
            model.remove(at: position)
            if lowerRank(key) == upperRank(key) { erasedKeys.insert(key) }

        case .assignAt(let position, let value):
            let key = model[position].key
            if position == 0 { coverage.assignAtFirst += 1 }
            if position == model.count - 1 { coverage.assignAtLast += 1 }
            if position > 0 && position < model.count - 1 { coverage.assignAtInterior += 1 }
            if upperRank(key) - lowerRank(key) >= 2 { coverage.assignInGroup += 1 }
            model[position] = MultiMapEntry(key: key, value: value)
        }

        if wasNonEmpty && model.isEmpty {
            coverage.emptiedByErase += 1
            emptiedByErase = true
        }
        operations.append(operation)
    }

    return (operations, coverage)
}

extension MultiMapBehaviorComparisonTests {
    /// Seeded MultiMap traces are deterministic and cover the generation policy
    func test_multiMapRandomizedTraceIsDeterministicAndCovered() {
        for seed in multiMapRandomizedSeeds {
            multiMapRandomizedTraceIsDeterministicAndCovered(seed: seed)
        }
    }

    /// Runs one seed in its own scope so every collection is released before the next seed.
    private func multiMapRandomizedTraceIsDeterministicAndCovered(seed: UInt64) {
        let first = generateMultiMapTrace(seed: seed, count: multiMapRandomizedOperationCount)
        let second = generateMultiMapTrace(seed: seed, count: multiMapRandomizedOperationCount)
        XCTAssertEqual(first.operations, second.operations, "seed=\(seed)")
        XCTAssertEqual(first.coverage, second.coverage, "seed=\(seed)")
        XCTAssertTrue(first.coverage.missing.isEmpty, "seed=\(seed), missing=\(first.coverage.missing)")
    }
}

extension MultiMapBehaviorComparisonTests {
    /// RedBlackTreeMultiMap matches std::multimap for seeded randomized traces
    func test_multiMapSeededRandomizedTraceMatchesCpp() {
        for seed in multiMapRandomizedSeeds {
            multiMapSeededRandomizedTraceMatchesCpp(seed: seed)
        }
    }

    /// Runs one seed in its own scope so every collection is released before the next seed.
    private func multiMapSeededRandomizedTraceMatchesCpp(seed: UInt64) {
        let operations = generateMultiMapTrace(seed: seed, count: multiMapRandomizedOperationCount).operations
        let swift: [MultiMapObservation]
        let cpp: [MultiMapObservation]
        do {
            swift = try executeSwiftTrace(operations)
            cpp = try executeCppTrace(operations)
        } catch {
            XCTFail("container=\(multiMapContainer), seed=\(seed), executor error=\(error)")
            return
        }

        let mismatch = firstRandomizedMismatch(
            container: multiMapContainer, seed: seed, operations: operations, swift: swift, cpp: cpp)
        if let mismatch { XCTFail(mismatch) }
    }
}

extension MultiMapBehaviorComparisonTests {
    /// A seeded MultiMap mismatch report contains the seed and the trace through failure
    ///
    /// Checks the shared seeded diagnostic with the MultiMap observation shape,
    /// tampering with the previous mapped value returned by a positional update.
    func test_multiMapRandomizedMismatchReportContainsRequiredContext() throws {
        let seed = multiMapRandomizedSeeds[0]
        let operations = generateMultiMapTrace(seed: seed, count: multiMapRandomizedOperationCount).operations
        let swift = try executeSwiftTrace(operations)
        // Tamper with one observation instead of relying on a library defect.
        let failing = try XCTUnwrap(swift.indices.first { $0 >= 17 && swift[$0].previous != nil })
        var cpp = swift
        let original = cpp[failing]
        cpp[failing] = MultiMapObservation(
            operation: original.operation,
            entry: original.entry,
            rank: original.rank,
            upperRank: original.upperRank,
            previous: original.previous.map { $0 + 1 },
            count: original.count,
            range: original.range,
            contents: original.contents
        )

        let message = try XCTUnwrap(firstRandomizedMismatch(
            container: multiMapContainer, seed: seed, operations: operations, swift: swift, cpp: cpp))
        XCTAssertTrue(message.contains("container=\(multiMapContainer)"))
        XCTAssertTrue(message.contains("seed=\(seed)"))
        XCTAssertTrue(message.contains("operation=\(failing)"))
        XCTAssertTrue(message.contains("input=\(operations[failing])"))
        XCTAssertTrue(message.contains("swift=\(swift[failing])"))
        XCTAssertTrue(message.contains("cpp=\(cpp[failing])"))
        XCTAssertTrue(message.contains("\(swift[failing].contents)"))
        for operationIndex in 0...failing {
            XCTAssertTrue(message.contains("\n  \(operationIndex): \(operations[operationIndex])"))
        }
        XCTAssertFalse(message.contains("\n  \(failing + 1): "))
    }
}
