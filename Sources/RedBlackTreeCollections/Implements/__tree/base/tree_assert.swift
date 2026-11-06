//
//  Assert.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/11/06.
//


#if DEBUG && _TREE_ASSERT_INTERNAL
@inline(__always)
public func _TREE_ASSERT_INTERNAL(
  _ condition: @autoclosure () -> Bool,
  _ message: @autoclosure () -> String = String(),
  file: StaticString = #file,
  line: UInt = #line
) { assert(condition(), message(), file: file, line: line) }
#else
@inline(__always)
public func _TREE_ASSERT_INTERNAL(
  _ condition: @autoclosure () -> Bool,
  _ message: @autoclosure () -> String = String(),
  file: StaticString = #file,
  line: UInt = #line
) {}
#endif
