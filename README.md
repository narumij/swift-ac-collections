# swift-ac-collections

English | [日本語](README.ja.md)

`swift-ac-collections` is an ordered data structure package designed for use with [AtCoder][atcoder].
It provides high-performance sets and dictionaries based on Red-Black Trees.

[![Swift](https://github.com/narumij/swift-ac-collections/actions/workflows/swift.yml/badge.svg?branch=main)](https://github.com/narumij/swift-ac-collections/actions/workflows/swift.yml)  
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Installation

### Using Swift Package Manager

Add the following to the `dependencies` section of your `Package.swift`:

```swift
dependencies: [
  .package(
    url: "https://github.com/narumij/swift-ac-collections",
    branch: "main"),
]
```

Then add the product to your target dependencies:

```swift
dependencies: [
  .product(name: "AcCollections", package: "swift-ac-collections")
]
```

Import it in your source code:

```swift
import AcCollections
```

## AtCoder 2025

If you need the version aligned with the AtCoder 2025 judge environment, specify the following branch:

```swift
dependencies: [
  .package(
    url: "https://github.com/narumij/swift-ac-collections",
    branch: "release/AtCoder/2025"),
]
```

## Containers

- RedBlackTreeSet — Ordered set (no duplicate elements)
- RedBlackTreeMultiSet — Ordered multiset (duplicates allowed)
- RedBlackTreeDictionary — Ordered dictionary (unique keys)
- RedBlackTreeMultiMap — Ordered map (duplicate keys allowed)

## Removal

Indices become invalid after removal (they must not be reused).
Use range-based removal APIs for consecutive deletions.

## Underscored Declarations

An "underscored declaration" refers to any declaration whose fully qualified name contains a component that begins with an underscore (`_`).
For example, the following names are technically declared as `public` but are not considered part of the public API:

- `FooModule.Bar._someMember(value:)` (underscored member)
- `FooModule._Bar.someMember` (underscored type)
- `_FooModule.Bar` (underscored module)
- `FooModule.Bar.init(_value:)` (initializer with underscored parameter)

In general, compatibility is not guaranteed for these declarations.
They may change or be removed in future releases without notice.

## License

This library is distributed under the Apache License 2.0:
https://www.apache.org/licenses/LICENSE-2.0

Part of the internal Red-Black Tree implementation is adapted from LLVM.
For the original license, see:
https://llvm.org/LICENSE.txt

---

Bug reports and feature requests are welcome via Issues or Pull Requests.

[atcoder]: https://atcoder.jp/
