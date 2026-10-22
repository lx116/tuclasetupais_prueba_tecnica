# Ticket 06: favorites (star, persisted on the device, /favorites page)
Branch: feat/favorites (stacked on feat/contact-filters, PR #5). Delivery: work-unit commits, PR on request. Runner: `flutter test`, `flutter analyze`. Source: Ticket 06 in lib/mai plus the "05 · Favoritos (/favorites)" design board and the architecture board (favorites feature, shared_prefs, FavoritesCubit).

## Specs
- S1 "TICKET 06 5- Favoritos. Hasta el momento este componente se esta queando por fuera de la lista." -> the star lives in the list: each row (wide) has a star that toggles the favorite; the open contact has one too.
- S2 Design board: "Favoritos: Tus contactos marcados con estrella. Se guardan en este dispositivo." -> favorites persist on the device (shared_preferences) and survive a restart.
- S3 Design board: route `/favorites` with the favorite contacts as cards (initials, name, department), a star to remove, a click opens `/contacts/:id`; empty state "Todavía no tienes favoritos" / "Toca la estrella de un contacto para guardarlo aquí." / "Ver contactos".
- S4 Design board: header nav "Contactos | Favoritos (count badge)"; on mobile a star icon links to `/favorites`.
- S5 (decision, same precedent as the contact detail) The favorites state is shared by the list, the detail, the header and the page, so it lives in `lib/core/favorites/` (domain, data, cubit, `FavoriteButton`); the page is its own feature `features/favorites` (3 layers). Features never import each other.
- S6 (assumption) Same rule as the detail: the page reads contacts from memory with no dice; if the last list call failed it shows a load error (no cache).
- S7 The favorites state loads at startup (`startServices`), like the contacts. A storage failure must not break the app: it starts with no favorites and logs.

## Tasks
- T1 (S2, S5, S7) core/favorites: domain, data (shared_preferences), FavoritesCubit, FavoriteButton, DI + startServices. Route: inline. Commit: see git log "feat(favorites): add the favorites state, storage and rules"
- T2 (S1, S4) Stars in the list rows and the detail, header nav with the count, router-level provider. Route: inline. Commit: see git log "feat(favorites): add the star to the list and the detail, and the header navigation"
- T3 (S3, S6) features/favorites page and the /favorites route. Route: inline. Commit: see git log "feat(favorites): add the favorites page at /favorites"

Route declaration: inline, sequential and dependent units, no writer trigger.

## Log
- L1 (2026-10-22) "Empecemos con favoritos del ticket 06" + lib/mai: "TICKET 06 5- Favoritos. Hasta el momento este componente se esta queando por fuera de la lista. Dentro de lo que cabe, el Favoritos puede posponerse y agregarse luego, no entraria dentro de una primera neciedad como lo puede ser una barra de busqueda o un filtros de query. Son las 4:54 al momento de esta entrada, aun asi no descarto que se logre."
- L2 PR #5 (filters) opened first. Engram mirror pending (mem_save fails with "multiple active runtime sessions"); this file is the source of truth.
- L3 Evidence: flutter analyze clean, 311 tests pass (3 runs), `flutter build web` OK. Decisions: shared favorites state in `lib/core/favorites` (cubit provided by the router through an outer ShellRoute, so tests that build the router get it from DI); the page is `features/favorites` with its own use case and reads contacts from memory (no dice, gated by ContactsAvailability); the page only asks for contacts once the stored favorites are read; stored ids with no contact are left out of the page but still counted in the header badge. Storage failures on load start with no favorites and log. Not verified: the look in a browser, and real device storage (tests use the shared_preferences mock; the storage plugin needs the real clock, so persistence is tested outside the fake-async zone).
