// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

extension Target.Dependency {
    
    static var supabase: Self {
        .product(name: "Supabase", package: "supabase-swift")
    }
}

let package = Package(
    name: "SupabaseClientKit",
    platforms: [.iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SupabaseClientKit",
            targets: ["SupabaseClientKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift.git", .upToNextMajor(from: "2.48.0"))
        
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SupabaseClientKit",
            dependencies: [.supabase]
            
        ),
        .testTarget(
            name: "SupabaseClientKitTests",
            dependencies: ["SupabaseClientKit"]
        ),
    ]
)
