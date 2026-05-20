# 📋 Diario de Desarrollo — Dashboard CalBlay

Este documento registra paso a paso todo el proceso de creación del Dashboard analítico de CalBlay.
Cada sección explica **qué se hizo**, **por qué** y **cómo funciona** para que cualquier miembro del equipo pueda entender el proyecto.

---

## Fase 0: Preparación del Repositorio
**Fecha:** 9 de mayo de 2026

### Paso 0.1 — Sincronizar la rama `dev` con GitHub
- **Comando:** `git fetch origin && git pull origin dev`
- **¿Qué hace?** Descarga los últimos cambios que otros compañeros han subido a GitHub y los aplica a tu copia local. Teníamos 5 commits de retraso (nos faltaban las migraciones 12 y 13).
- **Resultado:** Se descargaron las migraciones `000012_update_seats_table` y `000013_create_waiter_zones`, además de actualizaciones en `seeds/seed.sql`.

### Paso 0.2 — Crear la rama de desarrollo del Dashboard
- **Comando:** `git checkout -b feature/dashboard-webapp`
- **¿Qué hace?** Crea una rama nueva llamada `feature/dashboard-webapp` a partir de `dev` y nos cambia a ella automáticamente. Así todo el código del dashboard queda aislado hasta que lo queramos unir (merge) a la rama principal.
- **¿Por qué una rama separada?** Porque si cometemos un error, no afecta al código estable de la base de datos que ya funciona. Es una buena práctica de Git.

---

## Fase 1: Inicialización del Proyecto Frontend
**Fecha:** 9 de mayo de 2026

### Paso 1.1 — Crear el proyecto con Vite + React
- **Comando:** `npx create-vite dashboard --template react --no-interactive`
- **¿Qué hace?** Utiliza la herramienta `create-vite` para generar automáticamente toda la estructura de carpetas y archivos necesarios para un proyecto React moderno. La opción `--template react` le dice que use la plantilla de React, y `--no-interactive` evita que nos haga preguntas durante la creación.
- **¿Qué es Vite?** Es el "motor" que convierte nuestro código React en algo que el navegador puede entender. Es extremadamente rápido y moderno (mucho más que alternativas antiguas como Webpack).
- **¿Qué es React?** Es una librería de JavaScript creada por Facebook que permite construir interfaces de usuario dividiéndolas en piezas reutilizables llamadas "Componentes" (como piezas de Lego).
- **Resultado:** Se creó la carpeta `dashboard/` con la estructura base del proyecto.

### Paso 1.2 — Instalar dependencias
- **Comando:** `npm install` (ejecutado dentro de la carpeta `dashboard/`)
- **¿Qué hace?** Lee el archivo `package.json` (que lista todas las librerías que necesita el proyecto) y las descarga de internet. Se guardan en una carpeta llamada `node_modules/`.
- **Resultado:** Se instalaron 136 paquetes en 11 segundos. Los avisos de "EBADENGINE" son solo advertencias menores sobre la versión de Node.js, no afectan al funcionamiento.

### Estructura de archivos generada:
```
dashboard/
├── node_modules/        ← Librerías descargadas (NO se sube a GitHub)
├── public/              ← Archivos estáticos (favicon, imágenes públicas)
├── src/                 ← 🔥 AQUÍ va TODO nuestro código
│   ├── App.jsx          ← Componente principal de la aplicación
│   ├── App.css          ← Estilos del componente App (lo vamos a reemplazar)
│   ├── main.jsx         ← Punto de entrada: monta React en el HTML
│   └── index.css        ← Estilos globales (lo vamos a reemplazar)
├── index.html           ← El archivo HTML base donde se "inyecta" React
├── package.json         ← Lista de dependencias y scripts del proyecto
├── vite.config.js       ← Configuración de Vite
└── eslint.config.js     ← Configuración del linter (revisa errores de código)
```

---

## Fase 2: Sistema de Diseño Premium
**Fecha:** 9 de mayo de 2026

### Paso 2.1 — Limpiar los archivos de ejemplo de Vite
- **¿Qué hicimos?** Eliminamos todo el código de ejemplo que trae Vite por defecto (logos giratorios, contadores, estilos predefinidos). Son solo demos y no nos sirven.
- **Archivos modificados:** `src/App.jsx`, `src/App.css`, `src/index.css`
- **Archivos eliminados:** `src/assets/react.svg`, `public/vite.svg`

### Paso 2.2 — Definir el sistema de diseño (Design System)
- **¿Qué es un Design System?** Es un conjunto de reglas de diseño definidas en un solo lugar (colores, tipografías, espaciados, sombras, etc.) que se reutilizan en toda la aplicación. Así nos aseguramos de que todo sea coherente y elegante.
- **Archivo:** `src/index.css`
- **Paleta de colores elegante elegida:**
  - Fondo principal: Azul-gris muy oscuro (`#0f1117`) → Transmite profesionalidad y elegancia
  - Superficies/Tarjetas: Gris oscuro con transparencia → Efecto "glassmorphism" (cristal esmerilado)
  - Color de acento principal: Violeta/Índigo (`#6366f1`) → Moderno y premium
  - Color secundario: Esmeralda (`#10b981`) → Para indicadores positivos
  - Color de alerta: Ámbar (`#f59e0b`) → Para advertencias
  - Color de peligro: Rosa/Rojo (`#ef4444`) → Para errores y alertas críticas
  - Texto: Blanco suave y grises → Legibilidad sobre fondo oscuro

### Paso 2.3 — Crear el Layout base del Dashboard
- **¿Qué es un Layout?** Es la estructura "esqueleto" de la página: la barra lateral de navegación (sidebar), la cabecera superior (header) y el área central donde irán las gráficas.
- **Componentes creados:**
  - `src/components/Sidebar.jsx` + `src/components/Sidebar.css` → Menú lateral de navegación
  - `src/components/Header.jsx` + `src/components/Header.css` → Barra superior con título y usuario
  - `src/App.jsx` + `src/App.css` → Contenedor principal que une sidebar + header + contenido

---

## Fase 3: Página de Alérgenos
**Fecha:** 9 de mayo de 2026

### ¿Por qué esta página es importante?
La normativa europea (Reglamento UE 1169/2011) obliga a todos los establecimientos de restauración a informar sobre la presencia de **14 alérgenos** en sus platos. Además de cumplir la ley, gestionar bien los alérgenos mejora la experiencia del cliente y previene riesgos sanitarios graves.

### Paso 3.1 — Investigar el esquema de la base de datos
- Antes de escribir código, revisamos las tablas existentes en la base de datos:
  - `allergens`: Los 14 alérgenos UE con código, nombre en 3 idiomas (ES/CA/EN) y número UE
  - `ingredient_allergens`: Relación ingrediente ↔ alérgeno con tipo de presencia (`contains`, `may_contain`, `traces`)
  - `comensal_allergens`: Qué alergias tiene cada comensal registrado
  - `recipe_allergens`: Qué alérgenos tiene cada receta
  - `allergen_alerts`: Alertas generadas cuando un comensal pide un plato con un alérgeno peligroso

### Paso 3.2 — Crear la página AllergensPage
- **Archivos creados:**
  - `src/pages/AllergensPage.jsx` → El componente React con toda la lógica y estructura
  - `src/pages/AllergensPage.css` → Los estilos visuales específicos de esta página

### Paso 3.3 — Contenido de la página (6 secciones)

#### Sección 1: KPIs de Alérgenos (4 tarjetas)
Reutilizamos el componente `StatCard` que ya teníamos. Muestra:
- **Alertas Activas:** Cuántas alertas de alérgenos están sin resolver ahora mismo
- **Comensales con Alergias Registradas:** Total de clientes que han declarado alguna alergia
- **Platos Libres de Top 4 Alérgenos:** Cuántos platos de la carta son seguros para los 4 alérgenos más comunes
- **Tasa de Resolución:** Porcentaje de alertas que se resolvieron correctamente (objetivo: 100%)

#### Sección 2: Los 14 Alérgenos de la UE
Una cuadrícula visual que muestra **cada alérgeno con su icono, nombre y número UE**, junto con la cantidad de comensales que lo han declarado. Están ordenados por frecuencia y coloreados por severidad (rojo = muy frecuente, amarillo = medio, verde = poco frecuente).

Los 14 alérgenos son:
1. 🌾 Gluten | 2. 🦐 Crustáceos | 3. 🥚 Huevos | 4. 🐟 Pescado
5. 🥜 Cacahuetes | 6. 🫘 Soja | 7. 🥛 Lácteos | 8. 🌰 Frutos de cáscara
9. 🥬 Apio | 10. 🟡 Mostaza | 11. ⚪ Sésamo | 12. 🍷 Sulfitos
13. 🌿 Altramuces | 14. 🦪 Moluscos

#### Sección 3: Mapa de Calor (Heatmap) Platos × Alérgenos
- **¿Qué es un Heatmap?** Es una tabla visual donde cada celda tiene un color que indica la intensidad de un valor. En nuestro caso: rojo = "Contiene" (C), amarillo = "Trazas" (T), gris = libre.
- **¿Para qué sirve?** La cocina y los camareros pueden consultar de un vistazo qué alérgenos tiene cada plato de la carta. Es como una "ficha técnica" visual de toda la carta.

#### Sección 4: Distribución de Presencia
Barras horizontales que muestran cuántos ingredientes de la carta "contienen", "pueden contener" o tienen "trazas" de alérgenos. Incluye un dato clave destacado.

#### Sección 5: Alternativas Sugeridas
Para cada plato que causa muchas alertas, se sugiere una alternativa sin esos alérgenos. Esto es **muy útil para los camareros**: cuando un cliente dice "soy intolerante al gluten", el camarero puede consultar esta tabla y recomendar al instante una alternativa segura.

#### Sección 6: Historial de Alertas
Tabla con el registro de las últimas alertas: cuándo ocurrieron, qué comensal, qué alérgeno, en qué mesa, y si se resolvió o sigue activa.

### Paso 3.4 — Conectar la página al sistema de navegación
- **Archivo modificado:** `src/App.jsx`
- Se añadió la importación de `AllergensPage` y un nuevo `case 'allergens'` en el `switch` de navegación
- Ahora al hacer clic en "Alérgenos" en el menú lateral, se carga automáticamente esta nueva página

---

## Fase 4: Página de Ventas
**Fecha:** 9 de mayo de 2026

### ¿Por qué esta página es importante?
El control financiero es la base de cualquier negocio de restauración. Esta página permite a la gerencia de CalBlay ver en tiempo real cuánto están facturando, qué platos generan más ingresos, y comparar el rendimiento de cada local.

### Paso 4.1 — Investigar las tablas de la BD relacionadas con ventas
- `orders` + `order_items` → Cada pedido y sus líneas (qué platos, cantidades)
- `menu_card_items` → Precio de cada plato en la carta
- `recipes` → Categoría del plato (entrante, primer_plato, segundo_plato, postre, bebida)
- `establishments` → Para desglosar ingresos por local

### Paso 4.2 — Archivos creados
- `src/pages/SalesPage.jsx` → Componente React con toda la lógica y datos simulados
- `src/pages/SalesPage.css` → Estilos visuales específicos de esta página

### Paso 4.3 — Contenido de la página (6 secciones)

#### Sección 1: KPIs Financieros (6 tarjetas)
- **Ingresos Hoy:** Suma total de todos los pedidos del día
- **Ticket Medio:** Ingresos / Nº de pedidos (indica cuánto gasta de media cada mesa)
- **Pedidos Completados:** Nº de pedidos con estado 'served' hoy
- **Ingreso por Comensal:** Ingresos / Nº de comensales (más preciso que ticket medio)
- **Variación Semanal:** % de cambio respecto a la semana anterior
- **Hora Punta:** La franja horaria con más pedidos (útil para planificar personal)

**¿Cómo se obtendrá de la BD?** Con consultas SQL como:
```sql
-- Ticket medio del día
SELECT ROUND(SUM(mci.price * oi.quantity) / COUNT(DISTINCT o.id), 2)
FROM orders o
JOIN order_items oi ON oi.order_id = o.id
JOIN menu_card_items mci ON mci.id = oi.menu_card_item_id
WHERE o.status = 'served' AND DATE(o.created_at) = CURRENT_DATE;
```

#### Sección 2: Gráfico de Ingresos Semanales
Barras verticales por cada día de la semana. El día actual se destaca en verde.

#### Sección 3: Ingresos por Establecimiento
Compara los locales de CalBlay con su facturación semanal y nº de pedidos.

#### Sección 4: Desglose por Categoría de Plato
Barras horizontales que muestran qué porcentaje del ingreso total aporta cada categoría.

#### Sección 5: Top Platos por Facturación
Ranking de los platos que más dinero generan (precio × cantidad vendida). Diferente a "más pedidos".

#### Sección 6: Distribución de Tickets
Rangos de precio en los que se concentran los pedidos. Incluye insight sobre menús a precio cerrado.

### Paso 4.4 — Conexión al sistema de navegación
- Archivo modificado: `src/App.jsx`
- Se añadió `import SalesPage` y el `case 'sales'` en el switch

---

## Fase 5: Página de Pedidos
**Fecha:** 9 de mayo de 2026

### ¿Por qué esta página es importante?
Los pedidos son el corazón de la operativa de un restaurante. Esta página permite al gerente y al jefe de cocina ver en tiempo real el estado de todos los pedidos, detectar retrasos, analizar cancelaciones y equilibrar la carga entre salas.

### Paso 5.1 — Tablas de la BD utilizadas
- `orders` → Cada pedido (estado, mesa, camarero, timestamps)
- `order_items` → Líneas del pedido (plato, cantidad, estado individual)
- `rooms` / `tables` → Para el desglose por sala
- `recipes` → Nombre y categoría del plato

### Paso 5.2 — Archivos creados
- `src/pages/OrdersPage.jsx` → Componente React con datos simulados
- `src/pages/OrdersPage.css` → Estilos visuales de la página

### Paso 5.3 — Contenido de la página (7 secciones)

#### Sección 1: KPIs de Pedidos (6 tarjetas)
- **Pedidos Hoy:** Total de pedidos registrados
- **En Curso Ahora:** Pedidos en estados pendiente/confirmado/preparando
- **Completados:** Pedidos servidos correctamente
- **Cancelados:** Pedidos cancelados (objetivo: minimizar)
- **Ítems por Pedido:** Media de platos por pedido (indica tamaño de mesa)
- **Tasa Cancelación:** % de pedidos cancelados sobre el total

#### Sección 2: Pipeline de Estados
Flujo visual tipo "Pendiente → Confirmado → Preparando → Servido → Cancelado" con el conteo en cada etapa. De un vistazo se ve si hay acumulación en algún punto (ej. muchos en "Preparando" = cocina saturada).

#### Sección 3: Feed de Pedidos en Vivo
Lista scrollable de los últimos pedidos con su ID, platos, mesa, camarero y estado. Cada pedido tiene un borde de color lateral que indica su estado (amarillo=pendiente, azul=confirmado, violeta=preparando, verde=servido, rojo=cancelado). Funciona como un "monitor de cocina".

#### Sección 4: Pedidos por Hora
Gráfico de barras apiladas (verde=servidos, amarillo=en curso) para cada hora del día. Permite ver las horas de máxima actividad y planificar turnos.

#### Sección 5: Tiempo Medio por Etapa
Timeline visual que muestra cuántos minutos tarda de media un pedido en pasar por cada estado. Muy útil para detectar cuellos de botella (ej. si "En cocina" sube mucho, necesitas más personal).

#### Sección 6: Cancelaciones Frecuentes
Muestra qué platos se cancelan más y el motivo. Incluye una sugerencia accionable para reducir cancelaciones.

#### Sección 7: Rendimiento por Sala
Compara cada sala/zona del restaurante en nº de pedidos y tiempo medio de servicio. Útil para reasignar camareros si una sala está sobrecargada.

### Paso 5.4 — Conexión al sistema de navegación
- Archivo modificado: `src/App.jsx`
- Se añadió `import OrdersPage` y el `case 'orders'` en el switch

---

## Mejora: Selector de Establecimiento (Multi-Restaurante)
**Fecha:** 9 de mayo de 2026

### ¿Por qué esta mejora?
CalBlay tiene varios restaurantes (Centro, Port Olímpic, Gràcia). El gerente necesita poder ver las estadísticas de un local específico o de todos en conjunto.

### ¿Qué se ha añadido?
Un desplegable (dropdown) elegante en la **barra superior (Header)**, al lado del título de la página, que permite seleccionar:
- 🏢 **Todos los Restaurantes** → Vista global con datos agregados
- 🏙️ **CalBlay Centro** → Solo datos de Carrer Major, 12
- ⛵ **CalBlay Port Olímpic** → Solo datos de Passeig Marítim, 34
- 🌳 **CalBlay Gràcia** → Solo datos de Plaça del Sol, 8

### ¿Cómo funciona técnicamente?
1. En `App.jsx` se creó un estado `selectedEstablishment` (por defecto: `'all'`)
2. La lista de establecimientos se define como un array de objetos con `id`, `name`, `icon` y `address`
3. El Header recibe ambos como "props" y muestra el botón + dropdown
4. Al hacer clic en un restaurante, se llama a `onEstablishmentChange(id)` que actualiza el estado en App
5. Se usa un `useRef` + evento `mousedown` para cerrar el dropdown al hacer clic fuera de él
6. **En el futuro**, cuando se conecte a la BD, cada página añadirá `WHERE establishment_id = :id` a sus consultas SQL

### Archivos modificados
- `src/App.jsx` → Nuevo estado `selectedEstablishment`, lista de establecimientos, se pasa al Header
- `src/components/Header.jsx` → Reescrito con el dropdown, `useRef` para clic exterior
- `src/components/Header.css` → Nuevos estilos: botón, flecha rotable, menú desplegable con glassmorphism

---

## Fase 6: Página de Ocupación y Ajuste del Menú
**Fecha:** 15 de mayo de 2026

### ¿Por qué esta página es importante?
La página de Ocupación (Ocupación de Mesas) permite al personal de sala gestionar la capacidad del restaurante en tiempo real. Ayuda a minimizar los tiempos de espera y optimizar la asignación de mesas según su tamaño, viendo qué mesas están libres, ocupadas o reservadas.

### Paso 6.1 — Ajuste del Sidebar
- Por decisión del equipo, se han eliminado temporalmente las secciones de "Cocina" y "Proveedores" del menú lateral, para centrarnos en los módulos principales.
- Archivo modificado: `src/components/Sidebar.jsx` (se eliminaron los items correspondientes).

### Paso 6.2 — Archivos creados
- `src/pages/TablesPage.jsx` → Componente React que renderiza la vista en vivo de la sala y los KPIs de ocupación.
- `src/pages/TablesPage.css` → Estilos específicos, incluyendo un layout de tarjetas visuales que cambian de color según el estado de la mesa.

### Paso 6.3 — Contenido de la página
#### Sección 1: KPIs de Ocupación
Muestra métricas como la Ocupación Actual (%), Mesas Libres, Reservas Próximas, Comensales Actuales, Tiempo Medio/Mesa y Rotación de Turnos.

#### Sección 2: Estado de Mesas (En Vivo)
Un mapa/listado visual de las mesas y la terraza. Cada tarjeta muestra el nombre de la mesa, su capacidad y un indicador de estado con colores intuitivos (Verde = Libre, Rojo = Ocupada, Amarillo = Reservada). Si la mesa está ocupada, se muestra el número de comensales, tiempo transcurrido y camarero asignado.

#### Sección 3: Paneles Laterales
- **Ocupación por Tamaño:** Gráfico de barras horizontales que muestra qué tamaños de mesa (2 pax, 4 pax, etc.) tienen mayor ocupación.
- **Avisos Importantes:** Alertas automáticas del sistema (ej. mesas ocupadas por mucho tiempo, llegadas inminentes).

### Paso 6.4 — Conexión al sistema de navegación
- Archivo modificado: `src/App.jsx`
- Se añadió `import TablesPage` y el `case 'tables'` en el switch para renderizar el componente.

---

## Fase 7: Página de Personal
**Fecha:** 15 de mayo de 2026

### ¿Por qué esta página es importante?
Permite visualizar la asignación de zonas y la carga de trabajo de los camareros, así como realizar un seguimiento de su rendimiento en términos de generación de ingresos (upselling) y gestión de pedidos, basándonos en las tablas `users`, `waiter_zones`, `orders` y `audit_log`.

### Paso 7.1 — Archivos creados
- `src/pages/StaffPage.jsx` → Componente React que renderiza las métricas y paneles de personal.
- `src/pages/StaffPage.css` → Estilos específicos, incluyendo avatares de camareros, insignias de estado y animaciones en el timeline de actividad.

### Paso 7.2 — Contenido de la página
#### Sección 1: KPIs de Personal
Tarjetas que resumen el estado general del equipo: Personal en Turno, Pedidos Atendidos, Ticket Medio por Camarero y porcentaje de Alertas Resueltas.

#### Sección 2: Asignación de Zonas
Una lista visual que muestra qué camarero está asignado a qué sala (`room`), cuántas mesas tienen activas y un indicador rápido de la carga de trabajo actual (Alta Carga, Normal, Sin Asignar).

#### Sección 3: Actividad Relevante
Un *timeline* extraído del registro de auditoría (`audit_log`) que detalla las acciones más recientes e importantes realizadas por el personal (cancelaciones, resolución de alertas de alérgenos, reasignación de mesas).

#### Sección 4: Ranking de Rendimiento
Una tabla clasificada que incentiva y mide el esfuerzo de ventas. Evalúa a los camareros en función del número de pedidos gestionados y los ingresos totales generados, destacando indicadores clave como el *upselling*.

### Paso 7.3 — Integración
- Archivo modificado: `src/App.jsx`
- Se añadió `import StaffPage` y el correspondiente caso `case 'staff'` en el switch de enrutamiento interno.

---

## Fase 8: Conexión con la Base de Datos (API)
**Fecha:** 18 de mayo de 2026

### ¿Por qué esta fase es importante?
Hasta ahora, el dashboard mostraba datos simulados (Mock Data). Para que sea útil, debe conectarse a los datos reales de PostgreSQL. Sin embargo, por seguridad **nunca** se debe conectar React directamente a la base de datos, ya que expondría las contraseñas. Necesitamos una "capa intermedia" o API.

### Decisión de Arquitectura: PostgREST
Decidimos usar **PostgREST** en lugar de programar un backend manual (en Node.js o Python).
- **Aislamiento:** Corre en su propio contenedor Docker, lo que evita conflictos de dependencias o lenguajes con otras plataformas del equipo.
- **Automático:** Genera instantáneamente una API RESTful basada en las tablas y esquemas de nuestra base de datos.
- **Seguridad:** Utiliza los roles de PostgreSQL para definir qué puede o no puede verse.

### Paso 8.1 — Configuración de PostgREST y Roles
1. Se añadió el servicio `postgrest` al archivo `docker-compose.dev.yml` para que corra junto a PostgreSQL en el puerto `3000`.
2. Se crearon migraciones SQL (`000014_create_postgrest_roles`) para generar un rol de base de datos llamado `web_anon`. Este rol tiene permisos estrictamente de **lectura** (`SELECT`) sobre el esquema `public`, protegiendo la base de datos de modificaciones no autorizadas por parte del frontend.

### Paso 8.2 — Configuración del Frontend (CORS)
- **Problema de CORS:** El navegador bloquea peticiones de `localhost:5173` (Vite) a `localhost:3000` (PostgREST) por seguridad.
- **Solución:** Se configuró un proxy en `dashboard/vite.config.js`. Ahora, cuando React hace una petición a `/api`, Vite la redirige internamente a PostgREST evitando bloqueos del navegador.

### Paso 8.3 — Fetching de Datos Reales en React
- Se creó el archivo `src/api.js`, que actúa como un servicio centralizado para hacer las peticiones `fetch` al endpoint `/api/`. Este servicio maneja errores para evitar que la UI se rompa si la base de datos está vacía o apagada.
- En la página `OverviewPage.jsx`, implementamos el hook `useEffect` y `useState` para obtener el número de "Pedidos Hoy" directamente de la tabla `orders`. Esto sirve como **Prueba de Concepto (PoC)**, reemplazando el valor simulado por el valor real.

---

## Glosario de Términos

| Término | Explicación sencilla |
|---------|---------------------|
| **React** | Librería de JavaScript (creada por Facebook) para construir interfaces de usuario con "componentes" reutilizables |
| **Vite** | Motor de desarrollo ultra-rápido que compila tu código React para que el navegador lo entienda |
| **JSX** | Extensión de JavaScript que permite escribir código que parece HTML dentro de JavaScript. Los archivos `.jsx` son archivos de React |
| **Componente** | Una pieza independiente de la interfaz (como un botón, una tarjeta o un gráfico) que se puede reutilizar |
| **CSS** | Lenguaje que define los estilos visuales (colores, tamaños, posiciones) de una página web |
| **npm** | Gestor de paquetes de Node.js. Descarga e instala librerías de terceros |
| **package.json** | Archivo que lista todas las dependencias del proyecto y los comandos disponibles |
| **node_modules** | Carpeta donde npm guarda todas las librerías descargadas |
| **Glassmorphism** | Efecto visual moderno donde los elementos parecen cristales translúcidos con desenfoque de fondo |
| **Design System** | Conjunto de reglas de diseño (colores, tipografías, etc.) que se aplican de forma coherente en toda la app |
| **Layout** | La estructura/esqueleto de la página que define dónde va cada elemento (menú, cabecera, contenido) |
| **Dashboard** | Tipo de aplicación web que muestra datos resumidos en forma de gráficas, tablas y tarjetas |
| **Web App** | Cualquier aplicación que se usa a través del navegador (Chrome, Safari, etc.) |
| **Git Branch (Rama)** | Una copia paralela del código donde puedes trabajar sin afectar la versión estable |
| **Merge** | Unir los cambios de una rama a otra (ej. unir `feature/dashboard` a `dev`) |
| **Heatmap** | Tabla visual donde los colores de las celdas representan valores (ej. rojo = peligro, verde = seguro) |
| **Mock Data** | Datos simulados/inventados que se usan temporalmente para diseñar la interfaz antes de conectar con la base de datos real |
| **KPI** | Key Performance Indicator: métrica clave que resume el rendimiento de un aspecto del negocio |
| **Props** | Datos que un componente padre pasa a un componente hijo en React (como parámetros de una función) |
| **State (Estado)** | Datos internos de un componente React que pueden cambiar con el tiempo (ej. la página activa) |
