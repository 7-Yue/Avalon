// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Avalon",
    platforms: [
        .iOS(.v12),
    ],
    products: [
        .library(
            name: "Avalon",
            targets: [
                "AvalonExtensionOC",
                "AvalonExtensionSwift",
                "AvalonUIBoxOC",
                "AvalonUIBoxSwift",
            ]),
    ],
    dependencies: [
        
    ],
    targets: [
        .target(name: "AvalonExtensionOC",
                path: "Sources/Extension/OC"),
        .target(name: "AvalonExtensionSwift",
                path: "Sources/Extension/Swift"),
        .target(name: "AvalonUIBoxOC",
                path: "Sources/UIBox/OC"),
        .target(name: "AvalonUIBoxSwift",
                path: "Sources/UIBox/Swift"),
        .testTarget(
            name: "AvalonTests",
            dependencies: [
                "AvalonExtensionSwift",
                "AvalonExtensionOC",
                "AvalonUIBoxOC",
                "AvalonUIBoxSwift",
            ]),
    ]
)
