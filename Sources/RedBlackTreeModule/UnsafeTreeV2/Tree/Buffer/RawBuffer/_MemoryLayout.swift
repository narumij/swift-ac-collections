//
//  _MemoryLayout.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/21.
//

@frozen
@usableFromInline
package struct _MemoryLayout {

  #if DEBUG
    internal init<T>(_ t: T.Type) {
      self = MemoryLayout<T>._memoryLayout
    }
  #endif

  @inlinable
  internal init<T0, T1>(_ t0: T0.Type, _ t1: T1.Type) {
    self.stride = MemoryLayout<T0>.stride + MemoryLayout<T1>.stride
    self.alignment = max(MemoryLayout<T0>.alignment, MemoryLayout<T1>.alignment)
  }

  @inlinable
  internal init(stride: Int, alignment: Int) {
    self.stride = stride
    self.alignment = alignment
  }

  @usableFromInline package var stride: Int
  @usableFromInline package var alignment: Int
}
