# Convenciones del Proyecto

## Nombres

- Archivos Dart: `snake_case.dart`.
- Clases: `PascalCase`.
- Variables/funciones: `camelCase`.
- Modelos de dominio en ingles (`Interval`, `Routine`, `SessionLog`), aunque la UI este en espanol.
- Nombres de specs/carpetas: `NN-kebab-case-en-ingles` (ej. `05-custom-routine-builder`).

## Formato EARS para requirements

- `CUANDO <evento>, EL SISTEMA DEBE <comportamiento>.`
- `SI <condicion>, ENTONCES EL SISTEMA DEBE <comportamiento>.`
- `MIENTRAS <estado>, EL SISTEMA DEBE <comportamiento>.`
- `EL SISTEMA DEBE <comportamiento>` (para requisitos incondicionales).

Evitar frases vagas - todo criterio debe ser verificable.

## Gestion de estado

- Un solo enfoque en todo el proyecto (Riverpod recomendado).
- Prohibido usar `setState` para estado de negocio; solo permitido para estado puramente visual/local.

## Persistencia

- Toda tabla nueva requiere una entrada en `05-data-model.md` ANTES de implementarse.
- Migraciones de `drift` deben ser incrementales y nunca destructivas sin backup (ver F29).

## Testing

- Toda feature con logica no trivial requiere tests unitarios.
- Features con UI compleja o critica requieren al menos tests de widget.
- No se considera una `tasks.md` completa si el item de tests esta sin marcar.

## Accesibilidad (Definition of Done desde F31 en adelante)

- Todo widget interactivo custom debe tener `Semantics` label.
- Todo color de texto/fondo debe verificarse contra WCAG AA en ambos temas (F27).
- No usar unicamente color para transmitir informacion critica sin un indicador adicional.

## Internacionalizacion

- Ningun string visible al usuario debe hardcodearse en widgets a partir de F28.
- Antes de F28, centralizar strings en un solo archivo de constantes para facilitar la migracion.

## Git / control de versiones (sugerido)

- Un branch por feature: `feature/<ID>-<slug>` (ej. `feature/F05-custom-routine-builder`).
- Commit que cierra una feature referencia su ID (ej. `feat(F05): editor de rutinas propias`).

## Definition of Done general

- [ ] Compila sin warnings nuevos.
- [ ] Tests relevantes pasan.
- [ ] No rompe features previas (revisar postrequisitos en su `requirements.md`).
- [ ] Revisado contra este documento de convenciones.
