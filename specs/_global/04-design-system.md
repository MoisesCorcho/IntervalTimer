# Principios de Diseno / Design System

## Tono de marca

Energico pero no agresivo. La UI durante la ejecucion del timer debe ser minimalista y legible a
distancia (el usuario la mira de reojo, no la lee de cerca).

## Jerarquia visual durante la ejecucion del timer

1. **Tiempo restante** — elemento mas grande de la pantalla, siempre visible sin scroll.
2. **Nombre del intervalo actual** — con el color asignado al intervalo como fondo o acento (verificar
   contraste, nunca asumir).
3. **Progreso general de la rutina** (ej. "intervalo 3 de 8") — informacion secundaria, mas pequena.
4. **Controles (pause/skip)** — area de toque grande (min 48x48dp), se usan con manos sudadas/en movimiento.

## Theme tokens (valores base — F27 implementa ThemeData)

Definir en `core/theme/app_theme.dart`. Los widgets consumen via `Theme.of(context)`, nunca hardcodean hex.

| Token | Valor base (light) | Uso |
|---|---|---|
| `colorScheme.primary` | Material 3 seed energico (definir al implementar F01) | Acciones principales, FAB Start |
| `colorScheme.surface` | Blanco / gris muy claro | Fondos de pantalla |
| `colorScheme.onSurface` | Negro 87% | Texto general |
| `spacing.xs/sm/md/lg` | 4 / 8 / 16 / 24 dp | Padding y gaps (grid de 4dp) |
| `radius.sm/md/lg` | 8 / 12 / 16 dp | Cards, botones, campos |
| `timerDisplay` | `headlineLarge` + fuente mono tabular | Contador mm:ss |

F27 agrega variantes dark de cada token; este documento es la fuente de verdad de nombres y proposito.

## Color

- Los colores de intervalo (F01) son elegidos por el usuario; deben tener contraste calculado
  dinamicamente contra texto blanco/negro.
- Paleta de marca se define en `ThemeData` — evitar colores hardcodeados en widgets.
- Reservar rojo/naranja para alertas o cuenta regresiva final; no usarlos como colores "neutros".

### Paleta default por tipo de intervalo (F01)

Aplicar cuando el usuario no elige color explicito. Valores ARGB; override permitido por usuario.

| Tipo | Color default | ARGB |
|---|---|---|
| `warmup` | Amarillo suave | `0xFFFFC107` |
| `work` | Verde energico (profundo; texto blanco en ejecucion) | `0xFF2E7D32` |
| `rest` | Azul calmo (profundo; texto blanco en ejecucion) | `0xFF1565C0` |
| `stretch` | Violeta suave | `0xFF9C27B0` |
| `custom` | `colorScheme.primary` | Del tema |

### Contraste dinamico (`contrastTextColor`)

- **Ubicacion:** `core/utils/contrast_text_color.dart`
- **Funcion:** `Color contrastTextColor(Color background)` → `Colors.white` o `Colors.black`
- **Criterio:** ratio de contraste WCAG AA >= 4.5:1 para texto normal sobre el color de fondo dado.
- **Uso:** pantalla de ejecucion (F01 R17), badges de intervalo, cualquier texto sobre color de intervalo.
- F27: recalcular cuando cambie tema claro/oscuro si el fondo de pantalla afecta el area de contraste.

## Tipografia

- Fuente legible a distancia; numeros tabulares (mono-space) para el contador evita "saltos" de layout.
- Fuente sugerida para contador: `Roboto Mono` o equivalente con `fontFeatures: [FontFeature.tabularFigures()]`.
- Escala tipografica respeta `textScaleFactor` del sistema (F31).
- **Nombres de segmento en ejecucion:** MAYUSCULAS. Util `formatDisplayName` en `core/utils/name_format.dart` (trim + `toUpperCase`) al persistir nombres de usuario y al mostrar fase/siguiente. Labels de sistema: `PREPARACIÓN`, flatten F32/F34: `DESCANSO`, `DESCANSO FINAL`.

## Componentes reutilizables clave

| Componente | Ubicacion | Uso |
|---|---|---|
| `AppPrimaryButton` / `AppSecondaryButton` | `shared/widgets/app_primary_button.dart` | CTA rectangular radio sutil (`buttonRadius`/`radius.sm`) + sombra exterior; `compact` en dialogs; **no** stadium/pill |
| `DialogActionsRow` | `shared/widgets/dialog_actions_row.dart` | Fila horizontal de acciones en `AlertDialog` (evita apilar botones del OverflowBar) |
| `IntervalColorBadge` | `shared/widgets/` | Indicador de color + nombre |
| `CountdownRing` | `shared/widgets/` | Visualizacion circular del tiempo restante (default en ejecucion) |
| `ProgressBar` | `shared/widgets/` | Barra lineal alternativa; preferir en F31 si ring no es accesible |
| `NumberStepper` | `shared/widgets/` | Entero con botones ± (sets, etc.) — F33; sin teclado; touch >= 48dp |
| `IntervalDurationPicker` / `DurationStepper` | `shared/widgets/` | Duracion mm:ss con pickers verticales min/seg (chevron ±, long-press auto-repeat) — F33 UX update; valor en segundos; sin teclado |
| `FavoriteToggleButton` | `shared/widgets/` | F24 |
| `ProGate` | `shared/widgets/` | Wrapper premium F06 |

### NumberStepper e IntervalDurationPicker (F33 UX)

- **NumberStepper:** layout horizontal `[−] valor [+]`; valor `int` controlado (`value` + `onChanged`); `min`/`max`/`step`; botones deshabilitados en bordes; long-press auto-repeat; display no editable. Usar para sets y enteros pequeños.
- **IntervalDurationPicker** (alias `DurationStepper`): pickers **verticales** independientes (minutos / segundos) con chevrons ▲/▼; valor total en segundos; minutos ±1 min, segundos ±5 s sobre el total; total `mm:ss` debajo con label secundario "total"; long-press con aceleración; `AnimatedSwitcher` en cambios de valor; clamp a `minSeconds`/`maxSeconds`.
- **Apariencia:** contenedor suave (`surfaceContainerLow`, `radiusXl` ~20), tipografía dominante en el número (~40sp bold), labels secundarios grises; sin `TextField` ni rueda nativa.
- **Consumers:** formulario de ejercicio (F32) y de intervalo (F01).

### CountdownRing vs ProgressBar

- **Default (F01):** `CountdownRing` en pantalla de ejecucion.
- **Alternativa:** `ProgressBar` cuando F31 requiera representacion mas accesible o el usuario active modo simplificado.
- Ambos reciben `remainingFraction` (0.0–1.0) y color del intervalo actual; no calculan tiempo internamente.

## Patrones UX

### Validacion de formularios (F01 R11, R12)

- Mensaje de error **inline** debajo del campo invalido.
- No persistir datos invalidos.
- No usar dialog bloqueante para errores de validacion de campo.

### Estados vacio / carga / error

| Estado | Patron |
|---|---|
| Rutina vacia | Mensaje centrado + CTA "Agregar intervalo" |
| Carga de DB | `CircularProgressIndicator` centrado (AsyncNotifier loading) |
| Error de persistencia | SnackBar + opcion reintentar; log en debug |

### Confirmacion destructiva (F05+)

- Eliminar rutina: dialog con confirmacion explicita y boton destructivo separado del cancelar.

## Iconografia

- **Set unico:** Material Symbols (via `Icons` / `symbols` de Material 3).
- No mezclar con Cupertino salvo requisito explicito de plataforma.

## Motion

- Transicion entre intervalos: cambio de color de fondo con `AnimatedContainer` (~300ms).
- Feedback de skip/pause: escala breve del boton (100ms) — estado local con `setState` permitido.
- No animaciones que retrasen la respuesta de controles criticos del timer.

## Contenido multimedia de ejercicios (F03)

- Lottie preferido sobre video cuando el ejercicio se puede representar bien vectorialmente.
- Video reservado para ejercicios donde la tecnica real del cuerpo es dificil de transmitir animada.