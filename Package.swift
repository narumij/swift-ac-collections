// swift-tools-version: 6.0
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
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "AcCollections",
      dependencies: ["RedBlackTreeModule"]
    ),
    .target(
      name: "RedBlackTreeModule",
      dependencies: []
    ),
    .testTarget(
      name: "treeTests",
      dependencies: ["RedBlackTreeModule"]
    ),
    .executableTarget(
      name: "Executable",
      dependencies: [
        "RedBlackTreeModule"
      ], 
      path: "TestExecutable"
    ),
  ]
)
