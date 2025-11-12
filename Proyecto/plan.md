# Plan de Desarrollo de CYBorg V2.5

**Documento Maestro:** `DDA_CYBorg_V2.5.md`
**Misión:** Evolucionar la base de código actual para alcanzar la paridad de funciones y la sofisticación arquitectónica descritas en el DDA, transformando el prototipo en una herramienta de pentesting inteligente y robusta.

---

## 1. Estado Actual (Resumen Inicial)

Hemos establecido con éxito la arquitectura base Productor/Consumidor con `tmux`, resolviendo el problema de concurrencia de la v24.

-   **Componentes Existentes:** `panel_control.sh`, `panel_ejecutor.sh`, `lib_cyborg.sh`, `generate_report.sh`, y los archivos de `templates` y `KB` (YAMLs).
-   **Fortalezas:** La estructura de `tmux` es sólida y el patrón de comunicación mediante un pipe/cola de tareas es funcional.
-   **Debilidades Críticas (Desviaciones del DDA):**
    -   **Ausencia total de IA:** No hay llamadas a Ollama. La lógica de "razonamiento" es una simulación simple con `awk`.
    -   **Ejecución Simulada:** Las herramientas de Kali (Nmap, etc.) no se ejecutan realmente; sus salidas son texto predefinido.
    -   **Lógica Centralizada Incorrectamente:** `panel_ejecutor.sh` contiene lógica de ejecución que debería estar en `lib_cyborg.sh`.
    -   **Componentes Faltantes:** No existe el lanzador `cyborg_tui.sh` ni los paneles de visualización (`_visor_*`).
    -   **Gestión de Informes Simplista:** El `generate_report.sh` no implementa el conteo, la transformación de evidencias ni el ensamblaje final por IA.

---

## 2. Roadmap Principal y Desglose de Tareas

### ✅ Hito 1: Implementar el Flujo de Fusión de Datos (A-B-C-D-E)
*Este es el corazón del sistema y la máxima prioridad.*

-   [x] **Fase A (Recolectar):**
    -   [x] Refactorizar la lógica de ejecución de `panel_ejecutor.sh` a `lib_cyborg.sh`.
    -   [x] Implementar la ejecución del comando `nmap` real con salida en formato XML.
-   [x] **Fase B (Ingestión Estructurada):**
    -   [x] Crear una función `_ingest_nmap_xml` en `lib_cyborg.sh` que use `xsltproc` para extraer datos clave (puertos, servicios, versiones) del archivo `nmap_scan.xml`.
-   [x] **Fase D (Fusión y Razonamiento con IA):**
    -   [x] Crear una nueva función `run_cyborg_fusion_analysis` en `lib_cyborg.sh`.
    -   [x] Esta función deberá construir un *prompt* para Ollama, pasándole los datos estructurados de la Fase B y el contenido relevante de los YAMLs de la KB.
    -   [x] Implementar la lógica para llamar a Ollama (inicialmente podemos simular la llamada y la respuesta JSON esperada).
    -   [x] Parsear la respuesta de Ollama para generar un hallazgo formateado.
-   [x] **Fase E (Bucle de Retroalimentación):**
    -   [x] Actualizar el `panel_ejecutor.sh` para que, tras la Fase D, analice la respuesta de la IA en busca de `suggested_task` y la añada de nuevo a la cola (`comandos.pipe`).

### ✅ Hito 2: Refactorización y Centralización de la Lógica (Alineación Arquitectónica)
-   [x] Mover toda la lógica de ejecución, ingestión e IA de `panel_ejecutor.sh` a `lib_cyborg.sh` como dicta el DDA.
-   [x] El `panel_ejecutor.sh` debe quedar como un orquestador simple: lee una tarea de la cola y llama a la función correspondiente en la librería.

### ✅ Hito 3: Sofisticación de la Gestión de Informes
-   [x] Actualizar `generate_report.sh` para que cuente los hallazgos por nivel de criticidad.
-   [x] Implementar la conversión de evidencias `.xml` a `evidence_*.html` usando `xsltproc`.
-   [x] Crear la función `run_cyborg_assemble_html_report` en `lib_cyborg.sh` que llame a Ollama para ensamblar el informe final a partir de la plantilla, los contadores y los hallazgos.
-   [x] Integrar la llamada a esta función en `generate_report.sh`.

### ✅ Hito 4: Construcción del Ecosistema TUI Completo
-   [x] Crear el script lanzador `cyborg_tui.sh` que:
    -   [x] Acepte **parámetros por línea de comandos** (Nombre de Auditor, IP Objetivo).
    -   [x] Verifique dependencias.
    -   [x] Cree la estructura de directorios y archivos de comunicación.
    -   [x] Construya la sesión `tmux` de 5 paneles y lance cada script en su panel correspondiente.
-   [x] Crear los scripts `panel_visor_*.sh` faltantes.

### ✅ Hito 5: Implementación del Sistema de IA Híbrido
*Esta fase introduce una IA estratégica de "doble capa" para un razonamiento más profundo.*
-   [x] **IA Estratégica (Manual):**
    -   [x] Integración nativa con la herramienta `gemini-cli` de Kali, reemplazando la implementación manual con `curl`.
    -   [x] Añadir una opción al panel de control para que el auditor pueda invocar manualmente esta función.
-   [x] **IA Táctica (Automática):**
    -   [x] Reemplazar la llamada simulada a Ollama en `run_cyborg_fusion_analysis` con una **llamada real** para hacer el bucle de retroalimentación inteligente y autónomo.

### ✅ Hito 6: Implementación del Anonimizador de Consultas IA
*Asegura la confidencialidad de los datos del cliente al interactuar con APIs online.*
-   [x] **Filtro de Abstracción:**
    -   [x] Crear la función `run_cyborg_generate_anonymous_query` que utiliza Ollama para transformar datos de auditoría sensibles en una pregunta técnica, general y anónima.
    -   [x] Modificar el flujo de consulta a la IA Estratégica para usar este filtro, garantizando que no se envíe información confidencial a servicios externos.

### ✅ Hito 7: Maduración y Expansión
-   [x] **RAG (Retrieval- Augmented Generation) para Comandos:**
    -   [x] Se ha creado una base de conocimiento de manuales de herramientas (`KB/manuals`).
    -   [x] Se ha implementado la función `_execute_task_with_rag` que utiliza los manuales para que la IA Táctica genere comandos de herramientas reales, seguros y fiables. Esto elimina por completo la simulación de comandos.
-   [x] **Activar la IA en la Generación de Informes:**
    -   [x] Reemplazado el resumen ejecutivo simulado con un **proceso híbrido de IA de dos pasos**:
        1.  La IA Estratégica (Gemini) genera un borrador de resumen ejecutivo anónimo y de alta calidad basado en todos los logs de la auditoría.
        2.  La IA Táctica (Ollama) "re-hidrata" este borrador, inyectando de forma segura los datos confidenciales (IPs, nombres) para producir el texto final del informe.
-   [x] **Invocación Automática de IA Estratégica:**
    -   [x] Desarrollar una lógica en la IA Táctica que le permita identificar cuándo un problema supera su capacidad y necesita "escalar" la consulta a la IA Estratégica automáticamente (usando el filtro anonimizador).

### ✅ Hito 8: Expansión de la Base de Conocimiento y Razonamiento Estratégico
-   [x] **Arquitectura de Conocimiento Expandido (AKE):**
    -   [x] Reestructurar el directorio `KB` para incluir subdirectorios temáticos: `frameworks`, `legal`, `intel`, `wordlists`, `exploits`.
    -   [x] Poblar la AKE con contenido inicial (resúmenes de MAGERIT, NIS2, lista de fuentes de inteligencia confiables, manuales de herramientas adicionales como GoBuster y WhatWeb).
-   [x] **Motor de Razonamiento Estratégico:**
    -   [x] Crear una nueva función `run_cyborg_strategic_analysis` en `lib_cyborg.sh`.
    -   [x] Esta función construirá un *mega-prompt* para la IA Estratégica, combinando un hallazgo técnico con contexto de la AKE (riesgos, legal, inteligencia).
    -   [x] La IA Estratégica utilizará su capacidad de búsqueda para consultar las fuentes de `intel` y proporcionar un análisis contextualizado y actualizado.
-   [x] **Integración en el Flujo de Trabajo:**
    -   [x] Mejorar la opción `[a]` del panel de control para permitir al auditor lanzar un análisis estratégico profundo sobre un hallazgo específico.

### ✅ Hito 9: Implementación del Motor de Explotación Inteligente (MEI)
-   [x] **Expansión de la Base de Conocimiento para Explotación:**
    -   [x] Crear una nueva base de conocimiento para payloads (`KB/payloads/`).
    -   [x] Poblar con payloads iniciales para vulnerabilidades comunes (SQLi).
    -   [x] Añadir manuales RAG para herramientas de análisis activo como `nikto` y `sqlmap`.
-   [x] **Lógica de Sondeo de Vulnerabilidades:**
    -   [x] Crear la función `run_cyborg_vulnerability_probe` que permite a la IA Táctica hipotetizar vulnerabilidades y generar comandos de sondeo seguros (ej. con `curl`) usando los payloads de la KB.
-   [x] **Integración en el Bucle de Retroalimentación:**
    -   [x] Actualizar `run_cyborg_fusion_analysis` para que la IA pueda sugerir tareas de sondeo (`SQL_INJECTION_PROBE`) o escaneos activos (`NIKTO_SCAN`).
    -   [x] Modificar el `panel_ejecutor.sh` para que pueda orquestar estas nuevas tareas complejas.

### ✅ Hito 10: Auditoría de Infraestructura y Análisis de Host
-   [x] **Flexibilidad Táctica:**
    -   [x] Implementar una selección de workflow interactiva al inicio de la auditoría, permitiendo al auditor elegir entre un análisis "Web" o de "Infraestructura".
-   [x] **Nuevo Workflow de Infraestructura:**
    -   [x] Crear un manual RAG para `ICMP_SCAN` (`nmap -sn`) para la detección de hosts.
    -   [x] Crear un manual RAG para `NSE_VULN_SCAN` (`nmap --script vuln`) para la detección de vulnerabilidades de sistema.
    -   [x] Crear una nueva función de orquestación `run_infra_audit_workflow` en `lib_cyborg.sh`.
-   [x] **Expansión de la Inteligencia de Infraestructura:**
    -   [x] Añadir nuevas vulnerabilidades a `taxonomia.yaml` (ej. `FTP_ANONYMOUS_LOGIN`, `SMB_MS17_010`).
    -   [x] Actualizar el prompt de la IA Táctica para que reconozca y pueda sugerir las nuevas tareas de infraestructura.

### ✅ Hito 11: Implementación del Framework de Armamento Dinámico (FAD)
*Este hito transforma a CYBorg de un simple usuario de herramientas a un forjador de armas digitales personalizadas.*
-   [x] **Generación de Herramientas sobre la Marcha:**
    -   [x] Crear una plantilla base para scripts NSE en la Base de Conocimiento (`KB/templates`).
    -   [x] **Refactorizar `run_dynamic_nse_probe` a una función genérica `run_dynamic_tool_generation` capaz de manejar múltiples tipos de herramientas (Nmap, Metasploit, etc.).**
    -   [x] Crear plantillas adicionales en la KB para otros tipos de script (ej. Metasploit Resource Scripts).
    -   [x] Añadir una nueva opción al panel de control para que el auditor pueda especificar la intención y la herramienta para la que desea generar una sonda/script.
    -   [x] Implementar un paso de **aprobación de seguridad obligatorio** donde el auditor debe revisar y aceptar el código generado antes de su ejecución.

### ✅ Hito 12: Módulo de Inteligencia Externa (MIE) y Conectividad OSINT
*Dota a CYBorg de la capacidad de consultar APIs de terceros para enriquecer el reconocimiento.*
-   [x] **Gestión Segura de Claves API:**
    -   [x] Crear un sistema para gestionar claves API de servicios externos (Shodan, HIBP, etc.) de forma segura, sin hardcodearlas.
-   [x] **Orquestador de Consultas OSINT:**
    -   [x] Desarrollar una función `run_osint_query` en la librería que pueda interactuar con diferentes APIs externas.
-   [x] **Integración en la Interfaz de Usuario:**
    -   [x] Añadir opciones en el panel de control para que el auditor pueda lanzar consultas OSINT específicas contra el objetivo.
-   [x] **Fusión de Datos OSINT:**
    -   [x] Implementar la lógica para que la IA Táctica parsee las respuestas JSON de las APIs y las convierta en hallazgos estandarizados.

### ✅ Hito 13: Motor de Análisis del Lado del Cliente (MALC)
*Permite a CYBorg analizar el código fuente del lado del cliente (HTML, JS, CSS) en busca de vulnerabilidades.*
-   [x] **Recolector de Código Fuente:**
    -   [x] Implementar una función en `lib_cyborg.sh` que use `curl` para descargar el contenido de una URL proporcionada.
-   [x] **Motor de Análisis Estático con IA:**
    -   [x] Crear una función que envíe el código fuente recolectado a la IA Estratégica (Gemini) con un prompt especializado en la detección de secretos, endpoints, librerías vulnerables y fugas de información.
-   [x] **Integración en la Interfaz de Usuario:**
    -   [x] Añadir una nueva opción en el panel de control para que el auditor pueda iniciar un análisis de código de una URL específica.

### ✅ Hito 14: Motor de Interacción y Análisis Dinámico (MIAD)
*Utiliza un navegador headless (Puppeteer) controlado por IA para realizar análisis de seguridad dinámicos (DAST).*
-   [x] **Generación de Scripts de Interacción:**
    -   [x] Crear una función que tome una intención en lenguaje natural del auditor y use la IA Estratégica (Gemini) para generar un script de Puppeteer.
-   [x] **Ejecución de Scripts Puppeteer:**
    -   [x] Implementar una función wrapper en `lib_cyborg.sh` para ejecutar de forma segura los scripts de Puppeteer generados, capturando evidencias como capturas de pantalla y snapshots del DOM.
-   [x] **Análisis de Evidencias Dinámicas:**
    -   [x] Crear un bucle de retroalimentación donde las evidencias recolectadas (ej. HTML de una página de error) puedan ser re-analizadas por otros módulos (como el MALC o la IA Táctica).
-   [x] **Integración en la Interfaz y Dependencias:**
    -   [x] Añadir la opción de análisis dinámico al panel de control.
    -   [x] Actualizar el script de inicio para verificar las dependencias `node` y `puppeteer`.
-   [x] **Integración del Bucle de Retroalimentación MIAD->MALC:**
    -   [x] Refinamiento para que las evidencias del MIAD (snapshots DOM) sean analizadas automáticamente por el MALC.

### ✅ Hito 15: Profesionalización del Ecosistema de Informes y Auditoría
*Eleva a CYBorg de una herramienta de análisis a una plataforma de auditoría completa.*
-   [x] **Generación de Informes Duales (Cliente y Técnico):**
    -   [x] Implementar la creación de un informe técnico detallado en Markdown (`informe_tecnico_auditoria.md`) junto con el informe HTML del cliente.
    -   [x] El informe técnico contendrá todos los logs de la sesión, razonamiento de la IA, evidencias y consultas externas para una trazabilidad completa.
-   [x] **Funcionalidades Post-Procesamiento (Traducción, Envío):**
    -   [x] Añadir opciones de menú y funciones (placeholder) para traducir el informe del cliente y enviarlo por email, incluyendo la firma de integridad hash.
-   [x] **Personalización y Anotación del Auditor:**
    -   [x] Ampliar la configuración inicial para incluir el nombre de la empresa y técnicos adicionales.
    -   [x] Implementar un sistema para añadir anotaciones del auditor que se reflejan en los informes.
    -   [x] Añadir un interruptor de configuración para incluir notas de remediación en los hallazgos.
-   [x] **Módulo de Consulta en Caliente y Control de Verbosidad:**
    -   [x] Crear una nueva opción interactiva para que el auditor pueda realizar preguntas a la IA Estratégica en cualquier momento de la auditoría.
    -   [x] Añadir un control para gestionar la verbosidad de las respuestas de la IA.

### ✅ Hito 16: Persistencia Centralizada y Motor de Análisis de Inteligencia (MAIN)
*Dota a CYBorg de memoria a largo plazo, permitiendo el análisis de tendencias y la correlación de datos entre auditorías.*
-   [x] **Base de Datos de Inteligencia:**
    -   [x] Implementar la creación y gestión de una base de datos `sqlite3` central (`cyborg_intelligence.db`) para almacenar los resultados clave de todas las auditorías.
-   [x] **Persistencia de Hallazgos:**
    -   [x] Modificar los flujos de generación de hallazgos (IA, OSINT, manual) para que persistan automáticamente cada nuevo descubrimiento en la base de datos central, además de en el log de la sesión.
-   [x] **Interfaz de Consulta en Lenguaje Natural:**
    -   [x] Crear una nueva función `run_main_intelligence_query` que utiliza la IA Estratégica para traducir preguntas del auditor en lenguaje natural (ej: "mostrarme todos los hallazgos críticos de este mes") en consultas SQL válidas para la base de datos.
-   [x] **Integración en la Interfaz de Usuario:**
    -   [x] Añadir una nueva opción al panel de control que permita al auditor acceder al MAIN para realizar consultas sobre el histórico de inteligencia de la plataforma.

### ✅ Hito 17: Arquitectura de Datos Segregada (Hub-and-Spoke)
*Refactoriza la persistencia de datos para garantizar la seguridad y la compartimentación de la información sensible del cliente.*
-   [x] **Segregación de Bases de Datos:**
    -   [x] La base de datos central `cyborg_intelligence.db` (Hub) se modifica para almacenar únicamente metadatos anónimos y estadísticos (IDs de taxonomía, severidades, timestamps).
    -   [x] Se crea una nueva base de datos local `audit_findings.db` (Spoke) dentro de cada directorio de sesión para almacenar los detalles completos y sensibles de los hallazgos de esa auditoría específica.
-   [x] **Lógica de Persistencia Dual:**
    -   [x] La función `_persist_finding_to_db` se actualiza para realizar una doble escritura: el hallazgo detallado en la BD local y el hallazgo anonimizado en la BD central.
-   [x] **Ajuste del Motor de Consulta (MAIN):**
    -   [x] La función `run_main_intelligence_query` se ajusta para que el prompt de generación de SQL refleje el nuevo esquema anónimo de la base de datos central, asegurando que las consultas se mantengan a nivel de inteligencia de tendencias.

### ✅ Hito 18: Arquitectura Distribuida (Orquestador/Worker)
*Transforma CYBorg en un sistema de auditoría distribuido, capaz de orquestar múltiples nodos de ejecución.*
-   [x] **Introducción de Roles:**
    -   [x] Implementar un selector de rol al inicio (`Standalone`, `Orquestador`, `Worker`).
    -   [x] Crear un modo `Worker` que espera conexiones SSH sin lanzar la TUI completa.
-   [x] **Comunicación Segura y Gestión de Workers:**
    -   [x] Utilizar `ssh` y `scp` para la ejecución remota de tareas y la transferencia de evidencias.
    -   [x] Añadir un sistema de gestión de workers a través de un archivo `workers.conf` y un nuevo menú en el panel de control.
-   [x] **Refactorización del Motor de Ejecución para Distribución:**
    -   [x] Modificar las funciones de ejecución de tareas (`_execute_task_with_rag`, etc.) para que puedan delegar el trabajo a un worker remoto en lugar de ejecutarlo localmente.
-   [x] **Visualización y Logging del Clúster:**
    -   [x] Crear un nuevo `panel_visor_cluster.sh` para mostrar la actividad de distribución de tareas en tiempo real.
    -   [x] Lanzar el `panel_ejecutor.sh` en una ventana oculta de `tmux`, convirtiéndolo en un verdadero demonio orquestador.

### ✅ Hito 19: Maduración del Clúster y Resiliencia Operativa
*Solidifica la arquitectura distribuida, haciéndola más robusta, inteligente y fácil de gestionar.*
-   [x] **Health Checks y Estado de Workers:**
    -   [x] Implementar una función que verifique periódicamente la salud de los workers (carga de CPU, memoria, conectividad) y muestre su estado en la TUI.
-   [x] **Balanceo de Carga Inteligente:**
    -   [x] Mejorar `_get_next_worker` para que, en lugar de un simple round-robin, pueda seleccionar el worker con menos carga o más adecuado para una tarea específica.
-   [x] **Gestión de Fallos y Re-asignación de Tareas:**
    -   [x] Desarrollar una lógica que detecte si un worker falla durante una tarea y la re-asigne automáticamente a otro nodo disponible.
-   [x] **Sincronización de Recursos del Clúster:**
    -   [x] Crear un mecanismo para sincronizar recursos compartidos (ej. wordlists, scripts FAD) entre todos los nodos del clúster de forma automática.

### 🔲 Hito 20: Ingestión de Datos Externos y Modularidad de IA
*Dota a CYBorg de la capacidad de analizar información preexistente y adaptarse a diferentes proveedores de IA.*
-   [ ] **Framework de Ingestión de Datos:**
    -   [ ] Desarrollar un componente de UI de "Explorador de Archivos" para la TUI.
    -   [ ] Implementar funciones de `lib_cyborg.sh` para extraer texto de archivos `.pdf`, `.html` y `.md`.
-   [ ] **Pipeline de Procesamiento de Datos:**
    -   [ ] Crear una función que utilice la IA Táctica (Ollama) para anonimizar el texto extraído, eliminando PII (IPs, dominios, nombres de usuario) antes de cualquier análisis posterior.
    -   [ ] Integrar el texto anonimizado en la base de conocimiento de la sesión actual para ser usado como contexto por las IAs.
-   [ ] **Refactorización del Backend de IA:**
    -   [ ] Abstraer las llamadas a `gemini-cli` y `ollama` en funciones wrapper genéricas (ej. `_query_strategic_ia`, `_query_tactical_ia`).
    -   [ ] Implementar un sistema de configuración en `audit_state.conf` para definir qué IA usar (ej. `STRATEGIC_AI_PROVIDER=GEMINI`, `AI_MODE=HYBRID/LOCAL_ONLY`).
    -   [ ] Desarrollar el diálogo de UI para que el auditor pueda cambiar estas configuraciones desde el menú.

---

## 3. Roadmap de Implementación de la TUI (Cyber Commander)

**Análisis Estratégico:** El backend ha alcanzado una madurez funcional significativa, pero la TUI actual es un simple esqueleto no funcional. Esta parálisis impide el testeo, la depuración y la utilización de las capacidades ya desarrolladas. Esta nueva fase del plan se centra en construir la interfaz de usuario profesional descrita en `Proyecto/diseno_y_ux.md`, conectándola con el backend existente para dar vida al proyecto.

### Arquitectura Visual de Paneles (Vista por Defecto)
La TUI se estructurará siguiendo un layout de `tmux` específico para maximizar la visibilidad y el control. La numeración de paneles es la siguiente:

- **Panel 0 (Título):** Ocupa todo el ancho superior (4 filas). Muestra el título de la aplicación y un botón de opciones.
- **Panel 1 (Control):** Ubicado debajo del título, en la columna izquierda (ocupa 2/3 del ancho y 7 filas de alto).
- **Panel 2 (Gestión de Tareas y Nodos):** Debajo del panel 1, en la mitad izquierda de la división inferior.
- **Panel 3 (Hallazgos de Seguridad):** Debajo del panel 1, en la mitad derecha de la división inferior.
- **Panel 4 (Razonamiento IA - MAGERIT):** Ocupa el 1/3 derecho de la pantalla, en la mitad superior.
- **Panel 5 (Registro de Actividad):** Ocupa el 1/3 derecho de la pantalla, en la mitad inferior.

Esta estructura permite la conmutación y el intercambio de paneles. Por ejemplo, los paneles 2 y 3 pueden ser reemplazados por un único panel de diálogo para configuraciones avanzadas o el asistente de inicio. Todos los procesos en los paneles no visibles deben continuar su ejecución sin interrupción.

### 🔲 Hito 21: El Esqueleto Funcional (Header, Footer y Layout Base)
*Establece la estructura visual fundamental de la TUI, proporcionando un "lienzo" persistente para la información y las acciones.*
-   [ ] **Crear el Panel de Cabecera:** Desarrollar `_panel_header.sh` que muestre información global persistente (Objetivo, Auditor, Modo).
-   [ ] **Crear el Panel de Pie de Página:** Desarrollar `_panel_footer.sh` que muestre los atajos de teclado globales (F-Keys).
-   [ ] **Refactorizar el Layout por Defecto:** Modificar `layouts/default.sh` para que cree una estructura vertical de 3 filas (Header, Cuerpo, Footer) y coloque la disposición de paneles existente en la fila del "Cuerpo".
-   [ ] **Actualizar el Renderizador de Control:** Modificar `render_control_panel` para eliminar la información redundante que ahora se mostrará en la cabecera, simplificando su contenido.

### 🔲 Hito 22: El Corazón Visual (Paneles Dinámicos y Vistas Conmutables)
*Implementa la capacidad de cambiar el enfoque de la TUI para adaptarse a diferentes tareas, reduciendo la sobrecarga cognitiva del operador.*
-   [ ] **Crear Layouts de Vista:** Desarrollar los scripts de layout para cada vista definida en el diseño: `analisis_hallazgos.sh` y `gestion_cluster.sh`.
-   [ ] **Implementar el Mecanismo de Cambio de Vista:** Añadir lógica a `panel_control.sh` para capturar la tecla `F3`.
-   [ ] **Crear el Script de Cambio de Vista:** Desarrollar un script `_switch_view.sh` que, dado un nombre de vista, reconfigure los paneles de la ventana actual para que coincidan con el layout de esa vista sin matar la sesión de `tmux`.
-   [ ] **Actualizar Visores:** Asegurar que los paneles visores (`_visor_*`) sean compatibles con su uso en diferentes layouts.

### 🔲 Hito 23: La Interfaz Viva (Menús y Acciones)
*Conecta las acciones del usuario en la TUI con el backend, permitiendo el control total de la aplicación desde la interfaz.*
-   [ ] **Implementar el Menú Principal (F2):** Desarrollar en `panel_control.sh` un diálogo de menú interactivo **utilizando `gum choose`** que muestre todas las opciones del `diseno_y_ux.md`.
-   [ ] **Mapeo de Acciones a Comandos:** Implementar la lógica para que cada opción del menú (y atajos de teclado directos) envíe un comando formateado y específico al `comandos.pipe`.
-   [ ] **Expandir el Orquestador:** Modificar `panel_ejecutor.sh` para que entienda y pueda procesar la nueva gama de comandos provenientes del menú (ej: `OSINT_QUERY:SHODAN`, `GENERATE_REPORT`, `MAIN_QUERY:'...'`).
-   [ ] **Feedback al Usuario:** Implementar el uso de `tmux display-message` para dar confirmación instantánea de las acciones solicitadas.

### 🔲 Hito 24: La Inteligencia Interactiva (Diálogos y Formularios)
*Construye los componentes de UI más complejos que requieren entrada de datos estructurada por parte del auditor.*
-   [ ] **Desarrollar el Explorador de Archivos:** Crear un script que presente una interfaz navegable del sistema de ficheros para cumplir con los requisitos del **Hito 20**.
-   [ ] **Construir el Diálogo de Configuración de IA:** Crear un script que lea la configuración de `audit_state.conf`, la presente en un formulario y guarde los cambios, cumpliendo con los requisitos del **Hito 20**.
-   [ ] **Implementar Prompts de Entrada Genéricos:** Crear una función en `lib_cyborg.sh` que **utilice `gum input` y `gum write`** para solicitar cualquier tipo de entrada de texto del usuario (ej: para añadir un hallazgo manual o una anotación).

### 🔲 Hito 25: Pulido y Ergonomía
*Añade las características de "calidad de vida" que distinguen a una herramienta profesional de un prototipo funcional.*
-   [ ] **Guardado de Layouts de Panel:** Implementar la funcionalidad para que el usuario pueda guardar su disposición de paneles actual como un nuevo archivo de layout personalizado.
-   [ ] **Mejorar el Feedback Visual:** Implementar spinners de actividad **(con `gum spin`)**, barras de progreso **(con `gum progress`)** y temporizadores como se define en el catálogo de identidades visuales.
-   [ ] **Ayuda Contextual (F1):** Desarrollar un panel o diálogo que muestre una ayuda sobre los comandos disponibles y el uso de la aplicación.
-   [ ] **Revisión de Usabilidad:** Realizar una revisión completa de los flujos de trabajo desde la perspectiva del usuario para identificar y eliminar puntos de fricción.

---

## 4. Registro de Decisiones y Aprendizajes Clave

1.  **Decisión:** Se utiliza un *named pipe* (`comandos.pipe`) como cola de tareas (FIFO).
2.  **Aprendizaje:** El `panel_ejecutor.sh` usaba `awk` para parsear la taxonomía; se reemplazó por una IA (simulada) más robusta.
3.  **Decisión:** El desarrollo priorizó la lógica de IA (Hito 1) sobre la TUI completa (Hito 4).
4.  **Decisión:** El lanzador `cyborg_tui.sh` debe aceptar parámetros de línea de comandos, no ser interactivo.
5.  **Decisión:** La ingestión de XML se realiza con `xsltproc` por su robustez y separación de lógica.
6.  **Decisión Estratégica:** Se adopta un modelo de **IA Híbrida**. Una IA Táctica (local, rápida) para el control del flujo y una IA Estratégica (online, potente) para análisis profundos, legales y de contexto.
7.  **Decisión Arquitectónica:** Se prioriza el uso de herramientas nativas del sistema (`gemini-cli`) sobre implementaciones manuales (`curl`) para interactuar con APIs externas, mejorando la robustez y la seguridad.
8.  **Decisión de Seguridad:** Se implementa un "filtro anonimizador" (`run_cyborg_generate_anonymous_query`) para proteger la confidencialidad del cliente, asegurando que ninguna información sensible sea enviada a APIs externas.
9.  **Decisión de Arquitectura de Datos (CRÍTICA):** Tras identificar un riesgo de fuga de información, se abandona el modelo de base de datos única en favor de una **arquitectura Hub-and-Spoke**. Esto segrega los datos sensibles (en BDs locales por auditoría) de los datos de inteligencia anónima (en una BD central), garantizando la confidencialidad del cliente.
10. **Decisión de Escalabilidad:** Se adopta una **arquitectura distribuida Orquestador/Worker** basada en SSH para permitir la ejecución de auditorías en clúster, mejorando la velocidad y la capacidad para operaciones complejas.
11. **Decisión de Profesionalización de IA:** Se adopta el uso del fichero `gemini.md` para establecer una personalidad y un contexto persistentes para la IA Estratégica. Esto mejora la consistencia y la calidad de las respuestas. Se migra la recomendación de configuración hacia perfiles de usuario (`gemini pro login`) para mejorar la seguridad.
12. **Decisión de Arquitectura de IA:** Se centraliza la ejecución de `gemini-cli` en una función wrapper (`_run_gemini_cli`) que carga automáticamente el fichero de contexto `gemini.md`. Esto permite enriquecer el contexto de la IA (ej. con fuentes de inteligencia) y simplificar los prompts en el resto del código, mejorando la mantenibilidad y la calidad de las interacciones.
13. **Decisión de Toolkit TUI:** Se adopta **`gum` (de Charm.sh)** como la librería principal para la creación de componentes de TUI interactivos (menús, diálogos, spinners, etc.) debido a su estética moderna y facilidad de integración. Se mantiene `whiptail` como una alternativa de contingencia por su robustez y disponibilidad universal en sistemas base.

---

## 5. Próximos Pasos Inmediatos

**El proyecto ha pivotado para centrarse en la construcción de la interfaz de usuario.** El desarrollo del backend queda en pausa hasta que la TUI sea funcional y pueda servir como una plataforma estable para nuevas características.

1.  **Implementar el Hito 21:** La prioridad absoluta es construir el **esqueleto funcional de la TUI**. Esto desbloqueará el desarrollo visual y permitirá empezar a conectar el backend.
2.  **Avanzar secuencialmente por los Hitos de la TUI (22-25):** Una vez que el esqueleto esté en su lugar, procederemos a implementar las vistas, los menús interactivos y los diálogos avanzados en orden.
3.  **Integrar Backend con Frontend:** A medida que se construyan los componentes de la TUI, se conectarán a las funciones del backend ya existentes (`lib_cyborg.sh`).