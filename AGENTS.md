# AGENTS.md

Este proyecto usa Spec Driven Development (SDD). Antes de implementar cualquier feature:

1. Lee `specs/_global/00-how-to-use-these-specs.md` primero.
2. Lee `specs/_global/01-vision-and-principles.md` a `06-roadmap-and-dependencies.md` para contexto
   de producto, arquitectura, convenciones, design system, modelo de datos y roadmap.
3. Para una feature especifica, ve a `specs/features/<slug>/` y lee, en orden:
   `requirements.md` -> `design.md` -> `tasks.md`.
4. No implementes una feature cuyos prerequisitos no esten completos.
5. Al completar tasks, marca los checkboxes en el `tasks.md` correspondiente.

## Auditoria y correccion SDD de features

Para revisar o corregir specs de una feature sin repetir el prompt completo en el chat:

| Accion del usuario | Documento a cargar | Modo |
|---|---|---|
| *audita F0N*, *revisar specs*, *verificar SDD* | `specs/_global/07-sdd-feature-audit.md` | Solo lectura — no editar archivos |
| *corrige F0N*, *aplicar fixes*, *proceder* (tras auditoria) | `specs/_global/08-sdd-feature-correction.md` | Editar `requirements/design/tasks` de la feature |

- Auditar **una feature por sesion** salvo que el usuario pida otro alcance.
- Tras auditar, esperar confirmacion antes de corregir.
- Gold standard de calidad: `specs/features/01-interval-timer-core/` (referencia post-correccion).

Si usas Claude Code, copia este archivo a `CLAUDE.md` (`cp AGENTS.md CLAUDE.md`). Si usas Gemini CLI,
copialo a `GEMINI.md`. El contenido de `specs/` es el mismo para cualquier agente.

## Notas por herramienta (equipo usando xAI/Grok + opencode)

Ninguna herramienta necesita que muevas o dupliques `specs/` a una carpeta especial (a diferencia de
Kiro, que usa `.kiro/specs/`). Ambas leen este `AGENTS.md` automaticamente en la raiz del repo:

- **Grok (xAI):** es compatible con las convenciones de Claude Code sin configuracion adicional y lee
  `AGENTS.md`/`CLAUDE.md` de forma nativa. Ver https://docs.x.ai/build/features/skills-plugins-marketplaces
- **opencode:** tambien lee `AGENTS.md` automaticamente. Este repo incluye ademas un `opencode.json` con
  el campo `instructions` apuntando a `specs/_global/*.md`, para que opencode precargue los documentos
  globales (vision, arquitectura, convenciones, design system, data model, roadmap) en cada sesion en
  vez de depender de que el agente decida ir a leerlos por su cuenta.

## Documentos globales (cargar siempre al inicio de sesion)

@specs/_global/00-how-to-use-these-specs.md
@specs/_global/01-vision-and-principles.md
@specs/_global/02-architecture-and-structure.md
@specs/_global/03-conventions.md
@specs/_global/04-design-system.md
@specs/_global/05-data-model.md
@specs/_global/06-roadmap-and-dependencies.md
@specs/_global/07-sdd-feature-audit.md
@specs/_global/08-sdd-feature-correction.md
