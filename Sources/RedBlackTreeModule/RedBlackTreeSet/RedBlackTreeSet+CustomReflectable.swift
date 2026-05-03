//
//  RedBlackTreeSet+CustomReflectable.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/04.
//

// MARK: - CustomReflectable

extension RedBlackTreeSet: CustomReflectable {
  /// The custom mirror for this instance.
  public var customMirror: Mirror {
    Mirror(self, unlabeledChildren: self + [], displayStyle: .set)
  }
}
