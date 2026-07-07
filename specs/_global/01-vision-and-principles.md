# Vision y Principios del Producto

## Vision

Una app de interval timer enfocada en ejercicio, que permite estructurar sesiones de entrenamiento
(calentamiento, trabajo, descansos, estiramiento) con guia por voz, contenido preestablecido por
categoria, y seguimiento del progreso a lo largo del tiempo — todo funcionando de forma fluida sin
depender de conexion a internet para el uso diario.

## Principios de diseno de producto

1. **Offline-first.** El uso diario (crear rutinas, correr el timer, ver historial) debe funcionar sin
   internet. La conectividad es un plus (voces premium, compartir), nunca un requisito para lo basico.
2. **Cero friccion durante el entrenamiento.** Una vez que el usuario presiona "Start", no deberia
   necesitar tocar la pantalla salvo para pausar. Voz, vibracion y wakelock existen para esto.
3. **Empezar sin configurar.** Un usuario nuevo debe poder iniciar una rutina preestablecida en menos
   de 30 segundos desde que abre la app por primera vez (ver F30 Onboarding; ver politica MVP abajo).
4. **Los datos del usuario son suyos.** Todo el historial vive localmente por defecto; features que
   requieren backend (compartir, retos) son opt-in explicito, nunca automaticas.
5. **Monetizacion transparente, no agresiva.** La capa Pro desbloquea funciones adicionales; nunca
   degrada ni bloquea funcionalidad ya entregada de forma gratuita en una version previa.
6. **Simplicidad de mantenimiento.** Preferir soluciones locales/serverless sobre infraestructura pesada
   mientras la escala del producto no lo justifique.
7. **Timer preciso.** El tiempo restante se calcula desde timestamps (`DateTime.now()` vs inicio de
   segmento + pausas acumuladas), no desde decrementos por tick. Los ticks solo refrescan la UI.

## Alcance por fase de producto

Delimita que implementa cada feature para evitar solapamientos (especialmente F01 vs F05).

| Fase | Feature | Alcance de producto |
|---|---|---|
| Fase 0 | **F01** | Motor del timer + **una rutina activa** (draft): crear/editar intervalos, ejecutar sesion, persistir en drift. Sin biblioteca multi-rutina. |
| Fase 0 | **F03** | Catalogo de rutinas preestablecidas (assets); cargar preset en el timer. |
| Fase 1 | **F05** | Biblioteca multi-rutina: crear, duplicar (incl. presets), reordenar, eliminar. |
| Fase 7 | **F30** | Onboarding guiado para cumplir principio 3 en <30s. |

**F01 no debe** implementar lista de rutinas, duplicacion ni drag & drop — eso es F05.

## Politica MVP — principio 3 (antes de F30/F03)

Hasta que existan F30 y F03:

- La app abre directamente en la pantalla de creacion/ejecucion de la rutina activa (F01).
- El usuario puede pulsar Start con la rutina por defecto o una que acaba de armar.
- Eso cumple el espiritu de "empezar rapido" para desarrollo y QA internos; el umbral de 30s con preset
  se valida formalmente cuando F03 + F30 esten completas.

## Recuperacion ante fallos (edge cases globales)

| Escenario | Politica por defecto | Feature que puede refinar |
|---|---|---|
| App killed durante sesion `running` | Descartar sesion parcial; al reabrir, estado `idle` | F04 no registra log; F20/F21 pueden reanudar en el futuro |
| DB local corrupta / migracion fallida | Mostrar pantalla de error con opcion reinstalar datos | F29 backup/restore |
| Feature que requiere red sin conexion | Mensaje claro + degradacion; nunca pantalla en blanco | F07 voces premium |
| Suscripcion Pro expirada (F06) | Funciones Pro se bloquean; datos locales del usuario intactos | F06 |

## No-objetivos (explicitos)

- No es una app de planificacion nutricional ni de conteo de calorias detallado.
- No es una red social primaria; las features sociales (F25, F26) son complementarias.
- No se persigue paridad con wearables como feature de v1 (F21 es explicitamente fase futura).

## Publico objetivo

Personas que entrenan por su cuenta (en casa o gym) con rutinas de tiempo fijo tipo HIIT/circuitos, que
valoran no tener que mirar el telefono constantemente durante el ejercicio.