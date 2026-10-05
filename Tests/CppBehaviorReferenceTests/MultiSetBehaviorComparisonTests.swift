#if !COMPATIBLE_ATCODER_2025
import AcCollections
import CppBehaviorReference
import XCTest

final class MultiSetBehaviorComparisonTests: CppBehaviorReferenceTestCase {}

private enum MultiSetOperation: Equatable {
    case insert(Int64)
    case insertHint(Int64, at: Int)
    case lowerBound(Int64)
    case upperBound(Int64)
    case equalRange(Int64)
    case eraseKey(Int64)
    case eraseAt(Int)
    case removeAt(Int)
    case find(Int64)

    var argument: Int64 {
        switch self {
        case .insert(let value), .insertHint(let value, _),
             .lowerBound(let value), .upperBound(let value),
             .equalRange(let value), .eraseKey(let value),
             .find(let value):
            value
        case .eraseAt, .removeAt:
            0
        }
    }

    var cKind: Int32 {
        switch self {
        case .insert: Int32(CPP_MULTISET_OPERATION_INSERT)
        case .insertHint: Int32(CPP_MULTISET_OPERATION_INSERT_HINT)
        case .lowerBound: Int32(CPP_MULTISET_OPERATION_LOWER_BOUND)
        case .upperBound: Int32(CPP_MULTISET_OPERATION_UPPER_BOUND)
        case .equalRange: Int32(CPP_MULTISET_OPERATION_EQUAL_RANGE)
        case .eraseKey: Int32(CPP_MULTISET_OPERATION_ERASE_KEY)
        case .eraseAt: Int32(CPP_MULTISET_OPERATION_ERASE_AT)
        case .removeAt: Int32(CPP_MULTISET_OPERATION_REMOVE_AT)
        case .find: Int32(CPP_MULTISET_OPERATION_FIND)
        }
    }

    var position: Int64 {
        switch self {
        case .insertHint(_, let position), .eraseAt(let position),
             .removeAt(let position):
            Int64(position)
        default: -1
        }
    }
}

/// Equivalent `Int64` occurrences carry no identity. Where a new occurrence lands
/// inside an equivalent-key group is observed through `rank`, the zero-based
/// position of the returned index/iterator.
private struct MultiSetObservation: Equatable {
    let operation: MultiSetOperation
    let value: Int64?
    let rank: Int?
    let erasedCount: Int?
    /// `contains(_:)`, or `nil` when not reported.
    var found: Bool? = nil
    /// `count(of:)`, or `nil` when not reported.
    var count: Int? = nil
    let range: [Int64]
    let contents: [Int64]
}

private enum MultiSetTraceError: Error {
    case cppExecutorFailed(Int32)
    case invalidPosition(Int)
}

private func executeSwiftTrace(_ operations: [MultiSetOperation]) throws -> [MultiSetObservation] {
    var set = RedBlackTreeMultiSet<Int64>()

    func rank(_ index: RedBlackTreeMultiSet<Int64>.Index) -> Int {
        set.distance(from: set.startIndex, to: index)
    }

    /// Resolves a rank in `0..<count`; the result must be an element.
    func element(at position: Int) throws -> RedBlackTreeMultiSet<Int64>.Index {
        guard position >= 0 && position < set.count else {
            throw MultiSetTraceError.invalidPosition(position)
        }
        let index = set.index(set.startIndex, offsetBy: position)
        guard set.isElement(at: index) else {
            throw MultiSetTraceError.invalidPosition(position)
        }
        return index
    }

    return try operations.map { operation in
        var value: Int64?
        var rankResult: Int?
        var erasedCount: Int?
        var found: Bool?
        var count: Int?
        var range: [Int64] = []

        switch operation {
        case .insert(let newMember):
            value = set.insert(newMember).memberAfterInsert
        case .insertHint(let newMember, let position):
            guard position >= 0 && position <= set.count else {
                throw MultiSetTraceError.invalidPosition(position)
            }
            let hint = set.index(set.startIndex, offsetBy: position)
            let index = set.insert(newMember, hint: hint)
            value = set[index]
            rankResult = rank(index)
        case .lowerBound(let member), .upperBound(let member):
            let index: RedBlackTreeMultiSet<Int64>.Index
            if case .lowerBound = operation {
                index = set.lowerBound(member)
            } else {
                index = set.upperBound(member)
            }
            value = index == set.endIndex ? nil : set[index]
            rankResult = rank(index)
        case .equalRange(let member):
            range = Array(set[set.equalRange(member)])
        case .eraseKey(let member):
            erasedCount = set.eraseMulti(member)
        case .eraseAt(let position):
            rankResult = rank(set.erase(try element(at: position)))
        case .removeAt(let position):
            value = set.remove(at: try element(at: position))
        case .find(let member):
            found = set.contains(member)
            count = set.count(of: member)
        }

        return MultiSetObservation(
            operation: operation,
            value: value,
            rank: rankResult,
            erasedCount: erasedCount,
            found: found,
            count: count,
            range: range,
            contents: Array(set)
        )
    }
}

private func executeCppTrace(_ operations: [MultiSetOperation]) throws -> [MultiSetObservation] {
    let cOperations = operations.map { operation in
        var result = CppMultiSetOperation()
        result.kind = operation.cKind
        result.value = operation.argument
        result.position = operation.position
        return result
    }
    var observations = Array(repeating: CppMultiSetObservation(), count: operations.count)
    // Each operation appends at most one equal range and one full snapshot, and
    // neither can exceed the number of operations performed so far.
    var contents = Array(repeating: Int64.zero, count: 2 * operations.count * operations.count)

    let status = cOperations.withUnsafeBufferPointer { operationBuffer in
        observations.withUnsafeMutableBufferPointer { observationBuffer in
            contents.withUnsafeMutableBufferPointer { contentsBuffer in
                cpp_multiset_execute_trace(
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
    guard status == CPP_MULTISET_TRACE_SUCCESS else {
        throw MultiSetTraceError.cppExecutorFailed(status)
    }

    func slice(offset: Int, count: Int) -> [Int64] {
        Array(contents[offset..<(offset + count)])
    }

    return zip(operations, observations).map { operation, observation in
        MultiSetObservation(
            operation: operation,
            value: observation.has_value ? observation.value : nil,
            rank: observation.rank < 0 ? nil : Int(observation.rank),
            erasedCount: observation.erased_count < 0 ? nil : Int(observation.erased_count),
            found: observation.count < 0 ? nil : observation.found,
            count: observation.count < 0 ? nil : Int(observation.count),
            range: slice(offset: Int(observation.range_offset), count: Int(observation.range_count)),
            contents: slice(offset: Int(observation.contents_offset), count: Int(observation.contents_count))
        )
    }
}

private func firstMismatch(
    container: String,
    swift: [MultiSetObservation],
    cpp: [MultiSetObservation]
) -> String? {
    for operationIndex in 0..<min(swift.count, cpp.count) where swift[operationIndex] != cpp[operationIndex] {
        return "container=\(container), operation=\(operationIndex), input=\(swift[operationIndex].operation), swift=\(swift[operationIndex]), cpp=\(cpp[operationIndex])"
    }
    guard swift.count == cpp.count else {
        return "container=\(container), observation-count, swift=\(swift.count), cpp=\(cpp.count)"
    }
    return nil
}

private let multiSetContainer = "RedBlackTreeMultiSet/std::multiset"

extension MultiSetBehaviorComparisonTests {
    /// RedBlackTreeMultiSet matches std::multiset for insertion, bounds, equal ranges, and erasure
    func test_multiSetCuratedTraceMatchesCpp() throws {
        let operations: [MultiSetOperation] = [
            .insert(20),
            .insert(10),
            .insert(20), // Duplicate.
            .insert(30),
            .insert(20), // Duplicate.
            .lowerBound(0),
            .lowerBound(20),
            .upperBound(20),
            .lowerBound(25),
            .upperBound(30),
            .equalRange(20),
            .equalRange(15),
            .equalRange(10),
            .eraseKey(20), // Removes every equivalent occurrence.
            .eraseKey(20), // Absent key.
            .equalRange(20),
            .eraseKey(10),
        ]

        let swift = try executeSwiftTrace(operations)
        let cpp = try executeCppTrace(operations)
        XCTAssertNil(firstMismatch(container: multiSetContainer, swift: swift, cpp: cpp))
    }
}

extension MultiSetBehaviorComparisonTests {
    /// RedBlackTreeMultiSet non-endIndex hinted insertion matches std::multiset around an equivalent-key group
    func test_multiSetNonEndIndexHintedInsertionMatchesCpp() throws {
        let operations: [MultiSetOperation] = [
            .insert(10),
            .insert(20),
            .insert(20),
            .insert(30),
            // [10, 20, 20, 30]
            .insertHint(20, at: 1), // Exact hint at the start of the group.
            .insertHint(20, at: 2), // Within the group.
            .insertHint(20, at: 5), // After the group (hint is 30).
            .insertHint(20, at: 0), // Before the group (hint is 10); poor but valid.
            .insertHint(5, at: 7),  // Deliberately poor hint for a new least key.
            .insertHint(5, at: 1),  // Exact hint after the existing 5.
            .insertHint(30, at: 0), // Deliberately poor hint before an existing 30.
            .equalRange(20),
            .eraseKey(20),
            .insertHint(20, at: 3), // Reinsertion after erasure (hint is 30).
        ]

        let swift = try executeSwiftTrace(operations)
        let cpp = try executeCppTrace(operations)
        XCTAssertNil(firstMismatch(container: multiSetContainer, swift: swift, cpp: cpp))
    }
}

extension MultiSetBehaviorComparisonTests {
    /// RedBlackTreeMultiSet hinted insertion matches std::multiset around an equivalent-key group
    func test_multiSetHintedInsertionMatchesCpp() throws {
        let operations: [MultiSetOperation] = [
            .insert(10),
            .insert(20),
            .insert(20),
            .insert(30),
            // [10, 20, 20, 30]
            .insertHint(20, at: 1), // Exact hint at the start of the group.
            .insertHint(20, at: 2), // Within the group.
            .insertHint(20, at: 5), // After the group (hint is 30).
            .insertHint(20, at: 7), // endIndex.
            .insertHint(20, at: 0), // Before the group (hint is 10); poor but valid.
            .insertHint(5, at: 8),  // Deliberately poor hint for a new least key.
            .insertHint(5, at: 10), // endIndex, with an existing equivalent least key.
            .insertHint(5, at: 1),  // Exact hint between the two 5s.
            .insertHint(30, at: 0), // Deliberately poor hint before an existing 30.
            .insertHint(40, at: 13), // endIndex for a new greatest key.
            .equalRange(20),
            .eraseKey(20),
            .insertHint(20, at: 4), // Reinsertion after erasure (hint is 30).
        ]

        let swift = try executeSwiftTrace(operations)
        let cpp = try executeCppTrace(operations)
        XCTAssertNil(firstMismatch(container: multiSetContainer, swift: swift, cpp: cpp))
    }
}

extension MultiSetBehaviorComparisonTests {
    /// RedBlackTreeMultiSet boundary hints and erase-then-reinsert match std::multiset
    func test_multiSetBoundaryHintsAndReinsertionMatchCpp() throws {
        let operations: [MultiSetOperation] = [
            .insertHint(20, at: 0), // Empty multiset: startIndex == endIndex.
            .insertHint(10, at: 0), // startIndex; exact for a new least key.
            .insertHint(10, at: 0), // startIndex; before the least group.
            .insertHint(30, at: 3), // endIndex; exact for a new greatest key.
            .insertHint(30, at: 4), // endIndex; after the greatest group.
            // [10, 10, 20, 30, 30]
            .insertHint(10, at: 2), // Exact hint after the least group.
            .insertHint(30, at: 4), // Exact hint before the greatest group (hint is first 30).
            .insertHint(10, at: 7), // endIndex; poor for the least group.
            .insertHint(30, at: 0), // startIndex; poor for the greatest group.
            // [10, 10, 10, 10, 20, 30, 30, 30, 30]
            .eraseKey(10),          // Erase the least group.
            .insertHint(10, at: 0), // Reinsert at startIndex.
            .insertHint(10, at: 6), // endIndex; poor reinsertion into the new least group.
            .eraseKey(30),          // Erase the greatest group.
            .insertHint(30, at: 3), // Reinsert at endIndex.
            .insertHint(30, at: 0), // startIndex; poor reinsertion into the new greatest group.
            .eraseKey(10),
            .eraseKey(20),
            .eraseKey(30),          // Now empty.
            .insertHint(20, at: 0), // Reinsert into the emptied multiset.
            .insertHint(20, at: 0), // startIndex, inside a one-element group.
            .insertHint(20, at: 2), // endIndex, after the same group.
            .equalRange(20),
        ]

        let swift = try executeSwiftTrace(operations)
        let cpp = try executeCppTrace(operations)
        XCTAssertNil(firstMismatch(container: multiSetContainer, swift: swift, cpp: cpp))
    }
}

extension MultiSetBehaviorComparisonTests {
    /// RedBlackTreeMultiSet positional erase and hinted reinsertion match std::multiset
    ///
    /// `erase(_:)` exposes only the next position and `remove(at:)` only the erased
    /// element, so each is compared against its C++ counterpart for that fact alone.
    func test_multiSetPositionalEraseMatchesCpp() throws {
        let operations: [MultiSetOperation] = [
            .insertHint(20, at: 0), // Empty multiset.
            .insert(10),
            .insert(20),
            .insert(20),
            .insert(30),
            .insert(30),
            // [10, 20, 20, 20, 30, 30]
            .eraseAt(2),            // Interior occurrence of the 20 group; next is rank 2.
            .removeAt(2),           // Last occurrence of the 20 group.
            .eraseAt(0),            // First element; next is rank 0.
            .insertHint(10, at: 0), // Reinsert at startIndex.
            .removeAt(3),           // Last element.
            .eraseAt(2),            // Last element; next is endIndex.
            .insertHint(30, at: 2), // Reinsert at endIndex.
            .insertHint(30, at: 2), // Exact hint before the new last occurrence.
            .removeAt(0),           // First element.
            // [20, 30, 30]
            .insertHint(20, at: 0), // startIndex, before the least group.
            .eraseAt(0),            // First occurrence of the least group.
            .eraseAt(1),            // First occurrence of the greatest group.
            .insertHint(30, at: 1), // Reinsert before the remaining 30.
            .insertHint(20, at: 1), // Reinsert after the remaining 20.
            // [20, 20, 30, 30]
            .removeAt(0),
            .removeAt(0),
            .eraseAt(1),
            .eraseAt(0),            // Now empty; next is endIndex.
            .insertHint(20, at: 0), // Reinsert into the emptied multiset.
            .insertHint(20, at: 1), // endIndex, after the same group.
            .equalRange(20),
        ]

        let swift = try executeSwiftTrace(operations)
        let cpp = try executeCppTrace(operations)
        XCTAssertNil(firstMismatch(container: multiSetContainer, swift: swift, cpp: cpp))
    }
}

extension MultiSetBehaviorComparisonTests {
    /// A MultiSet mismatch report identifies both observations and the operation
    func test_multiSetMismatchReportContainsRequiredContext() {
        let operation = MultiSetOperation.insertHint(20, at: 1)
        let swift = [MultiSetObservation(
            operation: operation, value: 20, rank: 1, erasedCount: nil, range: [], contents: [10, 20, 20])]
        let cpp = [MultiSetObservation(
            operation: operation, value: 20, rank: 2, erasedCount: nil, range: [], contents: [10, 20, 20])]

        let message = firstMismatch(container: multiSetContainer, swift: swift, cpp: cpp)
        XCTAssertEqual(message?.contains("container=RedBlackTreeMultiSet/std::multiset"), true)
        XCTAssertEqual(message?.contains("operation=0"), true)
        XCTAssertEqual(message?.contains("input=insertHint(20, at: 1)"), true)
        XCTAssertEqual(message?.contains("swift="), true)
        XCTAssertEqual(message?.contains("rank: Optional(1)"), true)
        XCTAssertEqual(message?.contains("cpp="), true)
        XCTAssertEqual(message?.contains("rank: Optional(2)"), true)
    }
}

extension MultiSetBehaviorComparisonTests {
    /// std::multiset inserts normally for the minimal endIndex hint trace
    ///
    /// Confirms that the C++ reference itself accepts the minimal `endIndex` hint trace,
    /// so the Swift-side failure is not an imitation of undefined behavior.
    func test_multiSetEndIndexHintMinimalTraceCppReference() throws {
        let cpp = try executeCppTrace([.insert(10), .insertHint(20, at: 1)])
        XCTAssertEqual(cpp.last?.value, 20)
        XCTAssertEqual(cpp.last?.rank, 1)
        XCTAssertEqual(cpp.last?.contents, [10, 20])
    }
}

extension MultiSetBehaviorComparisonTests {
    /// RedBlackTreeMultiSet endIndex hint into a non-empty multiset matches std::multiset
    ///
    /// Smallest deterministic trace for the former `endIndex` hint failure. Before the
    /// fix, the multi `__find_leaf` tested `__hint == end` instead of
    /// `__prior == __begin_node_`, returned `end.__right_` as the leaf, and Debug stopped
    /// at `__tree_left_rotate`'s "node shouldn't be null" assertion.
    func test_multiSetEndIndexHintMinimalTrace() throws {
        let operations: [MultiSetOperation] = [
            .insert(10),
            .insertHint(20, at: 1), // endIndex.
        ]

        let swift = try executeSwiftTrace(operations)
        let cpp = try executeCppTrace(operations)
        XCTAssertNil(firstMismatch(container: multiSetContainer, swift: swift, cpp: cpp))
    }
}

// MARK: - Seeded randomized traces

// `SplitMix64` and `firstRandomizedMismatch` are shared in `SeededTraceSupport.swift`;
// the seeds, operation count, and phase length match the Set PoC.

private let multiSetRandomizedSeeds: [UInt64] = [1, 2, 3, 0x5EED, 0xC0FFEE]
private let multiSetRandomizedOperationCount = 300
/// Operations alternate between growing and shrinking phases of this length so each
/// trace repeatedly passes through dense, sparse, and empty states.
private let multiSetRandomizedPhaseLength = 40
/// Eight ordinary keys keep equivalent-key groups frequent and large.
private let multiSetRandomizedKeyDomain: ClosedRange<Int64> = 0...7
/// Occasional keys below and above every ordinary key.
private let multiSetRandomizedExtremeKeys: [Int64] = [.min, .max]

/// Generation-policy events, counted from the model state before each operation.
///
/// For a key whose equivalent group occupies ranks `lower..<upper`, every hint in
/// `lower...upper` is exact; the group-relative counters apply only when the group
/// is non-empty.
private struct MultiSetTraceCoverage: Equatable {
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
    /// Positional erasure of an occurrence whose group holds at least two occurrences.
    var positionalInGroup = 0
    var emptiedByErase = 0
    /// Insertion into a multiset that an erasure had emptied.
    var reinsertAfterEmptied = 0
    /// Insertion of an absent key whose group an earlier erasure removed.
    var reinsertErasedKey = 0

    /// The names of events that never occurred.
    var missing: [String] { missingCoverage(self) }
}

/// Generates a valid stateful trace for `seed` from an independent sorted-array model.
///
/// Hints are current zero-based ranks in `0...count`: the start or end of the key's
/// equivalent group, inside it, `startIndex`, `endIndex`, a poor rank before or after
/// the group, or a random rank. Positional erasure uses ranks in `0..<count`: the
/// first, the last, a random element, or an occurrence inside a present key's group.
private func generateMultiSetTrace(
    seed: UInt64,
    count operationCount: Int
) -> (operations: [MultiSetOperation], coverage: MultiSetTraceCoverage) {
    var random = SplitMix64(state: seed)
    var model: [Int64] = []
    var coverage = MultiSetTraceCoverage()
    var operations: [MultiSetOperation] = []
    var erasedKeys: Set<Int64> = []
    var emptiedByErase = false

    func lowerRank(_ key: Int64) -> Int {
        model.firstIndex { $0 >= key } ?? model.count
    }

    func upperRank(_ key: Int64) -> Int {
        model.firstIndex { $0 > key } ?? model.count
    }

    func randomKey() -> Int64 {
        if random.next(below: 16) == 0 {
            return multiSetRandomizedExtremeKeys[random.next(below: multiSetRandomizedExtremeKeys.count)]
        }
        return multiSetRandomizedKeyDomain.lowerBound
            + Int64(random.next(below: multiSetRandomizedKeyDomain.count))
    }

    /// A present key with probability `percent`% when the model is non-empty.
    func key(presentPercent percent: Int) -> Int64 {
        if !model.isEmpty && random.next(below: 100) < percent {
            return model[random.next(below: model.count)]
        }
        return randomKey()
    }

    func hintRank(for member: Int64) -> Int {
        let lower = lowerRank(member)
        let upper = upperRank(member)
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
            let member = model[random.next(below: model.count)]
            let lower = lowerRank(member)
            return lower + random.next(below: upperRank(member) - lower)
        }
    }

    for operationIndex in 0..<operationCount {
        let growing = (operationIndex / multiSetRandomizedPhaseLength) % 2 == 0
        // Cumulative weights: insert, insertHint, find, lowerBound, upperBound,
        // equalRange, eraseKey, eraseAt, removeAt.
        let weights = growing
            ? [20, 50, 58, 64, 70, 76, 84, 92, 100]
            : [8, 20, 26, 31, 36, 40, 60, 80, 100]
        let choice = random.next(below: 100)
        var operation: MultiSetOperation

        switch weights.firstIndex(where: { choice < $0 })! {
        case 0:
            operation = .insert(key(presentPercent: 50))
        case 1:
            let member = key(presentPercent: 50)
            operation = .insertHint(member, at: hintRank(for: member))
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
            operation = model.isEmpty ? .insert(randomKey()) : .eraseAt(elementRank())
        default:
            operation = model.isEmpty ? .insert(randomKey()) : .removeAt(elementRank())
        }

        let wasNonEmpty = !model.isEmpty
        switch operation {
        case .insert(let member), .insertHint(let member, _):
            let lower = lowerRank(member)
            let upper = upperRank(member)
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
            if groupCount == 0 && erasedKeys.contains(member) { coverage.reinsertErasedKey += 1 }
            if multiSetRandomizedExtremeKeys.contains(member) { coverage.extremeKey += 1 }

            if case .insertHint(_, let position) = operation {
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
            }
            model.insert(member, at: upper)

        case .find(let member), .lowerBound(let member), .upperBound(let member),
             .equalRange(let member):
            if multiSetRandomizedExtremeKeys.contains(member) { coverage.extremeKey += 1 }
            if lowerRank(member) < upperRank(member) {
                coverage.presentLookup += 1
            } else {
                coverage.absentLookup += 1
            }

        case .eraseKey(let member):
            if multiSetRandomizedExtremeKeys.contains(member) { coverage.extremeKey += 1 }
            let lower = lowerRank(member)
            let upper = upperRank(member)
            if lower < upper {
                coverage.presentEraseKey += 1
                if upper - lower >= 2 { coverage.multiEraseKey += 1 }
                model.removeSubrange(lower..<upper)
                erasedKeys.insert(member)
            } else {
                coverage.absentEraseKey += 1
            }

        case .eraseAt(let position), .removeAt(let position):
            let member = model[position]
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
            if upperRank(member) - lowerRank(member) >= 2 { coverage.positionalInGroup += 1 }
            model.remove(at: position)
            if lowerRank(member) == upperRank(member) { erasedKeys.insert(member) }
        }

        if wasNonEmpty && model.isEmpty {
            coverage.emptiedByErase += 1
            emptiedByErase = true
        }
        operations.append(operation)
    }

    return (operations, coverage)
}

extension MultiSetBehaviorComparisonTests {
    /// Seeded MultiSet traces are deterministic and cover the generation policy
    func test_multiSetRandomizedTraceIsDeterministicAndCovered() {
        for seed in multiSetRandomizedSeeds {
            multiSetRandomizedTraceIsDeterministicAndCovered(seed: seed)
        }
    }

    /// Runs one seed in its own scope so every collection is released before the next seed.
    private func multiSetRandomizedTraceIsDeterministicAndCovered(seed: UInt64) {
        let first = generateMultiSetTrace(seed: seed, count: multiSetRandomizedOperationCount)
        let second = generateMultiSetTrace(seed: seed, count: multiSetRandomizedOperationCount)
        XCTAssertEqual(first.operations, second.operations, "seed=\(seed)")
        XCTAssertEqual(first.coverage, second.coverage, "seed=\(seed)")
        XCTAssertTrue(first.coverage.missing.isEmpty, "seed=\(seed), missing=\(first.coverage.missing)")
    }
}

extension MultiSetBehaviorComparisonTests {
    /// RedBlackTreeMultiSet matches std::multiset for seeded randomized traces
    func test_multiSetSeededRandomizedTraceMatchesCpp() {
        for seed in multiSetRandomizedSeeds {
            multiSetSeededRandomizedTraceMatchesCpp(seed: seed)
        }
    }

    /// Runs one seed in its own scope so every collection is released before the next seed.
    private func multiSetSeededRandomizedTraceMatchesCpp(seed: UInt64) {
        let operations = generateMultiSetTrace(seed: seed, count: multiSetRandomizedOperationCount).operations
        let swift: [MultiSetObservation]
        let cpp: [MultiSetObservation]
        do {
            swift = try executeSwiftTrace(operations)
            cpp = try executeCppTrace(operations)
        } catch {
            XCTFail("container=\(multiSetContainer), seed=\(seed), executor error=\(error)")
            return
        }

        let mismatch = firstRandomizedMismatch(
            container: multiSetContainer, seed: seed, operations: operations, swift: swift, cpp: cpp)
        if let mismatch { XCTFail(mismatch) }
    }
}

extension MultiSetBehaviorComparisonTests {
    /// A seeded MultiSet mismatch report contains the seed and the trace through failure
    ///
    /// The shared seeded diagnostic is otherwise exercised only with Set observations;
    /// this checks it with the MultiSet shape, tampering with a returned rank.
    func test_multiSetRandomizedMismatchReportContainsRequiredContext() throws {
        let seed = multiSetRandomizedSeeds[0]
        let operations = generateMultiSetTrace(seed: seed, count: multiSetRandomizedOperationCount).operations
        let swift = try executeSwiftTrace(operations)
        // Tamper with one observation instead of relying on a library defect.
        let failing = try XCTUnwrap(swift.indices.first { $0 >= 17 && swift[$0].rank != nil })
        var cpp = swift
        let original = cpp[failing]
        cpp[failing] = MultiSetObservation(
            operation: original.operation,
            value: original.value,
            rank: original.rank.map { $0 + 1 },
            erasedCount: original.erasedCount,
            found: original.found,
            count: original.count,
            range: original.range,
            contents: original.contents
        )

        let message = try XCTUnwrap(firstRandomizedMismatch(
            container: multiSetContainer, seed: seed, operations: operations, swift: swift, cpp: cpp))
        XCTAssertTrue(message.contains("container=\(multiSetContainer)"))
        XCTAssertTrue(message.contains("seed=\(seed)"))
        XCTAssertTrue(message.contains("operation=\(failing)"))
        XCTAssertTrue(message.contains("input=\(operations[failing])"))
        XCTAssertTrue(message.contains("swift=\(swift[failing])"))
        XCTAssertTrue(message.contains("cpp=\(cpp[failing])"))
        for operationIndex in 0...failing {
            XCTAssertTrue(message.contains("\n  \(operationIndex): \(operations[operationIndex])"))
        }
        XCTAssertFalse(message.contains("\n  \(failing + 1): "))
    }
}
#endif
