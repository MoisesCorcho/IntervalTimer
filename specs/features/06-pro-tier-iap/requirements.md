# Requirements: Capa Pro / Compras In-App

**ID:** F06 &nbsp;|&nbsp; **Slug:** `06-pro-tier-iap` &nbsp;|&nbsp; **Fase:** Fase 1 · Personalizacion

## Resumen

Version de pago (unica o suscripcion) que desbloquea features premium via Google Play Billing / App Store In-App Purchase.

## Prerequisitos (deben estar completos antes de iniciar esta feature)

- F01 - Interval Timer Core

## Postrequisitos (features que dependen de esta)

- F25 - Compartir Rutinas con Otros Usuarios

## User Stories

- **Como** usuario, **quiero** comprar la version Pro desde la app, **para que** desbloqueo funciones avanzadas.
- **Como** desarrollador, **quiero** restringir ciertas features a usuarios Pro, **para que** puedo monetizar la app.

## Criterios de Aceptacion (formato EARS)

1. EL SISTEMA DEBE mostrar una pantalla de 'Upgrade a Pro' listando los beneficios.
2. CUANDO el usuario compra Pro, EL SISTEMA DEBE desbloquear inmediatamente las features marcadas como `proOnly` sin reiniciar la app.
3. EL SISTEMA DEBE restaurar compras previas (restore purchases) en caso de reinstalacion o cambio de dispositivo.
4. SI la compra falla o se cancela, ENTONCES EL SISTEMA DEBE mostrar un mensaje claro y mantener el estado free.
5. EL SISTEMA DEBE persistir localmente el estado `isPro` y verificarlo al abrir la app.

## Fuera de alcance (explicito)

- Cualquier comportamiento no listado arriba se considera fuera de alcance para esta version de la feature.
- Cambios de UI/UX no especificados aqui deben resolverse consultando `_global/04-design-system.md`.

## Referencias

- Ver `_global/05-data-model.md` para el modelo de datos completo del proyecto.
- Ver `_global/02-architecture-and-structure.md` para convenciones de arquitectura.
