# Como usar estas specs (SDD)

## Que es esto

Esta carpeta implementa **Spec Driven Development (SDD)**: antes de escribir codigo, cada feature se
especifica en tres documentos:

- **`requirements.md`** — QUE debe hacer la feature (user stories + criterios de aceptacion en formato
  EARS: "CUANDO ocurre X, EL SISTEMA DEBE hacer Y"). No habla de implementacion.
- **`design.md`** — COMO se va a construir (modelos de datos, arquitectura, decisiones tecnicas, riesgos).
- **`tasks.md`** — Lista de trabajo concreta y ordenada, con checklist y Definition of Done.

Cada feature declara **prerequisitos** (que debe existir antes) y **postrequisitos** (que depende de ella),
de forma que el orden de implementacion no sea arbitrario. Ver `06-roadmap-and-dependencies.md`.

## Flujo de trabajo recomendado con un agente de IA

1. Leer steering docs `01`–`06` y verificar que los prerequisitos de la feature esten **Completos** en el roadmap.
2. Aplicar siempre `03-conventions.md` (incluye **Calidad de codigo y reutilizacion**: preferir `shared/widgets/`, DRY, capas, no duplicar). No es opcional al implementar.
3. Abrir `requirements.md` de la feature. Si algo es ambiguo, resolverlo ANTES de pasar a design.
4. Revisar/ajustar `design.md`. No escribir codigo de produccion sin que este archivo refleje el enfoque real.
5. Si la feature introduce tablas drift o entidades nuevas: actualizar `05-data-model.md` **antes** del primer codigo.
6. Ejecutar `tasks.md` como checklist, marcando cada item al completarlo.
7. Antes de dar la feature por terminada, verificar la Definition of Done al final de `tasks.md` y el checklist de reutilizacion de `03-conventions.md`.

## Actualizacion de steering docs (obligatorio)

| Cambio | Documento a actualizar | Cuando |
|---|---|---|
| Nueva tabla o entidad drift | `05-data-model.md` | Antes del primer PR de codigo de la feature |
| Nuevo componente UI compartido | `04-design-system.md` | Al crear el widget en `shared/widgets/` |
| Nueva convencion de codigo | `03-conventions.md` | Cuando el equipo acuerde un patron nuevo |
| Nueva feature en el producto | `06-roadmap-and-dependencies.md` | Al crear la carpeta `specs/features/NN-slug/` |
| Decision arquitectonica global | `02-architecture-and-structure.md` | Cuando afecte a mas de una feature |

Los steering docs `00`–`06` tambien pueden auditarse con `07-sdd-feature-audit.md` adaptando las reglas
al contexto global (sin mezclar QUÉ/COMO, sin ambiguedades verificables).

## Implementacion paralela dentro de una fase

Features con los **mismos prerequisitos completos** y **sin solapamiento de archivos** pueden implementarse
en paralelo. Ejemplo tras F01 completa:

- F02, F03 y F04 pueden avanzar en branches separados si no modifican los mismos archivos core.
- Coordinar si ambas tocan `data/local/database.dart` (migraciones drift secuenciales, no paralelas).

## Auditoria y correccion de specs (antes de implementar)

Antes de codear una feature cuyas specs no fueron revisadas:

1. **Auditar** siguiendo `07-sdd-feature-audit.md` (solo lectura, una feature por sesion).
2. Tras confirmacion del equipo, **corregir** siguiendo `08-sdd-feature-correction.md`.
3. Usar `01-interval-timer-core` como referencia de calidad alcanzada.

Ver tambien la seccion homonima en `AGENTS.md` (raiz del repo).

## Esto es agnostico al agente, pero...

La metodologia (requirements -> design -> tasks) funciona igual sin importar que agente los lea:
Claude Code, Gemini CLI, opencode, Cursor, etc. Lo que SI cambia es el **archivo de entrada** que cada
herramienta busca automaticamente al arrancar en un repo:

| Agente | Archivo de contexto raiz | Notas |
|---|---|---|
| Claude Code | `CLAUDE.md` | Lee este archivo automaticamente al iniciar en el repo. |
| Gemini CLI | `GEMINI.md` | Equivalente funcional a `CLAUDE.md`. |
| Multiples agentes (estandar emergente) | `AGENTS.md` | Cada vez mas agentes lo soportan de forma nativa o via convencion. |
| Kiro (AWS) | `.kiro/specs/<feature>/{requirements,design,tasks}.md` | Estructura muy similar a esta, es la que inspiro este layout. |
| opencode / otros | Variable, revisar docs de cada uno | Generalmente tambien soportan `AGENTS.md` o config propia. |

**Recomendacion practica:** este repo incluye un `AGENTS.md` en la raiz que apunta a esta carpeta `specs/`.
Si usas Claude Code especificamente, copia o symlink `AGENTS.md` a `CLAUDE.md`:

```bash
cp AGENTS.md CLAUDE.md
```

## Convencion de estados (obligatoria)

Al inicio de cada `requirements.md` **y** en la tabla de `06-roadmap-and-dependencies.md`:

```
> Estado: No iniciada | En progreso | Completa | Bloqueada
```

- Actualizar a **En progreso** al crear el branch `feature/<NN>-<slug>`.
- Actualizar a **Completa** cuando la Definition of Done de `tasks.md` este cumplida.
- **Bloqueada** si falta un prerequisito o decision de producto pendiente.