# Design: Capa Pro / Compras In-App

**ID:** F06 &nbsp;|&nbsp; **Slug:** `06-pro-tier-iap`

## Contexto

Este documento describe el diseno tecnico para cumplir `requirements.md` de esta misma feature.
Antes de implementar, revisar `_global/02-architecture-and-structure.md` y `_global/03-conventions.md`.

## Decisiones de diseno

- Paquete `in_app_purchase` (oficial Flutter) sobre Google Play Billing / StoreKit.
- Servicio `PurchaseService` que expone `isPro: Stream<bool>` consumido por toda la app via provider/bloc.
- Feature flags: cada feature premium se envuelve con un widget/guard `ProGate` que redirige a la pantalla de upgrade si `isPro == false`.
- MVP sin validacion server-side (riesgo aceptado inicialmente); documentar en design.md el plan de migracion a validacion via Cloud Function.
- Definir catalogo de producto: compra unica 'Pro Lifetime' vs suscripcion mensual/anual (decision de negocio, dejar configurable).

## Diagrama de flujo (alto nivel)

```
[Trigger / Evento de usuario]
        |
        v
[Capa UI: Widget/Screen] --> [Capa de estado: Controller/Provider]
        |                              |
        v                              v
[Servicio de dominio especifico]   [Repositorio / Persistencia local]
        |
        v
[Efecto observable: UI actualizada / evento emitido a otras features]
```

*Nota: Este diagrama es una plantilla generica. Ajustar segun la naturaleza de la feature al
implementar (algunas features son puramente UI, otras solo backend/servicios, etc).*

## Riesgos y consideraciones

- Validar que los cambios de datos sean compatibles con versiones anteriores de la base de datos local
  (definir estrategia de migracion en `_global/05-data-model.md` si esta feature agrega/modifica tablas).
- Si esta feature interactua con hardware (audio, vibracion, notificaciones), probar en dispositivo fisico,
  no solo en emulador/simulador.

## Alternativas consideradas

*(Completar durante la implementacion si se descartan enfoques relevantes, para dejar registro de por que
se eligio el enfoque actual.)*
