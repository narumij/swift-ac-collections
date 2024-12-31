// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

var defines: [String] = [
//  "AC_COLLECTIONS_INTERNAL_CHECKS",
//  "TREE_INVARIANT_CHECKS",
]

var _settings: [SwiftSetting] = defines.map { .define($0) }

let package = Package(
  name: "swift-ac-collections",
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "AcCollections",
      targets: ["AcCollections"])
  ],
//  dependencies: [
//    .package(
//      url: "https://github.com/apple/swift-collections.git",
//      .upToNextMinor(from: "1.1.0") // or `.upToNextMajor
//    )
//  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "AcCollections",
      dependencies: ["RedBlackTreeModule"],
      swiftSettings: _settings
    ),
    .target(
      name: "RedBlackTreeModule",
      dependencies: [],
      swiftSettings: _settings
    ),
    .testTarget(
      name: "treeTests",
      dependencies: ["RedBlackTreeModule"],
      swiftSettings: _settings
    ),
    .executableTarget(
      name: "Executable",
      dependencies: [
//        .product(name: "Collections", package: "swift-collections"),
        "RedBlackTreeModule"
      ], 
      path: "TestExecutable",
      swiftSettings: _settings
    ),
  ]
)
