# SupabaseClientKit

SupabaseClientKit is a lightweight Swift wrapper around [supabase-swift](https://github.com/supabase/supabase-swift) that gives your iOS app a clean, type-safe API for authentication, database CRUD operations, and file storage. It also handles switching between development and production Supabase projects automatically based on the build configuration.

Built with Swift 6 concurrency in mind — every API is `async`/`await` and the main types are `Sendable`.

## Features

- **Environment-aware client** — uses your development Supabase project in `DEBUG` builds and your production project in release builds.
- **Authentication** — email/password, phone/password, email and phone OTP, and sign-in with ID tokens (Apple, Google, etc.), plus sign-out and current-user access.
- **Database operations** — insert, upsert, fetch, filtered fetch, single-row fetch, update, and delete through a small, typed wrapper.
- **Storage** — file uploads to Supabase Storage buckets.
- **Swift 6 / async-await** first, thread-safe by design.

## Requirements

- iOS 17.0+
- Swift 6.2+ (swift-tools-version 6.2, ships with Xcode 26+)
- A [Supabase](https://supabase.com) project

## Installation

Add SupabaseClientKit to your project using Swift Package Manager.

### Via Xcode

1. In Xcode, open **File → Add Package Dependencies…**
2. Enter the package URL:

   ```
   https://github.com/hdkmodha/SupabaseClientKit.git
   ```

3. Choose the latest version and add the **SupabaseClientKit** product to your app target.

### Via Package.swift

```swift
dependencies: [
    .package(url: "https://github.com/hdkmodha/SupabaseClientKit.git", .upToNextMajor(from: "1.0.0"))
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "SupabaseClientKit", package: "SupabaseClientKit")
        ]
    )
]
```

## Getting Started

### 1. Implement a client provider

`SupabaseClientKit` needs a `SupabaseClientProvider`, a protocol that supplies the development and production clients.

```swift
import Supabase
import SupabaseClientKit

struct AppSupabaseClientProvider: SupabaseClientProvider {

    let development: SupabaseClient
    let production: SupabaseClient

    init() {
        development = SupabaseClient(
            supabaseURL: URL(string: "https://your-project-dev.supabase.co")!,
            supabaseKey: "your-dev-anon-key"
        )

        production = SupabaseClient(
            supabaseURL: URL(string: "https://your-project.supabase.co")!,
            supabaseKey: "your-anon-key"
        )
    }
}
```

> Use the **anon/public** keys from the Supabase dashboard. Never ship your service-role key in a client app.

### 2. Create the kit and the manager

```swift
let supabaseClientKit = SupabaseClientKit(clientProvider: AppSupabaseClientProvider())
let supabaseManager = SupabaseManager(supabaseClient: supabaseClientKit)
```

### 3. Environment switching

`SupabaseClientKit` automatically selects the right client for you:

- `#if DEBUG` → `development`
- otherwise → `production`

No extra configuration is needed. Stand up instances once (e.g. via an app coordinator) and share them across your views.

## Authentication

All auth methods return the signed-in user's `UUID` (or a `Session` for ID-token sign-in).

### Sign in with email and password

```swift
do {
    let userId: UUID = try await supabaseManager.signIn(
        email: "user@example.com",
        password: "your-password"
    )
    print("Signed in as \(userId)")
} catch {
    print("Sign-in failed: \(error)")
}
```

### Sign up with email and password

```swift
do {
    let userId: UUID = try await supabaseManager.signUp(
        withEmail: "user@example.com",
        password: "your-password"
    )
} catch {
    // A "User already registered" error means the email is taken.
}
```

### Sign in with a magic link (email OTP)

```swift
try await supabaseManager.signInWithOTP(email: "user@example.com")
```

You can pass a `redirectTo` URL, control whether a user is created with `shouldCreateUser`, attach custom metadata via `data`, and add a `captchaToken` when required:

```swift
try await supabaseManager.signInWithOTP(
    email: "user@example.com",
    redirectTo: URL(string: "myapp://auth/callback"),
    shouldCreateUser: true,
    data: ["role": "premium"],
    captchaToken: nil
)
```

### Sign in with phone number and password

```swift
let userId: UUID = try await supabaseManager.signIn(
    withPhone: "+1234567890",
    password: "your-password"
)
```

### Send a phone OTP

```swift
try await supabaseManager.sendOTP(forPhoneNumber: "+1234567890")
```

Specify the delivery channel and other options:

```swift
try await supabaseManager.sendOTP(
    forPhoneNumber: "+1234567890",
    withChannel: .sms,          // or .whatsapp
    shouldCreateUser: true,
    data: ["locale": "en"],
    captchaToken: nil
)
```

### Sign up with phone number and password

```swift
let userId: UUID = try await supabaseManager.signUp(
    withPhone: "+1234567890",
    password: "your-password"
)
```

### Sign in with an ID token (Apple, Google, etc.)

```swift
let session = try await supabaseManager.signInWithIdToken(
    withToken: "id-token-from-sign-in-provider",
    accessToken: "access-token",
    provider: .apple
)
print("Session expires at \(session.expiresAt)")
```

### Sign out

```swift
try await supabaseManager.signOut()
```

### Get the current user

```swift
let user: User = try await supabaseManager.currentUser
print("Welcome, \(user.email ?? "user")")
```

## Database

CRUD methods are generic and accept any `Codable` model.

```swift
struct Todo: Codable {
    let id: UUID
    let task: String
    let completed: Bool
    let userID: UUID
}
```

### Insert

```swift
let todo = Todo(id: UUID(), task: "Buy groceries", completed: false, userID: userId)
try await supabaseManager.insert(intoTable: "todos", value: todo)
```

### Upsert

```swift
try await supabaseManager.upsert(intoTable: "todos", value: todo)
```

### Fetch all rows

```swift
let todos: [Todo] = try await supabaseManager.fetch(fromTable: "todos")
```

### Fetch rows matching a column value

```swift
let completedTodos: [Todo] = try await supabaseManager.fetch(
    fromTable: "todos",
    withMatching: "completed",
    andId: true
)
```

### Fetch a single row by column

```swift
let todo: Todo = try await supabaseManager.fetchOne(
    fromTable: "todos",
    macthingWith: "id",
    withId: todoID
)
```

### Update a row

```swift
let updatedTodo = Todo(id: todoID, task: "Buy groceries", completed: true, userID: userId)
try await supabaseManager.update(
    fromTable: "todos",
    macthingWith: "id",
    andWithId: todoID,
    item: updatedTodo
)
```

### Delete a row

```swift
try await supabaseManager.delete(
    fromTable: "todos",
    macthingWith: "id",
    andValue: todoID
)
```

> Remember: your Supabase tables need [Row Level Security (RLS)](https://supabase.com/docs/guides/database/postgres/row-level-security) policies so authenticated users can actually read/write their own data.

## Storage

`StorageManager` uploads files (e.g. photos) to a Supabase Storage bucket and returns the generated file path.

```swift
let path = try await storageManager.uploadPhoto(
    withData: imageData,
    bucketName: "avatars",
    projectURL: "https://your-project.supabase.co"
)
print("Uploaded to \(path)")
```

The returned path is a UUID-based filename, so collisions are avoided and `upsert: true` is used on upload. Public URLs can then be built as:

```swift
let publicURL = URL(string: "https://your-project.supabase.co/storage/v1/object/public/avatars/\(path)")!
```

> **Note:** `StorageManager` currently lives in the package target with internal access and is in the process of being finalized. A public API for storage will be exposed in an upcoming release.

## Example App Setup (SwiftUI)

```swift
import SwiftUI
import SupabaseClientKit

@main
struct ExampleApp: App {

    private let supabaseManager: SupabaseManager

    init() {
        let kit = SupabaseClientKit(clientProvider: AppSupabaseClientProvider())
        supabaseManager = SupabaseManager(supabaseClient: kit)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(supabaseManager)
        }
    }
}
```

## Supported Platforms

| Platform  | Minimum Version |
|-----------|-----------------|
| iOS       | 17.0            |

## Dependencies

- [supabase-swift](https://github.com/supabase/supabase-swift) `>= 2.48.0`

## License

`SupabaseClientKit` is released under the [MIT License](LICENSE).
