# Ticket 04: real-time search by name, kept in the URL
Branch: feat/contact-search (stacked on feat/ui-shell, PR #3). Delivery: work-unit commits, PR on request. Runner: `flutter test`, `flutter analyze`.

## Specs
- S1 "Un usuario debe poder buscar por nombre." Match on the contact name (case-insensitive, accent-insensitive: "matias" finds "Matías"; assumption).
- S2 "Neceistamos agregar una serchbar a la lista, el componente es un input reutilizable que vamos a almacenar en shared/presentation/widgets." -> `lib/shared/presentation/widgets/`.
- S3 "TICKET 04 - 2- Busqueda en tiempo real. [] 2.1 QUERYPARMS SEARCH" -> results update while typing (debounced 300ms, from the architecture board), no new list call per keystroke.
- S4 "como regla Agregar en los querys la busqueda, de esta forma podemos enviar la busqueda a otro usuario o copiarla en el portapales para enviarla a otro dispositivo." -> `?search=` is the source of truth: typing updates the URL; opening a URL with `?search=` fills the input and filters.
- S5 (design) Wide: input at the top of the list column. Mobile: input inside the teal header. No-results state: "Sin resultados para “xyz”" with a clear button.
- S6 (assumption) The search is kept when opening a contact (`/contacts/:id?search=`) and when going back to the list.
- S7 Out of scope: department filter chips (next ticket), favorites.

## Tasks
- T1 (S1, S3) SearchContacts use case + cubit `search(query)` + ContactsNoResults state. Route: inline. Commit: pending
- T2 (S2) SearchInput widget in shared/presentation/widgets. Route: inline. Commit: pending
- T3 (S4-S6) URL query param wiring, search in the list column/header, tests. Route: inline. Commit: pending

Route declaration: inline, sequential and dependent units, no writer trigger.

## Log
- L1 (2026-10-22) "Abre PR 3 y empecemos con el sistema de busqueda. Para este te dejo lo siguiente: Un usuario debe poder buscar por nombre. Neceistamos agregar una serchbar a la lista, el componente es un input reutilizable que vamos a almacenar en shared/presentation/widgets. Como necesidad tenemos: TICKET 04 - 2- Busqueda en tiempo real. [] 2.1 QUERYPARMS SEARCH y como regla Agregar en los querys la busqueda, de esta forma podemos enviar la busqueda a otro usuario o copiarla en el portapales para enviarla a otro dispositivo."
- L2 PR #3 opened first (feat/ui-shell). Engram mirror pending (mem_save fails with "multiple active runtime sessions"); this file is the source of truth.
