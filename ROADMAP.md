# moth-R Project Roadmap

Este documento describe las fases de desarrollo planificadas para el motor de voz moth-R. Las fechas son estimaciones y están sujetas a la disponibilidad de los colaboradores.

---

### **Phase 0: Foundation & Research (Q3 2024)**

*Objetivo: Establecer las herramientas, los procesos y los activos base del proyecto.*

*   [ ] **Setup Development Environment:** Configurar y documentar el entorno de compilación cruzada para AROS 68k (vbcc/gcc).
*   [ ] **Select & Document Analysis Tools:** Investigar, elegir y documentar el software para el análisis LPC offline (ej. Praat, scripts personalizados de Python).
*   [ ] **Select & Record Donor Voices:** Realizar el casting y la grabación de alta calidad de los dos "donantes de timbre" (masculino y femenino) en su idioma nativo. **(Hito Crítico)**

---

### **Phase 1: Proof of Concept - "It Speaks!" (Q4 2024)**

*Objetivo: Validar que la arquitectura híbrida es viable en hardware Amiga 68k real.*

*   [ ] **Create First Vocal DNA Model:** Realizar el análisis LPC de la voz masculina para crear el primer "Modelo de Timbre".
*   [ ] **Synthesize Minimal Phoneme Set:** Pre-sintetizar offline un banco de fonemas mínimo para el español (suficiente para decir "hola mundo moth erre").
*   [ ] **Develop "Playback Stub" on Amiga:** Escribir un programa de prueba mínimo en C/Ensamblador para Amiga que cargue y concatene estos fonemas para producir habla. **(Hito Más Importante del Proyecto)**
*   [ ] **Test on Real Hardware:** Validar el PoC en un Amiga real (A1200, PiStorm, etc.) y medir el rendimiento de la CPU y el uso de RAM.

---

### **Phase 2: Core Engine Development (Q1 2025)**

*Objetivo: Construir la biblioteca `moth-r-engine.library` y las herramientas básicas.*

*   [ ] **Develop `moth-r-engine.library` v0.5:** Crear la estructura de la biblioteca, implementar la carga de paquetes `.vpack` y la lógica de concatenación de fonemas.
*   [ ] **Implement Text Parser:** Añadir la capacidad de parsear texto, incluyendo tags básicos como `[voice:F]` y `[lang:en-UK]`.
*   [ ] **Generate First Full `.vpack`:** Crear el primer paquete de voz completo (ej: `es-ES-M.vpack`) con todos los fonemas del español.
*   [ ] **Develop `Say` Command v1.0:** Crear la primera versión funcional del comando de CLI `Say` que utiliza la nueva biblioteca.

---

### **Phase 3: Expansion & Demoscene Integration (Q2 2025)**

*Objetivo: Ampliar las capacidades del motor y desarrollar el revolucionario sistema de voz cantada.*

*   [ ] **Create Additional Voice Packs:** Generar los paquetes `.vpack` para la voz femenina y para un segundo idioma (ej: Inglés UK).
*   [ ] **Develop `Voice.prefs` Tool v1.0:** Crear la herramienta de preferencias de Workbench para seleccionar la voz y el idioma por defecto.
*   [ ] **Design & Develop MOD-SVS Engine:**
    *   [ ] Definir la especificación de control de voz vía tracker (qué efectos controlan qué parámetros vocales).
    *   [ ] Desarrollar el reproductor de módulos personalizado que integra `moth-r-engine.library`.
*   [ ] **Create "Genesis" Tech Demo:** Producir una demo técnica que muestre la voz cantada y los efectos en tiempo real. **(Hito de Presentación Pública)**

---

### **Phase 4: Maturity & Community (Ongoing from Q3 2025)**

*Objetivo: Refinar el motor, mejorar la documentación y fomentar la contribución de la comunidad.*

*   [ ] **Optimization:** Optimizar el código del motor para reducir la huella de CPU y memoria.
*   [ ] **Documentation for Voice Creators:** Escribir tutoriales detallados sobre cómo la comunidad puede crear y contribuir con nuevos paquetes de idioma para moth-R.
*   [ ] **Bug Fixing & Feature Requests:** Mantenimiento continuo basado en el feedback de la comunidad.
*   [ ] **Expand Language Support:** Integrar nuevos paquetes de idioma creados por la comunidad.
