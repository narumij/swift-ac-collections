import Foundation

extension Array: NextPermutation where Element: Comparable {
    @inlinable @inline(__always)
    mutating func _update<R>(_ body: (NextPermutationUnsafeHandle<Element>) -> R) -> R {
        withUnsafeMutableBufferPointer { buffer in
            body(NextPermutationUnsafeHandle(storage: buffer))
        }
    }
}

extension ContiguousArray: NextPermutation where Element: Comparable {
    @inlinable @inline(__always)
    mutating func _update<R>(_ body: (NextPermutationUnsafeHandle<Element>) -> R) -> R {
        withUnsafeMutableBufferPointer { buffer in
            body(NextPermutationUnsafeHandle(storage: buffer))
        }
    }
}

protocol NextPermutation: Sequence where Element: Comparable {
    @inlinable @inline(__always)
    mutating func _update<R>(_ body: (NextPermutationUnsafeHandle<Element>) -> R) -> R
}

extension NextPermutation {
    mutating func nextPermutation(upperBound: UnsafeMutableBufferPointer<Element>.Index? = nil) -> Bool {
        _update { $0.nextPermutation(upperBound: upperBound) }
    }
}

@usableFromInline
struct NextPermutationUnsafeHandle<Element: Comparable> {
    @inlinable @inline(__always)
    init(storage: UnsafeMutableBufferPointer<Element>) {
        self.storage = storage
    }
    @usableFromInline
    var storage: UnsafeMutableBufferPointer<Element>
    @usableFromInline
    typealias Index = UnsafeMutableBufferPointer<Element>.Index
}

extension NextPermutationUnsafeHandle {
    
    // 下記ソースコードはswift-algorithms Permutationsの派生成果物にあたります。
    // オリジナルはhttps://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Permutations.swift
    // ライセンス及び著作権はhttps://github.com/apple/swift-algorithms/blob/main/LICENSE.txt
    @inlinable
    internal func nextPermutation(upperBound: Index? = nil) -> Bool {
        guard !storage.isEmpty else { return false }
        var i = storage.index(before: storage.endIndex)
        if i == storage.startIndex { return false }
        
        let upperBound = upperBound ?? storage.endIndex
        
        while true {
            let ip1 = i
            storage.formIndex(before: &i)
            
            if storage[i] < storage[ip1] {
                let j = storage.lastIndex(where: { storage[i] < $0 })!
                storage.swapAt(i, j)
                self.reverse(subrange: ip1 ..< storage.endIndex)
                if i < upperBound {
                    return true
                } else {
                    i = storage.index(before: storage.endIndex)
                    continue
                }
            }
            
            if i == storage.startIndex {
                self.reverse(subrange: storage.startIndex ..< storage.endIndex)
                return false
            }
        }
    }
    
    // 下記ソースコードはswift-algorithms Rotateの派生成果物にあたります。
    // オリジナルはhttps://github.com/apple/swift-algorithms/blob/main/Sources/Algorithms/Rotate.swift
    // ライセンス及び著作権はhttps://github.com/apple/swift-algorithms/blob/main/LICENSE.txt
    @inlinable
    internal func reverse(subrange: Range<Index>) {
        if subrange.isEmpty { return }
        var lower = subrange.lowerBound
        var upper = subrange.upperBound
        while lower < upper {
            storage.formIndex(before: &upper)
            storage.swapAt(lower, upper)
            storage.formIndex(after: &lower)
        }
    }
}


