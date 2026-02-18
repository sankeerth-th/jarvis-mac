// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Jarvis",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "Jarvis", targets: ["Jarvis"]) 
    ],
    dependencies: [
    ],
    targets: [
        .executableTarget(
            name: "Jarvis",
            path: "Sources/Jarvis"
        )
    ]
)
