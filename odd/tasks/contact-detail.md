# Ticket 02: contact detail by URL (go_router)
Branch: feat/contact-detail (stacked on feat/contact-list, PR #1). Delivery: work-unit commits, one PR (user decides). Runner: `flutter test`, `flutter analyze`.

## Specs
- S1 Route: `contacts/:id`. "Para el detalle vamos a trabajar con el URL, de esta forma podemos persistir un detalle o enviar el enlace de un contacto." Uses go_router.
- S2 "Si no existe un id, lanzar un 404." (unknown id, non-numeric id and unknown routes show a 404)
- S3 "Si existe cargar la data del usuario."
- S4 "Detail es una vista independiente. Debe ir en su propia feature." New feature `contact_detail` with presentation/domain/data.
- S5 "Para detail no hare la simulacion del error, esta ya fue compeltada en el list." No dice and no delay in detail.
- S6 "si hay un error en la carga del list, no se pueda acceder a un detail, dado que no tenemos cache, seria un error de carga." Detail shows a load error when the list's last call failed.
- S7 (decision, user chose "Mover lo compartido a core"): code shared by both features moves to `lib/core/`; features never import each other.
- S8 (assumption) The list opens a detail by tapping an item (push, so back returns to the list). Query params belong to tickets 03/04, not this one.

## Tasks
- T1 (S7) Move Contact, catalog, validators, ContactModel, PhoneNumberValidator and ServiceGetContacts to lib/core/contacts; no behavior change. Route: inline. Commit: see git log "refactor: move shared contact code to core"
- T2 (S1, S2) go_router skeleton: routes, AppRoutes, NotFoundPage, ContactsPage, MaterialApp.router. Route: inline. Commit: pending
- T3 (S1-S6, S8) contact_detail feature, ContactsAvailability gate, list item navigation, DI. Route: inline. Commit: pending

Route declaration: all inline, sequential and dependent units, no writer trigger (no independent parallel units, context under backstop).

## Log
- L1 (2026-10-22) Ticket 02, vamos a usar go_router y queryparms para esta tarea.
  "Para el detalle vamos a trabajar con el URL, de esta forma podemos persistir un detalle o enviar el enlace de un contacto. contacts/:id. Si no existe un id, lanzar un 404. Si existe cargar la data del usuario. Detail es una vista independiente. Debe ir en su propia feature. Para detail no hare la simulacion del error, esta ya fue compeltada en el list. Si añadiria que si hay un error en la carga del list, no se pueda acceder a un detail, dado que no tenemos cache, seria un error de carga. Abre nueva feature para el detail"
- L2 (2026-10-22) Decision: shared code moves to core (asked, user picked "Mover lo compartido a core").
