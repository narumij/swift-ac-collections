# Memory Safety Design

English | [日本語](MemorySafety.ja.md)

In measured lookups and removals, the trees in this library perform on par with `std::set`. This document explains why that performance is not the result of leaving out safety checks.

The key is where the checks are placed. Part of the tree is safe to begin with. No checks are added there, and it runs the same steps as C++. The assumptions can break only where user operations enter. The checks are gathered there.

## 1. Strengths and weaknesses of a plain red-black tree

The tree in this library is adapted from `__tree` in LLVM libc++.

Its strength is that its internal operations are closed. Insertion, removal, rotation, and recoloring start from a state where the tree invariants hold, touch only live nodes, and end in a state where the invariants hold. For valid input, the existing algorithms are enough, and no memory violation occurs.

Its weakness is that it does nothing about operations that break those assumptions.

- **Moving out of bounds**: advancing past `end`, or stepping back before `begin`, reads null or memory that is not a node.
- **Invalidated positions**: moving from or accessing an iterator that points to a removed node reads freed memory.
- **Positions from another tree**: an iterator from a different tree cannot be told apart.

In C++, all of these are undefined behavior, and preventing them is the user's responsibility.

## 2. What the sentinel provides

This library uses an allocated sentinel node in place of a null pointer. Wherever null would normally appear, such as below a leaf, the link points to this sentinel. The sentinel is shared across trees, and its left, right, and parent all point to the sentinel itself.

The parent of the root is a different node. Each tree has its own `end` node, whose left link leads to the root. The right and parent links of `end` point to the sentinel. `end` is part of the tree; the sentinel is its outer edge.

As a result, following links stays within allocated memory. From a valid node, following left, right, or parent any number of times leads to a live node, `end`, or the sentinel. Following the sentinel's links further stays at the sentinel. Moving out of bounds shows up as reaching the sentinel, not as a violation.

This has two effects.

- **By construction, moving out of bounds never dereferences a null pointer.** This is not prevented by a check; there is no path that reaches null.
- **No null check is needed before each move.** Checking after the sentinel is reached is enough, which removes branches from traversal.

There are things the sentinel does not protect. The sentinel has no value, so reading a value needs a separate check. The sentinel cannot identify a removed node or a position from another tree. What the sentinel guarantees is limited to moves that start from a valid position.

## 3. What Result covers

`Result` is used only on paths where invalid user operations can enter.

Where they cannot, `Result` is not used. Inside the tree, insertion, lookup, and removal by key work on plain node pointers. Traversal with ordinary iterators advances while comparing against the end position, and does not wrap each move in a `Result`. As described in section 1, these are closed under the existing algorithms alone. Inside the tree, the steps are the same as in C++, and no stage needs an added position re-validation or `Result`-based failure handling. The checks are not left out; this is a range that does not need them.

Access and movement that start from a user's index are different. This includes traversal that repeatedly calls `index(after:)` from `startIndex`. The position may have been invalidated, or the move may go out of bounds. For moves that go out of bounds, the sentinel turns the failure from a violation into a reachable state. Invalidation is detected as a failure when the position is resolved. `Result` carries these failures back to the caller without dropping them.

On this path, moving and resolving return a value that holds either success or failure, not a bare node. In a design that returns pointers directly, failure becomes a special pointer value, and a caller that forgets to check can pass it straight to the next operation. With `Result`, the code states which of the two it is handling.

Operations are chained with `flatMap`. If one step fails, the following steps do not run, and the failure reaches the end of the chain unchanged. No further move or access is built on a failed position.

Because the failure remains a value, each public API can choose how to surface it: `nil`, `false`, an empty view, or a trap.

What `Result` guarantees is only that failure handling is explicit. The type does not guarantee that the pointer inside a success is correct. That is the job of the checks that produce the success, and of the boundary described in the next section.

## 4. What the boundary protects

The guarantees in sections 2 and 3 assume that operations start from a valid position. The public API boundary is what makes that assumption hold.

**From inside to outside: null does not leak.** A position that points to the sentinel never leaves as a public index. What the user receives is an index to an element, `endIndex`, or `nil`. At the moment an index leaves, it always points to a valid position.

**From outside to inside: returning positions are checked.** An index that was valid when it was handed out can be invalidated later, for example by a removal. What went out does not necessarily come back unchanged. For this reason, before an index from the user enters the internals, it is resolved to a position usable in the current tree, and the existence of the element and its generation are checked. An index that cannot be confirmed is not passed to the ordinary internal operations, and APIs that require a valid position trap. This validation also reads only allocated memory.

Positions are guaranteed valid when they leave, and confirmed still valid when they return. Together, these ensure that every position entering an internal operation is valid.

What this protects is the internal invariants. Inside the boundary, a position can be assumed valid, and internal operations do not have to repeat the same checks. Safety checks are gathered at the boundary, and the inside is kept safe by construction. This division is why performance and safety are not traded against each other.

## Summary

| Layer | Covers | How |
|---|---|---|
| Tree algorithms | Internal operations that invalid input cannot reach | Maintaining the invariants. Same steps as C++, without `Result` |
| Sentinel | Moving out of bounds | Removing every path that reaches null |
| `Result` | Operations that start from a user's index | Carrying failure as a value and stopping with `flatMap` |
| Public API boundary | Invalid positions going out or coming in | Guaranteeing on the way out, confirming on the way back |

The safety that the inside of the tree already has is kept as it is, and the remaining three layers cover the paths where its assumptions can break. This division is what supports both safety and speed.
