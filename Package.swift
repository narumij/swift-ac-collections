// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "swift-ac-collections",
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "AcCollections",
      targets: ["AcCollections"])
  ],
  dependencies: [
    .package(
      url: "https://github.com/apple/swift-collections.git",
      from: "1.1.4")
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "AcCollections",
      dependencies: ["RedBlackTreeModule"]
    ),
    .target(
      name: "RedBlackTreeModule",
      dependencies: [
        .product(name: "Collections", package: "swift-collections"),
      ]),
    .testTarget(
      name: "treeTests",
      dependencies: ["RedBlackTreeModule"]
    ),
    .executableTarget(
      name: "Executable",
      dependencies: [
        "RedBlackTreeModule"
      ]
    ),
  ]
)
