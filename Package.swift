// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SplashObjc",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "SplashObjc",
            targets: ["SplashObjc"]),
    ],
    dependencies: [
        .package(url: "https://github.com/marcocapano/Splash", .branch("master"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SplashObjc",
            dependencies: ["Splash"]),
        .target(
            name: "SplashObjcHTMLGen",
            dependencies: ["SplashObjc", "Splash"]
        ),
        .target(
            name: "SplashObjcImageGen",
            dependencies: ["SplashObjc", "Splash"]
        ),
        .target(
            name: "SplashObjcMarkdown",
            dependencies: ["SplashObjc", "Splash"]
        ),
        .target(
            name: "SplashObjcTokenizer",
            dependencies: ["SplashObjc", "Splash"]
        ),
        .testTarget(
            name: "SplashObjcTests",
            dependencies: ["SplashObjc"]),
    ]
)
