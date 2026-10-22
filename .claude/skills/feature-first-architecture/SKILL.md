---
name: feature-first-architecture
description: "Trigger: feature, cubit, bloc, use case, repository, datasource, DI, new screen, folder structure. Feature-first Flutter architecture with presentation/domain/data layers. IMMUTABLE."
license: Apache-2.0
metadata:
  author: "luisvelez"
  version: "1.0"
---

## Activation Contract

Load before creating or modifying any feature, cubit, use case, repository, datasource, model or DI registration in this project.

## Hard Rules

- This architecture is IMMUTABLE. Never rename, merge, split or reorder layers. Change it only on an explicit user instruction.
- Feature-first: every feature lives in `lib/features/<feature>/` with exactly three layers: `presentation`, `domain`, `data`.
- Dependency direction: `presentation -> domain <- data`. `presentation` never imports `data`. `domain` imports nothing from Flutter, `data` or `presentation`.
- State management: `flutter_bloc` with Cubits only. No Dio or HTTP. The only datasource is local.
- Dependency injection lives in ONE file, `lib/core/di/injection.dart`, called from `main()` before `runApp`. Nothing else registers or resolves dependencies, except `<feature>_provider.dart` reading from it.
- Files and folders use `snake_case`.

## Layer Contract

| Layer | Contains | Forbidden |
|-------|----------|-----------|
| `presentation/cubit/` | `<feature>_state.dart`, `<feature>_cubit.dart` (actions), `<feature>_provider.dart` (BlocProvider) | Widgets, business rules |
| `presentation/ui/` | Pages and widgets (visual and interactive only) | Cubit logic, data access |
| `domain/entities/` | Plain business objects | JSON, mapping, IO |
| `domain/repositories/` | Abstract repository contracts | Implementations |
| `domain/usecases/` | One use case per business rule, calling a repository | Data processing, parsing, formatting |
| `data/datasources/` | Local datasource (asset or storage) | Business rules |
| `data/models/` | JSON parsing and mapping to entities | UI, business rules |
| `data/repositories/` | Implementations of the domain contracts | Business rules |

## Decision Gates

| Need | Action |
|------|--------|
| Business rule | `domain/usecases/`, nothing more, nothing less |
| Parse or transform raw data | `data/models/` or the repository implementation |
| UI reacts to data | State in `presentation/cubit/`, widget in `presentation/ui/` |
| Logic shared across features | `lib/core/`, only if two or more features use it |

## Execution Steps

1. Create the three layers under `lib/features/<feature>/`, following the table.
2. Define entity, then abstract repository, then use case in `domain`.
3. Implement model, local datasource and repository in `data`.
4. Add state, cubit and provider in `presentation/cubit`, then the UI.
5. Register datasource, repository, use cases and cubit factory in `lib/core/di/injection.dart`.

## Output Contract

Report files created per layer and the DI registrations added. Flag any request that would break these rules instead of applying it.
