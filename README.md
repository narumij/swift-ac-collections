<!-- README.ja.md is the canonical source. README.md is its English translation. -->
<!-- Some jokes are allowed until 1.0. -->

# swift-ac-collections

English | [日本語](README.ja.md)

## Concept

swift-ac-collections is a Swift library that provides a variety of data structures, centered on

**sorted sets and dictionaries with performance comparable to C++ `std::set` / `std::map`**.

These sorted sets and dictionaries are designed to
**make it practical to solve [AtCoder][atcoder] problems that assume C++ `std::set` / `std::multiset`, with usable performance in Swift.**

[![CI](https://github.com/narumij/swift-ac-collections/actions/workflows/ci.yml/badge.svg?event=pull_request)](https://github.com/narumij/swift-ac-collections/actions/workflows/ci.yml?query=event%3Apull_request)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Usage

### Using Swift Package Manager

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
| `main` | ⭐ | Development version for general use, targeting the latest **somewhat** stable Swift |
| `compatible/AtCoder/2025` | | AtCoder 2025-compatible version |
| `release/AtCoder/2025` | | Version deployed in the AtCoder 2025 judge environment |

### Which branch should I use?

In general, `main` is recommended.

Use `compatible/AtCoder/2025` when compatibility with the AtCoder 2025 judge environment is required. This branch maintains compatibility with AtCoder 2025 while receiving maintenance such as documentation improvements, deprecation annotations, and additional warnings.

The `release/AtCoder/2025` branch preserves the exact state deployed on AtCoder.

The `main` branch targets the latest stable Swift and is under active development. Its core functionality and verification are largely in place, and it is already available for evaluation and use. However, stable API compatibility is not yet guaranteed, and APIs and implementations may change.

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

The generated API documentation is available on
[GitHub Pages](https://narumij.github.io/swift-ac-collections/documentation/redblacktreecollections/).

For generation, validation, and local preview instructions, see the [documentation maintenance guide](Maintanance/DOCUMENT.md#swift-doccの確認) (in Japanese).

## Underscored Declarations

An "underscored declaration" refers to any declaration whose fully qualified name contains a component that begins with an underscore (`_`). For example, the following names may technically be declared as `public`, but are not considered part of the public API:

- `FooModule.Bar._someMember(value:)` (underscored member)
- `FooModule._Bar.someMember` (underscored type)
- `_FooModule.Bar` (underscored module)
- `FooModule.Bar.init(_value:)` (initializer with an underscored parameter)

Likewise, do not expect compatibility guarantees for the codebase in general. These declarations may change as needed, including through incompatible changes.

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

**Exception: `Maintanance/` and all its subdirectories are excluded from the repository-wide Apache grant.** Rights held by narumij in their contents are reserved and require prior permission for reuse to the extent permission is legally required; third-party portions (including copied or adapted code snippets) are excluded from this claim and retain their applicable terms. See [Maintanance rights notice](Maintanance/LICENSE.md), including the statement on AI memory-support methods and the exceptions for existing grants, third-party rights, and GitHub functionality.

RedBlackTreeCollections' `__tree` is adapted from the LLVM implementation. For the original license, see  
[https://llvm.org/LICENSE.txt](https://llvm.org/LICENSE.txt).

---

Bug reports and feature requests are welcome via Issues or Pull Requests.

[atcoder]: https://atcoder.jp/
