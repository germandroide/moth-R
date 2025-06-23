### **Proyecto moth-R: Un Motor de Voz Sintética Multilingüe para AmigaOS 68k**

#### **1. Visión y Misión: Dando un Alma Única al Amiga**

El Proyecto moth-R busca revivir y revolucionar una de las características más icónicas del Amiga: su capacidad de hablar. Pero no nos conformamos con replicar el pasado. Nuestra misión es crear un motor de síntesis de voz de nueva generación, diseñado con una filosofía puramente "Amiga": eficiente, artístico y que empuje los límites de lo posible en hardware clásico.

**Nuestra visión se centra en la creación de dos "Actores Digitales" exclusivos:**

*   **Una voz masculina y otra femenina**, cada una con su propio timbre único e inconfundible. No serán clones de voces existentes, sino identidades vocales completamente nuevas, creadas para este proyecto.
*   Ambas voces serán **políglotas expertas**, capaces de hablar múltiples idiomas (castellano, inglés, francés, etc.) con una pronunciación y cadencia correctas, pero siempre conservando su timbre fundamental.
*   Serán **instrumentos artísticos**, permitiendo a los desarrolladores y demosceners modular su tono y aplicar efectos en tiempo real, integrando la voz como un instrumento más dentro de una producción musical.

El objetivo final es darle a AmigaOS 68k no solo una voz, sino un alma sonora con la que comunicarse y crear.

#### **2. El Desafío: Síntesis de Voz Avanzada en Hardware 68k**

Para entender por qué hemos elegido una estrategia tan específica, es crucial comprender las limitaciones del hardware Amiga:

| Recurso     | Limitación en Amiga 68k                                                                | Consecuencia para la Síntesis de Voz                                       |
| :---------- | :------------------------------------------------------------------------------------- | :------------------------------------------------------------------------- |
| **CPU**     | Un 68000/020/030/060 tiene una potencia de cálculo órdenes de magnitud inferior a la de un PC moderno. | **Inviable:** La síntesis generativa en tiempo real (crear audio desde cero) es demasiado intensiva. |
| **Memoria (RAM)** | La Fast RAM es un recurso precioso, a menudo limitado a unos pocos megabytes.               | **Inviable:** Cargar bases de datos de audio de alta calidad (decenas o cientos de MB) como hacen los TTS modernos es imposible. |
| **Almacenamiento** | Las demos a menudo deben caber en un disquete (ADF) y los sistemas tener una huella pequeña. | **Problemático:** El tamaño de las bibliotecas y los datos de voz es un factor crítico. |

Estos tres factores nos obligan a rechazar los enfoques convencionales y a diseñar una solución híbrida e inteligente.

#### **3. La Solución "mothr": Diseño Inteligente para un Rendimiento Óptimo**

Nuestra estrategia se basa en realizar todo el trabajo pesado "offline" en un PC moderno, para que el Amiga solo tenga que realizar tareas ligeras y rápidas en tiempo real.

**3.1. Por qué Rechazamos Otras Opciones**

*   **Flite Estándar (Concatenación de Audio Humano):** Aunque de alta calidad, los paquetes de voz basados en grabaciones humanas son demasiado grandes (varios MB por voz/idioma), lo que los hace poco prácticos para demos o sistemas con poco espacio.
*   **Síntesis Generativa en Tiempo Real (LPC/Neuronal):** Generar audio desde cero a partir de parámetros matemáticos requiere una potencia de CPU que el 68k simplemente no tiene.

**3.2. Nuestra Estrategia Híbrida: El Motor "Quimera"**

El proceso se divide en dos fases independientes:

**Fase de Diseño (Offline - en PC):**
1.  **Donantes de Timbre:** Seleccionamos dos personas (un hombre y una mujer) como "donantes de timbre" para nuestras voces mothr-M y mothr-F.
2.  **Extracción de la "Huella Vocal" (Análisis LPC):** Grabamos la voz de los donantes y usamos un software de análisis para extraer su "huella digital" matemática: los coeficientes del filtro LPC que definen su timbre único. No guardamos el audio, solo estos parámetros ultra-compactos.
3.  **Síntesis del Banco de Fonemas:** Para cada idioma (castellano, francés...), usamos un sintetizador en el PC. Le damos dos cosas:
    *   La "huella vocal" de la voz Quimera (M o F).
    *   Las reglas fonéticas del idioma.
    El PC genera entonces un **banco de sonidos de fonemas**, creando un audio sintético que tiene el timbre de nuestro donante pero la pronunciación perfecta del idioma objetivo.
4.  **Creación de Paquetes de Idioma (`.vpack`):** El resultado de este proceso son paquetes de idioma extremadamente pequeños, que contienen los fonemas pre-sintetizados y el diccionario fonético.

**Fase de Ejecución (Online - en Amiga 68k):**
1.  **Motor Ligero:** El Amiga utiliza una biblioteca (`mothr-engine.library`) cuyo único trabajo es **concatenar (pegar)** los fonemas pre-generados del `.vpack` correspondiente.
2.  **Bajo Impacto:** Esta operación es muy rápida y consume muy poca CPU. El Amiga no sintetiza nada; solo reproduce y mezcla pequeños fragmentos de audio, algo para lo que la arquitectura Amiga es excelente.

**3.3. Arquitectura del Sistema en AmigaOS 68k**

```
Fase Offline (PC)
┌──────────────────────┐   ┌──────────────────────┐
│  Grabación Humana M  │   │  Grabación Humana F  │
└──────────┬───────────┘   └──────────┬───────────┘
           │ Análisis LPC             │ Análisis LPC
           ▼                          ▼
┌──────────────────────┐   ┌──────────────────────┐
│  Modelo Timbre M     │   │  Modelo Timbre F     │
└──────────┬───────────┘   └──────────┬───────────┘
           │ Síntesis Offline         │ Síntesis Offline
           ▼                          ▼
┌──────────────────────┐   ┌──────────────────────┐
│ lang-es-M.vpack (150KB)│   │ lang-es-F.vpack (150KB)│
│ lang-fr-M.vpack (150KB)│   │ lang-fr-F.vpack (150KB)│
└──────────────────────┘   └──────────────────────┘

-----------------------------------------------------------------

Fase Online (Amiga 68k)
                                ┌───────────────────────────────────┐
"Say '[voice:F]Hola [voice:M]mundo'" │    mothr-engine.library         │
                                └───────────────┬───────────────────┘
                                                │ 1. Carga los .vpack necesarios
                                                │ 2. Parsea texto y tags
                                                │ 3. Concatena los fonemas
                                                ▼
                                ┌───────────────────────────────────┐
                                │          audio.device (AHI)       │
                                │ (Reproduce audio a tono y volumen │
                                │  especificados)                   │
                                └───────────────────────────────────┘
```

#### **4. Capacidades y Casos de Uso**

*   **Para el Sistema Operativo:**
    *   Un Workbench que habla con una voz clara, masculina o femenina, seleccionable en Preferencias.
    *   El sistema puede tener instalados ambos géneros y múltiples idiomas, ocupando un espacio mínimo en disco.

*   **Para la Demoscene (El Sistema MOD-SVS):**
    *   **Voz Cantada:** Usar un canal de un módulo de tracker para controlar la melodía (nota) y el ritmo (posición) de la voz sintetizada.
    *   **Control Expresivo:** Mapear los efectos del tracker a parámetros vocales:
        *   **Volumen:** Controla la ganancia de la voz.
        *   **Efecto Portamento (`3xx`):** Crea un glissando suave entre sílabas.
        *   **Efecto Vibrato (`4xx`):** Aplica un vibrato a la sílaba sostenida.
        *   **Comandos Personalizados (`EFx`):** Podrían usarse para cambiar de género (`[voice:F]`) o idioma (`[lang:fr]`) en mitad de una canción.

#### **5. Plan de Acción y Fases del Proyecto**

1.  **Fase 1: Diseño de los Timbres:**
    *   Selección y grabación de los dos "donantes de timbre".
    *   Análisis LPC y creación de los dos Modelos de Timbre mothr (M y F).

2.  **Fase 2: Desarrollo del Motor Central:**
    *   Desarrollar y compilar la `mothr-engine.library` para AROS 68k (`vbcc`/`gcc`). Esta será la biblioteca de concatenación.

3.  **Fase 3: Creación de Paquetes de Idioma:**
    *   Crear los diccionarios fonéticos para los idiomas iniciales (ej: Castellano, Inglés UK).
    *   Generar los primeros paquetes `.vpack` para ambas voces (M y F) en ambos idiomas.

4.  **Fase 4: Integración y Aplicaciones:**
    *   Desarrollar un nuevo comando `Say` y un panel de `Voice.prefs`.
    *   Desarrollar un reproductor de módulos de prueba (MOD-SVS) para una demo técnica.

#### **6. Llamada a la Comunidad: ¡Únete al Proyecto Fénix!**

Este proyecto es una oportunidad única para crear una pieza de software emblemática. Buscamos colaboradores apasionados:

*   **🗣️ Donantes de Timbre:** Un hombre y una mujer con voces claras y acceso a buen equipo de grabación.
*   **🧑‍💻 Desarrolladores de C/Ensamblador:** Para desarrollar el motor central, las bibliotecas y las aplicaciones en AmigaOS 68k.
*   **🎵 Músicos y Demosceners:** Para componer demos que usen el motor MOD-SVS y lleven la voz cantada a sus límites.
*   **🧪 Lingüistas y Testers:** Para ayudar a crear los diccionarios fonéticos y probar la calidad de la pronunciación en diferentes idiomas y plataformas (PiStorm, Vampire, WinUAE).

**Juntos, no solo le daremos al Amiga una nueva voz, sino que crearemos un instrumento digital que definirá una nueva era de creatividad en la plataforma.**
