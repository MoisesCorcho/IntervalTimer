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

## Calidad de codigo y reutilizacion (obligatorio para agentes e implementacion)

Estas reglas aplican a **toda** feature. Un agente o humano que implemente debe leerlas y aplicarlas
antes de copiar o inventar codigo nuevo.

### Reutilizacion de UI (preferir lo existente)

1. **Antes de crear un widget nuevo**, revisar:
   - el catalogo en `_global/04-design-system.md` (seccion *Componentes reutilizables clave*);
   - el directorio `lib/shared/widgets/`;
   - widgets similares en otras features (solo como referencia visual — no copiar bloques enteros).
2. **Si el componente ya existe** (`AppPrimaryButton`, `NumberStepper`, `DurationStepper` / `IntervalDurationPicker`, `DialogActionsRow`, `CountdownRing`, etc.), **usarlo**. No reinventar botones, steppers, dialogs de acciones ni anillos de countdown.
3. **Si el patron se repite en 2 o mas pantallas/features** (mismo layout + misma responsabilidad), extraer a `shared/widgets/` y documentarlo en `04-design-system.md` en el mismo cambio (ver `00-how-to-use-these-specs.md`).
4. **Widgets solo de una feature** viven en `features/<f>/presentation/`. No subir a `shared/` por anticipacion.
5. **Prohibido** copiar-pegar un widget de otra feature y renombrarlo. Extraer o importar desde `shared/`.

### DRY y no duplicacion

| Que | Donde debe vivir | No hacer |
|---|---|---|
| Modelos de dominio | `data/models/` | Duplicar clases en `features/` |
| Persistencia / DAOs | `data/local/`, `data/repositories/` | Abrir drift o SQL desde widgets |
| Utils transversales (contraste, mm:ss, nombres) | `core/utils/` | Copiar helpers en cada feature |
| Strings de UI | `core/constants/ui_strings.dart` (pre-F28) | Literales dispersos en widgets |
| Logica de negocio del timer | `features/timer/application/` | Reimplementar avance de tiempo en otra feature |
| Theme / colores de marca | `Theme.of(context)` / tokens | Hex hardcodeados en widgets |

- **Una sola fuente de verdad** por concepto (tiempo restante, schema de sesion, formato de duracion, etc.).
- Si dos features necesitan la misma regla de negocio, mover a `core/`, `data/` o a un contrato documentado en `02-architecture-and-structure.md` — no copiar el `if`.

### Capas y clean code (Flutter)

- **`build()` es presentacion:** sin I/O, sin reglas de negocio, sin parseo de DB. Como maximo formatea valores ya resueltos por el controller/provider.
- **Logica de dominio** → `application/` (`Notifier`) o `domain/` puro. Testeable sin montar UI.
- **Screens delgadas:** orquestan providers + widgets; el arbol complejo se parte en widgets privados o archivos en `presentation/widgets/`.
- **Nombres con intencion:** preferir `remainingDurationLabel` a `t` / `data2`.
- **Funciones cortas y un proposito:** si un metodo mezcla validar + persistir + navegar, separar.
- **Inmutabilidad de modelos:** preferir `final` / freezed; no mutar entidades de dominio desde la UI.
- **Imports:**
  - `presentation` no importa clases generadas por drift (`*Data`, `*Companion`); solo modelos de dominio y repositorios via providers.
  - Features **no** importan widgets de otra feature; comunicacion por providers/streams (ver arquitectura).
- **Const y performance basica:** usar `const` en widgets estaticos cuando sea posible; no reconstruir listas grandes sin `ListView.builder` / keys estables si hay scroll.

### Principio anti-parches y soluciones robustas (CERO PARCHES)

Queda **estrictamente prohibido** aplicar parches temporales, hacks sintomáticos o soluciones rápidas ("band-aids") para salir del paso. Toda implementación o corrección debe ser **robusta, escalable y mantenible**:

1. **Atacar la causa raíz:** Si ocurre un bug o una inconsistencia de estado, resolver el problema en el origen (capa de datos, modelo de dominio, máquina de estados o repositorio), nunca taparlo con condiciones defensivas ad-hoc (`if (x != null && ...)` o flags temporales en la UI) que oculten el fallo real.
2. **Respeto estricto de la arquitectura:** Prohibido bypassear capas (ej. acceder a persistencia desde widgets, mutar estado sin pasar por Notifiers/Controllers de Riverpod, o duplicar lógica de negocio en la vista).
3. **Escalabilidad y tipado fuerte:** Utilizar modelos inmutables, enums exhaustivos, sealed classes y validaciones centralizadas. No recurrir a `dynamic`, `Map<String, dynamic>` en capas de presentación ni estructuras débiles para evitar modelar el dominio adecuadamente.
4. **Mantenibilidad sobre inmediatez:** Preferir refactorizar y extraer abstracciones limpias antes que acumular deuda técnica o duplicar lógica por rapidez.
5. **Testeabilidad garantizada:** Toda solución debe ser verificable mediante tests unitarios o de widget que prueben el comportamiento de fondo y los casos borde, no solo el caso feliz.

### Checklist rapido antes de abrir PR / marcar task

- [ ] La solución resuelve la causa raíz sin introducir parches, hacks de UI ni atajos temporales.
- [ ] No hay widget nuevo que duplique uno de `shared/widgets/` o del design system.
- [ ] No hay modelo/helper copiado que ya exista en `data/` o `core/`.
- [ ] No hay logica de negocio no trivial solo dentro de un `State`/`build`.
- [ ] Strings y colores siguen `ui_strings` + theme (no hardcode de marca).
- [ ] Si se creo un shared widget: entrada en `04-design-system.md`.

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
- [ ] Revisado contra este documento de convenciones (incluye **Calidad de codigo y reutilizacion**).
- [ ] No introduce duplicacion evitable de widgets, modelos o helpers (ver checklist de reutilizacion).
- [ ] Si agrega tablas drift: `05-data-model.md` actualizado antes del merge.
- [ ] Si agrega widget en `shared/widgets/`: `04-design-system.md` actualizado.