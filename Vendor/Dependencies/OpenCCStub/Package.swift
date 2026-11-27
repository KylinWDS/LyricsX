// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "OpenCC",
    products: [
        .library(name: "OpenCC", targets: ["OpenCC"]),
    ],
    targets: [
        .target(name: "OpenCC"),
    ]
)
