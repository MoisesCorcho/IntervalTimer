# Tasks: Multilenguaje (i18n)

**ID:** F28 &nbsp;|&nbsp; **Slug:** `28-multi-language-i18n`

## Definition of Done

- [ ] Todos los criterios de aceptación R1 a R13 de `requirements.md` están implementados y verificados.
- [ ] Tests unitarios de resolución de locale, providers y sincronización de TTS pasando al 100%.
- [ ] Tests de widget para el selector de idioma y renderizado bilingüe (Español/Inglés) pasando.
- [ ] 100% de los strings de la interfaz extraídos a archivos `.arb` sin literales hardcodeados.
- [ ] Cumplimiento estricto del Principio Anti-Parches de `_global/03-conventions.md`.
- [ ] Preferencia `app_language` documentada en `_global/05-data-model.md`.
- [ ] No se rompió ninguna funcionalidad de las features previas (F01, F02, F03, F35).

## Checklist de implementacion

### 1. Infraestructura de Localización (Infrastructure & ARB)
- [ ] Configurar `l10n.yaml` y activar `generate: true` en `pubspec.yaml`. _(cubre R1, R4)_
- [ ] Crear archivos de mensajes `lib/core/l10n/app_es.arb` y `lib/core/l10n/app_en.arb` con paridad total de claves. _(cubre R1, R4)_
- [ ] Crear extensión de conveniencia `BuildContext.l10n` en `lib/core/l10n/l10n_extension.dart`. _(cubre R4)_
- [ ] Crear catálogos localizados en assets: `presets_es.json`, `presets_en.json`, `exercises_es.json`, `exercises_en.json`. _(cubre R7, R13)_

### 2. Dominio y Persistencia (Domain & Data)
- [ ] Definir enum `AppLanguage` (`system`, `es`, `en`) en `lib/features/settings/domain/app_language.dart`. _(cubre R2, R3)_
- [ ] Agregar clave `app_language` (default `'system'`) en `PreferencesRepository` (Drift `app_preferences`). _(cubre R3, R8)_
- [ ] Actualizar `AssetPresetCatalogRepository` para cargar los JSONs según el `Locale` activo. _(cubre R7, R13)_

### 3. Capa de Aplicación y Sincronización (Application & State)
- [ ] Crear `appLanguageProvider` y `effectiveLocaleProvider` en `lib/features/settings/application/language_providers.dart`. _(cubre R2, R3, R8, R10)_
- [ ] Integrar `effectiveLocaleProvider` en `SystemTtsEngine` para actualizar el idioma de locución y nombres fijos de fase ("Trabajo"/"Work", "Descanso"/"Rest", "Preparación"/"Get Ready"). _(cubre R5, R6, R11)_
- [ ] Configurar `MaterialApp.router` en `lib/app/app.dart` con `localizationsDelegates`, `supportedLocales` y el `locale` dinámico. _(cubre R4, R8, R9)_

### 4. Presentación y Ajustes (Presentation & UI)
- [ ] Implementar diálogo / selector de idioma en `SettingsScreen` (F35) con opciones: "Automático (Sistema)", "Español" e "English". _(cubre R3, R8)_
- [ ] Migrar el 100% de los widgets de la app para consumir `context.l10n` en lugar de `UiStrings`. _(cubre R4)_
- [ ] Formatear fechas y calendarios usando `DateFormat` localizado con el `Locale` activo. _(cubre R9)_

### 5. Tests y Validación (Testing)
- [ ] **Unit Tests (Resolución de Locale & Lógica):**
  - [ ] Test de resolución de `AppLanguage.system` mapeando al locale del dispositivo o fallback a `en`. _(cubre R2, R10)_
  - [ ] Test de resolución forzada de `AppLanguage.es` y `AppLanguage.en`. _(cubre R3)_
  - [ ] Test de sincronización de `SystemTtsEngine` al emitir cambio de locale. _(cubre R5, R6)_
  - [ ] Test de fallback ante archivo JSON de presets faltante o inválido. _(cubre R13)_
  - [ ] Test de preservación de texto original de usuario en `Workout` tras cambio de locale. _(cubre R12)_
- [ ] **Widget Tests (UI Bilingüe):**
  - [ ] Test de renderizado de `HomeScreen` y `SettingsScreen` en Español. _(cubre R1, R4)_
  - [ ] Test de cambio de idioma en caliente a Inglés y verificación de textos actualizados. _(cubre R3, R8, R9)_
  - [ ] Test de visualización del selector de idioma en Ajustes. _(cubre R3)_
- [ ] **Linter / Análisis de Cobertura de Strings:**
  - [ ] Verificar que no existan claves faltantes entre `app_es.arb` y `app_en.arb` (paridad 100%). _(cubre R1)_

## Mapa de trazabilidad

| Criterio EARS | Tareas que lo cubren |
|---|---|
| **R1** (Idiomas oficiales es/en) | Infra (1.1, 1.2), Tests (5.2, 5.3) |
| **R2** (Detección automática) | Domain (2.1), App (3.1), Tests (5.1) |
| **R3** (Selector en Ajustes) | Domain (2.1), Data (2.2), App (3.1), UI (4.1), Tests (5.1, 5.2) |
| **R4** (AppLocalizations en UI) | Infra (1.1, 1.2, 1.3), App (3.3), UI (4.2), Tests (5.2) |
| **R5** (Sincronización TTS) | App (3.2), Tests (5.1) |
| **R6** (Fases del Timer fijas) | App (3.2), Tests (5.1) |
| **R7** (Presets localizados) | Infra (1.4), Data (2.3) |
| **R8** (Persistencia y Hot Switch) | Data (2.2), App (3.1, 3.3), UI (4.1), Tests (5.2) |
| **R9** (Formato fechas/números) | App (3.3), UI (4.3), Tests (5.2) |
| **R10** (Fallback sistema) | App (3.1), Tests (5.1) |
| **R11** (Fallback voz TTS) | App (3.2), Tests (5.1) |
| **R12** (Inmutabilidad datos usuario) | Tests (5.1) |
| **R13** (Fallback catálogo Presets) | Infra (1.4), Data (2.3), Tests (5.1) |

## Notas de secuenciacion

Esta feature depende de: **F01** (Interval Timer Core), **F02** (Voz y Anuncios), **F03** (Presets) y **F35** (Ajustes).
No iniciar tareas de implementación en código hasta que dichos prerrequisitos estén en estado "Done".
