# Principios de Diseno / Design System

## Tono de marca

Energico pero no agresivo. La UI durante la ejecucion del timer debe ser minimalista y legible a
distancia (el usuario la mira de reojo, no la lee de cerca).

## Jerarquia visual durante la ejecucion del timer

1. **Tiempo restante** - elemento mas grande de la pantalla, siempre visible sin scroll.
2. **Nombre del intervalo actual** - con el color asignado al intervalo como fondo o acento (verificar
   contraste, nunca asumir).
3. **Progreso general de la rutina** (ej. "intervalo 3 de 8") - informacion secundaria, mas pequena.
4. **Controles (pause/skip)** - area de toque grande (min 48x48dp), se usan con manos sudadas/en movimiento.

## Color

- Los colores de intervalo (F01) son elegidos por el usuario; deben tener contraste calculado
  dinamicamente contra texto blanco/negro.
- Paleta de marca se define en `ThemeData` - evitar colores hardcodeados en widgets.
- Reservar rojo/naranja para alertas o cuenta regresiva final, evitar usarlos como colores "neutros".

## Tipografia

- Fuente legible a distancia, numeros tabulares (mono-space) para el contador de tiempo evita "saltos"
  de layout al cambiar de digito.
- Escala tipografica respeta `textScaleFactor` del sistema (F31).

## Componentes reutilizables clave

- `IntervalColorBadge` - indicador de color + nombre.
- `CountdownRing` / `ProgressBar` - visualizacion del tiempo restante.
- `FavoriteToggleButton` - F24.
- `ProGate` - wrapper para features premium (F06).

## Iconografia

Un solo set de iconos consistente en toda la app.

## Contenido multimedia de ejercicios (F03)

- Lottie preferido sobre video cuando el ejercicio se puede representar bien vectorialmente.
- Video reservado para ejercicios donde la tecnica real del cuerpo es dificil de transmitir animada.
