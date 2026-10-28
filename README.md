<!-- README.ja.md is the canonical source. README.md is its English translation. -->
<!-- Some jokes are allowed until 1.0. -->

# swift-ac-collections

English | [日本語](README.ja.md)

## Concept

swift-ac-collections is a Swift library that provides a variety of data structures, centered on

**sorted sets and dictionaries that aim for performance comparable to C++ `std::set` / `std::map`**.

These sorted sets and dictionaries are designed to
**make it practical to solve [AtCoder][atcoder] problems that assume C++ `std::set` / `std::multiset`, with usable performance in Swift.**

[![CI](https://github.com/narumij/swift-ac-collections/actions/workflows/ci.yml/badge.svg?event=pull_request)](https://github.com/narumij/swift-ac-collections/actions/workflows/ci.yml?query=event%3Apull_request)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Usage

### Using Swift Package Manager

The current package requires Swift 6.4 or later. On macOS, it targets macOS 15 or later.

Add the following to the `dependencies` section of your `Package.swift`:

```swift
dependencies: [
  .package(
    url: "https://github.com/narumij/swift-ac-collections",
    branch: "main"),
]
```

Then add the product to your build target:

```swift
dependencies: [
  .product(name: "AcCollections", package: "swift-ac-collections")
]
```

Import it in your source code:

```swift
import AcCollections
```

`AcCollections` is the usual entry point and re-exports the permutation APIs. Direct users should
import `NextPermutationModule`; the former `PermutationModule` name remains as a compatibility entry
point that re-exports the same declarations.

### Enabling OptionalElementBuffer

`OptionalElementBuffer` isn't exposed through `AcCollections` by default. To explicitly use this
experimental low-level utility, enable the `ENABLE_OPTIONAL_ELEMENT_BUFFER` trait on the package
dependency:

```swift
dependencies: [
  .package(
    url: "https://github.com/narumij/swift-ac-collections",
    branch: "main",
    traits: ["ENABLE_OPTIONAL_ELEMENT_BUFFER"]),
]
```

After enabling the trait, import `AcCollections` normally to use the one- through four-dimensional
`OptionalElementBuffer` types. For more about configuring dependency traits, see
[Adding dependencies to a Swift package](https://docs.swift.org/latest/documentation/packagemanagerdocs/addingdependencies/#Packages-with-Traits).

## Branch Strategy

| Branch | Recommended | Description |
|----------|----------|----------|
| `main` | ⭐ | Development version (Swift 6.4 or later) |
| `compatible/AtCoder/2025` | | AtCoder 2025-compatible version |
| `release/AtCoder/2025` | | Version deployed in the AtCoder 2025 judge environment |

Use `main` for general use. The library is under development; APIs and implementations may change.

Use `compatible/AtCoder/2025` for AtCoder 2025 compatibility, or `release/AtCoder/2025` for the version deployed on AtCoder.

---

## Containers

- RedBlackTreeSet — Sorted set (no duplicate elements)
- RedBlackTreeMultiSet — Sorted multiset (duplicates allowed)
- RedBlackTreeDictionary — Sorted dictionary (unique keys)
- RedBlackTreeMultiMap — Sorted map (duplicate keys allowed)

## Removal

Indices become invalid after removal and must not be reused.  
Use range-based removal APIs for consecutive deletions.

## Documentation

Current guides in this checkout:

- [RedBlackTreeCollections](Sources/RedBlackTreeCollections/RedBlackTreeCollections.docc/RedBlackTreeCollections.md)
- [NextPermutationModule](Sources/NextPermutationModule/NextPermutationModule.docc/NextPermutationModule.md)
- [OptionalElementBufferModule](Sources/OptionalElementBufferModule/OptionalElementBufferModule.docc/OptionalElementBufferModule.md)
- [ElementBufferModule](Sources/ElementBufferModule/ElementBufferModule.docc/ElementBufferModule.md)

The generated API documentation is available on
[GitHub Pages](https://narumij.github.io/swift-ac-collections/documentation/redblacktreecollections/).

## AtCoder 2025

If you need the exact version used by the AtCoder 2025 judge environment, specify the following:

```swift
dependencies: [
  .package(
    url: "https://github.com/narumij/swift-ac-collections",
    branch: "release/AtCoder/2025"),
]
```

## License

This library is distributed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

RedBlackTreeCollections' `__tree` is adapted from the LLVM implementation. For the original license, see  
[LLVM libc++ license](Licenses/LLVM-libcxx.txt).

Licenses for third-party code, including Swift Collections and Swift Algorithms, are included in [Licenses](Licenses/README.md).

---

Bug reports and feature requests are welcome via Issues or Pull Requests.

[atcoder]: https://atcoder.jp/
