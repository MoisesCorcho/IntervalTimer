# SDD Feature Audit (solo lectura)

**Rol:** Experto SDD · **Alcance:** este repositorio (`specs/features/<slug>/`).

## Cuando usar este documento

Cargar y seguir este protocolo cuando el usuario pida:

- *auditar*, *revisar*, *verificar* una feature contra SDD
- evaluar calidad de specs antes de implementar
- `/sdd-audit` o *"audita F0N"*

**Regla critica:** NO modificar ningun archivo. Esta fase es auditoria, no correccion.
Esperar confirmacion del usuario antes de aplicar fixes (ver `08-sdd-feature-correction.md`).

## Alcance por sesion

- Por defecto auditar **una feature a la vez** (ej. `specs/features/02-voice-countdown-announcements/`).
- Si el usuario pide varias, confirmar alcance antes de continuar (31 features es demasiado en un solo pase).

## Archivos a leer

Por cada feature:

1. `specs/features/<slug>/requirements.md`
2. `specs/features/<slug>/design.md`
3. `specs/features/<slug>/tasks.md`

Steering docs (para Regla 5 y anti-alucinacion):

- `specs/_global/01-vision-and-principles.md`
- `specs/_global/02-architecture-and-structure.md`
- `specs/_global/03-conventions.md`
- `specs/_global/04-design-system.md`
- `specs/_global/05-data-model.md`

## Las 6 reglas de evaluacion

### Regla 1 — Estructura de tres artefactos

Verificar que existan `requirements.md`, `design.md`, `tasks.md` y que cada uno cumpla su proposito:

| Archivo | Proposito |
|---|---|
| `requirements.md` | QUE — observable, sin implementacion |
| `design.md` | COMO — arquitectura, modelos, decisiones tecnicas |
| `tasks.md` | ORDEN — checklist ejecutable |

Marcar mezcla QUÉ/COMO (ej. timestamps, paquetes o patrones en `requirements.md`).

### Regla 2 — Sintaxis EARS

Por cada criterio de aceptacion en `requirements.md`:

- Debe seguir plantilla valida: **CUANDO** / **MIENTRAS** / **DONDE** / **SI…ENTONCES**.
- Senalar lenguaje vago sin metrica ("rapido", "facil", "adecuado", "fluidez visual" sin umbral).
- Confirmar que equivalga a un test futuro concreto.
- Senalar ausencia de **DONDE** en features UI-heavy o con comportamiento por plataforma/pantalla.

### Regla 3 — Granularidad y trazabilidad de tareas

- `tasks.md` con maximo **2 niveles** de jerarquia.
- **CRITICO:** cada tarea debe referenciar criterio(s) de `requirements.md` (ej. `_(cubre R3, R5)_`).
- Si faltan IDs en criterios (R1, R2…), marcarlo como hallazgo prioritario.
- Verificar orden logico: modelos → logica → UI → integracion → tests.

### Regla 4 — Deteccion temprana de ambiguedades

Actuar como implementador inmediato: listar **preguntas concretas** (no inventar respuestas) sobre:

- errores de red, permisos, hardware no disponible
- condiciones de carrera entre features
- casos borde no cubiertos por AC
- huecos entre user stories / tasks / criterios

### Regla 5 — Integracion con steering docs

- `requirements.md` y `design.md` deben referenciar explicitamente los `_global/` relevantes.
- Detectar decisiones tecnicas en `design.md` que contradigan `02-architecture` o `03-conventions`.
- Cruzar modelos de datos con `05-data-model.md`.

### Regla 6 — Validacion primero (happy path + errores)

- AC deben cubrir happy path **y** inputs invalidos / estados de fallo.
- `tasks.md` debe incluir tests explicitos (no solo "tests unitarios" generico).
- Al menos un caso de error testeable por feature.

## Verificacion anti-alucinacion (paquetes Flutter)

Antes de emitir veredicto sobre paquetes en `design.md` (drift, flutter_tts, in_app_purchase,
wakelock_plus, audio_session, flutter_local_notifications, table_calendar, fl_chart, lottie,
video_player, flutter_colorpicker, etc.):

1. Consultar documentacion actual en pub.dev o Context7 — **no asumir API por memoria**.
2. Reportar paquetes deprecados, renombrados o APIs que difieran del `design.md`.

## Formato del reporte de salida

### Tabla por feature

| Feature (ID) | Regla 1 | Regla 2 | Regla 3 | Regla 4 | Regla 5 | Regla 6 | Hallazgos clave |
|---|---|---|---|---|---|---|---|

Usar ✅ / ⚠️ / ❌ por regla.

### Cierre obligatorio del reporte

1. **Top 5 problemas transversales** (patrones, no solo por feature).
2. **Propuesta de cambio estructural sistematico** (ej. IDs EARS + `(cubre Rx)` en las N features).
3. **Lista priorizada** de features a corregir primero (Fase 0: F01–F04 antes que dependientes).

## Referencia de calidad

Usar `specs/features/01-interval-timer-core/` como **gold standard** tras su auditoria y correccion:
17 criterios R1–R18, trazabilidad completa, alineacion drift/Riverpod/RoutineItem.

## Siguiente paso

Tras entregar el reporte, preguntar si el usuario quiere proceder con correcciones.
Si confirma → cargar y ejecutar `08-sdd-feature-correction.md`.