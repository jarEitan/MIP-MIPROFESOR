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
Controllers/HomeController.cs      Index, Soporte, QuienesSomos, Registrarse, IniciarSesion,
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
| `guardarConfiguracion()` | Panel de control (simulado hasta que haya BD). El chat está en `chat.js` (entrada 2026-10-16) |

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

### 2026-10-12 — Sistema de perfiles (ver cualquier perfil por URL + editar el propio)
- Pedido: sistema de perfiles sin buscador; copiando la URL de otro usuario se puede ver su perfil. Regla nueva de arquitectura: **lo que es navegación va en `HomeController`**; las funciones que se llaman con `fetch` y usan la BD van **cada una en su propio controlador**.
- **Navegación** → `HomeController.Perfil(int? id)`: `/Home/Perfil/5` muestra el perfil del usuario 5 (sin sesión también); `/Home/Perfil` sin ID muestra el propio (sin sesión manda a Iniciar sesión). La vista `Views/Home/Perfil.cshtml` es solo el esqueleto.
- **Fetch + BD** → `PerfilesController`: `GET /Perfiles/ObtenerPerfil/{id}` (JSON con `encontrado`) y `POST /Perfiles/EditarPerfil` (con `[ValidateAntiForgeryToken]`; el ID sale **de la sesión**, nunca del formulario; actualiza `nombre`/`apellido` en la sesión).
- **BD**: SP nuevos `obtenerPerfil` (7 tablas: usuario, materias, niveles, modalidades, colegios, títulos, reseñas; nunca devuelve mail, DNI, dirección ni fecha de nacimiento) y `editarPerfil` (nombre, apellido, descripción en `Perfiles`, y precio por hora en `InfoProfesores` solo para profesores; vacío = a convenir). Están en la base y al final de `MIP-BD.sql`. Las consultas viven en `Models/BD.cs` (antes vacío); login y registro siguen en `BDsesion.cs`.
- Modelos nuevos: `PerfilUsuario`, `ResenaPerfil`, `EdicionPerfil`.
- `site.js`: `inicializarPerfil`, `cargarPerfil`, `mostrarPerfil` (+ avatar, cifras, reseñas, datos), `inicializarCopiarEnlacePerfil`, `guardarPerfil`. Todo lo que viene de la BD se pone con `textContent` (no se puede inyectar HTML). El nombre de quien dejó una reseña lleva a su perfil.
- `site.css`: sección **3.16 Perfil** (se borró el bloque `.perfilUsuario` que había quedado después de la sección 5). Diálogo `.dialog.dialogoAncho` para "Editar perfil".
- Se eliminó `Views/Sesion/Perfil.cshtml` y la acción `SesionController.Perfil`; los headers (alumno, profesor, admin) y las redirecciones de login/registro ahora van a `Home/Perfil`.
- Verificado: `dotnet build` sin errores ni advertencias; perfil propio y ajeno, con y sin sesión; perfil inexistente; editar (validaciones, precio a convenir, header actualizado sin recargar, HTML escapado); POST sin token → 400; 1280 px y 390 px sin scroll horizontal. Se usaron datos y cuentas de prueba que después se borraron.
- Pendiente: subir foto de perfil, editar materias/niveles/colegios (las tablas de catálogo están vacías), likes y reseñas desde el perfil.

### 2026-10-12 — Perfil completo: modal de edición, verificación de cuenta y selector con búsqueda
- **Base de datos** (la armó y corrigió Jarsou; `MIP-BD.sql` es su script): catálogos cargados (8 colegios, 20 materias, 3 niveles, 2 modalidades), función `faltantesVerificacion` y SP `obtenerOpcionesPerfil`, `obtenerDatosEdicion`, `obtenerFaltantesVerificacion`, `obtenerPerfil` (ahora con `calificacion` y el autor de cada reseña con `verificadoEmisor`) y `guardarPerfilCompleto` (un solo SP para todo el modal: listas de IDs separadas por coma y títulos separados por `|`; recalcula `Usuarios.verificado`).
- **Pestaña de perfil** (`Home/Perfil`, rediseñada): franja de color con la tarjeta encima, foto/iniciales, tick de verificado ✔ al lado del nombre, colegio y antigüedad, cifras (calificación, me gusta, precio), Sobre mí (HTML del editor), reseñas y datos.
  - **Mi perfil**: aviso "Tu cuenta todavía no está verificada" con lo que falta, botones *Editar perfil*, *Copiar enlace* y *Cerrar sesión*.
  - **Perfil de otro**: botones sin funcionalidad todavía (Pedir clase —solo profesores—, Mensaje, Agregar amigo, Me gusta, Dejar reseña, Reportar), salen de las tablas Clases, Chats/Mensajes, Amigos, Likes, Resenas y Consultas_Soporte. Muestran un snackbar "Muy pronto" (sin sesión llevan a Iniciar sesión).
- **Modal "Editar perfil"** (Dialog de BS6, centrado, campos en vertical, un solo botón Guardar):
  - *Modificar perfil*: Sobre mí con **editor de texto enriquecido Quill 2** (local en `wwwroot/lib/quill`), colegio(s), nivel(es) y, en profesores, materias, modalidades, precio por hora y títulos.
  - *Modificar cuenta*: foto de perfil con vista previa (el servidor la recorta al centro y la guarda como **WEBP 100×100** en `wwwroot/uploads/perfiles/` con SkiaSharp), nombre, apellido, mail, fecha de nacimiento, DNI, dirección y foto del DNI (se guarda en `App_Data/dni/`, **fuera de wwwroot**: no se puede abrir por URL).
  - Arriba muestra cuánto falta para verificar la cuenta. Al guardar se verifica sola si está todo.
  - El HTML de la descripción se limpia en el servidor con **HtmlSanitizer** (solo negrita, cursiva, subrayado, tachado, listas, cita y enlaces http/https/mailto), al guardar y al mostrar.
- **Aviso "Cuenta no verificada"** debajo del header en todas las páginas (partial `_avisoVerificacion`), con lo que falta y el botón *Completar mis datos* (`/Home/Perfil?editar=true` abre el modal). Se puede cerrar hasta la próxima sesión. Claves de sesión nuevas: `verificado` y `datosFaltantes` (se cargan al iniciar sesión, al registrarse y al guardar el perfil).
- **Componente reutilizable: selector con búsqueda** (`select[data-buscable]`, simple o `multiple`): click → lista scrolleable que se filtra mientras se escribe (sin tildes ni mayúsculas, primero las que empiezan con lo escrito), teclado (flechas, Enter, Esc, Backspace), etiquetas con ✕ en el múltiple. El `<select>` queda oculto y sigue mandando (value / selectedOptions / evento change). Se usa en el modal, en los filtros del Catálogo (materia, colegio, modalidad, nivel — modalidad y nivel dejaron de ser radios/checkboxes), en la Configuración del Panel y en el tipo de consulta de Soporte.
- Otros: `mostrarSnackbar()` (Snackbar del UI Kit), `pedirJson()`, `VerificacionCuenta` (texto "el DNI, la dirección y tu colegio"), `.gitignore` ignora `wwwroot/uploads/` y `App_Data/`. NuGet nuevos: `HtmlSanitizer` y `SkiaSharp`.
- Verificado: `dotnet build` sin errores ni advertencias; profesor y alumno completando todo hasta quedar verificados (tick en perfil y header sin recargar), mail y DNI repetidos, selector (filtrar, elegir, quitar, teclado, Esc dentro del modal), filtros del catálogo y "Limpiar filtros", foto WEBP 100×100 real, foto del DNI devuelve 404 por URL, HTML peligroso eliminado; 1280 px y 390 px sin scroll horizontal. Cuentas y archivos de prueba borrados al final.

### 2026-10-13 — Sistema de catálogo (con fetch, controller y JS propios)
- **Controller propio**: `CatalogoController` con `GET /Catalogo` (página con los selectores, preselecciona los filtros de la URL) y `GET /Catalogo/Buscar` (JSON: `total`, `pagina`, `porPagina`, `totalPaginas` y los profesores de la página). Se sacó la acción `Catalogo` de `HomeController`; todos los links del sitio ahora van a `Catalogo/Index`.
- **JS propio**: `wwwroot/js/catalogo.js` (se carga solo en el catálogo con `@section Scripts`). Lee los filtros, llama a `Catalogo/Buscar` con `fetch`, dibuja las tarjetas con `textContent` y la paginación, y guarda los filtros en la URL. Se borró `inicializarFiltrosCatalogo` de `site.js`.
- **Filtros**: búsqueda (nombre, materia, colegio o título, sin importar tildes), materia, colegio, modalidad y nivel (varios). Al cambiar un selector se busca desde la página 1; al escribir se espera 400 ms.
- **Tarjetas horizontales** (forma de la captura del Miro): avatar con foto o iniciales de color, nombre con sello "Verificado" (y "Popular" si tiene 4,8 o más con 2 reseñas o más), colegios, materias, resumen, calificación y niveles; a la derecha modalidad, precio por hora y botones *Ver perfil* y *Enviar pedido* (por ahora los dos llevan al perfil; cuando existan las clases, el segundo abre el pedido).
- **Paginación**: de a 10 por defecto, con Anterior / números / Siguiente y un selector de 5, 10, 15 o 20 por página.
- **BD**: SP `obtenerCatalogo` (filtros + `OFFSET/FETCH`, orden: verificados, calificación, reseñas) en `MIP-BD.sql`, junto con **16 profesores y 2 alumnos de prueba** (contraseña `Prueba123`, mails `@prueba.mip`) y reseñas. Borrarlos antes de publicar. `BD.obtenerCatalogo` devuelve `ResultadoCatalogo`.
- Inicio muestra los 3 primeros del catálogo; "Mi Colegio" filtra por el colegio del usuario.
- Sin verificar con `dotnet build` (no había .NET donde se escribió): compilar y probar en la PC.
- **Datos (misma fecha)**: niveles nuevos (Secundario 1 a 6, Terciario, Universitario; reemplazan Primaria/Secundaria/Universitario), ~66 colegios, institutos y universidades de **Ciudad de Buenos Aires** (una entrada por institución aunque tenga varias sedes), 35 materias unificadas (Historia, Geografía, Lengua y Literatura, Programación e Informática, Contabilidad y Administración...) y 48 profesores + 6 alumnos de prueba con reseñas. El sistema es solo para CABA: se sacaron Northlands y St. George's (fuera de la Ciudad). Todo en `MIP-BD.sql`.


### 2026-10-13 — Sistema de likes (Me gusta en los perfiles)
- Enfoque tomado del TP de Red Social: el botón hace un `fetch` POST, el servidor alterna el like y devuelve `leGusta` y `cantidadLikes`; la pantalla se actualiza con esa respuesta.
- **BD**: `MIP-BD.sql` (usa la tabla `Likes` existente): SP `obtenerLike` (estado del botón + total) y `alternarLike` (da o saca el like; resultado `ok | mismoUsuario | usuarioInexistente`). Ejecutar en la base antes de probar.
- **Controller propio**: `LikesController` con `GET /Likes/ObtenerLike/{id}` y `POST /Likes/AlternarLike` (con `[ValidateAntiForgeryToken]`; el emisor sale de la sesión, nunca del pedido). `BD.obtenerLike`/`alternarLike` y el modelo `ResultadoLike`.
- **Vista/JS/CSS**: el botón de corazón del perfil de otro usuario (`inicializarMeGusta` en `site.js`); sin sesión lleva a Iniciar sesión. Animación: el corazón salta, suelta corazoncitos coral/celeste/magenta y el contador rebota (se desactiva con `prefers-reduced-motion`).

### 2026-10-14 — Pedidos de clase y notificaciones
- **BD**: SP y funciones de pedidos y notificaciones al final de `MIP-BD.sql` (sin tocar tablas). Convención: `idEmisor` = quien hizo la última propuesta, `idReceptor` = quien tiene que responder (se intercambian al reubicar y al cancelar: quien cancela queda de emisor); toda clase dura 60 min; `fechaEmision` = fecha de la última novedad. Reglas: una clase **Pendiente se responde** (aceptar, rechazar o proponer otro horario), no se cancela; **Cancelar** solo existe para clases Confirmadas (con 24 h de anticipación; si no, chat) y para las Rechazadas que todavía no pasaron. **Rechazar un horario** deja la clase en `Rechazada` (activa hasta su fecha): quien lo propuso puede proponer otro horario o cancelarla.
- **Controllers con fetch**: `ClasesController` (`HorariosOcupados`, `EnviarPedido`, `Responder`, `Cancelar`, `Reubicar`; el usuario sale de la sesión y todos los POST llevan `[ValidateAntiForgeryToken]`) y `NotificacionesController` (`Contar`). Modelos `ClasePanel`, `MisClases`, `ResultadoClase`, `HorarioOcupado` y `NotificacionUsuario`; se borró el modelo de ejemplo `Clase`.
- **Pedir clase**: el diálogo `_dialogoPedirClase` (solo alumnos, en el layout) lo abren los botones `[data-pedir-clase]` del Catálogo ("Enviar pedido") y del Perfil ("Pedir clase"). Selector de día y hora (`_selectorHorario` + `crearSelectorHorario` en `clases.js`) que tacha las franjas ocupadas o que ya pasaron. Sin sesión lleva a Iniciar sesión; a un profesor le avisa que solo los alumnos piden clases.
- **Panel de Control**: clases reales (pendientes, confirmadas, historial y contadores), lista de **notificaciones** con un botón por cada una (lleva al Panel con la clase resaltada, al historial o al catálogo) y botones Aceptar / Rechazar / Reubicar / Cancelar. Si la clase empieza en menos de 24 h se explica y se ofrece el chat. Las novedades pasan a "vistas" al entrar al Panel.
- **JS propio**: `wwwroot/js/clases.js` (se carga en todas las páginas después de `site.js`; no hace nada si la página no tiene botones de pedir clase, insignia ni Panel). `crearElemento` pasó de `catalogo.js` a `site.js` para compartirlo. En el CSS, la tarjeta centrada de "no hay nada todavía" ahora es una sola clase reutilizable (`.card.estadoVacio`, usada en el perfil inexistente y en el Panel sin clases).
- **Insignia del botón Panel de Control**: siempre está en el HTML (oculta si es 0) y `clases.js` la actualiza con `/Notificaciones/Contar` al cargar y cada minuto; también se calcula al iniciar sesión.
- **Corrección (reglas de clases)**: antes se podía cancelar una clase que nadie había aceptado y rechazar un horario la mataba. Ahora Cancelar solo aparece en Confirmadas y Rechazadas activas, y rechazar un horario deja la clase viva para proponer otro o cancelar (SP `responderPedidoClase`, `cancelarClase`, `reubicarClase`, `obtenerMisClases` y `notificacionesDeUsuario`, ya aplicados en la base y en `MIP-BD.sql`). **Bug del link a Mi perfil**: en el perfil de otro usuario, la foto/nombre del header y el botón *Completar mis datos* recargaban ese mismo perfil, porque el link sin `asp-route-id` reutilizaba el `id` de la URL; ahora llevan el ID de la sesión.
- **Botones del Panel según cada caso**: *Pendiente que me toca responder* → Aceptar (en el alumno "Aceptar horario"), Rechazar y Proponer otro horario; *Pendiente que pedí yo* → solo Cambiar horario (no se cancela algo no aceptado); *Confirmada* → Cambiar horario y Cancelar clase (24 h; si no, chat); *Rechazada activa* → Proponer otro horario (principal si el horario rechazado era mío) y Cancelar clase. Todas las tarjetas llevan el link "Ver perfil de ..." y, en el historial, el alumno tiene "Pedir otra clase" (abre el diálogo ya con ese profesor) y el profesor "Ver perfil".
- **Ajustes siguientes**: (1) **Cancelar un pedido sin aceptar**: quien lo pidió puede cancelarlo en cualquier momento, sin la regla de 24 h (botón *Cancelar pedido*); quien tiene que responder no lo cancela, lo acepta, rechaza o propone otro horario. La regla de 24 h queda solo para clases Confirmadas. SP `cancelarClase` y `obtenerMisClases` (en la base y en `MIP-BD.sql`). (2) **Todo con fetch y sin recargar**: aceptar, rechazar, reubicar, cancelar y *Pedir otra clase* actualizan el Panel en el lugar (`refrescarPanel` en `clases.js` vuelve a pedir `/Home/PanelControl` y cambia solo las notificaciones, las clases, el historial, los contadores y la insignia); la clase que cambió se resalta y los botones de las notificaciones abren la pestaña sin recargar. (3) **Limpieza**: se borró el recargado con `sessionStorage` (`guardarResultadoYRecargar` y `mostrarResultadoGuardadoDelPanel`), el CSS `.saludo .aviso` (la notificación de ejemplo ya no existe) y los campos de los modelos que nadie lee (`MisClases.canceladas`, `ClasePanel.fechaNovedad` y `fotoOtro`, y varios de `NotificacionUsuario`).
- Verificado en el navegador con cuentas de prueba (alumna y profesora): pedir, reubicar de cada lado, aceptar, cancelar, `muyCerca`, clase terminada → Completada, notificaciones y resaltado desde la URL, sin errores de consola y sin scroll horizontal en 375 px.

### 2026-10-15 — Historial de clases (Panel y modal en los perfiles, todo con fetch)
- **Qué es**: botón **Historial** en cualquier perfil (a la derecha de las cifras) que abre un modal con las últimas clases de ese usuario. El historial propio del Panel de Control **también** pasó a pedirse con fetch: antes se dibujaba en el servidor (Razor) y `refrescarPanel()` copiaba el HTML de la página entera.
- **BD** (`MIP-BD.sql`, sección 9; también en `actualizar-historial.sql`, que ya se puede borrar): SP `obtenerHistorialClases(@idUsuario, @idVisitante)`. Devuelve 2 resultados (el dueño y sus clases). **Tope fijo de 20 clases** dentro del SP (sin parámetros de página ni cantidad: no hay forma de ver más atrás). Mirando el historial propio: Completada, Cancelada y Rechazada vencida. Mirando el de otro (o sin sesión): **solo Completadas**. Cada fila trae solo el **día** (`CAST AS DATE`, la hora no sale de la base), la contraparte, materias (las del **profesor** de la clase), colegios (los del **alumno** de la clase) y la puntuación de la **última reseña que el dueño del historial le dejó a esa persona** (solo reseñas visibles si lo mira otro). `puedeDarResena` = historial propio + clase Completada + sin reseña a esa persona. `obtenerMisClases` dejó de devolver el historial.
- **Cómo pasa una clase al historial** (sin job): `actualizarEstadosClases(@idUsuario)` la llaman los demás SP antes de leer o escribir. Confirmada que ya terminó (`fecha + 60 min <= ahora`) → Completada; Pendiente que llegó a su hora sin respuesta → Rechazada (vencida). Solo actualiza las clases de ese usuario, por eso `obtenerHistorialClases` la llama para el dueño del historial; además `clases.js` pide `/Notificaciones/Contar` cada minuto con una pestaña abierta.
- **Controller propio**: `HistorialController` con `GET /Historial/Obtener/{id}` (sin sesión también; quien mira sale **de la sesión**, nunca del pedido; `NoStore` porque la respuesta cambia según quién mira). `BD.obtenerHistorialClases` y los modelos `ClaseHistorial` / `ResultadoHistorial`.
- **JS propio**: `wwwroot/js/historial.js` (se carga solo en Perfil y Panel con `@section Scripts`). `dibujarHistorial()` arma **la misma tabla** para los dos: Profesor/Alumno · Materia · Colegio · Puntuación · Día (+ "Acción" solo en el Panel de un alumno). Puntuación = estrellas, o botón **Dar reseña** (por ahora solo avisa "muy pronto"; dentro del modal el aviso va en el mismo modal porque el snackbar queda detrás del diálogo), o un guion. Cancelada y Rechazada llevan un badge al lado del día. El nombre de la contraparte lleva a su perfil. **"Pedir otra clase" solo existe en el historial del Panel.**
- **Panel**: la pestaña Historial es un contenedor (`#contenidoHistorialPanel`) que llena `historial.js`. `refrescarPanel()` (clases.js) ya no copia `#tabHistorial`: vuelve a llamar `cargarHistorialPropio()` y devuelve la promesa; `abrirPestanaYClase` espera `esperarHistorialPropio()` antes de resaltar la fila (las filas existen recién cuando termina el fetch).
- **CSS**: la tabla del historial dejó de depender de `.panel` (`.card.tabla`, `.tabla .table`) para que la use también el modal; `.perfil .filaCifras` (cifras + botón), `.dialogoHistorial`, `.notaHistorial` y `.cargandoHistorial`.
- Verificado con Edge y cuentas de prueba (alumno y profesora del seed, clases de prueba que después se borraron): visitante sin sesión, alumno en su perfil y en el de una profesora, historial del Panel, "Pedir otra clase", link `?tab=historial&clase=ID` con la fila resaltada, `refrescarPanel()`, y 1280 px y 390 px sin scroll horizontal ni errores de consola. `dotnet build` sin errores.
- Pendiente: la función **Dar reseña** (el botón ya aparece) y mostrar una foto de la contraparte (el SP ya manda `fotoOtro`).

### 2026-10-15 — Datos de prueba para depurar (datos-prueba.sql / borrar-datos-prueba.sql)
- `datos-prueba.sql` carga 36 usuarios nuevos (24 alumnos y 12 profesores, mail `@seed.mip`, contraseña `Prueba123`, todos con colegio, nivel, perfil y, los profesores, materias, modalidades, títulos y precio), unas 325 clases en todos los estados, ~145 reseñas (con estados Pendiente / Rechazada y varias reseñas al mismo profesor para probar «la última»), 264 Me gusta, 28 chats con mensajes, amigos y consultas de soporte. También suma historial a los usuarios que ya existían: cada reseña vieja ahora tiene su clase completada.
- Casos para probar: Eitan (57) y los alumnos nuevos 1 y 2 superan las 20 clases completadas (tope de 20); el profesor Roberto Maidana (`P1`) también; los alumnos 21 a 24 no tienen ninguna clase (historial vacío); dos alumnos y un profesor quedan sin verificar a propósito; Eitan tiene una clase confirmada en menos de 24 h (muyCerca), una propuesta por responder, una rechazada reubicable y clases sin reseña («Dar reseña»).
- `borrar-datos-prueba.sql` lo deshace por rangos de ID (probado con ROLLBACK) y deja a Eitan con la fecha de «últimas notificaciones vistas» original.

### 2026-10-16 — BD nueva: chat con fetch, notificaciones calculadas y año en los colegios del profesor
- **BD (`MIP-BD.sql`, según el DER nuevo)**: se borraron las tablas `Chats` y `Notificaciones` (con sus datos y constraints) y el SP `marcarNotificacionesVistas`. `Mensajes` pasó a `idEmisor`, `idReceptor`, `contenido` (hasta 1000), `estado` (`No visto` por defecto | `Visto`) y `fechaEnvio`, con FK a `Usuarios` y un CHECK para que nadie se escriba a sí mismo. `Escuelas_Usuarios` sumó `desde` (datetime; se guarda el 1 de enero del año elegido, solo para profesores; los alumnos quedan en NULL). Los datos de ejemplo de `Escuelas_Usuarios` ya traen un año para los profesores.
- **Chat (SP nuevos)**: `enviarMensaje` (resultado `ok` | `mismoUsuario` | `usuarioInexistente` | `mensajeInvalido`), `obtenerConversaciones` (una fila por persona con su último mensaje y cuántos sin leer) y `obtenerChat` (todos los mensajes entre los dos, del más viejo al más nuevo; **al leerlo, los que te mandó la otra persona pasan a `Visto`**).
- **Notificaciones (sin tabla)**: la función `notificacionesDeUsuario` ahora junta lo que está a medio resolver en **Amigos** (solicitudes `Pendiente` que te mandaron; `idUsuario1` = quien la envía), **Mensajes** (uno por persona con mensajes `No visto`) y **Clases** (pedidos o propuestas que te toca responder y horarios tuyos que rechazaron). `obtenerNotificaciones` y `contarNotificaciones` leen de ahí, así que cada notificación desaparece sola cuando se resuelve (no hay "vistas").
- **Código**: `MensajesController` (`GET /Mensajes/Conversaciones`, `GET /Mensajes/Chat/{id}`, `POST /Mensajes/Enviar` con `[ValidateAntiForgeryToken]`; el usuario sale de la sesión), modelos en `MensajeChat.cs`, `NotificacionUsuario` con los campos nuevos y `wwwroot/js/chat.js` (solo en el Panel). El chat del Panel dejó de ser una maqueta: lista de conversaciones, chat abierto con separadores de día, hora y tildes (una = enviado, dos = visto) y envío, todo con fetch. Mientras la pestaña está a la vista se actualiza cada 10 s; con la pestaña oculta no se piden mensajes (si no, se marcarían como leídos sin verlos). Al abrir un chat se va su notificación y se actualizan los contadores. Se entra desde la pestaña, desde la notificación ("Abrir chat"), desde **"Ir al chat"** de una clase muy próxima y desde el botón **Mensaje** de cualquier perfil (`/Home/PanelControl?tab=chat&chat=ID`, aunque todavía no hayan hablado). Se borró `enviarMensajeChat()` de `site.js`.
- **Colegios del profesor**: en "Editar perfil", por cada colegio elegido aparece un campo para el año desde el que da clase ahí (solo el año, entre 1950 y el actual). Se manda como `idsEscuelas = "20:2015,21:2019"` y lo valida el servidor y el SP `guardarPerfilCompleto` (`anioColegioInvalido`). `obtenerDatosEdicion` devuelve el año de cada colegio y `obtenerPerfil` muestra "Colegio (desde 2015)".
- **Datos de prueba**: `datos-prueba.sql` carga los mensajes con emisor/receptor/estado (28 chats, el final de 2 de cada 3 queda sin leer) y el año de los colegios de los profesores; `borrar-datos-prueba.sql` ya no toca `Chats` ni `Notificaciones`.
- **Para aplicarlo**: borrar la base `MIP`, correr `MIP-BD.sql` y después `datos-prueba.sql` (cambiaron tablas, así que no alcanza con actualizar los SP).
- Verificado con SQL Server 2022 y el sitio corriendo contra esa base (cuentas del seed, Chromium a 1280 y 390 px): notificaciones de los 3 tipos, abrir chat desde la notificación y desde el perfil, contacto nuevo, enviar, "visto" que le llega al otro, "Ir al chat" de una clase muy próxima, años de los colegios (vacío, fuera de rango y guardado), modal del alumno sin cambios. `dotnet build` sin errores ni advertencias.
- Pendiente: **aceptar o rechazar solicitudes de amistad** (hecho el 2026-10-19, ver abajo).

### 2026-10-19 — Datos de prueba dentro de MIP-BD.sql y solicitudes de amistad desde la notificación
- **Datos de prueba en `MIP-BD.sql`** (sección «Datos de prueba», al final, antes de `USE [master]`): simulan unos dos años de uso. 456 cuentas (las 56 que ya estaban y 400 nuevas: ~90 profesores y ~310 alumnos, con DNI, dirección, colegio, nivel, perfil y, los profesores, materias, títulos, modalidades, precio y año en cada colegio; unas pocas cuentas recientes quedan incompletas a propósito), ~3800 clases en todos los estados (historial desde hace casi dos años, clases próximas, pedidos y propuestas por responder), ~520 reseñas (algunas Pendiente y Rechazada), ~1500 Me gusta, ~450 amistades (algunas pendientes), ~3300 mensajes en ~440 chats (lo más reciente de algunos queda sin leer) y 110 consultas de soporte.
- **Cuentas**: todas con contraseña `12345678` y mail `nombre.apellido@mip.edu.ar` (en minúscula y sin tildes; si se repite, con un número: `juan.perez2@mip.edu.ar`). Las que ya existían también cambiaron (Eitan es `eitan.glaz@mip.edu.ar`). Para probar: `eitan.glaz@mip.edu.ar` (alumno con más de 20 clases, una confirmada a menos de 24 h, un pedido esperando al profesor, una propuesta y un horario rechazado por responder, 3 solicitudes de amistad y 2 chats sin leer) y `sofia.martinez@mip.edu.ar` (profesora con 2 pedidos por responder y chats sin leer).
- **Fechas relativas**: todo se calcula desde el momento en que se corre el script (`@hoy`, `@ahora`), así que el sitio siempre parece en uso. `verificado` sale de `faltantesVerificacion`, la misma regla que usa el sitio. Las 2 clases sueltas de prueba que había quedaron reemplazadas por las generadas.
- **Se borraron `datos-prueba.sql` y `borrar-datos-prueba.sql`**: ya no hacen falta (y sus cuentas `@seed.mip` no existen más).
- **Solicitudes de amistad**: la notificación ahora trae **Aceptar** y **Rechazar** (antes llevaba a un perfil donde no se podía responder). SP nuevo `responderSolicitudAmistad` (aceptar → `Aceptada`; rechazar → se borra la fila para que se pueda volver a mandar), `POST /Notificaciones/ResponderAmistad` y `inicializarSolicitudesDeAmistad()` en `clases.js`. La notificación se va sin recargar, se actualizan los contadores y el foco pasa a la notificación siguiente. `quitarNotificacion()` pasó de `chat.js` a `clases.js` para que la usen los dos.
- **Chat en celular**: la lista de conversaciones es horizontal; ahora cada una es más angosta y asoma la siguiente, así se nota que hay más.
- **Para aplicarlo**: borrar la base `MIP` y correr `MIP-BD.sql` (trae las tablas, los SP y los datos).
- Verificado con SQL Server 2022 y el sitio corriendo contra esa base: el script corre sin errores, login con `12345678`, ningún mensaje ni clase anterior a la inscripción de sus usuarios, toda reseña tiene una clase completada, aceptar y rechazar solicitudes (contadores, foco y recarga), chat y notificaciones a 1280 y 375 px sin errores de consola. `dotnet build` sin errores ni advertencias.
