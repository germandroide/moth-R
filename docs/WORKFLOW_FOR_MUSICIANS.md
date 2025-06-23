# moth-R: Flujo de Trabajo para Músicos y Demosceners

Este documento describe el proceso creativo para hacer que moth-R cante una letra específica con una melodía y ritmo predefinidos, usando herramientas modernas y un tracker de Amiga.

## El Objetivo: Clonar una Actuación Vocal

Imagina que tienes una grabación de una línea vocal (o simplemente una idea melódica en tu cabeza). Nuestro objetivo es transferir tres elementos clave de esa actuación a moth-R:

1.  **La Letra:** Las palabras y su división en sílabas.
2.  **La Melodía:** La secuencia de notas musicales (su tono o pitch).
3.  **El Ritmo:** El momento exacto y la duración de cada sílaba.

## Herramientas Necesarias (En tu PC/Mac/Linux)

*   **Un Editor de Audio/DAW:** Audacity (gratis), Reaper, Ableton Live, etc. Para visualizar y editar la grabación de referencia.
*   **Un Editor de Partituras/MIDI (Opcional pero recomendado):** MuseScore (gratis), un secuenciador MIDI en tu DAW. Para transcribir la melodía.
*   **Un Editor de Texto:** Para crear el "script de la letra".
*   **Un Emulador de Amiga:** WinUAE/FS-UAE/Amiberry con un tracker como **ProTracker**.

---

## Flujo de Trabajo Detallado: Paso a Paso

### Paso 1: Preparar la Letra (El "Lyrics Script")

Primero, toma tu letra y divídela fonéticamente en sílabas. Este es el paso más manual y creativo.

*   **Letra Original:** "Eres inteligente"
*   **Letra Silabeada:** `E-res` `in-te-li-gen-te`

Luego, crea un archivo de texto simple (`cancion_letra.txt`). En este archivo, mapearás cada sílaba a una posición en tu módulo de ProTracker. El formato es `[patrón]:[fila]:[sílaba]`.

```
# Script de Letra para "MiCancion.mod"
01:00:E-res
01:08:in-te
01:10:li-gen
01:14:te
```

### Paso 2: Extraer la Melodía (La "Partitura Vocal")

Ahora necesitas saber qué notas musicales canta cada sílaba. Hay dos métodos:

*   **Método A (De Oído):** Usando un teclado MIDI o el teclado de tu PC, toca las notas de la melodía vocal en tu DAW o editor MIDI mientras escuchas la grabación original. Anota la secuencia: `C-4, E-4, F-4, D-4...`

*   **Método B (Automático):** Usa un software de detección de pitch. Herramientas como Melodyne son profesionales, pero incluso Audacity tiene plugins (Analyze -> Pitch and Beat) que pueden ayudarte a visualizar la melodía de una pista vocal y extraer las notas.

El resultado final es tu **"Partitura Vocal"**: una secuencia de notas que se corresponde con tus sílabas.

### Paso 3: Programar el Tracker en Amiga

¡Aquí es donde todo se une!

1.  Abre ProTracker en tu emulador.
2.  Carga tu música de acompañamiento en los canales 1, 2 y 3.
3.  Selecciona el **Canal 4 (el canal de moth-R)**.
4.  Usando tu "Partitura Vocal", introduce las notas de la melodía en las filas que corresponden a tu "Lyrics Script".

**Ejemplo visual en ProTracker:**

```
Pattern 01, Channel 4
Row 00: F-4 01 ...  <-- Coincide con la sílaba "E-res"
...
Row 08: G-4 01 ...  <-- Coincide con la sílaba "in-te"
...
Row 10: A-4 01 ...  <-- Coincide con la sílaba "li-gen"
...
Row 14: G-4 01 ...  <-- Coincide con la sílaba "te"
```

### Paso 4: Añadir Expresión Humana

Una melodía plana suena robótica. Usa los efectos del tracker para imitar a un cantante real:

*   **Usa el Efecto `3xx` (Portamento to Note):** Si el cantante original desliza su voz suavemente entre dos notas, usa este efecto para crear un **glissando** realista. Esta es la técnica más importante para el canto.
*   **Usa el Efecto `4xy` (Vibrato):** En las notas largas, añade un sutil vibrato para darles vida.
*   **Usa el Instrumento:** Asigna diferentes números de instrumento para cambiar de voz sobre la marcha (ej: `Inst 1` para la voz masculina, `Inst 2` para la femenina).

Al final del proceso, el reproductor personalizado de tu demo leerá el módulo y el script de la letra simultáneamente. Cuando vea `F-4` en la fila `00` del patrón `01`, le pedirá a moth-R que cante la sílaba "E-res" con el tono de la nota `F-4`.
