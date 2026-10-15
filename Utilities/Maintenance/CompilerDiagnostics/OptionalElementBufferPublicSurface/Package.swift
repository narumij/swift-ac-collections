// swift-tools-version: 6.4

import PackageDescription

// Compile fixture for the noncopyable ownership contract of OptionalElementBuffer 1D–4D (OPT-074 E).
// `OptionalSurfaceValid` must build. `OptionalCopyableRequirement` and `OptionalUseAfterConsume`
// must fail with the expected ownership diagnostics. `verify.sh` in this directory checks all three.
let package = Package(
  name: "OptionalElementBufferPublicSurfaceCompilerDiagnostic",
  platforms: [.macOS(.v15)],
  // OptionalElementBufferModule is reachable through AcCollections only with this opt-in trait.
  dependencies: [
    .package(path: "../../../..", traits: [.defaults, "ENABLE_OPTIONAL_ELEMENT_BUFFER"])
  ],
  targets: [
    .target(
      name: "OptionalSurfaceValid",
      dependencies: [.product(name: "AcCollections", package: "swift-ac-collections")]
    ),
    .target(
      name: "OptionalCopyableRequirement",
      dependencies: [.product(name: "AcCollections", package: "swift-ac-collections")]
    ),
    .target(
      name: "OptionalUseAfterConsume",
      dependencies: [.product(name: "AcCollections", package: "swift-ac-collections")]
    ),
  ]
)
