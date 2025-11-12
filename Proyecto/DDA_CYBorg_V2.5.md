# Documento de Diseño de Aplicación (DDA)

**Proyecto:** CYBorg v2.5

---

## 1.0 Introducción

### 1.1 Propósito del Documento

Este documento proporciona una descripción técnica completa y el razonamiento de diseño para el Proyecto CYBorg v2.5. Sirve como el manual descriptivo central, registrando la arquitectura del sistema, los conceptos técnicos, las estrategias de inteligencia artificial y la funcionalidad operativa de la plataforma.

### 1.2 Visión del Proyecto

CYBorg v2.5 es una plataforma de auditoría de ciberseguridad avanzada, diseñada para operar nativamente en entornos Kali Linux. Su objetivo es actuar como un "copiloto" inteligente para el auditor, automatizando tareas repetitivas, aumentando las capacidades de análisis y proporcionando un marco de trabajo seguro para la ejecución de auditorías complejas.

El sistema fusiona la automatización de scripts tradicional con un innovador sistema de IA Híbrida, permitiendo un análisis en tiempo real, la generación de armamento dinámico y la correlación de inteligencia de múltiples fuentes (OSINT, análisis de host, análisis de cliente).

### 1.3 Problema Resuelto

La versión 2.5 resuelve los problemas de concurrencia y bloqueo de procesos de versiones anteriores mediante la implementación de una arquitectura de Productor/Consumidor totalmente asíncrona. Además, introduce un modelo de IA Híbrida seguro que permite aprovechar la potencia de los LLM online (como Gemini) sin exponer jamás datos confidenciales del cliente, resolviendo uno de los mayores desafíos de cumplimiento y seguridad en la auditoría moderna.

### 1.4 Principios de Diseño Fundamentales

La arquitectura de CYBorg se rige por tres principios clave:

1.  **Seguridad por Defecto (Principio de Abstracción):** La protección de los datos del cliente es la directiva principal. Esto se implementa a través de:
    *   **IA Híbrida:** Ningún dato sensible (IPs, dominios, hashes) abandona la máquina local.
    *   **Arquitectura "Hub-and-Spoke":** Los datos de auditoría sensibles se segregan por sesión, mientras que solo los metadatos anónimos se centralizan para el análisis estadístico.

2.  **Auditor-in-the-Loop (HITL):** CYBorg es una herramienta de aumento, no de reemplazo. El auditor humano mantiene el control total.
    *   **Toma de Decisiones:** La IA Táctica sugiere acciones, pero el auditor puede ignorarlas, modificarlas o introducir sus propias tareas.
    *   **Aprobación Manual:** La ejecución de código generado dinámicamente (vía FAD) requiere la aprobación explícita del auditor, combinando la velocidad de la IA con el juicio humano.

3.  **Modularidad y Escalabilidad:** El sistema está diseñado para crecer.
    *   **Librería Central:** Toda la lógica de negocio reside en `lib_cyborg.sh`. Añadir una nueva capacidad (ej. una nueva herramienta) implica añadir una función a la librería y un manual RAG a la KB, sin modificar el núcleo del orquestador.
    *   **Arquitectura Distribuida:** El modelo Orquestador/Worker permite escalar la plataforma horizontalmente para auditorías más grandes y complejas.

---

## 2.0 Arquitectura del Sistema

### 2.1 Patrón de Diseño: Productor/Consumidor Asíncrono

El núcleo de CYBorg es un patrón Productor/Consumidor asíncrono que desacopla la interacción del usuario de la ejecución de tareas.

-   **Productor (`panel_control.sh`):** Es el panel de control de la TUI. Captura las entradas del usuario (comandos, consultas, etc.) y las escribe como mensajes en el bus de comunicación.
-   **Consumidor (`panel_ejecutor.sh`):** Es un demonio de larga duración que se ejecuta en un panel oculto. Escucha continuamente el bus de comunicación, lee los comandos en orden (FIFO) y los procesa de forma síncrona, llamando a la lógica de negocio correspondiente desde la librería.
-   **Bus de Comunicación:** Un conjunto de archivos y pipes con nombre (FIFO) dentro de un directorio de sesión (`$SESSION_DIR`) que gestiona el estado, los comandos y los logs (ej. `comandos.pipe`, `actividad.log`, `hallazgos.log`).

### 2.2 Componentes Centrales

-   **Lanzador (`cyborg_tui.sh`):** El punto de entrada principal.
    -   Verifica dependencias (Tmux, Curl, Jq, Gemini-CLI, Ollama, etc.).
    -   Verifica la configuración del entorno (login de gemini pro, claves API en `config/secrets.conf`).
    -   Crea el directorio de sesión (por defecto en `~/Documents/Auditorías/`).
    -   Inicia y configura la sesión de `tmux` con el layout de la TUI.
-   **Interfaz de Usuario TUI (Layout "Cyber Commander"):**
    -   **Panel Superior (Header):** Muestra el estado persistente (Objetivo, Estado de Auditoría).
    -   **Panel Central (Vista):** Panel principal conmutable que muestra los diferentes visores (`panel_visor_actividad.sh`, `panel_visor_hallazgos.sh`, etc.).
    -   **Panel Inferior (Footer):** El panel de control (`_panel_footer.sh`) que muestra la barra de acciones y el (`panel_control.sh`) que captura las entradas del teclado.
-   **Librería de Lógica (`lib_cyborg.sh`):** El cerebro que contiene toda la lógica de negocio. Ningún panel ejecuta lógica compleja; solo llaman a funciones de esta librería.

### 2.3 Pila Tecnológica

-   **Orquestación y Layout:** Tmux
-   **Lenguaje de Scripting:** Bash
-   **Widgets de Interfaz (TUI):** gum
-   **IA Táctica (Local):** Ollama
-   **IA Estratégica (Online):** Gemini-CLI
-   **Procesamiento de Datos:** Jq (JSON), XSLT (XML), SQLite (Bases de datos)
-   **Comunicaciones:** Curl (APIs, Web), SSH/SCP (Operación distribuida)
-   **Análisis Dinámico:** Node.js / Puppeteer (generado por IA)

### 2.4 Desglose de Componentes (Archivos Clave)

-   `cyborg_tui.sh` **(Lanzador):** Punto de entrada. Define variables de entorno, verifica dependencias y configuración, crea la sesión de `tmux` y el directorio de sesión.
-   `lib_cyborg.sh` **(Cerebro):** La librería de lógica central. Contiene todas las funciones de negocio (ej. `run_cyborg_fusion_analysis`, `run_dynamic_tool_generation`, `_execute_task_with_rag`, etc.). Es el único archivo que interactúa con las IAs y las herramientas.
-   `panel_ejecutor.sh` **(Consumidor / Orquestador):** El demonio de tareas. Ejecuta un bucle `while read` sobre `comandos.pipe`. Su única lógica es un `case` que mapea un comando de texto a la función correspondiente en `lib_cyborg.sh`.
-   `panel_control.sh` **(Productor / Controlador):** El panel de control TUI. Dibuja el menú y captura todas las pulsaciones de teclado del usuario.
-   `panel_visor_*.sh` **(Visores):** Scripts simples que ejecutan `tail -f` sobre los archivos de log (`actividad.log`, `hallazgos.log`, etc.) para mostrar datos en tiempo real.
-   `gemini.md` **(Personalidad IA):** El contexto persistente para la IA Estratégica (Gemini). Define su rol, capacidades y reglas de seguridad.
-   `KB/` **(Base de Conocimiento Local):** Contiene los manuales para RAG (`KB/manuals`), las plantillas para FAD (`KB/templates`) y los diccionarios (`KB/wordlists`).
-   `config/` **(Configuración):** Contiene la gestión de secretos (`secrets.conf`) y la lista de nodos (`workers.conf`).

---

## 3.0 Arquitectura de Inteligencia Artificial (IA Híbrida)

El diseño de IA de CYBorg es su componente más crítico, basado en un modelo de doble capa para maximizar la capacidad y garantizar la confidencialidad.

### 3.1 IA Táctica (Local - "El Teniente")

-   **Tecnología:** Ollama (ej. Llama 3).
-   **Rol:** Procesamiento de alta velocidad y alta seguridad. Opera 100% local.
-   **Responsabilidades:**
    -   **Manejo de Datos Sensibles:** Es la única IA que tiene acceso a los datos crudos de la auditoría (IPs, hashes, volcados de DOM, etc.).
    -   **Generación de Comandos (RAG):** Genera comandos de herramientas (Nmap, Hydra) de forma segura consultando manuales locales (`KB/manuals/`).
    -   **Filtrado y Anonimización:** Prepara las consultas para la IA Estratégica, eliminando todos los datos confidenciales.
    -   **"Re-hidratación":** Toma las respuestas anónimas de la IA Estratégica y les inyecta los datos sensibles para crear un resultado final contextualizado.

### 3.2 IA Estratégica (Online - "El General")

-   **Tecnología:** Gemini-CLI (Modelo Gemini Pro/Flash).
-   **Rol:** Conocimiento profundo, razonamiento complejo y generación creativa.
-   **Responsabilidades:**
    -   **Generación de Código Complejo:** Escribe scripts para el Framework de Armamento Dinámico (FAD), como scripts de Puppeteer, módulos de Metasploit y scripts NSE en Lua.
    -   **Análisis Estratégico:** Proporciona análisis de alto nivel (legal, de negocio, de inteligencia de amenazas) sobre hallazgos anónimos.
    -   **Generación de SQL:** Convierte consultas en lenguaje natural del auditor en consultas SQL seguras para el Motor de Análisis de Inteligencia (MAIN).
    -   **Contexto Persistente:** Utiliza `gemini.md` para mantener un contexto de rol y capacidades persistente.

### 3.3 Principio de Seguridad: Abstracción para la Confidencialidad

Este es el flujo de trabajo no negociable para proteger los datos del cliente:

1.  **Contexto Local (Sensible):** La IA Táctica (Ollama) identifica un hallazgo, ej: `Se ha encontrado Apache 2.4.29 en 10.1.1.5`.
2.  **Anonimización (Filtro):** La IA Táctica genera una pregunta abstracta y anónima: `Describe las vulnerabilidades conocidas para Apache 2.4.29`.
3.  **Consulta Estratégica (Anónima):** La pregunta anónima se envía a la IA Estratégica (Gemini).
4.  **Respuesta Estratégica (Anónima):** Gemini responde con conocimiento público: `Apache 2.4.29 es vulnerable a CVE-XXXX...`.
5.  **Re-hidratación (Contextualización):** La IA Táctica recibe la respuesta anónima y la aplica al contexto sensible: `[HALLAZGO] El host 10.1.1.5 es vulnerable a CVE-XXXX...`.

**Resultado:** En ningún momento, ningún dato sensible (IP, dominio, etc.) abandona la máquina local.

---

## 4.0 Módulos de Capacidad y Flujos de Trabajo

### 4.1 Base de Conocimiento (KB) y RAG

CYBorg utiliza una Base de Conocimiento (`KB/`) local para fundamentar las decisiones de la IA Táctica.

-   **RAG (Retrieval-Augmented Generation):** La IA Táctica genera comandos de herramientas (Nmap, Hydra) consultando los `KB/manuals/` correspondientes. Esto previene la "alucinación" de comandos y asegura que solo se usen flags y sintaxis aprobados.

### 4.2 Framework de Armamento Dinámico (FAD)

Evolución del RAG, el FAD utiliza la IA Estratégica (Gemini) para generar scripts y código en tiempo real.

-   **Flujo:** El auditor expresa una intención -> Gemini genera el código (Lua, Python, .rc) con placeholders -> Ollama inyecta los datos sensibles -> El script se presenta al auditor para aprobación manual antes de la ejecución.

### 4.3 Módulo de Inteligencia Externa (MIE)

Integra OSINT en el flujo de trabajo.

-   Utiliza `curl` y `jq` para conectarse a APIs de terceros (Shodan, HIBP, VirusTotal).
-   Las claves API se gestionan de forma segura en `config/secrets.conf`.
-   La IA Táctica (Ollama) procesa el JSON de la API y lo convierte en hallazgos estandarizados.

### 4.4 Motores de Análisis Lado-Cliente (MALC y MIAD)

-   **MALC (Motor de Análisis Estático):**
    -   Usa `curl` para descargar el código fuente (HTML, JS) de una URL.
    -   Envía el código a Gemini-CLI para una auditoría de seguridad estática (búsqueda de secretos hardcodeados, endpoints, librerías vulnerables).
-   **MIAD (Motor de Análisis Dinámico):**
    -   Usa Gemini-CLI para generar un script de Puppeteer (Node.js) basado en una intención del auditor (ej. "probar login con fuerza bruta").
    -   Ollama inyecta los datos sensibles (IPs, rutas de listas de palabras).
    -   El script se ejecuta en un navegador headless, interactuando con la aplicación como un usuario real.
-   **Sinergia:** El MIAD captura el resultado de su interacción (ej. un snapshot del DOM de una página de error) y lo pasa automáticamente al MALC para un análisis estático del resultado dinámico.

---

## 5.0 Arquitectura de Datos y Persistencia

### 5.1 Modelo "Hub-and-Spoke"

Para garantizar la segregación de datos del cliente, CYBorg utiliza un modelo de persistencia de doble base de datos.

-   **El Hub (Central - `cyborg_intelligence.db`):**
    -   Una única base de datos SQLite central.
    -   Almacena exclusivamente metadatos estadísticos y anónimos (ID de taxonomía, severidad, timestamp, fuente).
    -   Se utiliza para el análisis de tendencias a largo plazo entre todas las auditorías.
-   **Los Spokes (Locales - `audit_findings.db`):**
    -   Una nueva base de datos SQLite creada dentro de cada directorio de sesión (`$SESSION_DIR`).
    -   Almacena los hallazgos completos y detallados, incluyendo toda la información sensible (IPs, descripciones, evidencias) de esa única auditoría.

### 5.2 Motor de Análisis de Inteligencia (MAIN)

Es la interfaz del auditor para consultar la base de datos Hub central.

-   **Flujo:** El auditor escribe una consulta en lenguaje natural (ej. "¿Cuál es la vulnerabilidad más común que encontramos?") -> Gemini-CLI convierte la pregunta en una consulta SQL segura -> La consulta se ejecuta únicamente contra la base de datos anónima `cyborg_intelligence.db`.

Esto permite un análisis de inteligencia global sin ningún riesgo de fuga de datos entre clientes.

---

## 6.0 Arquitectura de Operación Distribuida

CYBorg está diseñado para escalar horizontalmente, permitiendo auditorías distribuidas y operaciones de Red Team.

-   **Rol: Orquestador:**
    -   La instancia principal de CYBorg con la TUI completa.
    -   Gestiona una lista de nodos worker (`workers.conf`).
    -   Toma decisiones estratégicas y distribuye tareas a los workers.
-   **Rol: Worker:**
    -   Una instancia de CYBorg iniciada en modo `worker`.
    -   Es headless (sin TUI) y entra en modo de espera.
    -   Recibe comandos del Orquestador, los ejecuta y devuelve los resultados.
-   **Protocolo de Comunicación:**
    -   La comunicación se realiza de forma segura y nativa utilizando SSH para la ejecución de comandos remotos y SCP para la transferencia de archivos (listas de palabras, evidencias, etc.).

---

## 7.0 Ecosistema de Informes y Usabilidad

### 7.1 Generación de Informes Duales

Al finalizar, el auditor puede generar dos tipos de informes:

-   **Informe para el Cliente (`informe_auditoria_cliente.html`):**
    -   Un informe profesional en HTML estilizado.
    -   Contiene el resumen ejecutivo (redactado por IA), métricas de criticidad y los hallazgos explicados de forma clara.
    -   Incluye los datos del auditor y la empresa.
-   **Informe Técnico Interno (`informe_tecnico_auditoria.md`):**
    -   Un archivo Markdown exhaustivo.
    -   Contiene todos los logs de la sesión: actividad, razonamiento de IA, consultas a Gemini, hallazgos crudos y anotaciones del auditor.
    -   Se utiliza para el archivo interno, la validación y el análisis estadístico posterior.

### 7.2 Personalización y Post-Procesamiento

-   El auditor puede añadir anotaciones manuales durante la auditoría.
-   El sistema incluye stubs funcionales para futuras capacidades de traducción y envío seguro por email (con firma hash).
-   La interfaz de usuario y el soporte de ratón en `tmux` están optimizados para una experiencia de usuario fluida y profesional.

### 7.3 Flujo de Trabajo del Auditor (Ejemplo de Uso)

A continuación, se describe un escenario de uso típico para ilustrar la interacción:

1.  **Inicio:** El auditor ejecuta `./cyborg_tui.sh`.
2.  **Setup:** El lanzador verifica las dependencias, solicita la información de la auditoría, crea el directorio de sesión en `~/Documents/Auditorías/` y construye la TUI.
3.  **Inicio Automático:** Inmediatamente, se envía un comando `START` al `panel_ejecutor`.
4.  **Reconocimiento:** El `panel_ejecutor` llama a `lib_cyborg.sh`, que inicia el workflow por defecto. La primera tarea (generada por RAG) es un escaneo Nmap. El resultado (`Nmap... puerto 22/OpenSSH`) aparece en `actividad.log`.
5.  **Razonamiento Táctico:** La IA Táctica (Ollama) analiza el resultado de Nmap. Reconoce "OpenSSH" y, basándose en la taxonomía, sugiere una nueva tarea: `SSH_BRUTEFORCE`. Esta sugerencia aparece en `razonamiento.log` y se añade a la cola de tareas.
6.  **Acción Táctica:** El `panel_ejecutor` procesa la tarea `SSH_BRUTEFORCE`. Llama a `lib_cyborg.sh`, que usa RAG (consultando `KB/manuals/SSH_BRUTEFORCE.txt`) para construir un comando `hydra` seguro y lo ejecuta.
7.  **Intervención Humana (HITL):** Mientras Hydra se ejecuta, el auditor ve el puerto 80 abierto. Decide no esperar a la IA. Presiona la tecla para "Añadir Hallazgo Manual" e introduce: `Puerto 80 abierto, posible servidor web`.
8.  **Consulta Estratégica:** El auditor quiere saber el impacto de una versión de Apache encontrada. Selecciona la opción "Análisis Estratégico" en el menú.
9.  **Abstracción Segura:** El auditor escribe: `Riesgos de Apache 2.4.29`. El sistema (Ollama) anonimiza esto y lo envía a Gemini-CLI.
10. **Respuesta Estratégica:** Gemini-CLI responde con una lista de CVEs y riesgos asociados, que aparece en el panel de razonamiento.
11. **Finalización:** El auditor selecciona "Generar Informes". El sistema crea el `informe_cliente.html` (con el resumen de IA) y el `informe_tecnico.md` (con todos los logs).

---

## 8.0 Hoja de Ruta y Trabajo Futuro

Este DDA describe un sistema maduro, pero la modularidad de CYBorg permite una expansión continua. Las áreas prioritarias para el desarrollo futuro incluyen:

-   **Implementación de Stubs:** Convertir los stubs funcionales (traducción, envío de email) en integraciones reales con las herramientas CLI correspondientes (ej. `translate-shell`, `mutt`).
-   **Expansión de la Base de Conocimiento (KB):**
    -   Añadir más manuales RAG para un conjunto más amplio de herramientas de Kali (Metasploit, SQLMap, Nikto).
    -   Añadir más plantillas FAD para la generación de código dinámico.
    -   Poblar el `KB/legal` y `KB/frameworks` con más resúmenes de cumplimiento (NIS2, ISO 27001, etc.).
-   **Mejora del Motor MAIN:** Implementar capacidades de consulta más complejas y visualización de datos para las tendencias de auditoría.
-   **Integración de más APIs OSINT:** Ampliar el Módulo de Inteligencia Externa (MIE) para incluir más fuentes de inteligencia.