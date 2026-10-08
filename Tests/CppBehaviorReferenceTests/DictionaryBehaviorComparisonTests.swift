#if !COMPATIBLE_ATCODER_2025
import AcCollections
import CppBehaviorReference
import XCTest

final class DictionaryBehaviorComparisonTests: CppBehaviorReferenceTestCase {}

/// Each case pairs one Swift API with the `std::map` operation that has the same
/// observable contract:
///
/// | Case | Swift | C++ |
/// | --- | --- | --- |
/// | `insert` | `insert(key:value:)` | `insert({k, v})` |
/// | `insertHint` | `insert(key:value:hint:)` | `insert(hint, {k, v})` |
/// | `updateValue` | `updateValue(_:forKey:)` | effect of `insert_or_assign(k, v)` |
/// | `updateValueHint` | `updateValue(_:forKey:hint:)` | effect of `insert_or_assign(hint, k, v)` |
/// | `subscriptAssign` | `dictionary[k] = v` | `map[k] = v` |
/// | `subscriptDefaultAdd` | `dictionary[k, default: 0] += v` | `map[k] += v` |
/// | `find` | `dictionary[k]`, `find(_:)`, `count(forKey:)` | `find(k)`, `count(k)` |
/// | `lowerBound` / `upperBound` | `lowerBound(_:)` / `upperBound(_:)` | `lower_bound(k)` / `upper_bound(k)` |
/// | `equalRange` | `dictionary[equalRange(_:)]` | `equal_range(k)` |
/// | `eraseKey` | `removeValue(forKey:)` | `erase(k)` |
///
/// `updateValue` returns the previous mapped value, which `insert_or_assign` does
/// not expose. Because the package compiles C++ below C++17, the C++ side spells
/// out `insert_or_assign`'s effect: `find(k)` reports the previous value and is
/// assigned through, or an absent key is inserted (with the hint when given).
private enum DictionaryOperation: Equatable {
    case insert(Int64, Int64)
    case insertHint(Int64, Int64, at: Int)
    case updateValue(Int64, forKey: Int64)
    case updateValueHint(Int64, forKey: Int64, at: Int)
    case subscriptAssign(Int64, Int64)
    case subscriptDefaultAdd(Int64, Int64)
    case find(Int64)
    case lowerBound(Int64)
    case upperBound(Int64)
    case equalRange(Int64)
    case eraseKey(Int64)

    var cOperation: CppMapOperation {
        var result = CppMapOperation()
        result.position = -1
        switch self {
        case .insert(let key, let value):
            result.kind = Int32(CPP_MAP_OPERATION_INSERT)
            (result.key, result.value) = (key, value)
        case .insertHint(let key, let value, let position):
            result.kind = Int32(CPP_MAP_OPERATION_INSERT_HINT)
            (result.key, result.value, result.position) = (key, value, Int64(position))
        case .updateValue(let value, let key):
            result.kind = Int32(CPP_MAP_OPERATION_INSERT_OR_ASSIGN)
            (result.key, result.value) = (key, value)
        case .updateValueHint(let value, let key, let position):
            result.kind = Int32(CPP_MAP_OPERATION_INSERT_OR_ASSIGN_HINT)
            (result.key, result.value, result.position) = (key, value, Int64(position))
        case .subscriptAssign(let key, let value):
            result.kind = Int32(CPP_MAP_OPERATION_SUBSCRIPT_ASSIGN)
            (result.key, result.value) = (key, value)
        case .subscriptDefaultAdd(let key, let value):
            result.kind = Int32(CPP_MAP_OPERATION_SUBSCRIPT_ADD)
            (result.key, result.value) = (key, value)
        case .find(let key):
            result.kind = Int32(CPP_MAP_OPERATION_FIND)
            result.key = key
        case .lowerBound(let key):
            result.kind = Int32(CPP_MAP_OPERATION_LOWER_BOUND)
            result.key = key
        case .upperBound(let key):
            result.kind = Int32(CPP_MAP_OPERATION_UPPER_BOUND)
            result.key = key
        case .equalRange(let key):
            result.kind = Int32(CPP_MAP_OPERATION_EQUAL_RANGE)
            result.key = key
        case .eraseKey(let key):
            result.kind = Int32(CPP_MAP_OPERATION_ERASE_KEY)
            result.key = key
        }
        return result
    }
}

private struct DictionaryEntry: Equatable, CustomStringConvertible {
    let key: Int64
    let value: Int64

    var description: String { "\(key):\(value)" }
}

/// Unreported facts are `nil`. `previous` is `.some(nil)` when an update reports
/// that the key was absent.
private struct DictionaryObservation: Equatable {
    let operation: DictionaryOperation
    let inserted: Bool?
    let entry: DictionaryEntry?
    let rank: Int?
    let upperRank: Int?
    let previous: Int64??
    let count: Int?
    let range: [DictionaryEntry]
    let contents: [DictionaryEntry]
}

private enum DictionaryTraceError: Error {
    case cppExecutorFailed(Int32)
    case invalidPosition(Int)
}

private func executeSwiftTrace(_ operations: [DictionaryOperation]) throws -> [DictionaryObservation] {
    var dictionary = RedBlackTreeDictionary<Int64, Int64>()

    func rank(_ index: RedBlackTreeDictionary<Int64, Int64>.Index) -> Int {
        dictionary.distance(from: dictionary.startIndex, to: index)
    }

    func hint(at position: Int) throws -> RedBlackTreeDictionary<Int64, Int64>.Index {
        guard position >= 0 && position <= dictionary.count else {
            throw DictionaryTraceError.invalidPosition(position)
        }
        return dictionary.index(dictionary.startIndex, offsetBy: position)
    }

    func entry(at index: RedBlackTreeDictionary<Int64, Int64>.Index) -> DictionaryEntry? {
        guard index != dictionary.endIndex else { return nil }
        let element = dictionary[index]
        return DictionaryEntry(key: element.key, value: element.value)
    }

    return try operations.map { operation in
        var inserted: Bool?
        var entryResult: DictionaryEntry?
        var rankResult: Int?
        var upperRank: Int?
        var previous: Int64??
        var count: Int?
        var range: [DictionaryEntry] = []

        switch operation {
        case .insert(let key, let value):
            let result = dictionary.insert(key: key, value: value)
            inserted = result.inserted
            entryResult = DictionaryEntry(
                key: result.memberAfterInsert.key, value: result.memberAfterInsert.value)
            // `insert(key:value:)` returns the member, not its index; locate it to
            // compare with the rank of the iterator returned by `std::map::insert`.
            rankResult = rank(dictionary.find(key))
        case .insertHint(let key, let value, let position):
            let result = dictionary.insert(key: key, value: value, hint: try hint(at: position))
            inserted = result.inserted
            entryResult = entry(at: result.indexAfterInsert)
            rankResult = rank(result.indexAfterInsert)
        case .updateValue(let value, let key):
            previous = .some(dictionary.updateValue(value, forKey: key))
        case .updateValueHint(let value, let key, let position):
            previous = .some(dictionary.updateValue(value, forKey: key, hint: try hint(at: position)))
        case .subscriptAssign(let key, let value):
            dictionary[key] = value
        case .subscriptDefaultAdd(let key, let value):
            dictionary[key, default: 0] += value
        case .find(let key):
            entryResult = dictionary[key].map { DictionaryEntry(key: key, value: $0) }
            rankResult = rank(dictionary.find(key))
            count = dictionary.count(forKey: key)
        case .lowerBound(let key), .upperBound(let key):
            let index: RedBlackTreeDictionary<Int64, Int64>.Index
            if case .lowerBound = operation {
                index = dictionary.lowerBound(key)
            } else {
                index = dictionary.upperBound(key)
            }
            entryResult = entry(at: index)
            rankResult = rank(index)
        case .equalRange(let key):
            let view = dictionary[dictionary.equalRange(key)]
            rankResult = rank(view.startIndex)
            upperRank = rank(view.endIndex)
            range = view.map { DictionaryEntry(key: $0.key, value: $0.value) }
        case .eraseKey(let key):
            // `removeValue(forKey:)` reports the removed value; `std::map::erase`
            // reports the removed count. Their common fact is the count.
            count = dictionary.removeValue(forKey: key) == nil ? 0 : 1
        }

        return DictionaryObservation(
            operation: operation,
            inserted: inserted,
            entry: entryResult,
            rank: rankResult,
            upperRank: upperRank,
            previous: previous,
            count: count,
            range: range,
            contents: dictionary.map { DictionaryEntry(key: $0.key, value: $0.value) }
        )
    }
}

private func executeCppTrace(_ operations: [DictionaryOperation]) throws -> [DictionaryObservation] {
    let cOperations = operations.map(\.cOperation)
    var observations = Array(repeating: CppMapObservation(), count: operations.count)
    // Each operation appends at most one equal range and one full snapshot, and
    // neither can exceed the number of operations performed so far.
    var contents = Array(repeating: CppMapEntry(), count: 2 * operations.count * operations.count)

    let status = cOperations.withUnsafeBufferPointer { operationBuffer in
        observations.withUnsafeMutableBufferPointer { observationBuffer in
            contents.withUnsafeMutableBufferPointer { contentsBuffer in
                cpp_map_execute_trace(
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
    guard status == CPP_MAP_TRACE_SUCCESS else {
        throw DictionaryTraceError.cppExecutorFailed(status)
    }

    func slice(offset: Int, count: Int) -> [DictionaryEntry] {
        contents[offset..<(offset + count)].map { DictionaryEntry(key: $0.key, value: $0.value) }
    }

    return zip(operations, observations).map { operation, observation in
        DictionaryObservation(
            operation: operation,
            inserted: observation.inserted < 0 ? nil : observation.inserted != 0,
            entry: observation.has_entry
                ? DictionaryEntry(key: observation.entry.key, value: observation.entry.value) : nil,
            rank: observation.rank < 0 ? nil : Int(observation.rank),
            upperRank: observation.upper_rank < 0 ? nil : Int(observation.upper_rank),
            previous: observation.reports_previous
                ? .some(observation.has_previous ? observation.previous_value : nil) : nil,
            count: observation.count < 0 ? nil : Int(observation.count),
            range: slice(offset: Int(observation.range_offset), count: Int(observation.range_count)),
            contents: slice(offset: Int(observation.contents_offset), count: Int(observation.contents_count))
        )
    }
}

private func firstMismatch(
    container: String,
    swift: [DictionaryObservation],
    cpp: [DictionaryObservation]
) -> String? {
    for operationIndex in 0..<min(swift.count, cpp.count) where swift[operationIndex] != cpp[operationIndex] {
        return "container=\(container), operation=\(operationIndex), input=\(swift[operationIndex].operation), swift=\(swift[operationIndex]), cpp=\(cpp[operationIndex])"
    }
    guard swift.count == cpp.count else {
        return "container=\(container), observation-count, swift=\(swift.count), cpp=\(cpp.count)"
    }
    return nil
}

private let dictionaryContainer = "RedBlackTreeDictionary/std::map"

extension DictionaryBehaviorComparisonTests {
    /// RedBlackTreeDictionary matches std::map for insertion, lookup, bounds, equal ranges, and erasure
    func test_dictionaryCuratedTraceMatchesCpp() throws {
        let operations: [DictionaryOperation] = [
            .insert(20, 200),
            .insert(10, 100),
            .insert(30, 300),
            .insert(20, 999), // Existing key; the mapped value is preserved.
            // [10:100, 20:200, 30:300]
            .find(20),
            .find(25), // Absent.
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
            .eraseKey(20), // Present.
            .eraseKey(20), // Absent.
            .find(20),
            .equalRange(20),
            .eraseKey(10),
            .eraseKey(30),
            .eraseKey(30), // Empty.
            .find(30),
        ]

        let swift = try executeSwiftTrace(operations)
        let cpp = try executeCppTrace(operations)
        XCTAssertNil(firstMismatch(container: dictionaryContainer, swift: swift, cpp: cpp))
    }
}

extension DictionaryBehaviorComparisonTests {
    /// RedBlackTreeDictionary update operations match their std::map counterparts
    func test_dictionaryUpdateSemanticsMatchCpp() throws {
        let operations: [DictionaryOperation] = [
            .updateValue(100, forKey: 10), // Absent: inserts, reports no previous value.
            .updateValue(111, forKey: 10), // Present: replaces, reports 100.
            .insert(10, 999),              // Present: preserves 111.
            .subscriptAssign(20, 200),     // Absent: inserts.
            .subscriptAssign(20, 222),     // Present: replaces.
            .subscriptDefaultAdd(30, 3),   // Absent: starts from zero.
            .subscriptDefaultAdd(30, 4),   // Present: accumulates.
            .subscriptDefaultAdd(10, 1),
            .find(30),
            .eraseKey(10),
            .updateValue(5, forKey: 10),   // Reinsertion after erasure.
        ]

        let swift = try executeSwiftTrace(operations)
        let cpp = try executeCppTrace(operations)
        XCTAssertNil(firstMismatch(container: dictionaryContainer, swift: swift, cpp: cpp))
    }
}

extension DictionaryBehaviorComparisonTests {
    /// RedBlackTreeDictionary hinted insertion and update match std::map
    func test_dictionaryHintedInsertionMatchesCpp() throws {
        let operations: [DictionaryOperation] = [
            .insertHint(20, 200, at: 0), // Empty dictionary: startIndex == endIndex.
            .insertHint(10, 100, at: 0), // startIndex; exact hint for a new least key.
            .insertHint(30, 300, at: 2), // endIndex; exact hint for a new greatest key.
            // [10:100, 20:200, 30:300]
            .insertHint(25, 250, at: 2), // Exact hint (before 30).
            .insertHint(15, 150, at: 4), // endIndex; poor but valid.
            .insertHint(35, 350, at: 0), // startIndex; poor but valid.
            .insertHint(5, 50, at: 6),   // endIndex; poor for a new least key.
            // [5:50, 10:100, 15:150, 20:200, 25:250, 30:300, 35:350]
            .insertHint(20, 999, at: 3), // Existing key at its exact position; preserved.
            .insertHint(20, 999, at: 0), // Existing key, startIndex; preserved.
            .insertHint(20, 999, at: 7), // Existing key, endIndex; preserved.
            .insertHint(5, 999, at: 0),  // Existing least key at startIndex.
            .insertHint(35, 999, at: 7), // Existing greatest key at endIndex.
            .updateValueHint(222, forKey: 20, at: 3), // Existing key, exact hint; replaced.
            .updateValueHint(333, forKey: 30, at: 0), // Existing key, poor hint; replaced.
            .updateValueHint(400, forKey: 40, at: 7), // New key, endIndex.
            .updateValueHint(1, forKey: 1, at: 0),    // New key, startIndex.
            .updateValueHint(17, forKey: 17, at: 9),  // New key, endIndex; poor.
            .equalRange(17),
            .eraseKey(17),
            .insertHint(17, 170, at: 4), // Reinsertion after erasure, exact hint (before 20).
        ]

        let swift = try executeSwiftTrace(operations)
        let cpp = try executeCppTrace(operations)
        XCTAssertNil(firstMismatch(container: dictionaryContainer, swift: swift, cpp: cpp))
    }
}

extension DictionaryBehaviorComparisonTests {
    /// RedBlackTreeDictionary erase-then-reinsert at boundaries matches std::map
    func test_dictionaryBoundaryReinsertionMatchesCpp() throws {
        let operations: [DictionaryOperation] = [
            .insert(10, 100),
            .insert(20, 200),
            .insert(30, 300),
            // [10:100, 20:200, 30:300]
            .eraseKey(10),                // Erase the least key.
            .insertHint(10, 101, at: 0),  // Reinsert at startIndex.
            .eraseKey(30),                // Erase the greatest key.
            .insertHint(30, 301, at: 2),  // Reinsert at endIndex.
            .eraseKey(10),
            .insertHint(10, 102, at: 2),  // Reinsert the least key at endIndex; poor.
            .eraseKey(30),
            .insertHint(30, 302, at: 0),  // Reinsert the greatest key at startIndex; poor.
            .eraseKey(10),
            .updateValueHint(103, forKey: 10, at: 0), // Reinsert by update at startIndex.
            .eraseKey(30),
            .updateValueHint(303, forKey: 30, at: 2), // Reinsert by update at endIndex.
            .eraseKey(10),
            .eraseKey(20),
            .eraseKey(30),                // Now empty.
            .insertHint(40, 400, at: 0),  // Reinsert into the emptied dictionary.
            .eraseKey(40),
            .updateValueHint(50, forKey: 50, at: 0), // Update into the emptied dictionary.
        ]

        let swift = try executeSwiftTrace(operations)
        let cpp = try executeCppTrace(operations)
        XCTAssertNil(firstMismatch(container: dictionaryContainer, swift: swift, cpp: cpp))
    }
}

extension DictionaryBehaviorComparisonTests {
    /// A Dictionary mismatch report identifies both observations and the operation
    func test_dictionaryMismatchReportContainsRequiredContext() {
        let operation = DictionaryOperation.insertHint(20, 999, at: 1)
        func observation(value: Int64) -> DictionaryObservation {
            DictionaryObservation(
                operation: operation, inserted: false, entry: DictionaryEntry(key: 20, value: value),
                rank: 1, upperRank: nil, previous: nil, count: nil, range: [],
                contents: [DictionaryEntry(key: 10, value: 100), DictionaryEntry(key: 20, value: value)])
        }
        let swift = [observation(value: 200)]
        let cpp = [observation(value: 999)]

        let message = firstMismatch(container: dictionaryContainer, swift: swift, cpp: cpp)
        XCTAssertEqual(message?.contains("container=RedBlackTreeDictionary/std::map"), true)
        XCTAssertEqual(message?.contains("operation=0"), true)
        XCTAssertEqual(message?.contains("input=insertHint(20, 999, at: 1)"), true)
        XCTAssertEqual(message?.contains("swift="), true)
        XCTAssertEqual(message?.contains("cpp="), true)
        XCTAssertEqual(message?.contains("[10:100, 20:200]"), true)
        XCTAssertEqual(message?.contains("[10:100, 20:999]"), true)
    }
}

// MARK: - Seeded randomized traces

// `SplitMix64` and `firstRandomizedMismatch` are shared in `SeededTraceSupport.swift`;
// the seeds, operation count, and phase length match the Set and MultiSet traces.

private let dictionaryRandomizedSeeds: [UInt64] = [1, 2, 3, 0x5EED, 0xC0FFEE]
private let dictionaryRandomizedOperationCount = 300
/// Operations alternate between growing and shrinking phases of this length so each
/// trace repeatedly passes through dense, sparse, and empty states.
private let dictionaryRandomizedPhaseLength = 40
private let dictionaryRandomizedKeyDomain: ClosedRange<Int64> = 0...15
/// Occasional keys below and above every ordinary key.
private let dictionaryRandomizedExtremeKeys: [Int64] = [.min, .max]

/// Generation-policy events, counted from the model state before each operation.
///
/// For a unique key the only exact hint is its lower-bound rank: the existing entry,
/// or the entry before which an absent key belongs.
private struct DictionaryTraceCoverage: Equatable {
    var insertIntoEmpty = 0
    var insertIntoNonEmpty = 0
    var insertNewKey = 0
    var insertExistingKey = 0
    var insertHintNewKey = 0
    var insertHintExistingKey = 0
    var updateNewKey = 0
    var updateExistingKey = 0
    var updateHintNewKey = 0
    var updateHintExistingKey = 0
    var subscriptAssignNewKey = 0
    var subscriptAssignExistingKey = 0
    var subscriptAddNewKey = 0
    var subscriptAddExistingKey = 0
    var hintOnEmpty = 0
    var hintAtStart = 0
    var hintAtEnd = 0
    var insertHintExact = 0
    var insertHintPoor = 0
    var updateHintExact = 0
    var updateHintPoor = 0
    var extremeKey = 0
    /// A new key below or above every key of a non-empty dictionary.
    var newLeastKey = 0
    var newGreatestKey = 0
    var presentFind = 0
    var absentFind = 0
    var presentBoundOrRange = 0
    var absentBoundOrRange = 0
    var presentErase = 0
    var absentErase = 0
    /// Erasure of the least or greatest key while at least two entries remain.
    var eraseLeastKey = 0
    var eraseGreatestKey = 0
    var emptiedByErase = 0
    /// Insertion into a dictionary that an erasure had emptied.
    var reinsertAfterEmptied = 0
    /// Insertion of an absent key that an earlier erasure removed.
    var reinsertErasedKey = 0

    /// The names of events that never occurred.
    var missing: [String] { missingCoverage(self) }
}

/// Generates a valid stateful trace for `seed` from an independent sorted key/value
/// model.
///
/// Every value-bearing operation uses the distinct value `1_000 + operation number`,
/// so preservation, replacement, and returned previous values stay observable. Hints
/// are current zero-based ranks in `0...count`: exact, one past exact, `startIndex`,
/// `endIndex`, a poor rank before or after exact, or a random rank.
private func generateDictionaryTrace(
    seed: UInt64,
    count operationCount: Int
) -> (operations: [DictionaryOperation], coverage: DictionaryTraceCoverage) {
    var random = SplitMix64(state: seed)
    var model: [(key: Int64, value: Int64)] = []
    var coverage = DictionaryTraceCoverage()
    var operations: [DictionaryOperation] = []
    var erasedKeys: Set<Int64> = []
    var emptiedByErase = false

    func lowerRank(_ key: Int64) -> Int {
        model.firstIndex { $0.key >= key } ?? model.count
    }

    func isPresent(_ key: Int64) -> Bool {
        let lower = lowerRank(key)
        return lower < model.count && model[lower].key == key
    }

    func randomKey() -> Int64 {
        if random.next(below: 16) == 0 {
            return dictionaryRandomizedExtremeKeys[random.next(below: dictionaryRandomizedExtremeKeys.count)]
        }
        return dictionaryRandomizedKeyDomain.lowerBound
            + Int64(random.next(below: dictionaryRandomizedKeyDomain.count))
    }

    /// A present key with probability `percent`% when the model is non-empty.
    func key(presentPercent percent: Int) -> Int64 {
        if !model.isEmpty && random.next(below: 100) < percent {
            return model[random.next(below: model.count)].key
        }
        return randomKey()
    }

    func hintRank(for key: Int64) -> Int {
        let exact = lowerRank(key)
        switch random.next(below: 7) {
        case 0: return exact
        case 1: return min(exact + 1, model.count)
        case 2: return 0
        case 3: return model.count
        case 4: return exact > 0 ? random.next(below: exact) : 0
        case 5: return exact < model.count ? exact + 1 + random.next(below: model.count - exact) : model.count
        default: return random.next(below: model.count + 1)
        }
    }

    for operationIndex in 0..<operationCount {
        let growing = (operationIndex / dictionaryRandomizedPhaseLength) % 2 == 0
        // Cumulative weights: insert, insertHint, updateValue, updateValueHint,
        // subscriptAssign, subscriptDefaultAdd, find, lowerBound, upperBound,
        // equalRange, eraseKey.
        let weights = growing
            ? [10, 22, 30, 40, 46, 52, 60, 66, 72, 78, 100]
            : [4, 10, 14, 20, 23, 26, 32, 36, 40, 44, 100]
        let presentPercent = growing ? 25 : 50
        let value = Int64(1_000 + operationIndex)
        let choice = random.next(below: 100)
        let operation: DictionaryOperation

        switch weights.firstIndex(where: { choice < $0 })! {
        case 0:
            operation = .insert(key(presentPercent: presentPercent), value)
        case 1:
            let hintedKey = key(presentPercent: presentPercent)
            operation = .insertHint(hintedKey, value, at: hintRank(for: hintedKey))
        case 2:
            operation = .updateValue(value, forKey: key(presentPercent: presentPercent))
        case 3:
            let hintedKey = key(presentPercent: presentPercent)
            operation = .updateValueHint(value, forKey: hintedKey, at: hintRank(for: hintedKey))
        case 4:
            operation = .subscriptAssign(key(presentPercent: presentPercent), value)
        case 5:
            operation = .subscriptDefaultAdd(key(presentPercent: presentPercent), value)
        case 6:
            operation = .find(key(presentPercent: 50))
        case 7:
            operation = .lowerBound(key(presentPercent: 50))
        case 8:
            operation = .upperBound(key(presentPercent: 50))
        case 9:
            operation = .equalRange(key(presentPercent: 50))
        default:
            operation = .eraseKey(key(presentPercent: growing ? 50 : 90))
        }

        let wasNonEmpty = !model.isEmpty
        switch operation {
        case .insert(let key, _), .insertHint(let key, _, _),
             .updateValue(_, let key), .updateValueHint(_, let key, _),
             .subscriptAssign(let key, _), .subscriptDefaultAdd(let key, _):
            let exact = lowerRank(key)
            let present = isPresent(key)
            if model.isEmpty {
                coverage.insertIntoEmpty += 1
                if emptiedByErase {
                    coverage.reinsertAfterEmptied += 1
                    emptiedByErase = false
                }
            } else {
                coverage.insertIntoNonEmpty += 1
                if !present && exact == 0 { coverage.newLeastKey += 1 }
                if !present && exact == model.count { coverage.newGreatestKey += 1 }
            }
            if !present && erasedKeys.contains(key) { coverage.reinsertErasedKey += 1 }
            if dictionaryRandomizedExtremeKeys.contains(key) { coverage.extremeKey += 1 }

            switch operation {
            case .insert:
                if present { coverage.insertExistingKey += 1 } else { coverage.insertNewKey += 1 }
            case .insertHint(_, _, let position):
                if present { coverage.insertHintExistingKey += 1 } else { coverage.insertHintNewKey += 1 }
                if position == exact { coverage.insertHintExact += 1 } else { coverage.insertHintPoor += 1 }
            case .updateValue:
                if present { coverage.updateExistingKey += 1 } else { coverage.updateNewKey += 1 }
            case .updateValueHint(_, _, let position):
                if present { coverage.updateHintExistingKey += 1 } else { coverage.updateHintNewKey += 1 }
                if position == exact { coverage.updateHintExact += 1 } else { coverage.updateHintPoor += 1 }
            case .subscriptAssign:
                if present { coverage.subscriptAssignExistingKey += 1 } else { coverage.subscriptAssignNewKey += 1 }
            default:
                if present { coverage.subscriptAddExistingKey += 1 } else { coverage.subscriptAddNewKey += 1 }
            }

            switch operation {
            case .insertHint(_, _, let position), .updateValueHint(_, _, let position):
                if model.isEmpty {
                    coverage.hintOnEmpty += 1
                } else {
                    if position == 0 { coverage.hintAtStart += 1 }
                    if position == model.count { coverage.hintAtEnd += 1 }
                }
            default:
                break
            }

            // Apply the operation's semantics: `insert` preserves, the others replace
            // or (for the defaulted subscript) accumulate.
            switch operation {
            case .insert(_, let value), .insertHint(_, let value, _):
                if !present { model.insert((key, value), at: exact) }
            case .updateValue(let value, _), .updateValueHint(let value, _, _),
                 .subscriptAssign(_, let value):
                if present { model[exact].value = value } else { model.insert((key, value), at: exact) }
            case .subscriptDefaultAdd(_, let value):
                if present { model[exact].value += value } else { model.insert((key, value), at: exact) }
            default:
                break
            }

        case .find(let key):
            if dictionaryRandomizedExtremeKeys.contains(key) { coverage.extremeKey += 1 }
            if isPresent(key) { coverage.presentFind += 1 } else { coverage.absentFind += 1 }

        case .lowerBound(let key), .upperBound(let key), .equalRange(let key):
            if dictionaryRandomizedExtremeKeys.contains(key) { coverage.extremeKey += 1 }
            if isPresent(key) { coverage.presentBoundOrRange += 1 } else { coverage.absentBoundOrRange += 1 }

        case .eraseKey(let key):
            if dictionaryRandomizedExtremeKeys.contains(key) { coverage.extremeKey += 1 }
            if isPresent(key) {
                let rank = lowerRank(key)
                coverage.presentErase += 1
                if model.count >= 3 && rank == 0 { coverage.eraseLeastKey += 1 }
                if model.count >= 3 && rank == model.count - 1 { coverage.eraseGreatestKey += 1 }
                model.remove(at: rank)
                erasedKeys.insert(key)
            } else {
                coverage.absentErase += 1
            }
        }

        if wasNonEmpty && model.isEmpty {
            coverage.emptiedByErase += 1
            emptiedByErase = true
        }
        operations.append(operation)
    }

    return (operations, coverage)
}

extension DictionaryBehaviorComparisonTests {
    /// Seeded Dictionary traces are deterministic and cover the generation policy
    func test_dictionaryRandomizedTraceIsDeterministicAndCovered() {
        for seed in dictionaryRandomizedSeeds {
            dictionaryRandomizedTraceIsDeterministicAndCovered(seed: seed)
        }
    }

    /// Runs one seed in its own scope so every collection is released before the next seed.
    private func dictionaryRandomizedTraceIsDeterministicAndCovered(seed: UInt64) {
        let first = generateDictionaryTrace(seed: seed, count: dictionaryRandomizedOperationCount)
        let second = generateDictionaryTrace(seed: seed, count: dictionaryRandomizedOperationCount)
        XCTAssertEqual(first.operations, second.operations, "seed=\(seed)")
        XCTAssertEqual(first.coverage, second.coverage, "seed=\(seed)")
        XCTAssertTrue(first.coverage.missing.isEmpty, "seed=\(seed), missing=\(first.coverage.missing)")
    }
}

extension DictionaryBehaviorComparisonTests {
    /// RedBlackTreeDictionary matches std::map for seeded randomized traces
    func test_dictionarySeededRandomizedTraceMatchesCpp() {
        for seed in dictionaryRandomizedSeeds {
            dictionarySeededRandomizedTraceMatchesCpp(seed: seed)
        }
    }

    /// Runs one seed in its own scope so every collection is released before the next seed.
    private func dictionarySeededRandomizedTraceMatchesCpp(seed: UInt64) {
        let operations = generateDictionaryTrace(seed: seed, count: dictionaryRandomizedOperationCount).operations
        let swift: [DictionaryObservation]
        let cpp: [DictionaryObservation]
        do {
            swift = try executeSwiftTrace(operations)
            cpp = try executeCppTrace(operations)
        } catch {
            XCTFail("container=\(dictionaryContainer), seed=\(seed), executor error=\(error)")
            return
        }

        let mismatch = firstRandomizedMismatch(
            container: dictionaryContainer, seed: seed, operations: operations, swift: swift, cpp: cpp)
        if let mismatch { XCTFail(mismatch) }
    }
}

extension DictionaryBehaviorComparisonTests {
    /// A seeded Dictionary mismatch report contains the seed and the trace through failure
    ///
    /// The shared seeded diagnostic is otherwise exercised only with Set and MultiSet
    /// observations; this checks it with key/value contents, tampering with a returned
    /// previous value.
    func test_dictionaryRandomizedMismatchReportContainsRequiredContext() throws {
        let seed = dictionaryRandomizedSeeds[0]
        let operations = generateDictionaryTrace(seed: seed, count: dictionaryRandomizedOperationCount).operations
        let swift = try executeSwiftTrace(operations)
        // Tamper with one observation instead of relying on a library defect.
        let failing = try XCTUnwrap(swift.indices.first {
            $0 >= 17 && swift[$0].previous.flatMap { $0 } != nil
        })
        var cpp = swift
        let original = cpp[failing]
        cpp[failing] = DictionaryObservation(
            operation: original.operation,
            inserted: original.inserted,
            entry: original.entry,
            rank: original.rank,
            upperRank: original.upperRank,
            previous: original.previous.map { $0.map { $0 + 1 } },
            count: original.count,
            range: original.range,
            contents: original.contents
        )

        let message = try XCTUnwrap(firstRandomizedMismatch(
            container: dictionaryContainer, seed: seed, operations: operations, swift: swift, cpp: cpp))
        XCTAssertTrue(message.contains("container=\(dictionaryContainer)"))
        XCTAssertTrue(message.contains("seed=\(seed)"))
        XCTAssertTrue(message.contains("operation=\(failing)"))
        XCTAssertTrue(message.contains("input=\(operations[failing])"))
        XCTAssertTrue(message.contains("swift=\(swift[failing])"))
        XCTAssertTrue(message.contains("cpp=\(cpp[failing])"))
        // Key/value contents are printed as `key:value` entries.
        XCTAssertTrue(message.contains("\(swift[failing].contents)"))
        for operationIndex in 0...failing {
            XCTAssertTrue(message.contains("\n  \(operationIndex): \(operations[operationIndex])"))
        }
        XCTAssertFalse(message.contains("\n  \(failing + 1): "))
    }
}
#endif
