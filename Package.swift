// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StoreUtils",
    defaultLocalization: "en",
    platforms: [.iOS(.v14), .macCatalyst(.v14)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "StoreUtils",
            targets: ["StoreUtils"]),
        .library(name: "StoreUtilsUI",
                 targets: ["StoreUtilsUI"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/RevenueCat/purchases-ios.git", Version("4.0.0")..<Version("5.0.0")),
        .package(url: "https://github.com/grepug/UIKitUtils", branch: "dev_3.1.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "StoreUtils",
            dependencies: [.product(name: "RevenueCat", package: "purchases-ios")],
            path: "Sources/StoreUtils"),
        .target(name: "StoreUtilsUI",
                dependencies: ["StoreUtils", "UIKitUtils"],
                path: "Sources/StoreUtilsUI"),
        .testTarget(
            name: "StoreUtilsTests",
            dependencies: ["StoreUtils"]),
    ]
)
