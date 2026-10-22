# Ticket 05: department filter in the URL, 404 when nothing matches
Branch: feat/contact-filters (stacked on feat/contact-search, PR #4). Delivery: work-unit commits, PR on request. Runner: `flutter test`, `flutter analyze`.

## Specs
- S1 "TICKET 05 - 3- Filtros [] 3.1 filtro por departamento. 3.2 QUERYPARMS FILTER" -> department chips (Todos + the catalog departments, as in the design) and the filter in the URL as `?department=` (name taken from the design's architecture board `?search=&department=`; value is the accent-free lowercase name, e.g. `ingenieria`).
- S2 "Cuando las querys no hacen match con ningun resultados debemos avisar con un 404 en conjunto con un mensaje del problema: No se encontraron resultados." -> when the search and/or filter match nothing, the list column shows a 404 with "No se encontraron resultados" (replaces the "Sin resultados para …" state). It stays inside the list column (not a full page) so the user can still change the query; an unknown department value also ends here. Assumption: this is a visual 404 in the UI, not an HTTP status.
- S3 Filter and search combine (both must match) and both travel in the URL; opening a contact and going back keep both.
- S4 Same rules as the search: filtering is done in memory over the loaded list, no new list call or dice roll; resizing keeps it.
- S5 Out of scope: favorites.

## Tasks
- T1 (S1, S2) Domain and URL model: foldText, FilterContactsByDepartment, ContactsQuery (search + department) and AppRoutes. Route: inline. Commit: see git log "feat(filters): add the department filter rule" (rule only) and the next commit (query model)
- T2 (S1-S4) Cubit state, DepartmentFilter chips, URL wiring, 404 no-results state, tests. Route: inline. Commit: see git log "feat(filters): filter contacts by department from the ?department= URL parameter"

Route declaration: inline, sequential and dependent units, no writer trigger.

## Log
- L1 (2026-10-22) "Empecemos con los filtros del ticket 05. TICKET 05 - 3- Filtros [] 3.1 filtro por departamento. 3.2 QUERYPARMS FILTER. Cuando las querys no hacen match con ningun resultados debemos avisar con un 404 en conjunto con un mensaje del problema: No se encontraron resultados."
- L2 PR #4 (search) opened first. Engram mirror pending (mem_save fails with "multiple active runtime sessions"); this file is the source of truth.
- L3 Evidence: flutter analyze clean, 235 tests pass (3 runs), `flutter build web` OK. The search and the filter travel together as `ContactsQuery` (replaces the search-only plumbing); the cubit combines both over the in-memory list. The no-results state now shows "404" + "No se encontraron resultados" + "Limpiar filtros" and replaces "Sin resultados para …". The chips scroll horizontally (as in the design) so one can start off screen in the 400px column. Not verified: the look in a browser.
