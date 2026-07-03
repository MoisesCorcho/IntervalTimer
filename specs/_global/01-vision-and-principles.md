# Vision y Principios del Producto

## Vision

Una app de interval timer enfocada en ejercicio, que permite estructurar sesiones de entrenamiento
(calentamiento, trabajo, descansos, estiramiento) con guia por voz, contenido preestablecido por
categoria, y seguimiento del progreso a lo largo del tiempo - todo funcionando de forma fluida sin
depender de conexion a internet para el uso diario.

## Principios de diseno de producto

1. **Offline-first.** El uso diario (crear rutinas, correr el timer, ver historial) debe funcionar sin
   internet. La conectividad es un plus (voces premium, compartir), nunca un requisito para lo basico.
2. **Cero friccion durante el entrenamiento.** Una vez que el usuario presiona "Start", no deberia
   necesitar tocar la pantalla salvo para pausar. Voz, vibracion y wakelock existen para esto.
3. **Empezar sin configurar.** Un usuario nuevo debe poder iniciar una rutina preestablecida en menos
   de 30 segundos desde que abre la app por primera vez (ver F30 Onboarding).
4. **Los datos del usuario son suyos.** Todo el historial vive localmente por defecto; features que
   requieren backend (compartir, retos) son opt-in explicito, nunca automaticas.
5. **Monetizacion transparente, no agresiva.** La capa Pro desbloquea funciones adicionales; nunca
   degrada ni bloquea funcionalidad ya entregada de forma gratuita en una version previa.
6. **Simplicidad de mantenimiento.** Preferir soluciones locales/serverless sobre infraestructura pesada
   mientras la escala del producto no lo justifique.

## No-objetivos (explicitos)

- No es una app de planificacion nutricional ni de conteo de calorias detallado.
- No es una red social primaria; las features sociales (F25, F26) son complementarias.
- No se persigue paridad con wearables como feature de v1 (F21 es explicitamente fase futura).

## Publico objetivo

Personas que entrenan por su cuenta (en casa o gym) con rutinas de tiempo fijo tipo HIIT/circuitos, que
valoran no tener que mirar el telefono constantemente durante el ejercicio.
