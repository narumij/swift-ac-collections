import AcCollections
import CppBehaviorReference
import Testing

private enum SetOperation: Equatable {
    case insert(Int64)
    case insertHint(Int64, at: Int)
    case lowerBound(Int64)
    case eraseKey(Int64)

    var argument: Int64 {
        switch self {
        case .insert(let value), .insertHint(let value, _),
             .lowerBound(let value), .eraseKey(let value):
            value
        }
    }

    var cKind: Int32 {
        switch self {
        case .insert: Int32(CPP_SET_OPERATION_INSERT)
        case .lowerBound: Int32(CPP_SET_OPERATION_LOWER_BOUND)
        case .eraseKey: Int32(CPP_SET_OPERATION_ERASE_KEY)
        case .insertHint: Int32(CPP_SET_OPERATION_INSERT_HINT)
        }
    }

    var position: Int64 {
        switch self {
        case .insertHint(_, let position): Int64(position)
        default: -1
        }
    }
}

private struct SetObservation: Equatable {
    let operation: SetOperation
    let booleanResult: Bool
    let value: Int64?
    let contents: [Int64]
}

private func executeSwiftTrace(_ operations: [SetOperation]) throws -> [SetObservation] {
    var set = RedBlackTreeSet<Int64>()

    return try operations.map { operation in
        let booleanResult: Bool
        let value: Int64?

        switch operation {
        case .insert(let newMember):
            let result = set.insert(newMember)
            booleanResult = result.inserted
            value = result.memberAfterInsert
        case .insertHint(let newMember, let position):
            guard position >= 0 && position <= set.count else {
                throw TraceError.invalidPosition(position)
            }
            let hint = set.index(set.startIndex, offsetBy: position)
            let result = set.insert(newMember, hint: hint)
            booleanResult = result.inserted
            value = set[result.indexAfterInsert]
        case .lowerBound(let member):
            let index = set.lowerBound(member)
            booleanResult = false
            value = index == set.endIndex ? nil : set[index]
        case .eraseKey(let member):
            booleanResult = set.remove(member) != nil
            value = nil
        }

        return SetObservation(
            operation: operation,
            booleanResult: booleanResult,
            value: value,
            contents: Array(set)
        )
    }
}

private func executeCppTrace(_ operations: [SetOperation]) throws -> [SetObservation] {
    let cOperations = operations.map { operation in
        var result = CppSetOperation()
        result.kind = operation.cKind
        result.value = operation.argument
        result.position = operation.position
        return result
    }
    var observations = Array(repeating: CppSetObservation(), count: operations.count)
    var contents = Array(repeating: Int64.zero, count: operations.count * operations.count)

    let status = cOperations.withUnsafeBufferPointer { operationBuffer in
        observations.withUnsafeMutableBufferPointer { observationBuffer in
            contents.withUnsafeMutableBufferPointer { contentsBuffer in
                cpp_set_execute_trace(
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
    guard status == CPP_SET_TRACE_SUCCESS else {
        throw TraceError.cppExecutorFailed(status)
    }

    return zip(operations, observations).map { operation, observation in
        let start = Int(observation.contents_offset)
        let end = start + Int(observation.contents_count)
        return SetObservation(
            operation: operation,
            booleanResult: observation.boolean_result,
            value: observation.has_value ? observation.value : nil,
            contents: Array(contents[start..<end])
        )
    }
}

private enum TraceError: Error {
    case cppExecutorFailed(Int32)
    case invalidPosition(Int)
}

private func firstMismatch(
    container: String,
    swift: [SetObservation],
    cpp: [SetObservation]
) -> String? {
    for operationIndex in 0..<min(swift.count, cpp.count) where swift[operationIndex] != cpp[operationIndex] {
        return "container=\(container), operation=\(operationIndex), input=\(swift[operationIndex].operation), swift=\(swift[operationIndex]), cpp=\(cpp[operationIndex])"
    }
    guard swift.count == cpp.count else {
        return "container=\(container), observation-count, swift=\(swift.count), cpp=\(cpp.count)"
    }
    return nil
}

@Test("RedBlackTreeSet matches std::set for the first curated trace")
func setCuratedTraceMatchesCpp() throws {
    let operations: [SetOperation] = [
        .insert(4),
        .insert(1),
        .insert(4),
        .insert(7),
        .lowerBound(0),
        .lowerBound(4),
        .lowerBound(5),
        .lowerBound(8),
        .eraseKey(4),
        .eraseKey(4),
    ]

    let swift = try executeSwiftTrace(operations)
    let cpp = try executeCppTrace(operations)
    #expect(firstMismatch(container: "RedBlackTreeSet/std::set", swift: swift, cpp: cpp) == nil)
}

@Test("RedBlackTreeSet hinted insertion matches std::set")
func setHintedInsertionMatchesCpp() throws {
    let operations: [SetOperation] = [
        .insert(10),
        .insert(20),
        .insert(30),
        .insertHint(25, at: 0), // Deliberately poor hint.
        .insertHint(5, at: 0),  // Exact insertion position.
        .insertHint(40, at: 5), // endIndex.
        .insertHint(20, at: 2), // Duplicate element.
    ]

    let swift = try executeSwiftTrace(operations)
    let cpp = try executeCppTrace(operations)
    #expect(firstMismatch(container: "RedBlackTreeSet/std::set", swift: swift, cpp: cpp) == nil)
}

@Test("A mismatch report identifies both observations and the operation")
func mismatchReportContainsRequiredContext() {
    let operation = SetOperation.insert(4)
    let swift = [SetObservation(operation: operation, booleanResult: true, value: 4, contents: [4])]
    let cpp = [SetObservation(operation: operation, booleanResult: false, value: 4, contents: [4])]

    let message = firstMismatch(container: "RedBlackTreeSet/std::set", swift: swift, cpp: cpp)
    #expect(message?.contains("container=RedBlackTreeSet/std::set") == true)
    #expect(message?.contains("operation=0") == true)
    #expect(message?.contains("input=insert(4)") == true)
    #expect(message?.contains("swift=") == true)
    #expect(message?.contains("cpp=") == true)
}
