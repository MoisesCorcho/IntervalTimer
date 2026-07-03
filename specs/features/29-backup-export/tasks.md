# Tasks: Backup y Exportacion de Datos

**ID:** F29 &nbsp;|&nbsp; **Slug:** `29-backup-export`

## Definition of Done

- [ ] Todos los criterios de aceptacion de `requirements.md` estan implementados y verificados manualmente.
- [ ] Tests unitarios/widget relevantes pasan.
- [ ] Se sigue el checklist de accesibilidad de `_global/03-conventions.md` (a partir de F31).
- [ ] No se rompieron features previas (verificar dependientes listados como postrequisitos).
- [ ] Codigo revisado (self-review o PR) contra `_global/03-conventions.md`.

## Checklist de implementacion

- [ ] Implementar exportacion de historial a CSV.
- [ ] Implementar exportacion/importacion de backup completo en JSON.
- [ ] Implementar flujo de restauracion con confirmacion y validacion de integridad del archivo.
- [ ] Verificar inclusion de la base de datos local en backups nativos del OS.
- [ ] Tests de round-trip: exportar -> borrar datos -> restaurar -> verificar igualdad.

## Notas de secuenciacion

Esta feature depende de: F04, F12.
No iniciar tasks de este archivo hasta que los prerequisitos esten en estado "Done".
