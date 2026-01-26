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
      dirs.append("<?>") // broken parent relation
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
  let headCount = maxVisible / 2
  let tailCount = maxVisible / 2

  let head = dirs.prefix(headCount)
  let tail = dirs.suffix(tailCount)

  var indent = ""

  func emit(_ text: String, last: Bool) {
    print(indent + (last ? "└─ " : "├─ ") + text)
    indent += last ? "    " : "│   "
  }

  // Head segment
  for d in head {
    emit(d, last: false)
  }

  // Ellipsis if truncated
  if depth > maxVisible {
    emit("… (depth \(depth - maxVisible))", last: false)
  }

  // Tail segment
  var idx = 0
  for d in tail {
    let last = (idx == tail.count - 1)
    emit(d, last: last)
    idx &+= 1
  }
}

@inlinable
func describePointerIndex(_ id: _PointerIndex) -> String {
  switch id {
  case .nullptr: return "nullptr"
  case .end:     return "end"
  case .debug:   return "debug"
  default:       return String(id)
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
