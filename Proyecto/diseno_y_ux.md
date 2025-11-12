# Guía de Diseño y Experiencia de Usuario (UX) para CYBorg TUI

Este documento establece los principios de diseño, la identidad visual y las directrices de experiencia de usuario para la Terminal User Interface (TUI) de CYBorg v2.5. Su objetivo es garantizar una experiencia coherente, intuitiva y profesional para el auditor de seguridad.

---

## 1. Filosofía de Diseño: "Clarity in Chaos"

La auditoría de seguridad es inherentemente compleja. La TUI de CYBorg no debe añadir complejidad, sino aportar claridad. Cada elemento visual y cada interacción deben estar diseñados para reducir la carga cognitiva del operador, permitiéndole centrarse en el análisis y la toma de decisiones, no en descifrar la interfaz.

**Principios Clave:**
- **Claridad sobre Densidad:** Es mejor mostrar la información correcta de forma clara que toda la información posible de forma densa.
- **Feedback Constante:** El usuario siempre debe saber qué está haciendo el sistema, especialmente durante tareas largas.
- **Eficiencia del Teclado:** La TUI está optimizada para el uso sin ratón. Los atajos de teclado deben ser intuitivos y consistentes.
- **Contexto Ampliado:** La plataforma debe ser capaz de ingerir y razonar sobre información externa, no limitarse únicamente a los datos que genera.

---

## 2. Identidad Visual

### Logo Oficial (ASCII Art)

El logo debe usarse en pantallas de bienvenida o en cabeceras importantes para reforzar la marca de la herramienta.

```
  _______  __   __  _______  ______    _______  ______
 |       ||  | |  ||       ||    _ |  |   _   ||      |
 |  _____||  |_|  ||    ___||   | ||  |  |_|  ||  _    |
 | |_____ |       ||   |___ |   |_||_ |       || | |   |
 |_____  ||       ||    ___||    __  ||       || |_|   |
  _____| ||   _   ||   |___ |   |  | ||   _   ||       |
 |_______||__| |__||_______||___|  |_||__| |__||______|
                  v2.5 - Strategic Pentesting AI
```

### Paleta de Colores

La paleta de colores está definida en `lib_cyborg.sh` y tiene un significado semántico que debe respetarse en toda la TUI.

- **CYAN (`C_CYAN`):** Títulos, cabeceras, elementos de UI importantes y prompts de usuario. Denota estructura y guía.
- **GREEN (`C_GREEN`):** Éxito, confirmaciones, estado "OK", hallazgos positivos (en el sentido de encontrados). Denota progreso y resultados.
- **YELLOW (`C_YELLOW`):** Advertencias, solicitudes de entrada, información importante que requiere atención. Denota precaución.
- **RED (`C_RED`):** Errores, fallos críticos, acciones destructivas, hallazgos de alta severidad. Denota peligro y urgencia.
- **MAGENTA (`C_MAGENTA`):** Razonamiento de la IA Táctica (Ollama). Denota inteligencia local y análisis de bajo nivel.
- **BLUE (`C_BLUE`):** Razonamiento de la IA Estratégica (Gemini). Denota inteligencia profunda y análisis de alto nivel.
- **WHITE / BOLD (`C_WHITE`, `C_BOLD`):** Texto estándar, datos clave.
- **GRAY (`C_GRAY`):** Información secundaria, timestamps, separadores, texto de ayuda. Denota contexto y baja prioridad.

---

## 3. Arquitectura de la TUI: El Paradigma "Cyber Commander"

Inspirada en la ergonomía y eficiencia de gestores de terminal como Midnight Commander (`mc`), la TUI de CYBorg adoptará una estructura de tres zonas para maximizar la claridad y el control.

1.  **Cabecera (Barra Superior):** Una línea persistente en la parte superior de la ventana de `tmux` que muestra el estado global de la auditoría.
2.  **Cuerpo Principal (Paneles Dinámicos):** El área de trabajo principal, compuesta por múltiples paneles. Esta área puede cambiar su disposición (Vistas) para adaptarse a la tarea actual del auditor.
3.  **Pie de Página (Barra de Acciones):** Una línea persistente en la parte inferior que muestra los atajos de teclado más comunes (F-keys), proporcionando una guía constante y acelerando la interacción.

---

## 4. Catálogo de Identidades Visuales (Componentes de UI)

Esta sección define cómo se debe representar cada pieza de información en la TUI.

### 4.1. Tareas (Jobs & Tasks)
Representan cualquier acción ejecutada por el sistema, ya sea localmente o en un worker.

-   **Estados y Representación:**
    -   `[·] ENCOLADA`: (Gris) La tarea está en la cola, esperando a ser procesada.
    -   `[»] EN PROGRESO`: (Amarillo) La tarea está siendo ejecutada activamente.
    -   `[+] PROCESANDO DATOS`: (Cian) El sistema está ingiriendo y analizando un fichero externo.
    -   `[] DELEGADA`: (Cian) La tarea ha sido asignada a un worker remoto.
    -   `[] COMPLETADA`: (Verde) La tarea finalizó con éxito.
    -   `[] FALLIDA`: (Rojo) La tarea terminó con un error.

-   **Formato en Listas:** `[ESTADO] [ID_TAREA] NOMBRE_TAREA -> Worker (local | user@ip) [PROGRESO] (Tiempo Transcurrido)`

### 4.2. Hallazgos de Seguridad (Findings)
El componente más crítico. Debe ser denso en información pero fácil de escanear. Tendrá un estado expandido y colapsado.

-   **Ciclo de Vida y Representación:**
    -   `[?] HIPÓTESIS`: (Gris) La IA Táctica ha sugerido una posible vulnerabilidad.
    -   `[!] VULNERABLE`: (Amarillo) La vulnerabilidad ha sido confirmada por una sonda o análisis.
    -   `[🛡️] VERIFICADO`: (Verde) El auditor ha verificado manually el hallazgo y ha adjuntado evidencia.
    -   `[] MITIGADO`: (Azul) Se ha aplicado o sugerido una remediación.

-   **Formato Colapsado (en listas):** `[ESTADO] [SEVERIDAD] ID_TAXONOMÍA: Descripción breve...`
    -   Severidad: [Baja], [Media], [Alta], [Crítica] con sus respectivos colores.

-   **Formato Expandido (en panel de detalle):**
    ```
    ┌─ HALLAZGO: SQL_INJECTION_VULNERABLE ───────────────────────────────┐
    │ Estado: [!] VULNERABLE   Severidad: [Alta]                         │
    ├─ DESCRIPCIÓN ──────────────────────────────────────────────────────┤
    │ Se ha detectado un punto de entrada vulnerable a Inyección SQL en  │
    │ el parámetro 'id' del endpoint /api/users.                         │
    ├─ ANÁLIS DE RIESGO (MAGERIT) ──────────────────────────────────────┤
    │ Activo Afectado: [D.db] (Base de datos)                            │
    │ Amenaza: [A.12] Modificación no autorizada de la información       │
    │ Impacto Estimado: Alto                                             │
    ├─ CONTEXTO LEGAL/NORMATIVO ──────────────────────────────────────────┤
    │ NIS2: Incumplimiento potencial de "medidas técnicas apropiadas".   │
    ├─ REMEDIACIÓN SUGERIDA (IA) ─────────────────────────────────────────┤
    │ Implementar consultas parametrizadas (prepared statements) para... │
    ├─ EVIDENCIAS ────────────────────────────────────────────────────────┤
    │ └──  evidence_miad/sqli_proof_20240815.txt                      │
    └────────────────────────────────────────────────────────────────────┘
    ```

### 4.3. Nodos Worker (Cluster Nodes)
Solo relevante en modo Orquestador.

-   **Estados y Representación:**
    -   `[] CONECTADO`: (Verde) El worker está en línea y disponible.
    -   `[⚙️] OCUPADO`: (Amarillo) El worker está ejecutando una tarea.
    -   `[?] DESCONECTADO`: (Rojo) No se puede contactar con el worker.
    -   `[] ERROR`: (Rojo) El worker ha reportado un error en la última tarea.

-   **Formato en Listas:** `[ESTADO] user@ip_worker | Tareas: N | CPU: XX% | RAM: YY%`

### 4.4. Diálogos Interactivos
Ventanas emergentes que se superponen a los paneles para la entrada del usuario. **Se implementarán utilizando el toolkit `gum` para una estética profesional y moderna.**

-   **Prompt de Entrada:** Un cuadro con un borde claro para solicitar texto. (Implementación: `gum input`).
-   **Confirmación:** Un diálogo con opciones `[ Sí ]` / `[ No ]`. (Implementación: `gum confirm`).
-   **Menú de Opciones:** Una lista numerada de opciones seleccionables. (Implementación: `gum choose`).
-   **Explorador de Archivos TUI:** Un diálogo a pantalla completa o en un panel grande que permite navegar por el sistema de archivos local para seleccionar un documento (`.html`, `.pdf`, `.md`) para su importación. Se controla con las flechas y la tecla `Enter`. (Implementación: `gum file`).
-   **Diálogo de Configuración de IA:** Un formulario para ajustar el comportamiento de los LLMs.
    ```
    ┌─ CONFIGURACIÓN DE INTELIGENCIA ARTIFICIAL ────────────────────────┐
    │                                                                   │
    │ Modo de IA: [ Híbrido (Local + Online) ▼]                          │
    │                                                                   │
    │ IA Estratégica (Online): [ Gemini (gemini-2.5-flash) ▼]            │
    │                                                                   │
    │ IA Táctica (Local): [ Ollama (llama3:8b) ] (automático)            │
    │                                                                   │
    │       [ Guardar ]                  [ Cancelar ]                   │
    └───────────────────────────────────────────────────────────────────┘
    ```

### 4.5. Widgets de Barra de Estado
Elementos para el pie de página o para indicar progreso.

-   **Barra de Progreso:** `[██████----] 60%` (Implementación: `gum progress`).
-   **Spinner de Actividad:** Un caracter que rota (`/`, `-`, `\`, `|`) para mostrar que el sistema está pensando. (Implementación: `gum spin`).
-   **Temporizador:** `(01m 32s)` (Implementación: Script `bash` personalizado).

---

## 5. Diseño de Vistas Conmutables

Para evitar la sobrecarga de información, la TUI tendrá varias "Vistas" predefinidas. El usuario podrá cambiar entre ellas con una tecla (`F3`).

### Vista 1: Mando y Control (Por Defecto)
- **Layout:** Similar al actual. Un panel grande a la izquierda para el **Control** y tres paneles más pequeños a la derecha.
- **Contenido de Paneles:**
    - **Izquierda:** `panel_control.sh` (Menú interactivo).
    - **Superior Derecha:** `Registro de Actividad` (Tareas locales y delegadas, mezcladas y ordenadas por tiempo).
    - **Medio Derecha:** `Razonamiento IA` (Logs de IA Táctica y Estratégica).
    - **Inferior Derecha:** `Hallazgos Recientes` (Muestra los últimos 5 hallazgos, en formato colapsado).

### Vista 2: Análisis de Hallazgos
- **Layout:** Dos paneles verticales (50%/50%).
- **Contenido de Paneles:**
    - **Izquierda:** `Lista de Hallazgos` (Todos los hallazgos de la sesión, en formato colapsado. Se puede navegar por la lista).
    - **Derecha:** `Detalle del Hallazgo` (Muestra la vista expandida del hallazgo seleccionado en el panel izquierdo).

### Vista 3: Gestión del Clúster (Solo modo Orquestador)
- **Layout:** Dos paneles verticales (40%/60%).
- **Contenido de Paneles:**
    - **Izquierda:** `Lista de Workers` (Muestra todos los nodos, su estado y métricas).
    - **Derecha:** `Log de Actividad del Clúster` (Muestra un log filtrado solo con tareas delegadas, transferencias y comunicaciones entre nodos).

---

## 6. Diseño de Menús y Acciones

### Barra de Acciones (Pie de Página - F-Keys)
`[F1 Ayuda] [F2 Menú] [F3 Vista] [F5 Analizar] [F9 Opciones] [F10 Salir]`

### Menú Principal (Accesible con F2)
Un diálogo interactivo que presenta todas las capacidades de la aplicación.

```
┌─ MENÚ PRINCIPAL ────────────────────────────────────────────────────────┐
│ 1. Auditoría                                                          │
│    -> Añadir Hallazgo Manual...                                         │
│    -> Añadir Anotación de Auditor...                                    │
│    -> Parar/Reanudar Tareas Automáticas                                 │
│                                                                       │
│ 2. Análisis                                                           │
│    -> [a] Análisis Estratégico Profundo... (sobre un hallazgo)          │
│    -> [o] Consultas OSINT (MIE)...                                      │
│    -> [c] Análisis Lado Cliente (MALC)...                               │
│    -> [d] Interacción Dinámica (MIAD)...                                │
│    -> [g] Generar Sonda Dinámica (FAD)...                               │
│                                                                       │
│ 3. Gestión de Datos                                                   │
│    -> Importar Evidencia Externa (PDF, HTML, MD)...                     │
│                                                                       │
│ 4. Informes                                                           │
│    -> [g] Generar Informes (Cliente y Técnico)                        │
│    -> Traducir Informe...                                               │
│    -> Enviar Informe por Email...                                       │
│                                                                       │
│ 5. Inteligencia (MAIN)                                                │
│    -> Consultar Base de Datos Central...                                │
│                                                                       │
│ 6. Sistema                                                            │
│    -> [w] Gestión de Workers (Cluster)                                  │
│    -> Opciones de Configuración (IA, etc.)...                           │
│    -> Guardar Layout de Paneles...                                      │
└─────────────────────────────────────────────────────────────────────────┘
```