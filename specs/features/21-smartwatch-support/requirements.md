# Requirements: Soporte para Smartwatch (Wear OS / Apple Watch)

> Estado: No iniciada

**ID:** F21 &nbsp;|&nbsp; **Slug:** `21-smartwatch-support` &nbsp;|&nbsp; **Fase:** Fase 4 · Audio y Experiencia (Futuro)

## Resumen

App companion o extension que muestra el timer en el reloj inteligente, con vibracion y controles basicos desde la muneca.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F01 - Interval Timer Core
- F19 - Pantalla Siempre Encendida

## Postrequisitos (features que dependen de esta)

- Ninguno registrado actualmente

## User Stories

- **Como** usuario, **quiero** ver el timer en mi reloj inteligente, **para que** no necesito sacar el telefono durante el entrenamiento.

## Criterios de Aceptacion (formato EARS)

1. EL SISTEMA DEBE mostrar en el reloj: nombre del intervalo actual y tiempo restante, sincronizado con el telefono.
2. EL SISTEMA DEBE permitir pausar/reanudar/saltar intervalo desde el reloj.
3. EL RELOJ DEBE vibrar en los mismos momentos clave que el telefono (inicio de intervalo, cuenta regresiva).
4. ESTA feature se considera de FASE FUTURA: requiere apps companion nativas separadas (Wear OS con Kotlin/Compose, watchOS con Swift/SwiftUI) fuera del codebase Flutter principal.

## Fuera de alcance (explicito)

- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version de la feature.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- Ver `_global/05-data-model.md` para el modelo de datos completo del proyecto.
- Ver `_global/02-architecture-and-structure.md` para convenciones de arquitectura.
