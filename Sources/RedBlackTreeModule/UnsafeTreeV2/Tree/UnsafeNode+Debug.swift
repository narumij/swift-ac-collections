//
//  UnsafeNode+Debug.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/05.
//

extension UnsafeNode {

  @inlinable
  func debugDescription(resolve: (Pointer?) -> Int?) -> String {
    let id = ___node_id_
    let l = resolve(__left_)
    let r = resolve(__right_)
    let p = resolve(__parent_)
    let color = __is_black_ ? "B" : "R"
    #if DEBUG
      let rc = ___recycle_count
    #else
      let rc = -1
    #endif

    return """
      node[\(id)] \(color)
        L: \(l.map(String.init) ?? "nil")
        R: \(r.map(String.init) ?? "nil")
        P: \(p.map(String.init) ?? "nil")
        needsDeinit: \(___needs_deinitialize)
        recycleCount: \(rc)
      """
  }
}
