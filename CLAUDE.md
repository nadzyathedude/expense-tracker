# Project Rules

## 🧱 Architecture

Use: **MVVM + Repository + DataSource + Unidirectional Data Flow**

```
View (SwiftUI)
  ↓
ViewModel (@MainActor)
  ↓
UseCase (optional)
  ↓
Repository
  ├── RemoteDataSource
  └── Cache (Memory / Disk / URLCache / CoreData)
```

### Rules
- Views MUST NOT contain business logic
- ViewModels MUST NOT perform networking directly
- Repositories are the single source of truth
- DataSources handle only data access
- Prefer unidirectional data flow

---

## 🧠 State Management

### Required
- Each screen MUST have a single state object
- State MUST be immutable from outside ViewModel

```swift
struct ViewState<T> {
    var data: T?
    var isLoading: Bool
    var error: String?
}
```

### Alternative (preferred for async flows)

```swift
enum ViewState<T> {
    case idle
    case loading
    case success(T)
    case error(Error)
    case empty
}
```

### Forbidden
- Multiple unrelated `@Published` properties
- State scattered across multiple objects

---

## 📱 ViewModel Rules

- MUST be annotated with `@MainActor`
- MUST expose read-only state
- MUST handle business logic only
- MUST NOT import networking layer directly

```swift
@MainActor
final class FeatureViewModel: ObservableObject {
    @Published private(set) var state: ViewState<Model> = .idle
}
```

---

## 🌐 Networking

### Rules
- Use a single `APIClient`
- Use endpoint-based requests
- Networking MUST NOT be used in Views or ViewModels directly

```swift
protocol APIClient {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}
```

---

## 💾 Caching

### Strategy (multi-layer)

```
URLCache (HTTP)
  ↓
MemoryCache (NSCache)
  ↓
Disk (FileManager / CoreData)
```

### Rules
- Repository decides data source (cache vs network)
- Cache MUST support TTL
- Cache MUST NOT depend on UI layer

---

## 🔁 Data Flow

1. **View** → triggers actions
2. **ViewModel** → updates state
3. **Repository** → provides data
4. **DataSource** → fetches data

---

## 🧪 Dependency Injection

### Rules
- Use constructor injection ONLY
- Avoid singletons unless justified
- Prefer lightweight DI container

```swift
final class AppContainer {
    let apiClient: APIClient
}
```

---

## ⚠️ Error Handling

### Rules
- NEVER expose raw errors to UI
- ALWAYS map to user-friendly messages
- Use structured error types

```swift
do {
    try await action()
} catch {
    handle(error)
}
```

---

## 🎨 UI (SwiftUI)

### Rules
- Views MUST be stateless where possible
- Views MUST NOT contain business logic
- Use small reusable components
- Prefer `.task {}` over `onAppear`

```swift
switch state {
case .loading:
    ProgressView()
case .success(let data):
    ContentView(data: data)
case .error:
    ErrorView()
default:
    EmptyView()
}
```

---

## 🧼 Code Organization

### Project Structure

```
App/
├── Core/
├── DesignSystem/
├── Features/
├── Services/
├── Resources/
└── Tests/
```

### Rules
- Use feature-based structure
- Extensions MUST be grouped by type
- Avoid "god files"
- Avoid barrel files

---

## 🏷 Naming Conventions

### Types — PascalCase
- `ProfileView`
- `ProfileViewModel`
- `UserRepository`

### Variables / Functions — camelCase
- `fetchUser()`
- `isLoading`

### Protocols — descriptive naming
- `ProfileRepository`
- `DataFetching`

### Implementations
- `DefaultProfileRepository`

### Extensions
- `String+Extensions.swift`
- `View+Extensions.swift`

---

## 🧵 Concurrency

### Rules
- ViewModels MUST run on `@MainActor`
- Services MUST NOT run on MainActor
- Use `async/await`
- Avoid callbacks unless necessary

---

## 🧩 Events (One-shot actions)

```swift
enum FeatureEvent {
    case showError(String)
    case navigateNext
}

@Published var event: FeatureEvent?
```

### Rules
- Use for navigation, alerts, side-effects
- MUST NOT be used as state replacement

---

## 🚫 Anti-Patterns (Forbidden)

### General
- `print()` in production
- Force unwrap (`!`)
- Massive files (>500 lines)
- Deep nesting (>3 levels)

### Architecture
- Business logic in Views
- Networking in ViewModels
- Direct dependency on concrete implementations
- Multiple sources of truth

### Performance
- Heavy work on main thread
- Blocking UI thread
- Large synchronous operations

### SwiftUI
- Using `@State` instead of `@StateObject` for ViewModels
- Retain cycles in closures
- Overly complex Views

---

## 📏 Code Style

- Functions ≤ 30 lines
- One responsibility per type
- Prefer `struct` over `class`
- Use extensions to split logic

---

## 🧱 Advanced (Optional)

### UseCases
Use when business logic becomes complex.

```swift
struct FetchDataUseCase {
    let repository: Repository

    func execute() async throws -> Model {
        try await repository.fetch()
    }
}
```

---

## 🔒 Strict Rules for AI

When generating code:

1. ALWAYS follow architecture layers
2. NEVER place business logic in Views
3. ALWAYS use `async/await`
4. ALWAYS create ViewModel for screens
5. ALWAYS use dependency injection
6. NEVER use global mutable state
7. NEVER use force unwrap
8. ALWAYS keep files small and modular
