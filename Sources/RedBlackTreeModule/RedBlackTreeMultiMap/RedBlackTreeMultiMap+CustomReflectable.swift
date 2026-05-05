//
//  RedBlackTreeMultiMap+.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/05.
//

// MARK: - CustomReflectable

extension RedBlackTreeMultiMap: CustomReflectable {
  /// The custom mirror for this instance.
  public var customMirror: Mirror {
    Mirror(self, unlabeledChildren: self + [], displayStyle: .dictionary)
  }
}
