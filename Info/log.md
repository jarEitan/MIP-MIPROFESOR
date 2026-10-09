# LOG DEL PROYECTO — MiProfesor (MIP)

> Documento vivo para usar como **contexto al seguir programando** (humanos o IA).
> Leer junto con [systemPrompt.md](systemPrompt.md), que define las reglas de código.
> Agregar una entrada nueva en el **Historial de cambios** cada vez que se trabaje.

---

## 1. Qué es el proyecto

**MiProfesor (MIP)**: plataforma web que conecta **alumnos** con **profesores** vinculados a su **colegio**.
Misión: *"Una plataforma donde cada docente puede compartir su conocimiento y cada alumno encontrar la ayuda que necesita."*

Funcionalidades previstas (según prototipos de referencia):
- Registro con rol **Alumno** (nombre, colegio, nivel) o **Profesor** (credenciales, materias, colegios, horarios).
- **Catálogo** de profesores con filtro por materia, nivel y **colegio** ("Mi Colegio").
- Reserva de clases **presenciales o virtuales**.
- **Panel de Control** con 4 módulos: Administrar Clases, Historial, Chat Directo, Configuración.
- **Cancelar / Reubicar** clase: si es con anticipación se cancela sola; si está próxima abre chat con el profesor.
- **Reseñas** de clases.
- **Soporte**: preguntas frecuentes y formulario de contacto.

Equipo:
| Persona | Rol |
|---|---|
| Francisco Martinez | Project Leader |
| Tobias Schatzyki | Database |
| Eitan Ariel Glaz | Front-end |
| Ariel Chocron | Back-end |

---

## 2. Stack técnico

| Capa | Tecnología |
|---|---|
| Framework | ASP.NET Core MVC, **.NET 9** (`MIP-MIPROFESOR.csproj`, namespace `MIP_MIPROFESOR`) |
| Vistas | Razor (`.cshtml`) |
| CSS / layout | **Bootstrap 6.0.0-alpha.1** local (`wwwroot/lib/bootstrap/dist`) + **un solo** CSS propio: `wwwroot/css/site.css` (ver [guiaDeEstilo.md](guiaDeEstilo.md)) |
| JS | Vanilla JS modular en `wwwroot/js/site.js` + `bootstrap.bundle.min.js` cargado como **módulo ES** (`<script type="module">`). **jQuery quitado del layout** (los archivos siguen en `wwwroot/lib`; si una vista usa `_ValidationScriptsPartial`, agregar jQuery en su `@section Scripts`) |
| Fuentes | Las tres de la marca, **locales** en `wwwroot/fonts/` (`@font-face` al inicio de `site.css`): **Eras Bold ITC** (`--fuenteTitulos`: h1, h2, logo, lema), **Fredoka** (`--fuenteMarca`: botones, etiquetas, cifras) y **Plus Jakarta Sans** (`--fuenteTexto`: párrafos y formularios) |
| Íconos | **Bootstrap Icons 1.11.3** local en `wwwroot/lib/bootstrap-icons/` → `<i class="bi bi-nombre" aria-hidden="true"></i>`. Catálogo: https://icons.getbootstrap.com |
| BD | SQL Server + **Dapper 2.1.89** + `Microsoft.Data.SqlClient 7.1.1`. Todo en `Models/BD.cs` (hoy **vacío**) |
| Sesión | `Microsoft.AspNetCore.Session` ya configurado en `Program.cs` (`AddDistributedMemoryCache`, `AddSession`, `UseSession`). Cultura `es-AR` por defecto (precios `8.000`, notas `4,9`) |

> ⚠️ Todavía **no hay archivo `.sql`** en la raíz. El systemPrompt exige leerlo antes de escribir queries.

---

## 3. Referencias de diseño

- **Figma** (prototipo + UI kit): https://www.figma.com/design/HDhfuOx62CKtV0MSiQWDl4/MIP y **Miro**: https://miro.com/app/board/uXjVHVYvc3g=/ . Se configuran en `.mcp.json`, pero en la sesión de 2026-10-08 los dos servidores **no conectaron** (proxy 403) y el plan Starter de Figma ya había llegado al límite de llamadas. Los textos y secciones nuevos salieron de las **imágenes de marca** (`wwwroot/img/*.webp`, copiadas de `/knowledge`) y del documento de conocimiento del proyecto.
- Estilo visual de los prototipos Netlify del equipo (solo el estilo, no el código):
  - https://eclectic-semolina-f2b73a.netlify.app/ → **Panel de Control** (logueado).
  - https://gorgeous-crumble-edc300.netlify.app/ → **Soporte**.
- **Cómo se organiza el código**: ver [guiaDeEstilo.md](guiaDeEstilo.md) (filosofía sacada de `TP-Sala-de-escape`, `bootstrap` y `TP06-ARTE`).

---

## 4. Sistema de diseño (variables en `:root` de `site.css`)

### Colores de marca
| Variable | Valor | Uso |
|---|---|---|
| `--colorCoral` | `#FF5757` | Marca, botón principal (`primary` de Bootstrap) |
| `--colorCoralOscuro` | `#D51F47` | Magenta de marca: hover, links, errores (`danger`) |
| `--colorCeleste` | `#5CE1E6` | Acento, píldoras, foco (`accent`) |
| `--colorTinta` | `#111827` | Texto, bordes marcados, footer (`inverse`) |
| `--colorPapel` | `#FFF7F2` | Fondo cálido de la página |

Hay más variables suaves (`--colorCoralSuave`, `--colorCelesteSuave`, `--colorBorde`, `--colorTextoSuave`, éxito) en el bloque `0) VARIABLES Y BASE`.

### Lenguaje visual
- **Neo-brutal**: borde 2px tinta (`--bordeMarcado`) + **sombra desplazada sólida** (`--sombraMarcada`). Hover: la tarjeta se "levanta"; active: se "hunde". `.card.estatica` desactiva el levantado (formularios, tablas, chat).
- Fondos con grilla de puntos, manchas coral/celeste difuminadas, tarjetas ilustrativas flotantes en la portada, palabra resaltada con `<mark>` (marcador celeste), sigla "MIP" gigante en el footer.
- **Escalable**: tamaños fluidos con `clamp()`; desde 1536px la raíz sube a 112,5 % y desde 1920px a 125 % (el contenido crece en monitores grandes en vez de quedar chiquito).
- El header, el menú y los bloques de filtros cambian de modo según el **ancho del contenedor** (`@container`), no de la ventana.

### Componentes reutilizables (bloque `2)` del CSS)
Clase base + modificador (`.boton .principal`, `.card .coral`, `.icono .celeste`). La tabla completa de vocabulario está en [guiaDeEstilo.md](guiaDeEstilo.md#cómo-se-reutiliza-vocabulario-base).

### Animaciones
Aparición al scroll (`.revelar` → `.visible`, escalonada con `--retraso`), cinta infinita de materias, flotado de tarjetas, pulso de la insignia de notificaciones. Todo se apaga con `prefers-reduced-motion`.

---

## 5. Mapa de archivos (estado actual)

```
Controllers/HomeController.cs      Index, Catalogo, Soporte, QuienesSomos, Registrarse, IniciarSesion,
                                   PanelControl, MiColegio, CerrarSesion, Privacy, Error (datos de ejemplo con TODO BD)
Models/BD.cs                       VACÍO — acá van todas las consultas Dapper
Models/Profesor.cs, Clase.cs       Modelos de ejemplo (propiedades auto-implementadas)
Program.cs                         Sesión, cultura es-AR
Views/_ViewImports.cshtml          + @using Microsoft.AspNetCore.Http (Session en vistas)
Views/Shared/_Layout.cshtml        Esqueleto: head, header según sesión, <main>, footer, scripts (bootstrap como módulo)
Views/Shared/_encabezadoInvitado   Header SIN sesión (drawer en < lg)
Views/Shared/_encabezadoUsuario    Header CON sesión (Panel de Control + insignia, menú de usuario)
Views/Shared/_piePagina            Footer 4 columnas + sigla MIP
Views/Shared/_marcaLogo            Logo + "MiProfesor"
Views/Shared/_tarjetaProfesor      Tarjeta de profesor (Inicio y Catálogo)
Views/Shared/_preguntasFrecuentes  Acordeón de FAQ (Inicio y Soporte)
Views/Home/Index                   Landing (§6)
Views/Home/Catalogo                Buscador + filtros (materia, nivel, colegio, modalidad) + resultados
Views/Home/Registrarse             Alumno / Profesor (`?rol=`)
Views/Home/IniciarSesion           Ingreso
Views/Home/Soporte                 Buscador de ayuda, 3 tarjetas, FAQ, formulario de contacto
Views/Home/PanelControl            Saludo, métricas, pestañas: Administrar clases, Historial, Chat, Configuración
Views/Home/QuienesSomos            Misión, problemas, equipo, identidad de marca (imágenes), proceso (Figma/Miro)
Views/Home/Privacy                 Privacidad (usa .cabecera)
wwwroot/css/site.css               ÚNICO CSS propio
wwwroot/js/site.js                 ÚNICO JS propio
wwwroot/img/                       logoChico.png (el que usan las vistas) + .webp de la marca (paleta, tipografía, UI kit, flujos, mapa del sitio, signo, merchandising, prototipo)
wwwroot/fonts/                     Plus Jakarta Sans y Fredoka (woff2, latin + latin-ext)
wwwroot/lib/                       bootstrap 6 (dist), bootstrap-icons
Info/                              systemPrompt.md (reglas), guiaDeEstilo.md (filosofía), log.md (este archivo)
```

Se **eliminó** `Views/Shared/_Layout.cshtml.css`. Regla: un solo CSS.

---

## 6. Landing (`Views/Home/Index.cshtml`)

Cada zona grande es una `<section>` aislada; los ítems internos son `<div>`.

| # | Sección (clase) | Contenido |
|---|---|---|
| 1 | `.portada` | Píldora, h1 con `<mark>`, buscador (`#formularioBuscador`), CTAs "Soy alumno" / "Quiero enseñar" y composición de tarjetas ilustrativas (`aria-hidden`) |
| 2 | `.cinta` | Cinta infinita de materias (`ViewBag.materiasDestacadas`) |
| 3 | `.pasos` (`#seccionComoFunciona`) | 3 pasos |
| 4 | `.perfiles` | Tarjetas Alumno y Profesor con CTA a registro (`?rol=`) |
| 5 | `.funciones` | 6 funcionalidades |
| 6 | `.destacados` | Profesores destacados (`_tarjetaProfesor`) + colegios |
| 7 | `.opiniones` | Carrusel de reseñas (BS6 scroll-snap: 1 / 2 / 3 ítems por ancho) |
| 8 | `.preguntas` | Acordeón `<details>` (`_preguntasFrecuentes`) |
| 9 | `.llamadoFinal` | Bloque final con degradado animado |

Los **textos son provisorios**, tomados de los prototipos y del documento de conocimiento.

---

## 7. JavaScript (`wwwroot/js/site.js`)

Patrón: una función por módulo, todas llamadas desde `inicializarSitio()` en `DOMContentLoaded`. Cada función sale temprano si su elemento no existe (así el mismo archivo sirve para todas las páginas).

| Función | Qué hace |
|---|---|
| `mostrarMensaje` / `mostrarErrorEnCampo` / `normalizarTexto` / `correoValido` | Utilidades de validación (patrón del systemPrompt) |
| `inicializarEncabezadoConScroll()` | `.conSombra` en `#encabezado` al hacer scroll |
| `inicializarRevelarAlScroll()` | Agrega `.revelar` (escalonado con `--retraso`) y `.visible` con IntersectionObserver |
| `validarBusqueda()` / `inicializarBuscador()` | Buscador de portada; `fetch` de sugerencias comentado |
| `inicializarFiltrosCatalogo()` | Filtra en el navegador por texto, materia, nivel, colegio y modalidad ("Ambas" coincide con las dos); muestra cantidad y `#sinResultados` |
| `inicializarRolesDeRegistro()` / `validarRegistro()` | Cambia los campos según rol y valida |
| `validarIngreso()` | Valida y, si está bien, va a `/Home/PanelControl` (TODO BD) |
| `inicializarBuscadorDeAyuda()` / `validarContacto()` | Soporte |
| `inicializarAccesosDelPanel()` | `data-abrir-tab` abre la pestaña correspondiente |
| `enviarMensajeChat()` / `guardarConfiguracion()` | Panel de control (simulados hasta que haya BD) |

La clase `jsActivo` se pone en `<html>` con un script inline en el `<head>`: lo que se revela al scroll solo se oculta si hay JS.

---

## 8. Sesión

El layout decide el header según la sesión:
```csharp
@if (Context.Session.GetString("idUsuario") == null) { <partial name="_encabezadoInvitado" /> }
else { <partial name="_encabezadoUsuario" /> }
```
Claves: `idUsuario`, `nombreUsuario`, `inicialesUsuario`, `cantidadNotificaciones` (sugerido `rolUsuario`). Logout: `CerrarSesion` hace `HttpContext.Session.Clear()`.

⚠️ **Mientras no exista el login real**, `PanelControl` crea una sesión de ejemplo ("Mateo Gómez") si no hay una, y el formulario de ingreso redirige a `PanelControl` si los campos son válidos. Borrar ambos al conectar la BD (están marcados con `TODO BD`).

---

## 9. Pendientes (TODO)

- [ ] Recibir el **`.sql`** de la BD (Tobias) y ponerlo en la raíz.
- [ ] Implementar `BD.cs` (cadena de conexión en `appsettings.json` → `ConnectionStrings`).
- [ ] Reemplazar los datos de ejemplo del `HomeController` por consultas (buscar `TODO BD`).
- [ ] Login/registro reales guardando las claves de sesión (§8) y proteger `PanelControl` / `MiColegio`.
- [ ] Contrastar textos y estilo con **Figma y Miro** cuando conecten los MCP (hoy falló el proxy).
- [ ] Endpoint JSON de sugerencias para el buscador (fetch ya comentado en `site.js`).
- [ ] Confirmar la **licencia web** de Eras Bold ITC (el `.woff2` se sirve públicamente desde `wwwroot/fonts/erasBoldItc.woff2`).
- [ ] Imágenes de marca: las originales son de 512px de ancho; pedir las de mayor resolución.
- [ ] Contraste del texto blanco sobre coral (~3:1): evaluar usar tinta o el magenta en botones chicos.
- [ ] Los links a Figma/Miro de *Quiénes somos* son privados: decidir si se publican.
- [ ] Bootstrap 6 sigue en **alpha**: revisar cambios antes de cada actualización.
- [ ] El proyecto apunta a **.NET 9**; la compilación se verificó con una copia a .NET 10 (el SDK 9 no estaba disponible en el entorno). Compilar en tu máquina con .NET 9.

---

## 10. Cómo mejorar (recomendaciones)

### Arquitectura / backend
- **Separar controladores** cuando crezca: `CuentaController` (login/registro/logout), `CatalogoController`, `PanelController`, `SoporteController`. Hoy todo apunta a `Home` para que los links funcionen sin más; al mover acciones, actualizar `asp-controller` en los partials del header/footer.
- **ViewModels en vez de ViewBag** para vistas con varios datos (ej. `LandingViewModel { List<string> MateriasDestacadas }`): tipado y sin casteos. Propiedades auto-implementadas como pide el systemPrompt.
- En `BD.cs` usar una única `connectionString` estática leída de configuración; preferir **Stored Procedures** si la BD los trae.
- **Contraseñas**: guardar hash (ej. `PasswordHasher<T>` de ASP.NET o BCrypt), nunca texto plano.
- Agregar un **filtro o chequeo de sesión** reutilizable para proteger `PanelControl` y demás vistas privadas (en lugar de repetir el `if` en cada acción).
- Formularios POST con `@Html.AntiForgeryToken()` / `[ValidateAntiForgeryToken]`.

### Frontend
- ~~Íconos con emojis~~ → **hecho**: Bootstrap Icons local.
- ~~Fuente local~~ → **hecho**.
- ~~Quitar jQuery del layout~~ → **hecho**. Se pueden borrar `wwwroot/lib/jquery*` si nunca se usa validación unobtrusive.
- Si `site.css` crece mucho, mantener **un solo archivo** (regla) y respetar el orden: Header → generales → Main (en orden de página, numerado `3.x`) → Footer.
- Al crear vistas nuevas, **reusar** `.boton`, `.pildora`, `.encabezadoSeccion`, `.card`, `.icono`, `.cabecera` y `.revelar` antes de inventar clases nuevas (ver [guiaDeEstilo.md](guiaDeEstilo.md)).
- ~~Header con sesión: link activo + badge de notificaciones~~ → **hecho** (`.boton .badge` con pulso, lee `Session["cantidadNotificaciones"]`).
- ~~Partial común del logo~~ → **hecho** (`_marcaLogo.cshtml`). Si los headers siguen creciendo, extraer también el botón hamburguesa.
- Las tarjetas de la portada usan datos ficticios (Sofía Martínez, etc.) solo como ilustración: no conectarlas a la BD; si se quiere mostrar profesores reales, hacer una sección aparte "Profesores destacados".
- Modo oscuro: todos los colores ya son variables; bastaría redefinirlas en `@media (prefers-color-scheme: dark)`.

### Calidad / accesibilidad / SEO
- Probar en dispositivos reales: 360 px, 768 px, 992 px, 1200 px, 1400 px.
- Correr **Lighthouse** (Chrome DevTools) para rendimiento y accesibilidad.
- Revisar contraste de texto gris (`--colorTextoSuave`) sobre fondos claros (AA).
- ~~Open Graph~~ → **hecho** (`og:title`, `og:description`, `og:image` con `logoChico.png`, y `theme-color`). Mejorable: imagen OG de 1200×630 propia.
- ~~`aria-current="page"`~~ → **hecho** en ambos headers.
- Ya implementado: `prefers-reduced-motion` desactiva animaciones; `:focus-visible` con anillo celeste; elementos decorativos con `aria-hidden`.

### Proceso
- Commitear por funcionalidad con mensajes descriptivos.
- Actualizar este log en cada sesión de trabajo (sección 11).

---

## 11. Historial de cambios

### 2026-10-07 — Configuración MCP
- Se creó `.mcp.json` con servidores HTTP de **Figma** (`https://mcp.figma.com/mcp`) y **Miro** (`https://mcp.miro.com/`). El CLI `claude` no estaba en el PATH, por eso se configuró por archivo de proyecto. Falta autenticarlos.

### 2026-10-07 — Layout de la landing (sin sesión)
- Se tomó el estilo de los dos prototipos Netlify (paleta, fuente, bordes oscuros, degradado coral→tinta, header/footer).
- `_Layout.cshtml` reescrito: `lang="es"`, meta description, favicon con el logo, Plus Jakarta Sans, script `jsActivo`, header condicional por sesión, `<main>` sin container (cada sección maneja su ancho), footer en partial.
- Nuevos partials: `_encabezadoInvitado`, `_encabezadoUsuario` (esqueleto), `_piePagina`.
- `Index.cshtml`: landing completa de 7 secciones (§6).
- `HomeController.Index`: `ViewBag.materiasDestacadas` con lista fija (TODO BD).
- `site.css` reescrito desde cero (tokens, componentes, animaciones, responsive, reduced motion).
- `site.js` reescrito de forma modular (§7).
- `_ViewImports`: `@using Microsoft.AspNetCore.Http`.
- Eliminado `_Layout.cshtml.css`. Privacy envuelta en contenedor.
- Verificado: `dotnet build` sin errores ni advertencias; `/` responde 200 y `site.css` carga. **No** se revisó visualmente en navegador.

### 2026-10-07 — Mejoras visuales + escala más compacta
- Pedido: "la portada está perfecta, achicá todo lo demás (tarjetas, header, footer, textos)" + aplicar mejoras de §10 + parecerse más al Figma.
- **Figma seguía sin autenticar** → no se pudo leer. El ajuste de contenido/estilo al Figma queda pendiente (§9).
- Escala reducida en todo menos la portada (ver §4 "Escala compacta"). Gutters de grilla `g-3 g-lg-4`; footer `g-4`.
- Emojis → **Bootstrap Icons** locales (portada, perfiles, funcionalidades, link de soporte).
- Fuente **local** (`@font-face`) en lugar de Google Fonts.
- `logoChico.png` (256 px, 19 KB) generado desde `logo.png`; usado en vistas, favicon y `og:image`.
- Nuevo partial `_marcaLogo.cshtml` (headers + footer).
- Layout: Open Graph, `theme-color`, preload de la fuente, **sin jQuery**.
- Headers: `aria-current="page"`; "Cómo funciona" ahora apunta a `/#seccionComoFunciona` (funciona desde cualquier página); header con sesión con link activo + insignia de notificaciones con pulso.
- JS: el cierre del menú móvil detecta links con `#` en cualquier parte del href.
- **Bug corregido**: el `backdrop-filter` del header convertía al header en contenedor de los elementos `position: fixed`, entonces el offcanvas móvil quedaba con la altura del header y generaba **scroll horizontal** en celular. Se movió el desenfoque a `.encabezadoPrincipal::before`. ⚠️ No volver a poner `backdrop-filter`, `transform` o `filter` directamente en el header.
- Verificado: `dotnet build` sin errores ni advertencias; todos los recursos responden 200; capturas con Edge headless en 1440 px y 375 px, sin desbordes horizontales (scrollWidth = ancho de pantalla).

### 2026-10-08 — Bootstrap 6, CSS reorganizado y todas las secciones
- Pedido: reorganizar las clases de CSS con la filosofía de `TP-Sala-de-escape` (pocas clases reutilizadas, base + modificador, selectores descendientes, un solo archivo en orden Header → generales → Main → Footer), **actualizar a Bootstrap 6**, hacerlo escalable con personalidad y agregar todas las secciones de los ejemplos (imágenes, Figma, Miro). La filosofía quedó escrita en [guiaDeEstilo.md](guiaDeEstilo.md).
- **Bootstrap 6.0.0-alpha.1** vendorizado en `wwwroot/lib/bootstrap/dist`. Migración a la sintaxis nueva: breakpoints como prefijo (`md:col-6`), Drawer/Dialog/Menu en lugar de offcanvas/modal/dropdown, acordeón con `<details>`, carrusel scroll-snap, JS como módulo ES. Gotchas documentados en la guía (§5): `!important` dentro de capas, header con `@container`.
- `site.css` **reescrito desde cero** (de `.botonMip`/`.etiquetaPildora`/`.iconoTarjeta`… a `.boton`/`.pildora`/`.icono`… con modificadores). `site.js` reescrito con las funciones de las nuevas vistas.
- Vistas nuevas: Catálogo, Soporte, Quiénes somos, Registrarse, Iniciar sesión, Panel de Control (+ Privacy rehecha). Partials nuevos: `_tarjetaProfesor`, `_preguntasFrecuentes`. Landing ampliada (profesores destacados, colegios, opiniones, FAQ). Modelos de ejemplo `Profesor` y `Clase`; `HomeController` con datos de ejemplo marcados `TODO BD`.
- Quiénes somos incluye las imágenes de marca (paleta, tipografía, UI kit, flujos, mapa del sitio, merchandising, prototipo) y enlaces a Figma y Miro.
- `Program.cs`: cultura `es-AR` (precios `8.000`, calificaciones `4,9`).
- Fuentes: se suma Fredoka local. **Eras Bold ITC no estaba disponible.**
- Verificado: revisión visual con Chromium (390, 768, 1024, 1280 y 1920 px) sin scroll horizontal ni errores de consola; prueba de interacciones (drawer, menú de usuario, pestañas, diálogo, carrusel, acordeón, filtros, validaciones, chat); compilación real de las vistas Razor y corrida del servidor con una copia en .NET 10 (el proyecto sigue en .NET 9); flujo ingreso → panel → cerrar sesión.
- **No se pudo** leer Figma ni Miro (servidores MCP sin conexión por proxy 403): el contenido salió de las imágenes y del documento de conocimiento.

### 2026-10-09 — Eras Bold ITC y espacios más compactos
- Se incorporó **Eras Bold ITC** (archivo que pasó Jarsou, convertido a `erasBoldItc.woff2`, precargada en el layout). Según el manual de marca se reserva para los titulares de mayor jerarquía: `h1`, `h2`, texto del logo (`.marcaLogo span`), lema del footer (`.pie .eslogan`), sigla MIP del footer y la muestra de *Titulares* en Quiénes somos. Fredoka queda para botones, etiquetas y cifras.
- Se agregó `text-wrap: balance` a `h1`/`h2` (Eras es más ancha que Plus Jakarta Sans) y se bajó el tamaño mínimo del `h2` para que entre en 390 px.
- **Menos aire vertical**: `--espacioSeccion` pasó de `clamp(3rem, 6vw, 5rem)` a `clamp(1.75rem, 3.5vw, 3rem)`; `.encabezadoSeccion` baja de 2.25rem a 1.5rem de margen inferior; la portada, las cabeceras de página y `.acceso` también tienen menos padding.
- **Mensaje final (`.llamadoFinal`) y footer (`.pie`) más compactos**: menos padding, menos separación entre columnas y listas, y el equipo en el footer ahora muestra nombre y rol en una sola línea.
