// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

extension Target.Dependency {
    static let swiftArgumentParser = Target.Dependency.product(name: "ArgumentParser", package: "swift-argument-parser")
}

let package = Package(
    name: "kbprefs",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/eonist/FileWatcher.git", from: "0.2.3"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.1.2"),
    ],
    targets: [
        .executableTarget(name: "kbprefs", dependencies: ["KBPreferences", "Yams", .swiftArgumentParser]),
        .target(name: "KBPreferences", dependencies: ["FileWatcher", "Yams"]),
    ]
)
