# Convenciones del Proyecto

## Nombres

- Archivos Dart: `snake_case.dart`.
- Clases: `PascalCase`.
- Variables/funciones: `camelCase`.
- Modelos de dominio en ingles (`Interval`, `Routine`, `SessionLog`), aunque la UI este en espanol.
- Nombres de specs/carpetas: `NN-kebab-case-en-ingles` (ej. `05-custom-routine-builder`).
- Providers Riverpod: sufijo descriptivo (`timerControllerProvider`, `routineRepositoryProvider`).

## Formato EARS para requirements

- `CUANDO <evento>, EL SISTEMA DEBE <comportamiento>.`
- `SI <condicion>, ENTONCES EL SISTEMA DEBE <comportamiento>.`
- `MIENTRAS <estado>, EL SISTEMA DEBE <comportamiento>.`
- `DONDE <contexto>, CUANDO <evento>, EL SISTEMA DEBE <comportamiento>.`
- `EL SISTEMA DEBE <comportamiento>` (para requisitos incondicionales).

Evitar frases vagas — todo criterio debe ser verificable.

## Gestion de estado (Riverpod — obligatorio)

- **Unico enfoque:** `flutter_riverpod` en todo el proyecto. No usar Bloc, GetX ni otros frameworks de estado.
- **Controllers de negocio:** `Notifier` o `AsyncNotifier` (no `StateNotifier` legacy salvo codigo existente).
- **Cuando usar cada uno:**
  - `Notifier` — estado sincrono (ej. `TimerController` con maquina de estados).
  - `AsyncNotifier` — estado con carga async inicial (ej. cargar rutina desde drift).
- **Prohibido:** `setState` para estado de negocio (rutinas, timer, persistencia).
- **Permitido con `setState`:** animaciones locales, indices de tab, estado visual efimero que no afecta dominio ni persistencia (ej. escala de boton en press).

## Persistencia

- Toda tabla nueva requiere una entrada en `05-data-model.md` **antes** de implementarse.
- Migraciones de `drift` deben ser incrementales y nunca destructivas sin backup (ver F29).
- Motor unico: drift. No introducir `isar` ni JSON como almacenamiento primario de entidades de usuario.

## Testing

- Toda feature con logica no trivial requiere tests unitarios.
- Features con UI compleja o critica requieren al menos tests de widget.
- No se considera una `tasks.md` completa si el item de tests esta sin marcar.

### Testing del timer (F01 y features que dependan del tiempo)

- **Fuente de verdad en tests:** timestamps (`DateTime`), no decrementos por tick.
- **Avance de tiempo:** usar `fake_async` — nunca `sleep` real ni `Future.delayed` sin fake async.
- **Unit tests de controllers:** `ProviderContainer` con overrides de repositorios mock.
- **Widget tests de contador (R2):** `tester.pump(Duration(milliseconds: 100))` o menos para verificar actualizacion visible.
- **Background (R5):** simular pausa de app avanzando reloj con `fake_async` hasta 60 min y verificar `remainingMs` dentro de ±1000ms.

Ejemplo de patron (referencia, no codigo de produccion):

```dart
fakeAsync((async) {
  controller.start();
  async.elapse(const Duration(minutes: 5));
  expect(controller.remainingMs, expectedMs);
});
```

## Accesibilidad (regla escalonada)

| Desde | Requisito |
|---|---|
| **F01** | Contraste WCAG AA (>= 4.5:1) en colores de intervalo via `contrastTextColor` |
| **F27** | Contraste en ambos temas claro/oscuro para toda la UI |
| **F31** | `Semantics` en widgets interactivos custom; no depender solo de color para info critica |

## Internacionalizacion

- Ningun string visible al usuario debe hardcodearse en widgets a partir de F28.
- Antes de F28, centralizar strings en **`lib/core/constants/ui_strings.dart`**.
- Importar desde ese archivo en widgets; no dispersar strings en multiples archivos.

## Manejo de errores

- Errores de validacion de formulario: inline bajo el campo (ver `04-design-system.md`).
- Errores de persistencia: excepciones capturadas en repositorio; UI muestra SnackBar con mensaje de `ui_strings.dart`.
- No tragar excepciones silenciosamente — log en modo debug (`debugPrint` o `dart:developer`).

## Git / control de versiones

- Un branch por feature: `feature/<NN>-<slug>` (ej. `feature/01-interval-timer-core`).
- Commits con ID de feature: `feat(F01): descripcion en espanol o ingles`.
- No mezclar features en un mismo branch salvo dependencia tecnica explicita.

## Definition of Done general

- [ ] Compila sin warnings nuevos.
- [ ] Tests relevantes pasan.
- [ ] No rompe features previas (revisar postrequisitos en su `requirements.md`).
- [ ] Revisado contra este documento de convenciones.
- [ ] Si agrega tablas drift: `05-data-model.md` actualizado antes del merge.