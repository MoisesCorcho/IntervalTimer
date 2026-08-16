# Design: Backup y Exportacion de Datos

**ID:** F29 &nbsp;|&nbsp; **Slug:** `29-backup-export`

## Contexto

Este documento describe la arquitectura técnica para la exportación y restauración de datos locales (F29), soportando respaldo completo en JSON y exportación de historial en CSV de forma transaccional y offline.
Alineado con `_global/02-architecture-and-structure.md`, `_global/03-conventions.md` (Principio Anti-Parches) y `_global/05-data-model.md`.

## Decisiones Técnicas y de Persistencia

1. **Esquema de Payload JSON Versionado (`BackupPayload`):**
   - Se utiliza un contenedor envelope con metadatos claros para validar integridad y compatibilidad antes de tocar SQLite:
     ```json
     {
       "schemaVersion": 1,
       "exportDate": "2026-08-16T12:00:00.000Z",
       "appVersion": "1.0.0+1",
       "data": {
         "workouts": [...],
         "workoutExercises": [...],
         "routines": [...],
         "intervals": [...],
         "routineItems": [...],
         "sessionLogs": [...],
         "bodyMeasurements": [...],
         "unlockedAchievements": [...],
         "reminders": [...],
         "favoriteRoutines": [...],
         "appPreferences": [...]
       }
     }
     ```
2. **Restauración Atómica en SQLite/Drift (`AppDatabase.restoreBackup`):**
   - Todo el proceso de borrado e inserción se ejecuta dentro de una única transacción `database.transaction(() async { ... })`.
   - Se respeta el orden estricto de borrado e inserción para no violar restricciones de Foreign Key (FK):
     - **Orden de borrado:** `routine_items` -> `intervals` -> `routines` -> `workout_exercises` -> `workout_circuits` -> `workouts` -> `session_logs` -> `body_measurements` -> `unlocked_achievements` -> `reminders` -> `favorite_routines` -> `app_preferences`.
     - **Orden de inserción:** Inserción en orden inverso (padres antes que hijos).
3. **Servicio Desacoplado (`BackupService`):**
   - `DefaultBackupService` orquesta la extracción/serialización desde los DAOs/repositorios y la interacción con el sistema de archivos temporal (`path_provider`).
4. **Generador de CSV de Historial (`CsvHistoryExporter`):**
   - Transforma los registros de `session_logs` a texto plano CSV con escape de caracteres especiales (comillas dobles para campos de texto como notas y nombres).
5. **Integración con Sistema Operativo (Scoped Storage):**
   - **Exportación:** Se escribe el archivo temporalmente en `getTemporaryDirectory()` y se invoca `SharePlus.shareXFiles([XFile(path)])`.
   - **Importación:** Se utiliza `FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json'])` para leer el archivo seleccionado.

## Modelos de Dominio y Serialización

```dart
@freezed
class BackupPayload with _$BackupPayload {
  const factory BackupPayload({
    required int schemaVersion,
    required DateTime exportDate,
    required String appVersion,
    required BackupData data,
  }) = _BackupPayload;

  factory BackupPayload.fromJson(Map<String, dynamic> json) =>
      _$BackupPayloadFromJson(json);
}

@freezed
class BackupData with _$BackupData {
  const factory BackupData({
    @Default([]) List<WorkoutRowData> workouts,
    @Default([]) List<WorkoutExerciseRowData> workoutExercises,
    @Default([]) List<RoutineRowData> routines,
    @Default([]) List<IntervalRowData> intervals,
    @Default([]) List<RoutineItemRowData> routineItems,
    @Default([]) List<SessionLogRowData> sessionLogs,
    @Default([]) List<BodyMeasurementRowData> bodyMeasurements,
    @Default([]) List<UnlockedAchievementRowData> unlockedAchievements,
    @Default([]) List<ReminderRowData> reminders,
    @Default([]) List<FavoriteRoutineRowData> favoriteRoutines,
    @Default([]) List<AppPreferenceRowData> appPreferences,
  }) = _BackupData;

  factory BackupData.fromJson(Map<String, dynamic> json) =>
      _$BackupDataFromJson(json);
}
```

## Arquitectura de Providers (Riverpod)

```
[AppDatabase] <--------------------+
       |                           |
       v                           | (Transacción Atómica)
[BackupService]                    |
       |                           |
       v                           |
[backupControllerProvider] --------+
  - exportFullBackup()
  - exportHistoryCsv()
  - restoreBackupFromFile()
       |
       v
[SettingsScreen: Datos y Respaldo]
```

## Diagrama de Flujo: Exportación y Restauración Atómica

```
=== EXPORTACIÓN ===
[Usuario: Crear copia de seguridad]
               |
               v
[BackupService extrae todas las tablas Drift]
               |
               v
[Serializa BackupPayload a JSON] -> [Guarda en temp dir]
               |
               v
[SharePlus abre hoja nativa de compartir]

=== RESTAURACIÓN ===
[Usuario: Restaurar copia de seguridad]
               |
               v
[FilePicker selecciona archivo .json]
               |
               v
[BackupService parsea y valida schemaVersion en memoria]
       /               \
 (Inválido/Error)       (Válido)
      /                   \
[Muestra SnackBar Error]   [Diálogo modal de confirmación destructiva]
                                 /                     \
                          (Cancelar)                (Confirmar)
                              /                          \
                        [Cierra diálogo]       [Drift Database Transaction]
                                                 1. DELETE all tables
                                                 2. INSERT backup data
                                                         |
                                                (Éxito) / \ (Fallo)
                                                       /   \
                             [Invalidate all Providers]     [Rollback Total DB]
                                       |                             |
                             [SnackBar: Éxito]          [SnackBar: Error sin cambios]
```

## Riesgos, Mitigaciones y Causa Raíz

1. **Riesgo: Restauración interrumpida a mitad del proceso deja la DB corrupta:**
   - **Solución Causa Raíz:** La restauración se ejecuta íntegramente dentro de `database.transaction()`. SQLite garantiza rollback total y automático si ocurre cualquier excepción durante el proceso, manteniendo los datos previos intactos.
2. **Riesgo: Incompatibilidad de versiones de base de datos futuras:**
   - **Solución Causa Raíz:** El campo `schemaVersion` en el envelope del JSON permite versionar el payload. Si la app detecta un schema más nuevo del que soporta, rechaza la importación limpiamente antes de abrir la transacción.
3. **Riesgo: Archivos CSV con caracteres especiales rompen el formato de Excel:**
   - **Solución Causa Raíz:** `CsvHistoryExporter` formatea explícitamente en UTF-8 con BOM (Byte Order Mark) y escapa comillas dobles y comas en campos de texto libre (`note` y `displayName`), asegurando apertura perfecta en Excel, Numbers y Google Sheets.

## Alternativas Descartadas

- **Copiar el archivo de SQLite `.sqlite` directamente en crudo:**
  - *Descartada:* Depende del path interno del sistema operativo, sufre bloqueos de archivos abiertos (WAL mode) y no permite compatibilidad ni inspección de datos entre diferentes plataformas (Android/iOS).
- **Fusión (merge) automática de datos:**
  - *Descartada:* Genera colisiones de foreign keys y duplicados difíciles de resolver en entornos offline sin backend de resolución de conflictos.
