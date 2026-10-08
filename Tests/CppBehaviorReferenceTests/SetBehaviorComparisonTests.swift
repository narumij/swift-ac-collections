#if !COMPATIBLE_ATCODER_2025
import AcCollections
import CppBehaviorReference
import XCTest

final class SetBehaviorComparisonTests: CppBehaviorReferenceTestCase {}

private enum SetOperation: Equatable {
    case insert(Int64)
    case insertHint(Int64, at: Int)
    case lowerBound(Int64)
    case upperBound(Int64)
    case find(Int64)
    case eraseKey(Int64)

    var argument: Int64 {
        switch self {
        case .insert(let value), .insertHint(let value, _),
             .lowerBound(let value), .upperBound(let value),
             .find(let value), .eraseKey(let value):
            value
        }
    }

    var cKind: Int32 {
        switch self {
        case .insert: Int32(CPP_SET_OPERATION_INSERT)
        case .lowerBound: Int32(CPP_SET_OPERATION_LOWER_BOUND)
        case .upperBound: Int32(CPP_SET_OPERATION_UPPER_BOUND)
        case .find: Int32(CPP_SET_OPERATION_FIND)
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
    /// `count(of:)`, or `nil` when not reported.
    var count: Int? = nil
    let contents: [Int64]
}

private func executeSwiftTrace(_ operations: [SetOperation]) throws -> [SetObservation] {
    var set = RedBlackTreeSet<Int64>()

    return try operations.map { operation in
        let booleanResult: Bool
        let value: Int64?
        var count: Int?

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
        case .upperBound(let member):
            let index = set.upperBound(member)
            booleanResult = false
            value = index == set.endIndex ? nil : set[index]
        case .find(let member):
            booleanResult = set.contains(member)
            value = nil
            count = set.count(of: member)
        case .eraseKey(let member):
            booleanResult = set.remove(member) != nil
            value = nil
        }

        return SetObservation(
            operation: operation,
            booleanResult: booleanResult,
            value: value,
            count: count,
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
            count: observation.count < 0 ? nil : Int(observation.count),
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

extension SetBehaviorComparisonTests {
    /// RedBlackTreeSet matches std::set for the first curated trace
    func test_setCuratedTraceMatchesCpp() throws {
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
        XCTAssertNil(firstMismatch(container: "RedBlackTreeSet/std::set", swift: swift, cpp: cpp))
    }
}

extension SetBehaviorComparisonTests {
    /// RedBlackTreeSet hinted insertion matches std::set
    func test_setHintedInsertionMatchesCpp() throws {
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
        XCTAssertNil(firstMismatch(container: "RedBlackTreeSet/std::set", swift: swift, cpp: cpp))
    }
}

extension SetBehaviorComparisonTests {
    /// RedBlackTreeSet boundary hints and erase-then-reinsert match std::set
    ///
    /// A unique set's returned index is fully determined by its value and the contents,
    /// so `value` and `contents` together also fix the returned rank.
    func test_setBoundaryHintsAndReinsertionMatchCpp() throws {
        let operations: [SetOperation] = [
            .insertHint(20, at: 0), // Empty set: startIndex == endIndex.
            .insertHint(10, at: 0), // startIndex; exact for a new least key.
            .insertHint(30, at: 2), // endIndex; exact for a new greatest key.
            // [10, 20, 30]
            .insertHint(10, at: 0), // Existing least key at startIndex.
            .insertHint(10, at: 3), // Existing least key at endIndex; poor.
            .insertHint(30, at: 3), // Existing greatest key at endIndex.
            .insertHint(30, at: 0), // Existing greatest key at startIndex; poor.
            .eraseKey(10),          // Erase the least key.
            .insertHint(10, at: 0), // Reinsert at startIndex.
            .eraseKey(30),          // Erase the greatest key.
            .insertHint(30, at: 2), // Reinsert at endIndex.
            .eraseKey(10),
            .insertHint(10, at: 2), // Reinsert the least key at endIndex; poor.
            .eraseKey(30),
            .insertHint(30, at: 0), // Reinsert the greatest key at startIndex; poor.
            .eraseKey(10),
            .eraseKey(20),
            .eraseKey(30),          // Now empty.
            .insertHint(40, at: 0), // Reinsert into the emptied set.
        ]

        let swift = try executeSwiftTrace(operations)
        let cpp = try executeCppTrace(operations)
        XCTAssertNil(firstMismatch(container: "RedBlackTreeSet/std::set", swift: swift, cpp: cpp))
    }
}

extension SetBehaviorComparisonTests {
    /// A mismatch report identifies both observations and the operation
    func test_mismatchReportContainsRequiredContext() {
        let operation = SetOperation.insert(4)
        let swift = [SetObservation(operation: operation, booleanResult: true, value: 4, contents: [4])]
        let cpp = [SetObservation(operation: operation, booleanResult: false, value: 4, contents: [4])]

        let message = firstMismatch(container: "RedBlackTreeSet/std::set", swift: swift, cpp: cpp)
        XCTAssertEqual(message?.contains("container=RedBlackTreeSet/std::set"), true)
        XCTAssertEqual(message?.contains("operation=0"), true)
        XCTAssertEqual(message?.contains("input=insert(4)"), true)
        XCTAssertEqual(message?.contains("swift="), true)
        XCTAssertEqual(message?.contains("cpp="), true)
    }
}

// MARK: - Seeded randomized traces

// `SplitMix64` and `firstRandomizedMismatch` are shared in `SeededTraceSupport.swift`.

private let setRandomizedSeeds: [UInt64] = [1, 2, 3, 0x5EED, 0xC0FFEE]
private let setRandomizedOperationCount = 300
/// Operations alternate between growing and shrinking phases of this length so each
/// trace repeatedly passes through dense, sparse, and empty states.
private let setRandomizedPhaseLength = 40
/// A small ordinary key domain makes duplicates and present-key erasure frequent.
private let setRandomizedKeyDomain: ClosedRange<Int64> = 0...15
/// Occasional keys below and above every ordinary key.
private let setRandomizedExtremeKeys: [Int64] = [.min, .max]

/// Generation-policy events, counted from the model state before each operation.
private struct SetTraceCoverage: Equatable {
    var hintOnEmpty = 0
    var hintAtStart = 0
    var hintAtEnd = 0
    var exactHint = 0
    var poorHint = 0
    var duplicateInsert = 0
    var extremeKey = 0
    var presentLookup = 0
    var absentLookup = 0
    var presentErase = 0
    var absentErase = 0
    var emptiedByErase = 0

    /// The names of events that never occurred.
    var missing: [String] { missingCoverage(self) }
}

/// Generates a valid stateful trace for `seed` from an independent sorted-array model.
///
/// Hints are current zero-based ranks in `0...count`, chosen as the exact insertion
/// rank, `startIndex`, `endIndex`, one past the exact rank, or a random rank.
private func generateSetTrace(
    seed: UInt64,
    count operationCount: Int
) -> (operations: [SetOperation], coverage: SetTraceCoverage) {
    var random = SplitMix64(state: seed)
    var model: [Int64] = []
    var coverage = SetTraceCoverage()
    var operations: [SetOperation] = []

    func lowerRank(_ key: Int64) -> Int {
        model.firstIndex { $0 >= key } ?? model.count
    }

    func randomKey() -> Int64 {
        if random.next(below: 16) == 0 {
            return setRandomizedExtremeKeys[random.next(below: setRandomizedExtremeKeys.count)]
        }
        return setRandomizedKeyDomain.lowerBound
            + Int64(random.next(below: setRandomizedKeyDomain.count))
    }

    /// A present key with probability `percent`% when the model is non-empty.
    func key(presentPercent percent: Int) -> Int64 {
        if !model.isEmpty && random.next(below: 100) < percent {
            return model[random.next(below: model.count)]
        }
        return randomKey()
    }

    for operationIndex in 0..<operationCount {
        let growing = (operationIndex / setRandomizedPhaseLength) % 2 == 0
        // Cumulative weights: insert, insertHint, find, lowerBound, upperBound, eraseKey.
        let weights = growing ? [30, 60, 70, 80, 90, 100] : [10, 25, 35, 45, 55, 100]
        let choice = random.next(below: 100)
        let operation: SetOperation

        switch weights.firstIndex(where: { choice < $0 })! {
        case 0:
            operation = .insert(key(presentPercent: growing ? 25 : 50))
        case 1:
            let member = key(presentPercent: growing ? 25 : 50)
            let exact = lowerRank(member)
            let position: Int
            switch random.next(below: 5) {
            case 0: position = exact
            case 1: position = 0
            case 2: position = model.count
            case 3: position = min(exact + 1, model.count)
            default: position = random.next(below: model.count + 1)
            }
            if model.isEmpty {
                coverage.hintOnEmpty += 1
            } else {
                if position == 0 { coverage.hintAtStart += 1 }
                if position == model.count { coverage.hintAtEnd += 1 }
            }
            if position == exact { coverage.exactHint += 1 } else { coverage.poorHint += 1 }
            operation = .insertHint(member, at: position)
        case 2:
            operation = .find(key(presentPercent: 50))
        case 3:
            operation = .lowerBound(key(presentPercent: 50))
        case 4:
            operation = .upperBound(key(presentPercent: 50))
        default:
            operation = .eraseKey(key(presentPercent: growing ? 50 : 90))
        }

        let member = operation.argument
        let rank = lowerRank(member)
        let present = rank < model.count && model[rank] == member
        if setRandomizedExtremeKeys.contains(member) { coverage.extremeKey += 1 }

        switch operation {
        case .insert, .insertHint:
            if present {
                coverage.duplicateInsert += 1
            } else {
                model.insert(member, at: rank)
            }
        case .find, .lowerBound, .upperBound:
            if present { coverage.presentLookup += 1 } else { coverage.absentLookup += 1 }
        case .eraseKey:
            if present {
                coverage.presentErase += 1
                model.remove(at: rank)
                if model.isEmpty { coverage.emptiedByErase += 1 }
            } else {
                coverage.absentErase += 1
            }
        }
        operations.append(operation)
    }

    return (operations, coverage)
}

private let setContainer = "RedBlackTreeSet/std::set"

extension SetBehaviorComparisonTests {
    /// SplitMix64 reproduces the reference sequence
    func test_splitMix64MatchesReferenceSequence() {
        var random = SplitMix64(state: 0)
        XCTAssertEqual(random.next(), 0xE220_A839_7B1D_CDAF)
        XCTAssertEqual(random.next(), 0x6E78_9E6A_A1B9_65F4)
        XCTAssertEqual(random.next(), 0x06C4_5D18_8009_454F)
    }
}

extension SetBehaviorComparisonTests {
    /// Seeded Set traces are deterministic and cover the generation policy
    func test_setRandomizedTraceIsDeterministicAndCovered() {
        for seed in setRandomizedSeeds {
            setRandomizedTraceIsDeterministicAndCovered(seed: seed)
        }
    }

    /// Runs one seed in its own scope so every collection is released before the next seed.
    private func setRandomizedTraceIsDeterministicAndCovered(seed: UInt64) {
        let first = generateSetTrace(seed: seed, count: setRandomizedOperationCount)
        let second = generateSetTrace(seed: seed, count: setRandomizedOperationCount)
        XCTAssertEqual(first.operations, second.operations, "seed=\(seed)")
        XCTAssertEqual(first.coverage, second.coverage, "seed=\(seed)")
        XCTAssertTrue(first.coverage.missing.isEmpty, "seed=\(seed), missing=\(first.coverage.missing)")
    }
}

extension SetBehaviorComparisonTests {
    /// RedBlackTreeSet matches std::set for seeded randomized traces
    func test_setSeededRandomizedTraceMatchesCpp() {
        for seed in setRandomizedSeeds {
            setSeededRandomizedTraceMatchesCpp(seed: seed)
        }
    }

    /// Runs one seed in its own scope so every collection is released before the next seed.
    private func setSeededRandomizedTraceMatchesCpp(seed: UInt64) {
        let operations = generateSetTrace(seed: seed, count: setRandomizedOperationCount).operations
        let swift: [SetObservation]
        let cpp: [SetObservation]
        do {
            swift = try executeSwiftTrace(operations)
            cpp = try executeCppTrace(operations)
        } catch {
            XCTFail("container=\(setContainer), seed=\(seed), executor error=\(error)")
            return
        }

        let mismatch = firstRandomizedMismatch(
            container: setContainer, seed: seed, operations: operations, swift: swift, cpp: cpp)
        if let mismatch { XCTFail(mismatch) }
    }
}

extension SetBehaviorComparisonTests {
    /// A seeded Set mismatch report contains the seed and the trace through failure
    func test_setRandomizedMismatchReportContainsRequiredContext() throws {
        let seed = setRandomizedSeeds[0]
        let operations = generateSetTrace(seed: seed, count: setRandomizedOperationCount).operations
        let swift = try executeSwiftTrace(operations)
        // Tamper with one observation instead of relying on a library defect.
        let failing = 17
        var cpp = swift
        let original = cpp[failing]
        cpp[failing] = SetObservation(
            operation: original.operation,
            booleanResult: !original.booleanResult,
            value: original.value,
            count: original.count,
            contents: original.contents
        )

        let message = try XCTUnwrap(firstRandomizedMismatch(
            container: setContainer, seed: seed, operations: operations, swift: swift, cpp: cpp))
        XCTAssertTrue(message.contains("container=\(setContainer)"))
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
