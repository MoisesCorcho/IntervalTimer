# Como usar estas specs (SDD)

## Que es esto

Esta carpeta implementa **Spec Driven Development (SDD)**: antes de escribir codigo, cada feature se
especifica en tres documentos:

- **`requirements.md`** - QUE debe hacer la feature (user stories + criterios de aceptacion en formato
  EARS: "CUANDO ocurre X, EL SISTEMA DEBE hacer Y"). No habla de implementacion.
- **`design.md`** - COMO se va a construir (modelos de datos, arquitectura, decisiones tecnicas, riesgos).
- **`tasks.md`** - Lista de trabajo concreta y ordenada, con checklist y Definition of Done.

Cada feature declara **prerequisitos** (que debe existir antes) y **postrequisitos** (que depende de ella),
de forma que el orden de implementacion no sea arbitrario. Ver `06-roadmap-and-dependencies.md`.

## Flujo de trabajo recomendado con un agente de IA

1. Abrir `requirements.md` de la feature a implementar. Si algo es ambiguo, resolverlo ANTES de pasar a
   design (no dejar que el agente asuma silenciosamente).
2. Revisar/ajustar `design.md`. El agente no deberia escribir codigo de produccion sin que este archivo
   refleje el enfoque real que va a tomar.
3. Ejecutar `tasks.md` como checklist, marcando cada item al completarlo.
4. Antes de dar la feature por terminada, verificar la Definition of Done al final de `tasks.md`.

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

## Convencion de estados (sugerida)

Agregar manualmente al inicio de cada `requirements.md`, al empezar a trabajar en la feature:

```
> Estado: No iniciada | En progreso | Completa | Bloqueada
```
