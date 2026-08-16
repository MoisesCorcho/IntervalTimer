# Design: Multilenguaje (i18n)

**ID:** F28 &nbsp;|&nbsp; **Slug:** `28-multi-language-i18n`

## Contexto

Este documento describe la arquitectura técnica para implementar el soporte completo de internacionalización (Español e Inglés) en la interfaz, el motor de voz (TTS), las etiquetas del temporizador y el catálogo de rutinas preestablecidas (F28).
Alineado con `_global/02-architecture-and-structure.md`, `_global/03-conventions.md` (Principio Anti-Parches) y `_global/05-data-model.md`.

## Decisiones Técnicas y de Arquitectura

1. **Framework de Localización Estándar (`flutter_localizations` + `.arb`):**
   - Configuración oficial de Flutter con `generate: true` en `pubspec.yaml` y archivo de configuración `l10n.yaml`.
   - Archivos de mensajes en `lib/core/l10n/`:
     - `app_es.arb` (Español)
     - `app_en.arb` (Inglés)
   - Generación de la clase fuertemente tipada `AppLocalizations` y extensión `context.l10n` para acceso limpio en widgets.
2. **Modelo de Preferencia de Idioma (`AppLanguage`):**
   - Enum de dominio en `lib/features/settings/domain/app_language.dart`:
     ```dart
     enum AppLanguage {
       system,
       es,
       en;

       String get displayName => switch (this) {
         system => 'Automático (Sistema)',
         es => 'Español',
         en => 'English',
       };

       Locale? toLocale() => switch (this) {
         system => null,
         es => const Locale('es'),
         en => const Locale('en'),
       };
     }
     ```
   - Persistido en `app_preferences` como `app_language` (`'system'`, `'es'`, `'en'`) mediante `PreferencesRepository`.
3. **Propagación Reactiva al Árbol de Widgets (`MaterialApp.router`):**
   - `App` observa `effectiveLocaleProvider`. Si la preferencia es `system`, Flutter resuelve el locale según `BasicLocaleListResolution` con fallback a `const Locale('en')`.
   - Modificar la preferencia actualiza instantáneamente el árbol de widgets sin parpadeos ni reinicio.
4. **Sincronización Dinámica con el Motor de Voz (`SystemTtsEngine`):**
   - `SystemTtsEngine` escucha `effectiveLocaleProvider`. Cuando el locale cambia, invoca `_tts.setLanguage(locale.toLanguageTag())` y actualiza los strings de fase fijos (Trabajo/Work, Descanso/Rest, Prep/Get Ready).
5. **Catálogos de Presets Localizados en Assets (F03):**
   - En `assets/routines/` se almacenan:
     - `presets_es.json` y `presets_en.json`
     - `exercises_es.json` y `exercises_en.json`
   - `AssetPresetCatalogRepository` recibe el `effectiveLocaleProvider` y carga el par de archivos correspondiente.

## Arquitectura de Providers (Riverpod)

```
[PreferencesRepository] (Drift app_preferences)
       |
       v
[appLanguageProvider] -> Notifier<AppLanguage> (lectura y guardado de 'app_language')
       |
       v
[effectiveLocaleProvider] -> Provider<Locale> (resuelve 'system' vs 'es'/'en')
       |
       +---> [MaterialApp.router] (locale, localizationsDelegates)
       |
       +---> [SystemTtsEngine] (actualiza voz nativa y tags de fase)
       |
       +---> [presetCatalogProvider] (carga presets_es.json vs presets_en.json)
```

## Estructura de Archivos

```
lib/
  core/
    l10n/
      app_es.arb
      app_en.arb
      l10n_extension.dart         # BuildContext.l10n extension
  features/
    settings/
      domain/
        app_language.dart
      application/
        language_providers.dart
      presentation/
        widgets/language_selector_tile.dart
```

## Diagrama de Flujo: Cambio de Idioma en Caliente

```
[Usuario cambia idioma en Ajustes: 'en']
                 |
                 v
[appLanguageProvider guarda 'en' en Drift]
                 |
                 v
[effectiveLocaleProvider emite Locale('en')]
                 |
       +---------+---------+--------------------+
       |                   |                    |
       v                   v                    v
[MaterialApp.router]   [SystemTtsEngine]  [presetCatalogProvider]
Re-renderiza UI en     Reconfigura voz a  Invalida catálogo y
Inglés (< 50ms)        'en-US'            carga presets_en.json
```

## Riesgos, Mitigaciones y Causa Raíz

1. **Riesgo: Strings hardcodeados residuales en la UI:**
   - **Solución Causa Raíz:** Se establece una prueba de análisis estático / unit test que verifica que ningún widget de presentación contenga literales de texto directos, migrando el 100% de `UiStrings` a `AppLocalizations`.
2. **Riesgo: Motor TTS de plataforma sin soporte para el locale elegido:**
   - **Solución Causa Raíz:** `SystemTtsEngine` verifica la disponibilidad con `isLanguageAvailable()`. Si falla `en-US`, intenta con `en`; si falla completamente, degrada a visualización en pantalla sin lanzar excepciones.
3. **Riesgo: Formato de fechas en calendario e historial:**
   - **Solución Causa Raíz:** Uso estricto de `DateFormat.yMMMMd(locale.languageCode)` del paquete `intl` inicializado con `initializeDateFormatting()`.

## Alternativas Descartadas

- **Traducción en tiempo de ejecución vía servicios online:**
  - *Descartada:* Viola el Principio 1 (Offline-first) y agrega latencia innecesaria.
- **Campos multilingües anidados dentro de un solo JSON gigante de presets:**
  - *Descartada:* Hace los modelos de dominio complejos y acopla la estructura a claves de idioma. Archivos separados por locale es mucho más limpio y escalable.
