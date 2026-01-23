//
//  RedBlackTreeBound.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/19.
//

public enum RedBlackTreeBound<_Key>: _KeyType {
  case start
  case lower(_Key)
  case upper(_Key)
  case end
}

// TODO: 以下を公開にするかどうかは要再検討

public func end<K>() -> RedBlackTreeBound<K> {
  .end
}

public func lowerBound<K>(_ k: K) -> RedBlackTreeBound<K> {
  .lower(k)
}

public func upperBound<K>(_ k: K) -> RedBlackTreeBound<K> {
  .upper(k)
}

public func start<K>() -> RedBlackTreeBound<K> {
  .start
}
