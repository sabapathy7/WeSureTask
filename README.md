# WeSureTask

Payroll Management take-home for WeSure — create payrolls, associate employees, and review a summary of wages and taxes.

<!-- Add screenshots here, e.g.: -->
<!-- ![Payroll List](docs/screenshots/list.png) ![Create Payroll](docs/screenshots/create.png) ![Payroll Detail](docs/screenshots/detail.png) -->

## How to Run

- Requirements: Xcode 16+, iOS 17.6+ simulator or device.
- Open `WeSureTask.xcodeproj`, select the `WeSureTask` scheme, and run (⌘R).
- Run tests with ⌘U, or from the command line:
  ```
  xcodebuild test \
    -project WeSureTask.xcodeproj \
    -scheme WeSureTask \
    -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest'
  ```
- The UI test target launches the app with a `-ui-testing` argument that swaps in an in-memory Core Data store and an empty mock API, so UI tests start from a deterministic, unseeded state rather than the bundled example payroll.

## Architecture

MVVM + Repository — deliberately not Clean Architecture. Three screens don't justify a full UseCase/Interactor/Mapper layer per feature; for a codebase this size that ceremony reads as over-engineering as often as it reads as rigor. A stated, reasoned tradeoff is worth more than defaulting to either extreme.

```
View (SwiftUI)
  ↓ observes
ViewModel (@Observable, @MainActor)
  ↓ depends on protocol
PayrollRepository (protocol)
  ↓
PayrollRepositoryImpl ──┬── CoreDataPayrollStore (local, source of truth)
                        └── PayrollAPI (protocol) → MockPayrollAPI
Domain: Payroll, Employee, PayrollCalculator (plain Sendable structs, no framework imports)
```

Two rules carry most of the design:
1. `NSManagedObject` never leaves the store layer — `CoreDataPayrollStore` maps to/from plain `Payroll`/`Employee` structs; views and view models never import CoreData.
2. Tax math lives in a pure, dependency-free `PayrollCalculator`, not in a view model: wages strictly greater than $1,000 and not exempt → 5% tax, rounded per employee.

Built with Swift 6 language mode and complete concurrency checking on — view models are `@MainActor`, domain/DTO types are `Sendable`, and persistence/network writes run off the main actor.

## Offline Strategy

Core Data is the source of truth — the app only ever reads from it, so the UI renders identically whether or not the network is reachable.

Creating a payroll is an **optimistic local write**: insert into Core Data as `.pending` → the list updates immediately → the record is pushed to `MockPayrollAPI` in the background → state becomes `.synced` or `.failed`. A failed push doesn't lose the record or block the UI — it stays on-device, flagged: no data loss, no blocking spinner.

`.synced` against a mock API is a fiction — nothing is actually synchronized anywhere — but the state machine and the `PayrollAPI` abstraction seam are real, and wouldn't change if a `URLSession`-backed client were dropped in behind it.

## Testing

- **Unit tests** (Swift Testing, `WeSureTaskTests`): `PayrollCalculatorTests`/`PayrollSummaryTests` cover the tax rule's edge cases against the brief's own worked example (exactly $1,000 → untaxed, exemption overrides amount, per-employee rounding); `CoreDataPayrollStoreTests` round-trips persistence against an in-memory store; `MockPayrollAPITests` covers latency/failure injection; `PayrollRepositoryTests` covers the optimistic-write path; `PayrollListViewModelTests`/`CreatePayrollViewModelTests` cover state and validation.
- **UI tests** (XCTest/XCUITest, `WeSureTaskUITests`): launched with `-ui-testing` for a deterministic empty-state seed. Covers empty-state rendering, cancel-dismisses-sheet, create-appears-in-list, and Save-disabled-until-valid.
- **CI**: GitHub Actions runs both test targets on every push/PR to `main`.

## Example

The bundled seed data matches the brief's worked example:

| Employee | Wages | Exempt | Taxes | Net |
|---|---|---|---|---|
| Sarah Mitchell | $900 | No | $0 | $900 |
| James Caldwell | $1,900 | Yes | $0 | $1,900 |
| Laura Nguyen | $2,000 | No | $100 | $1,900 |

**Payroll Summary** — Total: $4,800 · Total Taxes: $100 · Total Net: $4,700

## Screenshots

| Payroll List | Create Payroll | Payroll Detail | All-Exempt (no tax row) |
|---|---|---|---|
| <img width="200" alt="Payroll List screen showing a seeded payroll" src="https://github.com/user-attachments/assets/845a418f-479a-4a63-bbf1-1203896be163" /> | <img width="200" alt="Create Payroll screen with a filled-in employee row" src="https://github.com/user-attachments/assets/87301576-eded-4262-b346-2119a63a1a5c" /> | <img width="200" alt="Payroll Detail screen matching the brief's worked example" src="https://github.com/user-attachments/assets/89e59685-1694-4e21-a32a-ebe729c63db4" /> | <img width="200" alt="Detail screen for an all-exempt payroll with the Total Taxes row hidden" src="https://github.com/user-attachments/assets/98acf1af-a1c3-4289-8c8e-6714695b287f" /> |


## With More Time

- SwiftData instead of Core Data, for a greenfield iOS 17+ target
- Denormalized payroll totals for large employee lists, instead of recomputing on every render
- A real sync/outbox with retry, instead of push-once-and-record-the-outcome
- Modularize into an SPM `PayrollCore` package
- Snapshot tests, pinned to one simulator/OS to avoid cross-machine flakiness
- A full localization pass (String Catalog + translations) — not part of the brief's Technical Requirements, and `Text("literal")` is already localization-ready by default at zero cost, so a translated String Catalog was judged unrequested scope. Dynamic Type and dark mode were checked directly in the Simulator at the largest accessibility text size and don't clip or truncate.
- Edit/delete of existing payrolls and multi-currency support — out of scope for this exercise
