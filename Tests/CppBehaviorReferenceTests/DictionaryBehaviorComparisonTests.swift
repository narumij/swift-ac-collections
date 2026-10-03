import AcCollections
import CppBehaviorReference
import Testing

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

@Test("RedBlackTreeDictionary matches std::map for insertion, lookup, bounds, equal ranges, and erasure")
func dictionaryCuratedTraceMatchesCpp() throws {
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
    #expect(firstMismatch(container: dictionaryContainer, swift: swift, cpp: cpp) == nil)
}

@Test("RedBlackTreeDictionary update operations match their std::map counterparts")
func dictionaryUpdateSemanticsMatchCpp() throws {
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
    #expect(firstMismatch(container: dictionaryContainer, swift: swift, cpp: cpp) == nil)
}

@Test("RedBlackTreeDictionary hinted insertion and update match std::map")
func dictionaryHintedInsertionMatchesCpp() throws {
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
    #expect(firstMismatch(container: dictionaryContainer, swift: swift, cpp: cpp) == nil)
}

@Test("A Dictionary mismatch report identifies both observations and the operation")
func dictionaryMismatchReportContainsRequiredContext() {
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
    #expect(message?.contains("container=RedBlackTreeDictionary/std::map") == true)
    #expect(message?.contains("operation=0") == true)
    #expect(message?.contains("input=insertHint(20, 999, at: 1)") == true)
    #expect(message?.contains("swift=") == true)
    #expect(message?.contains("cpp=") == true)
    #expect(message?.contains("[10:100, 20:200]") == true)
    #expect(message?.contains("[10:100, 20:999]") == true)
}
