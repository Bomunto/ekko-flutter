// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ekko_flutter",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .library(name: "ekko-flutter", targets: ["ekko_flutter"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://gitlab.com/bomunto/ekko-ios", from: "1.0.7")
    ],
    targets: [
        .target(
            name: "ekko_flutter",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "Ekko", package: "ekko-ios")
            ]
        )
    ]
)
