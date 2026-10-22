# Ticket 03: UI (design integration, ShellRoute master-detail, resize persistence)
Branch: feat/ui-shell (stacked on feat/contact-detail, PR #2). Delivery: work-unit commits, PR on request. Runner: `flutter test`, `flutter analyze`. Design source: /Users/luisvelez/Downloads/Contacts App.html (9 boards, decoded to the session scratchpad; palette Dark Teal #1A535C, Strong Cyan #4ECDC4, Mint Cream #F7FFF7, font Manrope).

## Specs
- S1 "La interfaz de usuario requiere shell route para dividir la vista en dos columnas. La columan de contactos y la columna de detalle. Esta herramienta viene incluida dentro de go_router."
- S2 "Una pantalla se considera ancha una vez pasados los 900px, por debajo de esta es una vista mobile" (wide = width > 900; 900 itself is mobile).
- S3 "vamos a usar el shell router y persistencia en redimencion. La redimencion no debe romper el contenido ni hacerlo perder." Resizing across 900 keeps the loaded list (no reload, no new dice roll), the selected contact (URL) and the list scroll position.
- S4 "agrega un boton de reload para cunado ocurra el problema de la lista vacia o el error." Reload button in the empty and error states of the list.
- S5 "Te voy a proporcionar el contenido de desing para integrarlo a la UI." Palette, Manrope, header, list rows with skeleton loading, error and empty states, detail card, mobile list/detail, per the design boards.
- S6 (user chose "Español, como el diseño") Visible copy in Spanish as in the design; code and identifiers stay in English; tests that assert copy are updated.
- S7 (decision) Out of scope: search field, department chips, favorites, "Enviar correo"/"Llamar" actions (they need other tickets or url_launcher) and the "Ubicación" field (not in the model). Mentioned to the user.
- S8 Existing behavior kept: `/contacts`, `/contacts/:id`, 404 for unknown/non-numeric id, detail never rolls the dice, list error blocks the detail, direct detail URL does not load the list on mobile.

## Tasks
- T1 (S5) Design system in core: AppColors, AppTheme with bundled Manrope, breakpoints, StateMessage, ReloadButton, BrandHeader. Route: inline. Commit: see git log "feat(ui): add design system"
- T2 (S1-S6, S8) ContactsShell (ShellRoute), list panel, skeleton, reload buttons, detail restyle, 404 restyle, Spanish copy, updated tests. Route: inline. Commit: pending

Route declaration: inline, sequential and dependent units, no writer trigger.

## Log
- L1 (2026-10-22) "Vamos a realizar el nuevo ticket 3, la UI. Te voy a proporcionar el contenido de desing para integrarlo a la UI. /Users/luisvelez/Downloads/Contacts App.html vamos a usar el shell router y persistencia en redimencion. La redimencion no debe romper el contenido ni hacerlo perder. Ademas agrega un boton de reload para cunado ocurra el problema de la lista vacia o el error. TICKET 03- 6- IU. La interfaz de usuario requiere shell route para dividir la vista en dos columnas. La columan de contactos y la columna de detalle. Esta herramienta viene incluida dentro de go_router. Una pantalla se considera ancha una vez pasados los 900px, por debajo de esta es una vista mobile"
- L2 (2026-10-22) Decision: UI copy in Spanish (asked; user picked "Español, como el diseño").
- L3 Engram mirror pending (mem_save fails with "multiple active runtime sessions"); this file is the source of truth.
