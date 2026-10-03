import AcCollections
import CppBehaviorReference
import Testing

private enum MultiSetOperation: Equatable {
    case insert(Int64)
    case insertHint(Int64, at: Int)
    case lowerBound(Int64)
    case upperBound(Int64)
    case equalRange(Int64)
    case eraseKey(Int64)

    var argument: Int64 {
        switch self {
        case .insert(let value), .insertHint(let value, _),
             .lowerBound(let value), .upperBound(let value),
             .equalRange(let value), .eraseKey(let value):
            value
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
        }
    }

    var position: Int64 {
        switch self {
        case .insertHint(_, let position): Int64(position)
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

    return try operations.map { operation in
        var value: Int64?
        var rankResult: Int?
        var erasedCount: Int?
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
        }

        return MultiSetObservation(
            operation: operation,
            value: value,
            rank: rankResult,
            erasedCount: erasedCount,
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

@Test("RedBlackTreeMultiSet matches std::multiset for insertion, bounds, equal ranges, and erasure")
func multiSetCuratedTraceMatchesCpp() throws {
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
    #expect(firstMismatch(container: multiSetContainer, swift: swift, cpp: cpp) == nil)
}

@Test("RedBlackTreeMultiSet non-endIndex hinted insertion matches std::multiset around an equivalent-key group")
func multiSetNonEndIndexHintedInsertionMatchesCpp() throws {
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
    #expect(firstMismatch(container: multiSetContainer, swift: swift, cpp: cpp) == nil)
}

@Test("RedBlackTreeMultiSet hinted insertion matches std::multiset around an equivalent-key group")
func multiSetHintedInsertionMatchesCpp() throws {
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
    #expect(firstMismatch(container: multiSetContainer, swift: swift, cpp: cpp) == nil)
}

@Test("A MultiSet mismatch report identifies both observations and the operation")
func multiSetMismatchReportContainsRequiredContext() {
    let operation = MultiSetOperation.insertHint(20, at: 1)
    let swift = [MultiSetObservation(
        operation: operation, value: 20, rank: 1, erasedCount: nil, range: [], contents: [10, 20, 20])]
    let cpp = [MultiSetObservation(
        operation: operation, value: 20, rank: 2, erasedCount: nil, range: [], contents: [10, 20, 20])]

    let message = firstMismatch(container: multiSetContainer, swift: swift, cpp: cpp)
    #expect(message?.contains("container=RedBlackTreeMultiSet/std::multiset") == true)
    #expect(message?.contains("operation=0") == true)
    #expect(message?.contains("input=insertHint(20, at: 1)") == true)
    #expect(message?.contains("swift=") == true)
    #expect(message?.contains("rank: Optional(1)") == true)
    #expect(message?.contains("cpp=") == true)
    #expect(message?.contains("rank: Optional(2)") == true)
}

/// Confirms that the C++ reference itself accepts the minimal `endIndex` hint trace,
/// so the Swift-side failure is not an imitation of undefined behavior.
@Test("std::multiset inserts normally for the minimal endIndex hint trace")
func multiSetEndIndexHintMinimalTraceCppReference() throws {
    let cpp = try executeCppTrace([.insert(10), .insertHint(20, at: 1)])
    #expect(cpp.last?.value == 20)
    #expect(cpp.last?.rank == 1)
    #expect(cpp.last?.contents == [10, 20])
}

/// Smallest deterministic trace for the former `endIndex` hint failure. Before the
/// fix, the multi `__find_leaf` tested `__hint == end` instead of
/// `__prior == __begin_node_`, returned `end.__right_` as the leaf, and Debug stopped
/// at `__tree_left_rotate`'s "node shouldn't be null" assertion.
@Test("RedBlackTreeMultiSet endIndex hint into a non-empty multiset matches std::multiset")
func multiSetEndIndexHintMinimalTrace() throws {
    let operations: [MultiSetOperation] = [
        .insert(10),
        .insertHint(20, at: 1), // endIndex.
    ]

    let swift = try executeSwiftTrace(operations)
    let cpp = try executeCppTrace(operations)
    #expect(firstMismatch(container: multiSetContainer, swift: swift, cpp: cpp) == nil)
}
