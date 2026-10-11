// swift-tools-version: 6.4

import PackageDescription

let package = Package(
  name: "BareArrayViewEscapeCompilerDiagnostic",
  platforms: [.macOS(.v15)],
  dependencies: [
    .package(path: "../../../..")
  ],
  targets: [
    .target(
      name: "BareArrayViewEscapeCompilerDiagnostic",
      dependencies: [
        .product(name: "AcCollections", package: "swift-ac-collections")
      ],
      swiftSettings: [
        .enableExperimentalFeature("Lifetimes")
      ]
    )
  ]
)
