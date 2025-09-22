// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "web_view_sdk_lib",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "web_view_sdk_lib",
            targets: ["web_view_sdk_lib"]
        ),
    ],

    targets: [
        .binaryTarget(
            name: "web_view_sdk_lib",
            path: "Sources/web_view_sdk.xcframework"
        ),
        .testTarget(
            name: "web_view_sdk_libTests",
            dependencies: ["web_view_sdk_lib"]
        )
    ]
)
