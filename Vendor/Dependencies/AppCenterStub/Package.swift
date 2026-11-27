// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "AppCenter",
    products: [
        .library(name: "AppCenter", targets: ["AppCenter"]),
        .library(name: "AppCenterAnalytics", targets: ["AppCenterAnalytics"]),
        .library(name: "AppCenterCrashes", targets: ["AppCenterCrashes"]),
    ],
    targets: [
        .target(name: "AppCenter"),
        .target(name: "AppCenterAnalytics"),
        .target(name: "AppCenterCrashes"),
    ]
)
