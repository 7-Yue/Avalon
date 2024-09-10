// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Avalon",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "Avalon",
                 targets: ["Avalon"]),
    ],
    dependencies: [
        
    ],
    targets: [
        .target(name: "Avalon"),
        .testTarget(name: "AvalonTests",
                    dependencies: ["Avalon"]),
    ]
)
