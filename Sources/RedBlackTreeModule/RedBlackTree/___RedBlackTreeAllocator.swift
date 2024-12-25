//
//  ___RedBlackTreeAllocator.swift
//  swift-ac-collections
//
//  Created by narumij on 2024/12/26.
//

import Collections

@usableFromInline
protocol ___RedBlackTreeAllocatorBase: ___RedBlackTreeBody { }

extension ___RedBlackTreeAllocatorBase {
  
  @inlinable
  mutating func __construct_node(_ k: Element) -> _NodePtr {
    let n = Swift.min(___nodes.count, ___values.count)
    ___nodes.append(.zero)
    ___values.append(k)
    return n
  }

  @inlinable
  mutating func destroy(_ p: _NodePtr) {
    ___nodes[p].invalidate()
  }
}

@usableFromInline
protocol ___RedBlackTreeAllocator: ___RedBlackTreeBody {
  var ___stock: Heap<_NodePtr> { get set }
}

extension ___RedBlackTreeAllocator {
  
  @inlinable
  mutating func ___garbageCollect() {
    // 未使用末尾を開放する
    var last = ___nodes.count
    while last != 0, !___stock.isEmpty, ___stock.max == last - 1 {
      _ = ___stock.popMax()
      last -= 1
    }
    let amount = max(___nodes.count - last, 0)
    ___nodes.removeLast(amount)
    ___values.removeLast(amount)
  }

  @inlinable
  mutating func __construct_node(_ k: Element) -> _NodePtr {
    if let stock = ___stock.popMin() {
      ___values[stock] = k
      return stock
    }
    let n = Swift.min(___nodes.count, ___values.count)
    ___nodes.append(.zero)
    ___values.append(k)
    return n
  }

  @inlinable
  mutating func destroy(_ p: _NodePtr) {
    ___nodes[p].invalidate()
    ___stock.insert(p)
    ___garbageCollect()
  }
}

