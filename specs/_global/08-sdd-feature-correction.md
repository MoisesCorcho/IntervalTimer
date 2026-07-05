# SDD Feature Correction (edicion de specs)

**Rol:** Experto SDD · **Alcance:** este repositorio (`specs/features/<slug>/`).

## Cuando usar este documento

Cargar y seguir este protocolo cuando el usuario pida:

- *corregir*, *arreglar*, *aplicar fixes* a una feature tras auditoria
- *proceder* con el plan de correccion SDD
- `/sdd-fix` o *"corrige F0N"*

**Precondicion:** existe un reporte de auditoria (de `07-sdd-feature-audit.md`) o el usuario
confirma explicitamente que se deben aplicar correcciones sin auditoria previa.

## Alcance por sesion

- Corregir **una feature a la vez** salvo indicacion contraria del usuario.
- Solo editar archivos bajo `specs/features/<slug>/` y, si la feature introduce entidades nuevas,
  actualizar `specs/_global/05-data-model.md` cuando `tasks.md` lo requiera.

## Paquete de correccion estructural (aplicar en orden)

### 1. `requirements.md`

- Asignar IDs **R1…Rn** a cada criterio EARS con encabezado `### R{N} — Titulo`.
- Separar secciones: **Happy path** y **Validacion y error** cuando aplique.
- Usar plantillas EARS completas, incluyendo **DONDE** para criterios UI/contextuales.
- Eliminar detalles de implementacion (mover a `design.md`).
- Resolver ambiguedades con tabla **Decisiones de producto** (no inventar en silencio; si falta
  respuesta del usuario, formular preguntas antes de editar).
- Referenciar explicitamente los `_global/` relevantes (01–05).
- Alinear user stories con criterios: toda funcionalidad en stories/tasks debe tener AC.

### 2. `design.md`

- Referenciar steering docs (01–05).
- Alinear con `02-architecture` (drift, capas, carpetas) y `03-conventions` (Riverpod unico).
- Alinear modelos con `05-data-model.md`; usar `RoutineItem` union cuando aplique.
- Documentar contratos observables referenciados desde requirements (eventos, streams).
- Verificar paquetes en pub.dev antes de documentar APIs.
- Diagrama de flujo especifico de la feature (no plantilla generica sin adaptar).

### 3. `tasks.md`

- Anotar cada tarea con `_(cubre R{N})_` o `_(cubre R2, R5)_`.
- Mantener maximo 2 niveles de jerarquia.
- Orden: datos/persistencia → logica/controller → UI → lifecycle → tests.
- Desglosar tests en items explicitos:
  - unit happy path
  - unit error/edge
  - widget (si UI critica)
  - cada uno con criterios referenciados
- Incluir **Mapa de trazabilidad** (tabla Criterio → Tareas).
- Definition of Done debe listar rango completo de criterios (ej. R1–R18).

## Plantillas de referencia

### Criterio en `requirements.md`

```markdown
### R3 — Avance automatico entre intervalos

CUANDO el tiempo restante del intervalo actual llega a 0 y existen intervalos posteriores,
EL SISTEMA DEBE avanzar automaticamente al siguiente intervalo con su duracion completa,
sin input del usuario.
```

### Tarea en `tasks.md`

```markdown
- [ ] Implementar avance automatico entre intervalos al llegar a 0. _(cubre R3, R6)_
```

### Criterio con contexto UI (DONDE)

```markdown
### R9 — Vista de ejecucion

DONDE el usuario esta en la pantalla de ejecucion del temporizador,
CUANDO la sesion esta en estado `running` o `paused`,
EL SISTEMA DEBE mostrar ...
```

## Checklist pre-commit (auto-verificacion)

Antes de dar por cerrada la correccion, verificar:

- [ ] Toda user story tiene criterio(s) asociado(s)
- [ ] Toda tarea tiene `_(cubre Rx)_` o justificacion explicita en mapa
- [ ] Ningun criterio usa lenguaje vago sin metrica
- [ ] `design.md` no contradice `02-architecture` ni `03-conventions`
- [ ] Tests nombran escenarios, no solo "tests unitarios"
- [ ] Huecos de auditoria resueltos o documentados en Decisiones de producto

## Gold standard

Replicar el nivel de `specs/features/01-interval-timer-core/`:

- 18 criterios con IDs, trazabilidad, happy+error, DONDE/MIENTRAS donde corresponde
- design alineado drift + Riverpod + modelo global
- tasks con mapa de trazabilidad y 5+ items de test explicitos

## Commit sugerido

Tras corregir, si el usuario pide commit:

```
docs(F0N): refine <slug> specs after SDD audit
```

Convencion: tipo `docs`, scope = ID de feature, cuerpo listando cambios principales.

## Priorizacion entre features

Corregir en orden de dependencias (`06-roadmap-and-dependencies.md`):

1. **Fase 0:** F01 → F02 → F03 → F04
2. Luego features cuyos prerequisitos ya esten corregidos e implementados