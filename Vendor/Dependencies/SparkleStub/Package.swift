// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Sparkle",
    products: [
        .library(name: "Sparkle", targets: ["Sparkle"]),
    ],
    targets: [
        .target(name: "Sparkle"),
    ]
)
