# swift-ac-collections

English | [日本語](README.ja.md)

`swift-ac-collections` is an open-source package that provides data structures and related utilities intended for use on [AtCoder][atcoder].

[![Swift](https://github.com/narumij/swift-ac-collections/actions/workflows/swift.yml/badge.svg?branch=main)](https://github.com/narumij/swift-ac-collections/actions/workflows/swift.yml)  
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Usage

### Using Swift Package Manager

Add the following to the `dependencies` section of your `Package.swift`:

```Swift
dependencies: [
  .package(
    url: "https://github.com/narumij/swift-ac-collections",
    branch: "main"),
]
```

Then add the following to your build target:

```Swift
dependencies: [
  .product(name: "AcCollections", package: "swift-ac-collections")
]
```

Import it in your source code:

```Swift
import AcCollections
```

## AtCoder 2025

If you want to use the same version as the AtCoder 2025 judge environment, use the following:

```Swift
dependencies: [
  .package(
    url: "https://github.com/narumij/swift-ac-collections",
    branch: "release/AtCoder/2025"),
]
```

## Contents

**Note:** This section is outdated, as the package is undergoing major updates for the next judge update and for general use.

### RedBlackTreeModule

This module provides containers based on Red-Black Trees, a type of balanced binary search tree.

Specifically, it provides the following containers, corresponding to C++’s `std::set`, `std::multiset`, `std::map`, and `std::multimap`.

#### 1. RedBlackTreeSet

- A Set that manages **unique elements**.
- Insertion, deletion, and search are generally performed in `O(log n)`.
- Conforms to `Collection`, so indexed element access, `startIndex`, `endIndex`, and related APIs are available.
- Provides boundary search methods such as `lowerBound` and `upperBound`.
- Usage examples: [AtCoder submission example (ABC370D)](https://atcoder.jp/contests/abc370/submissions/62143443) / [AtCoder submission example (ABC385D)](https://atcoder.jp/contests/abc385/submissions/61848462), etc.

#### 2. RedBlackTreeMultiSet

- A MultiSet that manages elements **with duplicates**.
- `count(_:)` returns how many times a specific element is contained.
- Other characteristics and usage are similar to `RedBlackTreeSet`.
- Usage example: [AtCoder submission example (ABC358D)](https://atcoder.jp/contests/abc358/submissions/62143179), etc.

#### 3. RedBlackTreeMultiMap

- A Map that manages **duplicate keys and values**.
- `count(forKey:)` returns how many elements exist for a specific key.
- Its API is based on MultiSet and Dictionary, while trying to follow Swift conventions as much as possible.

#### 4. RedBlackTreeDictionary

- A Dictionary that manages **keys and values**.
- Basic operations such as key lookup, insertion, and deletion are performed in `O(log n)`.
- Supports dictionary literals via `ExpressibleByDictionaryLiteral`.

#### Simple usage examples

```Swift
import AcCollections

// RedBlackTreeSet example
var set = RedBlackTreeSet<Int>()
set.insert(10)
set.insert(5)
set.insert(5)    // duplicates are ignored
print(set)       // example: [5, 10]
print(set.min()) // example: Optional(5)

// RedBlackTreeMultiSet example
var multiset = RedBlackTreeMultiSet<Int>([1, 2, 2, 3])
multiset.insert(2)
print(multiset)       // example: [1, 2, 2, 2, 3]
print(multiset.count(2))  // example: 3

// RedBlackTreeDictionary example
var dict = RedBlackTreeDictionary<String, Int>()
dict["apple"] = 5
dict["banana"] = 3
print(dict) // example: [apple: 5, banana: 3]

// RedBlackTreeMultiMap example
var multimap = RedBlackTreeMultiMap<String, Int>()
multimap.insert(key: "apple", value: 5)
multimap.insert(key: "apple", value: 2)
multimap.insert(key: "banana", value: 3)
print(multimap)  // example: [apple: 5, apple: 2, banana: 3]
```

#### Index

Each data structure in the Red-Black Tree module stores tree nodes in an internal array.

When comparing indices of this internal array, the comparison result does not match the sorted order of the elements.

Swift’s standard protocols require index comparison to be consistent with element order, so this module uses an abstracted index.

This is `Index`. In practice, it behaves similarly to a C++ iterator.

Most APIs in the Red-Black Tree module use this abstracted `Index`.

Please note that it is different from a simple `Int` index.

- The `indices` property returns a sequence of `Index` values.

#### Index invalidation on deletion and safe range deletion

When a deletion operation is performed, the target node is cleared and becomes part of a reuse-management linked list.

An index that points to a deleted node simply becomes invalid.

You need to be careful about this behavior when performing range deletion.

- Continuing to use a reference to a deleted node will crash.

- If you need to check whether an index is valid, use `isValid(index:)`.

- `endIndex` is an exception; its internal index is always unchanged.

Various subsequences and iterators include deletion-safety measures, so they can generally be used for range deletion without issue.

##### Range deletion examples

0. Delete normally

This is the easy way to avoid the problem.

After many twists and turns, this has become stable.

Making `Index` conform to `Strideable` was very slow, such as `O(log n)` per element.

Instead, this implementation gains speed by using separately prepared iterators and sequences.

The `..<` operator normally creates a `Range`, but depending on type inference, it can become another kind of sequence.

In other words, it is replaced by a deletion-safe sequence or iterator, so you can use it without being conscious of the details.

```Swift
var tree0: RedBlackTreeSet<Int> = [0,1,2,3,4,5]
for i in tree0.startIndex ..< tree0.endIndex {
  tree0.remove(at: i) // i becomes invalid at this point
  print(tree0.isValid(index: i)) // false
}
print(tree0.count) // 0
```

```Swift
var tree0: RedBlackTreeSet<Int> = [0,1,2,3,4,5]
for i in tree0.indices {
  tree0.remove(at: i) // i becomes invalid at this point
  print(tree0.isValid(index: i)) // false
}
print(tree0.count) // 0
```

```Swift
var tree0: RedBlackTreeSet<Int> = [0,1,2,3,4,5]
for i in (tree0.startIndex ..< tree0.endIndex).reversed() {
  tree0.remove(at: i) // i becomes invalid at this point
  print(tree0.isValid(index: i)) // false
}
print(tree0.count) // 0
```

```Swift
var tree0: RedBlackTreeSet<Int> = [0,1,2,3,4,5]
for i in tree0.indices.reversed() {
  tree0.remove(at: i) // i becomes invalid at this point
  print(tree0.isValid(index: i)) // false
}
print(tree0.count) // 0
```

If you use the container outside these deletion-safe sequences or iterators, one of methods 1 through 5 below may be useful.

1. Get the next index before deleting

This is the basic way to avoid the problem. The deletion-safe iterators do the same thing internally.

```Swift
var tree: RedBlackTreeSet<Int> = [0,1,2,3,4,5]
var i = tree.startIndex
while i != tree.endIndex { // endIndex is immutable
  let j = i
  i = tree.index(after: i)
  tree.remove(at: j) // j becomes invalid at this point
  print(tree.isValid(index: j)) // false
}
print(tree.count) // 0
```

2. Delete using a special `forEach`

You can loop over both index and value, and use this for deletion.

Use this when you need to do something in addition to deletion, such as in ABC385D.

```Swift
var tree: RedBlackTreeSet<Int> = [0,1,2,3,4,5]
tree[tree.startIndex ..< tree.endIndex].forEach { i, e in
  tree.remove(at: i)
  print(e) // each element
  print(tree.isValid(index: i)) // false
}
print(tree.count) // 0
```

3. Delete using `removeSubrange(_: Range<Index>)`

You can specify the deletion target by an index range.

In general, this is faster in constant factors than deleting in a loop.

The asymptotic complexity is not very different.

```Swift
var tree: RedBlackTreeSet<Int> = [0,1,2,3,4,5]
tree.removeSubrange(tree.startIndex ..< tree.endIndex)
XCTAssertEqual(tree.count, 0)
```

4. Delete using `remove(contentsOf: Range<Element>)`

You can specify the deletion target by a value range.

It takes slightly more time because it needs to search for the boundaries, but this is also fast.

```Swift
var tree: RedBlackTreeSet<Int> = [0, 1, 2, 3, 4, 5]
tree.remove(contentsOf: 0 ..< 6)
// 0 through 5 are deleted, and the result is empty
```

5. Define your own `erase()` and delete

You can also write deletion code similar to C++’s `set`.

```Swift
extension RedBlackTreeSet {
  mutating func erase(at position: Index) -> Index {
    defer { remove(at: position) }
    return index(after: position)
  }
}

var tree: RedBlackTreeSet<Int> = [0, 1, 2, 3, 4, 5]
var idx = tree.startIndex
while idx != tree.endIndex {
  idx = tree.erase(at: idx)
}
```

x. Not recommended because the comparison operator is not `O(1)`, but you can also loop using comparison.

```Swift
var tree: RedBlackTreeSet<Int> = [0, 1, 2, 3, 4, 5]
var idx = tree.startIndex
while idx < tree.endIndex {
  idx = tree.erase(at: idx)
}
```

#### `remove(_:)` in MultiSet

For deleting multiple elements by element value, copy-on-write checks are relatively strict.

This applies to `remove(_:)` in `RedBlackTreeMultiSet`, and to APIs such as `remove(contentsOf:)` in other collections.

Depending on usage, repeated full copies may occur.

To avoid this, it is preferable that iterators, subsequences, indices, and similar values have already been consumed at the time of deletion.

```Swift
var multiset: RedBlackTreeMultiSet<Int> = [0,0,1,1,2,2]
for member in multiset {
  // At this point, the iterator is still valid.
  // To avoid invalidating the iterator, an internal copy is performed.
  // In this case, one internal copy occurs.
  multiset.remove(member)
}
```

```Swift
var multiset: RedBlackTreeMultiSet<Int> = [0,0,1,1,2,2]
for member in multiset.map({ $0 }) {
  // The iterator has already been consumed, so no copy occurs.
  multiset.remove(member)
}
```

There are circumstances where this kind of protection cannot be applied to range deletion by index.

Please be careful about index invalidation.

#### MultiMap

This container was added because missing functionality was noticed while comparing against standard containers and the STL.

I do not know of any problems that target this container, so it has no AC track record, and its API and tuning are still rough.

However, since it is based on the other containers built so far, its performance is reasonably good.

Its API is like a dictionary degraded into a multiset, and combined with the fact that key access returns subsequences, it is desperately hard to use if you think of it as a dictionary.

For now, you need to make full use of `lowerBound`, `upperBound`, `equalRange`, `indices`, and `enumerated`.

### PermutationModule

#### Usage

```Swift
import AcCollections

for p in [1,2].nextPermutations() {
  print(p.map{$0})
  // [1,2]
  // [2,1]
}
```

#### Description

The nice thing about this API is that it enumerates the remaining permutations in lexicographical order.

The termination condition is when the sequence returns to the same order as the sorted order, and output stops just before that.

There is a problem called ABC328E. When I read the editorial code written in C++, I mistakenly thought for about a year that C++ could brute-force this problem.

That was not the case. It was computable because `next_permutation` only moves through lexicographical changes, reducing the number of combinations to consider.

Whether 28! can be prepared in two seconds is not a library issue; it was simply impossible in the first place.

Because of this misunderstanding, I pursued a low-overhead implementation, and as a result produced a very lightweight one.

As a bonus, `unsafePermutations` and `unsafeNextPermutations` are also provided. These cancel copy-on-write behavior and do not perform copying.

## Declarations with underscores

A “declaration with an underscore” refers to any declaration whose fully qualified name contains a component that starts with an underscore (`_`).

For example, the following names are technically declared as `public`, but are not considered public API:

- `FooModule.Bar._someMember(value:)` — a member with an underscore
- `FooModule._Bar.someMember` — a type with an underscore
- `_FooModule.Bar` — a module with an underscore
- `FooModule.Bar.init(_value:)` — an initializer with an underscored argument

Also, contents included in subdirectories other than `Sources` are not public API.

Feel free to quote these parts and use them as “bonsai” to maintain as your own library.

Since they may be changed or removed in future releases, it is recommended that you copy the parts you need and manage them yourself.

Similarly, do not expect compatibility to be guaranteed across the codebase in general.

These declarations may be changed as needed, and incompatible changes may be introduced.

## License

This library is distributed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

RedBlackTreeModule is modified from an LLVM implementation.  
For the original license, see:

[https://llvm.org/LICENSE.txt](https://llvm.org/LICENSE.txt)

PermutationModule is modified from an implementation by swift-algorithms.  
For the original license, see:

[https://github.com/apple/swift-algorithms/blob/main/LICENSE.txt](https://github.com/apple/swift-algorithms/blob/main/LICENSE.txt)

---

Bug reports and feature requests are welcome via Issues or Pull Requests.  
Thank you for using this package!

[atcoder]: https://atcoder.jp/
