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

---

## Code Quality Enforcement

### SwiftFormat rules

- SwiftFormat is REQUIRED
- Code MUST be auto-formatted before commit
- CI MUST fail if formatting is not applied
- Developers MUST run SwiftFormat locally

### SwiftLint rules

- SwiftLint is REQUIRED
- Code MUST pass SwiftLint with `--strict`
- No warnings allowed in CI
- Lint errors MUST block merge

### Combined rules

- SwiftFormat MUST run BEFORE SwiftLint
- Generated code MUST comply with both tools
- No manual formatting that conflicts with SwiftFormat

### Forbidden

- Committing unformatted code
- Ignoring SwiftLint errors
- Disabling rules without explicit justification

### AI-specific rules

- ALWAYS generate code compatible with SwiftFormat
- ALWAYS generate code that passes SwiftLint
- NEVER use:
  - `print()`
  - force unwrap (`!`)
  - blocking main thread operations

---

## Testing Strategy

### Level 1 — Business Logic Testing

- All business logic MUST be covered by tests
- ViewModels MUST have unit tests
- UseCases (if present) MUST have unit tests
- Repositories MUST have integration tests with mocked data sources
- No UI testing at this level

Requirements:

- Use dependency injection for testability
- Use mocks/stubs instead of real network calls
- Tests MUST be deterministic
- Tests MUST run fast (<1s per test)

### Level 2 — UI Smoke Testing (Agent-driven)

Automated UI validation uses: `claude-in-mobile`

- Smoke tests MUST cover critical user flows:
  - App launch
  - Navigation between main screens
  - Basic user actions (tap, scroll, input)
- Tests are NOT for pixel-perfect validation
- Focus on "app does not crash" and "flows work"

### Agent Rules

- The agent MUST be able to run UI flows independently
- UI flows MUST be deterministic
- Avoid animations or delays that break automation
- Avoid non-deterministic UI state

### Forbidden

- Untested business logic
- Network calls in tests
- Flaky UI tests
- Tests depending on external services

### AI-Specific Rules

- ALWAYS generate tests for:
  - ViewModels
  - UseCases
- NEVER generate code without corresponding tests
- UI flows MUST be testable by automation agents

---

## UI Smoke Scenarios (claude-in-mobile)

### Purpose

- Define minimal, stable UI flows that validate app health
- Ensure app does not crash and core navigation works
- Designed for execution by an automation agent

### Tooling

All UI scenarios MUST be compatible with: `claude-in-mobile`

### Scenario Format

Each scenario MUST follow this structure:

- Name
- Preconditions
- Steps (numbered)
- Expected Result

### Supported Commands (for agent)

Use only simple deterministic commands:

- `launch_app`
- `tap("AccessibilityID")`
- `type_text("text")`
- `wait("AccessibilityID")`
- `assert_visible("AccessibilityID")`
- `assert_not_visible("AccessibilityID")`
- `scroll("direction")`

### Required Scenarios

#### 1. App Launch

Preconditions:

- App is installed

Steps:

1. `launch_app`
2. `wait("MainScreen")`

Expected Result:

- Main screen is visible
- No crash

#### 2. Navigation Flow

Steps:

1. `launch_app`
2. `tap("ProfileTab")`
3. `wait("ProfileScreen")`
4. `tap("SettingsButton")`
5. `wait("SettingsScreen")`

Expected Result:

- Navigation works without crash
- All screens are displayed

#### 3. Basic Interaction

Steps:

1. `launch_app`
2. `wait("MainScreen")`
3. `scroll("down")`
4. `tap("FirstItem")`
5. `wait("DetailsScreen")`

Expected Result:

- Content is scrollable
- Item opens correctly

#### 4. Input Flow

Steps:

1. `launch_app`
2. `tap("SearchField")`
3. `type_text("test")`
4. `wait("SearchResults")`

Expected Result:

- Input works
- Results appear

### UI Requirements for Testability

- All interactive elements MUST have AccessibilityID
- IDs MUST be stable and NOT generated dynamically
- Avoid animations that break deterministic testing
- Avoid random content affecting layout

### Forbidden

- Using coordinates instead of AccessibilityID
- Relying on timing instead of explicit waits
- Non-deterministic UI states
- Hidden or dynamic IDs

### AI-Specific Rules

- ALWAYS generate AccessibilityID for:
  - buttons
  - inputs
  - key UI elements
- ALWAYS ensure new screens are testable via these scenarios
- NEVER generate UI without testability in mind

---

## AI Testing Lifecycle

### Purpose

Define a complete automated testing loop where an AI agent:

- writes tests
- executes them
- validates UI flows
- generates reports
- detects failures and suggests fixes

### Level 1 — Code Testing Flow

#### Responsibilities

The agent MUST:

1. Generate tests for:
   - ViewModels
   - UseCases
   - Repositories (with mocks)
2. Execute tests:
   - Run all unit and integration tests
   - Ensure all tests pass
3. Validate:
   - No failing tests
   - No flaky tests
   - Fast execution

#### Commands

- `run_unit_tests`
- `run_integration_tests`

#### Output

The agent MUST generate a report:

- total tests
- passed
- failed
- execution time
- failed test names
- suspected cause of failure

### Level 2 — UI Testing Flow (Smoke via MCP)

Using: `claude-in-mobile`

#### Responsibilities

The agent MUST:

1. Load smoke scenarios
2. Execute them via MCP
3. Capture:
   - screenshots at each step
   - failure points

#### Commands

- `run_ui_scenarios`
- `capture_screenshot`
- `assert_visible`
- `tap`
- `type_text`

#### Output

The agent MUST generate a UI report:

- scenarios executed
- passed / failed
- step-by-step results
- screenshots
- failure step
- suspected UI issue

### Failure Analysis

If ANY test fails, the agent MUST:

- Identify failure location:
  - View
  - ViewModel
  - Repository
  - Networking
- Suggest probable cause
- Suggest fix strategy (NOT full rewrite)

### PR Flow Integration

After every Pull Request:

1. Run code tests
2. Run UI smoke scenarios
3. Aggregate results

#### Final Report MUST include:

- Code test summary
- UI test summary
- Screenshots (if UI tests run)
- Combined status: PASS / FAIL
- List of issues
- Suggested fixes

### Feature Update Scenario

When a new feature is added, the agent MUST:

1. Detect new screens / flows
2. Update smoke scenarios
3. Add missing steps
4. Re-run ALL tests (code + UI)

### Continuous Validation Rules

- Tests MUST be re-runnable at any time
- UI flows MUST remain deterministic
- Reports MUST be reproducible

### Forbidden

- Ignoring failed tests
- Partial test runs
- Missing reports
- UI tests without screenshots
- Tests depending on external services

### AI-Specific Rules

- ALWAYS generate tests with new code
- ALWAYS run tests after generation
- ALWAYS produce a report
- NEVER leave failures unexplained
- ALWAYS suggest where the issue is located

---

## Auto-Fix Loop

### Purpose

Define a controlled loop where the AI agent:

- detects failures
- attempts minimal fixes
- re-runs tests
- stops when stable or limit reached

### Trigger Conditions

The auto-fix loop MUST start when:

- Unit tests fail
- Integration tests fail
- UI smoke scenarios fail

### Loop Behavior

The agent MUST follow this sequence:

1. Analyze failure report
2. Identify probable root cause
3. Apply minimal fix
4. Re-run affected tests ONLY
5. Validate results

Repeat until:

- All tests pass, OR
- Max attempts reached

### Max Attempts

- Maximum: 3 iterations per failure
- After 3 failures → STOP and report

### Fix Scope Rules

The agent is allowed to modify ONLY:

- ViewModels
- UseCases
- Repositories
- UI bindings (SwiftUI views)

The agent MUST NOT modify:

- API contracts
- Public interfaces
- Core architecture
- Dependency injection setup

### Allowed Fix Types

- Null / optional handling fixes
- State handling corrections
- Missing async handling (`await` / `Task`)
- Incorrect bindings in SwiftUI
- AccessibilityID fixes (for UI tests)

### Forbidden Fixes

- Rewriting entire files
- Removing tests to pass
- Hardcoding values just to satisfy tests
- Disabling SwiftLint / SwiftFormat rules
- Ignoring failing scenarios

### Validation After Fix

After each fix, the agent MUST:

1. Re-run:
   - Affected unit tests
   - Affected UI scenarios (if UI-related)
2. Ensure:
   - No new failures introduced
   - No regression in previously passing tests

### Reporting

The agent MUST produce a fix report:

- iteration count
- issue identified
- fix applied
- result (pass/fail)
- remaining issues

### Final Outcome

#### If successful:

- All tests pass
- Report marked as RESOLVED

#### If failed:

- Report marked as UNRESOLVED
- Include:
  - failing tests
  - suspected root cause
  - recommended manual fix

### PR Integration

- Auto-fix MUST run after failed CI
- If resolved → update PR status to PASS
- If unresolved → block merge

### AI-Specific Rules

- ALWAYS prefer minimal changes
- NEVER introduce breaking changes
- ALWAYS preserve architecture rules
- ALWAYS keep code readable and maintainable
