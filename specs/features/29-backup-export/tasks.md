# Tasks: Backup y Exportacion de Datos

**ID:** F29 &nbsp;|&nbsp; **Slug:** `29-backup-export`

## Definition of Done

- [ ] Todos los criterios de aceptación R1 a R15 de `requirements.md` están implementados y verificados.
- [ ] Tests unitarios de serialización, exportación CSV y transacción atómica pasando al 100%.
- [ ] Tests de round-trip completos (exportar DB -> resetear -> restaurar -> verificar paridad total de datos).
- [ ] Tests de widget para la sección "Datos y Respaldo" en Ajustes y diálogo de confirmación pasando.
- [ ] Cumplimiento estricto del Principio Anti-Parches de `_global/03-conventions.md`.
- [ ] No se rompió ninguna funcionalidad de las features de datos previas (F01, F04, F32).

## Checklist de implementacion

### 1. Dependencias y Modelos de Datos (Data & Models)
- [ ] Agregar dependencias `file_picker` y `csv` (o generador UTF-8 dedicado) en `pubspec.yaml` si se requieren. _(cubre R3, R4, R6)_
- [ ] Definir modelos de serialización inmutables `BackupPayload` y `BackupData` en `lib/features/backup/domain/models/backup_payload.dart`. _(cubre R1, R2)_
- [ ] Implementar método transaccional `AppDatabase.restoreFullBackup(BackupData data)` en `lib/data/local/database.dart` con borrado en orden de FK e inserción atómica. _(cubre R8, R13)_

### 2. Servicios de Dominio y Exportación (Domain & Services)
- [ ] Implementar `CsvHistoryExporter` en `lib/features/backup/domain/services/csv_history_exporter.dart` con UTF-8 BOM, cabeceras y escape de texto. _(cubre R4, R5, R15)_
- [ ] Definir interfaz `BackupService` e implementar `DefaultBackupService` en `lib/features/backup/domain/services/backup_service.dart` para extracción y validación de JSON. _(cubre R1, R2, R11, R12, R15)_
- [ ] Implementar validación en memoria de `schemaVersion` e integridad del JSON en `BackupService`. _(cubre R11, R12)_

### 3. Capa de Aplicación y Estado (Application & State)
- [ ] Crear `backupServiceProvider` y `BackupController` en `lib/features/backup/application/backup_controller.dart` gestionando estados `AsyncValue` (loading, success, error). _(cubre R1, R3, R4, R6, R7, R8, R9, R13, R14)_
- [ ] Implementar invalidación global de providers tras una restauración exitosa para refrescar la UI. _(cubre R9)_

### 4. Presentación y Ajustes (Presentation & UI)
- [ ] Implementar sección "Datos y Respaldo" en `SettingsScreen` (F35) con opciones: "Crear copia de seguridad", "Restaurar copia de seguridad" y "Exportar historial a CSV". _(cubre R10)_
- [ ] Implementar diálogo modal de confirmación destructiva antes de ejecutar la restauración con botones "Cancelar" y "Restaurar". _(cubre R7, R14)_
- [ ] Mostrar SnackBars y diálogos de error descriptivos ante fallo de validación o restauración. _(cubre R9, R11, R12, R13)_

### 5. Tests y Validación (Testing)
- [ ] **Unit Tests (Serialización & CSV):**
  - [ ] Test de serialización/deserialización de `BackupPayload` preservando todos los tipos de datos y UUIDs. _(cubre R1, R2)_
  - [ ] Test de generación de CSV con caracteres especiales (comas, saltos de línea) y formato de columnas. _(cubre R4, R5)_
  - [ ] Test de exportación con base de datos vacía. _(cubre R15)_
- [ ] **Unit Tests (Validación & Transacción Drift):**
  - [ ] Test de rechazo de JSON corrupto o con versión superior (`schemaVersion > SUPPORTED_VERSION`). _(cubre R11, R12)_
  - [ ] Test de restauración atómica exitosa (Full Replace) en base de datos en memoria. _(cubre R8)_
  - [ ] Test de rollback total ante fallo simulado durante la transacción (verificar que los datos previos no cambian). _(cubre R13)_
  - [ ] **Round-Trip Test:** Población inicial -> Exportar a JSON -> Resetear DB -> Restaurar JSON -> Comparar igualdad de todas las tablas. _(cubre R1, R2, R8)_
- [ ] **Widget Tests (UI):**
  - [ ] Test de visualización de opciones en sección de Ajustes. _(cubre R10)_
  - [ ] Test de apertura del diálogo de confirmación y flujo de cancelación ("Cancelar" no altera datos). _(cubre R7, R14)_
  - [ ] Test de visualización de errores y estados de carga durante la restauración. _(cubre R9, R11)_

## Mapa de trazabilidad

| Criterio EARS | Tareas que lo cubren |
|---|---|
| **R1** (Generación Backup JSON) | Models (1.2), Service (2.2), App (3.1), Tests (5.1, 5.2) |
| **R2** (Estructura envelope JSON) | Models (1.2), Service (2.2), Tests (5.1, 5.2) |
| **R3** (Compartir vía share_plus) | Infra (1.1), App (3.1) |
| **R4** (Exportar CSV) | Service (2.1), App (3.1), Tests (5.1) |
| **R5** (Columnas y formato CSV) | Service (2.1), Tests (5.1) |
| **R6** (Selector file_picker) | Infra (1.1), App (3.1) |
| **R7** (Diálogo confirmación) | App (3.1), UI (4.2), Tests (5.3) |
| **R8** (Restauración atómica Drift) | Database (1.3), App (3.1), Tests (5.2) |
| **R9** (Invalidación & Notificación) | App (3.1, 3.2), UI (4.3), Tests (5.3) |
| **R10** (Sección en Ajustes) | UI (4.1), Tests (5.3) |
| **R11** (Rechazo JSON corrupto) | Service (2.3), UI (4.3), Tests (5.2, 5.3) |
| **R12** (Incompatibilidad versión) | Service (2.3), UI (4.3), Tests (5.2) |
| **R13** (Rollback atómico) | Database (1.3), App (3.1), Tests (5.2) |
| **R14** (Cancelación de usuario) | App (3.1), UI (4.2), Tests (5.3) |
| **R15** (Exportación sin datos) | Service (2.1, 2.2), Tests (5.1) |

## Notas de secuenciacion

Esta feature depende de: **F01** (Interval Timer Core), **F04** (Calendario e Historial), **F32** (Constructor de Entrenamientos) y **F35** (Ajustes).
No iniciar tareas de implementación en código hasta que dichos prerrequisitos estén en estado "Done".
