# Requirements: Backup y Exportacion de Datos

> Estado: No iniciada

**ID:** F29 &nbsp;|&nbsp; **Slug:** `29-backup-export` &nbsp;|&nbsp; **Fase:** Fase 7 · Calidad y Pulido

## Resumen

Sistema integral de exportación y respaldo de datos locales que permite al usuario generar una copia de seguridad completa en formato JSON (para restaurar la app en cualquier dispositivo) y exportar su historial de sesiones a formato CSV (para análisis en hojas de cálculo como Excel o Google Sheets), todo gestionado de forma offline mediante las hojas nativas del sistema operativo.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F01 - Interval Timer Core
- F04 - Calendario e Historial de Sesiones
- F32 - Constructor de Entrenamientos por Ejercicios
- F35 - Navegacion de Secciones, Preparacion y Ajustes

## Postrequisitos (features que dependen de esta)

- Ninguno registrado actualmente

## User Stories

- **Como** usuario, **quiero** exportar un archivo de respaldo con todos mis entrenamientos, historial y preferencias, **para que** pueda transferir mis datos si cambio de teléfono o protegerlos ante pérdida del dispositivo.
- **Como** usuario, **quiero** restaurar mi aplicación a partir de un archivo de backup JSON, **para que** pueda recuperar mi historial y configuraciones completas de manera exacta.
- **Como** usuario, **quiero** exportar mi historial de entrenamientos a formato CSV, **para que** pueda abrirlo en Excel o Google Sheets y analizar mi progreso deportivo en detalle.

## Decisiones de producto (registradas en auditoria)

| Tema | Decision | Justificacion |
|---|---|---|
| **Estrategia de restauración** | Sobrescritura total (Full Replace) atómica dentro de una transacción Drift con validación previa de schema y confirmación destructiva. | Previene inconsistencias relacionales, duplicación de IDs y estados corruptos que surgen en estrategias de fusión (merge) offline complejas. |
| **Formatos soportados** | **JSON** para backup/restauración de toda la app; **CSV** exclusivo para exportación de historial legible en hojas de cálculo. | El JSON mantiene tipos, UUIDs y relaciones relacionales intactas. El CSV es el estándar de lectura para análisis de datos por el usuario. |
| **Entidades en Backup JSON** | Entrenamientos (`Workouts` y `WorkoutExercises`), Rutinas de intervalos (`Routines` e `Intervals`), Historial (`SessionLogs`), Peso y medidas (`BodyMeasurements`), Logros (`UnlockedAchievements`), Recordatorios (`Reminders`), Favoritos (`FavoriteRoutines`) y Preferencias (`AppPreferences`). | Respalda el 100% de los datos generados por el usuario en la app. |
| **Interacción con el SO** | Hoja de compartir nativa (`share_plus`) para exportar; selector de archivos nativo (`file_picker` con filtro `.json`) para importar. | Respeta Scoped Storage y políticas de privacidad en Android 13+ e iOS sin requerir permisos de almacenamiento invasivos (`MANAGE_EXTERNAL_STORAGE`). |
| **Ubicación en UI** | Sección dedicada "Datos y Respaldo" dentro de la pantalla de Ajustes (F35). | Centraliza la gestión de datos personales en el lugar esperado por el usuario. |

## Criterios de Aceptacion — Happy path (formato EARS)

### R1 — Generación de Backup Completo en JSON

DONDE el usuario presiona "Crear copia de seguridad" en la sección de Respaldo de Ajustes,  
CUANDO se solicita la exportación,  
EL SISTEMA DEBE serializar la totalidad de las tablas de datos locales en una estructura JSON válida que incluya metadatos y todas las entidades de usuario.

### R2 — Estructura y metadata del archivo JSON

CUANDO se genera el archivo de backup JSON,  
EL SISTEMA DEBE estructurarlo con un envelope que contenga:
- `schemaVersion`: entero con la versión de esquema de exportación (ej. `1`).
- `exportDate`: fecha y hora UTC en formato ISO 8601.
- `appVersion`: versión de la aplicación.
- `data`: objeto con las colecciones (`workouts`, `routines`, `sessionLogs`, `bodyMeasurements`, `achievements`, `reminders`, `favorites`, `preferences`).

### R3 — Guardado y compartición de Backup vía hoja nativa

CUANDO el archivo JSON es generado con éxito,  
EL SISTEMA DEBE invocar la hoja de compartir nativa del sistema operativo (`share_plus`), permitiendo al usuario guardarlo en "Archivos", enviarlo por correo o subirlo a Google Drive / iCloud Drive.

### R4 — Exportación del Historial de Sesiones a CSV

DONDE el usuario presiona "Exportar historial a CSV" en la sección de Respaldo,  
CUANDO existen registros de sesiones en la base de datos,  
EL SISTEMA DEBE generar un archivo `.csv` formateado en UTF-8 con delimitador por comas (o punto y coma según convención estándar) y abrir la hoja de compartir nativa.

### R5 — Formato y columnas del archivo CSV

CUANDO se genera el archivo CSV del historial,  
EL SISTEMA DEBE incluir una fila de cabecera seguida de los registros con las columnas:
`ID, Fecha, Hora_Inicio, Nombre_Rutina, Tipo, Duracion_Total_Segundos, Duracion_Formateada, Estado, Intervalos_Completados, Notas`.

### R6 — Selección de archivo para restaurar vía selector nativo

DONDE el usuario presiona "Restaurar copia de seguridad" en la pantalla de Ajustes,  
CUANDO se abre el selector de archivos nativo (`file_picker`),  
EL SISTEMA DEBE restringir la selección únicamente a archivos con extensión `.json`.

### R7 — Diálogo de confirmación destructiva antes de restaurar

DONDE el usuario ha seleccionado un archivo JSON válido,  
CUANDO el archivo ha sido verificado en memoria,  
EL SISTEMA DEBE mostrar un diálogo modal de confirmación advirtiendo claramente que los datos actuales del dispositivo serán reemplazados por los del respaldo, requiriendo acción explícita ("Restaurar" o "Cancelar").

### R8 — Restauración atómica de datos en SQLite/Drift

DONDE el usuario confirma la restauración en el diálogo,  
CUANDO se inicia el proceso de restauración,  
EL SISTEMA DEBE ejecutar una transacción atómica única en Drift que:
1. Elimine los registros de las tablas locales actuales.
2. Inserte todos los registros contenidos en el payload del JSON.
3. Actualice las preferencias locales.

### R9 — Notificación de éxito y recarga reactiva de estado

CUANDO la transacción de restauración concluye con éxito,  
EL SISTEMA DEBE invalidar los providers de Riverpod correspondientes para refrescar todas las vistas de la app inmediatamente y mostrar un SnackBar confirmando la restauración.

### R10 — Ubicación en Ajustes (F35)

DONDE el usuario navega a la pantalla de Ajustes (F35),  
EL SISTEMA DEBE mostrar una sección "Datos y Respaldo" con las opciones: "Crear copia de seguridad", "Restaurar copia de seguridad" y "Exportar historial a CSV".

## Criterios de Aceptacion — Validacion, casos borde y error (formato EARS)

### R11 — Rechazo de archivo JSON corrupto o malformado

SI el usuario selecciona un archivo que no es un JSON válido o carece de la estructura esperada en `data`,  
ENTONCES EL SISTEMA DEBE abortar el proceso sin modificar la base de datos actual y mostrar un mensaje de error descriptivo ("Archivo de respaldo inválido o corrupto").

### R12 — Incompatibilidad de versión de esquema de backup

SI el archivo JSON contiene un `schemaVersion` superior al soportado por la versión actual de la aplicación,  
ENTONCES EL SISTEMA DEBE rechazar la restauración y notificar al usuario que debe actualizar la aplicación para poder restaurar ese respaldo.

### R13 — Rollback automático ante fallo durante la transacción

SI ocurre un error de base de datos o excepción durante la inserción de los datos del backup,  
ENTONCES EL SISTEMA DEBE ejecutar rollback total de la transacción de Drift, asegurando que los datos previos del usuario permanezcan exactamente en su estado original sin corrupción parcial.

### R14 — Cancelación por parte del usuario

CUANDO el usuario cancela la selección en el selector de archivos o presiona "Cancelar" en el diálogo de confirmación,  
EL SISTEMA DEBE cerrar la interacción sin realizar cambios en los datos ni emitir errores.

### R15 — Exportación con colecciones vacías

DONDE el usuario solicita crear un backup o exportar CSV en una instalación nueva sin datos registrados,  
EL SISTEMA DEBE generar el archivo correspondiente con estructura válida y colecciones vacías (o cabecera sola en CSV) sin arrojar excepciones.

## Fuera de alcance (explicito)

- Sincronización continua en segundo plano tipo Dropbox sync (requiere backend en tiempo real reservado para F25/F26).
- Fusión/Merge interactivo de registros individuales (resolución manual de conflictos ítem por ítem).
- Cifrado con contraseña personalizada del archivo JSON en v1 (el archivo es texto plano estructurado).

## Referencias

- Ver `_global/01-vision-and-principles.md` (Principio 4: Los datos del usuario son suyos; Recuperación ante fallos: DB corrupta).
- Ver `_global/02-architecture-and-structure.md` (Acceso a repositorios y persistencia Drift).
- Ver `_global/03-conventions.md` (Principio Anti-Parches y manejo seguro de transacciones).
- Ver `_global/05-data-model.md` (Estrategia de migraciones y snapshot de entidades).
