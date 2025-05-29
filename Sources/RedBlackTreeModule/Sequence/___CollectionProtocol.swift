//
//  ___CollectionProtocol.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/05/29.
//

@usableFromInline
protocol ___CollectionProtocol: CompareProtocol {
  // この実装がないと、迷子になる?
  func ___distance(from start: _NodePtr, to end: _NodePtr) -> Int
  
  func ___index(after i: _NodePtr) -> _NodePtr
  func ___index(before i: _NodePtr) -> _NodePtr
  
  func ___formIndex(after i: inout _NodePtr)
  func ___formIndex(before i: inout _NodePtr)

  func ___index(_ i: _NodePtr, offsetBy distance: Int) -> _NodePtr
  func ___index(_ i: _NodePtr, offsetBy distance: Int, limitedBy limit: _NodePtr) -> _NodePtr?

  func ___formIndex(_ i: inout _NodePtr, offsetBy distance: Int)
  func ___formIndex(_ i: inout _NodePtr, offsetBy distance: Int, limitedBy limit: _NodePtr) -> Bool

  func ___is_valid(_ p: _NodePtr) -> Bool
}

