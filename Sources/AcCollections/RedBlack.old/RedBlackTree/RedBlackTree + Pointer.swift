import Foundation

@usableFromInline
protocol _Pointer: Equatable {
    associatedtype _Pointee
}

@usableFromInline
protocol _BufferPointer: _Pointer
{
    init(elements: UnsafeMutablePointer<_Pointee>, offset: Int)
    var elements: UnsafeMutablePointer<_Pointee> { get }
    var offset: Int { get }
}

extension _BufferPointer {
    
    @inlinable
    var __raw_pointer: UnsafeMutablePointer<_Pointee> {
        @inline(__always) get { (elements + offset) }
    }
}

