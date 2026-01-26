//
//  unsafe_node+pointer+debug.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/26.
//

#if DEBUG

  // TODO: まだ正しくうごかないので、直すこと

  // MARK: - Path Dump Utilities (Root → Target)

  @inlinable
  func collectPath(
    from root: UnsafeMutablePointer<UnsafeNode>,
    to target: UnsafeMutablePointer<UnsafeNode>
  ) -> [UnsafeMutablePointer<UnsafeNode>] {
    var path: [UnsafeMutablePointer<UnsafeNode>] = []
    var p = target

    while p != .nullptr {
      path.append(p)
      if p == root { break }
      p = p.__parent_
    }

    return path.reversed()
  }

  @inlinable
  func pathDirections(
    _ path: [UnsafeMutablePointer<UnsafeNode>]
  ) -> [String] {
    guard path.count >= 2 else { return [] }

    var dirs: [String] = []

    for i in 1..<path.count {
      let parent = path[i - 1]
      let node = path[i]

      if parent.__left_ == node {
        dirs.append("Left")
      } else if parent.__right_ == node {
        dirs.append("Right")
      } else {
        dirs.append("<?>")  // broken parent relation
      }
    }

    return dirs
  }

  @inlinable
  func printFullPath(_ dirs: [String]) {
    let joined = dirs.map { $0.prefix(1) }.joined(separator: " → ")
    print("Path: Root → \(joined)")
    print("Depth:", dirs.count)
  }

  @inlinable
  func printPrettyPath(
    _ dirs: [String],
    maxVisible: Int = 6
  ) {
    print("Root")

    let depth = dirs.count
    guard depth > 0 else { return }

    var indent = ""

    func emit(_ text: String, last: Bool) {
      print(indent + (last ? "└─ " : "├─ ") + text)
      indent += last ? "    " : "│   "
    }

    // --- Case 1: small path → print normally
    if depth <= maxVisible {
      for i in 0..<depth {
        emit(dirs[i], last: i == depth - 1)
      }
      return
    }

    // --- Case 2: large path → truncated display
    let headCount = maxVisible / 2
    let tailCount = maxVisible / 2

    let head = dirs.prefix(headCount)
    let tail = dirs.suffix(tailCount)

    for d in head {
      emit(d, last: false)
    }

    emit("… (depth \(depth - maxVisible))", last: false)

    for i in 0..<tail.count {
      emit(tail[i], last: i == tail.count - 1)
    }
  }

  @inlinable
  func describePointerIndex(_ id: _PointerIndex) -> String {
    switch id {
    case .nullptr: return "nullptr"
    case .end: return "end"
    case .debug: return "debug"
    default: return String(id)
    }
  }

  @inlinable
  func dumpPath(
    root: UnsafeMutablePointer<UnsafeNode>,
    target: UnsafeMutablePointer<UnsafeNode>,
    label: String = ""
  ) {
    let title = "==== Tree Path Dump \(label) ===="
    print(title)
    defer { print(String(repeating: "-", count: title.count)) }

    let nodes = collectPath(from: root, to: target)
    let dirs = pathDirections(nodes)

    // Pretty tree
    printPrettyPath(dirs)

    // Full path
    printFullPath(dirs)

    // Final node info
    if let last = nodes.last {
      print(
        "Target:",
        "ptr=", last,
        "id=", describePointerIndex(last.pointee.___raw_index)
      )
    } else {
      print("Target: <none>")
    }
  }

#endif

@frozen
@usableFromInline
enum RBInvariantViolation: Error, CustomStringConvertible, @unchecked Sendable {
  case rootParentNull(node: UnsafeMutablePointer<UnsafeNode>)
  case rootNotLeftChild(node: UnsafeMutablePointer<UnsafeNode>)
  case rootNotBlack(node: UnsafeMutablePointer<UnsafeNode>)

  case leftParentMismatch(node: UnsafeMutablePointer<UnsafeNode>)
  case rightParentMismatch(node: UnsafeMutablePointer<UnsafeNode>)
  case leftRightAlias(node: UnsafeMutablePointer<UnsafeNode>)

  case redRed(node: UnsafeMutablePointer<UnsafeNode>)

  case leftSubtreeInvalid(node: UnsafeMutablePointer<UnsafeNode>)
  case blackHeightMismatch(node: UnsafeMutablePointer<UnsafeNode>)

  @usableFromInline
  var description: String {
    switch self {
    case .rootParentNull: return "Root parent is nullptr"
    case .rootNotLeftChild: return "Root is not left child"
    case .rootNotBlack: return "Root is red"

    case .leftParentMismatch: return "Left child's parent mismatch"
    case .rightParentMismatch: return "Right child's parent mismatch"
    case .leftRightAlias: return "Left and right child alias"

    case .redRed: return "Red node has red child"

    case .leftSubtreeInvalid: return "Left subtree invalid"
    case .blackHeightMismatch: return "Black height mismatch"
    }
  }
}

@usableFromInline
internal func __tree_sub_invariant_checked(
  _ x: UnsafeMutablePointer<UnsafeNode>
) throws -> UInt {

  if x == .nullptr {
    return 1
  }

  // left parent consistency
  if x.__left_ != .nullptr && x.__left_.__parent_ != x {
    throw RBInvariantViolation.leftParentMismatch(node: x)
  }

  // right parent consistency
  if x.__right_ != .nullptr && x.__right_.__parent_ != x {
    throw RBInvariantViolation.rightParentMismatch(node: x)
  }

  // left/right alias
  if x.__left_ == x.__right_ && x.__left_ != .nullptr {
    throw RBInvariantViolation.leftRightAlias(node: x)
  }

  // red–red violation
  if !x.__is_black_ {
    if x.__left_ != .nullptr && !x.__left_.__is_black_ {
      throw RBInvariantViolation.redRed(node: x)
    }
    if x.__right_ != .nullptr && !x.__right_.__is_black_ {
      throw RBInvariantViolation.redRed(node: x)
    }
  }

  let lh: UInt
  do {
    lh = try __tree_sub_invariant_checked(x.__left_)
  } catch {
    throw RBInvariantViolation.leftSubtreeInvalid(node: x)
  }

  let rh = try __tree_sub_invariant_checked(x.__right_)
  if lh != rh {
    throw RBInvariantViolation.blackHeightMismatch(node: x)
  }

  return lh + (x.__is_black_ ? 1 : 0)
}

@usableFromInline
internal func __tree_invariant_checked(
  _ root: UnsafeMutablePointer<UnsafeNode>
) throws -> Bool {

  if root == .nullptr {
    return true
  }

  if root.__parent_ == .nullptr {
    throw RBInvariantViolation.rootParentNull(node: root)
  }

  if !__tree_is_left_child(root) {
    throw RBInvariantViolation.rootNotLeftChild(node: root)
  }

  if !root.__is_black_ {
    throw RBInvariantViolation.rootNotBlack(node: root)
  }

  _ = try __tree_sub_invariant_checked(root)

  return true
}
