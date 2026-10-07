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
| CSS / layout | **Bootstrap 5.3.3** local (`wwwroot/lib/bootstrap`) + **un solo** CSS propio: `wwwroot/css/site.css` |
| JS | Vanilla JS modular en `wwwroot/js/site.js` + `bootstrap.bundle.min.js`. **jQuery quitado del layout** (los archivos siguen en `wwwroot/lib`; si una vista usa `_ValidationScriptsPartial`, agregar jQuery en su `@section Scripts`) |
| Fuente | **Plus Jakarta Sans** variable (200–800) **local** en `wwwroot/fonts/` (`@font-face` al inicio de `site.css`, precargada en el layout). Origen: `@fontsource-variable/plus-jakarta-sans@5.1.1` |
| Íconos | **Bootstrap Icons 1.11.3** local en `wwwroot/lib/bootstrap-icons/` → `<i class="bi bi-nombre" aria-hidden="true"></i>`. Catálogo: https://icons.getbootstrap.com |
| BD | SQL Server + **Dapper 2.1.89** + `Microsoft.Data.SqlClient 7.1.1`. Todo en `Models/BD.cs` (hoy **vacío**) |
| Sesión | `Microsoft.AspNetCore.Session` ya configurado en `Program.cs` (`AddDistributedMemoryCache`, `AddSession`, `UseSession`) |

> ⚠️ Todavía **no hay archivo `.sql`** en la raíz. El systemPrompt exige leerlo antes de escribir queries.

---

## 3. Referencias de diseño

- **Figma** (prototipo + UI kit) y **Miro**: configurados como MCP en `.mcp.json` (raíz), pero **sin autenticar** al momento de crear la landing. Los textos de la landing NO salieron del Figma.
  - Para conectarlos: abrir Claude → `/mcp` → `figma` → *Authenticate*, igual con `miro`.
  - ⚠️ `.mcp.json` está versionado; si no se quiere en el repo, agregarlo a `.gitignore`.
- Estilo visual tomado de dos prototipos (Tailwind) del equipo:
  - https://eclectic-semolina-f2b73a.netlify.app/ → **Panel de Control** (logueado): tabs laterales, tarjetas de clase, tabla historial, chat, form configuración.
  - https://gorgeous-crumble-edc300.netlify.app/ → **Soporte**: hero con degradado coral→tinta, buscador, 3 tarjetas, FAQ, formulario.
  - Ambos comparten header (logo + Inicio / Catálogo / Mi Colegio / Soporte + botón "Panel de Control" + avatar) y footer (4 columnas).
  - Sirven de guía para las próximas vistas (PanelControl y Soporte).

---

## 4. Sistema de diseño (tokens en `:root` de `site.css`)

### Colores
| Variable | Valor | Uso |
|---|---|---|
| `--colorCoral` | `#FF5757` | Marca, botón principal, títulos de logo |
| `--colorCoralOscuro` | `#D51F47` | Hover de coral, links, errores |
| `--colorCoralSuave` | `#FFE8E8` | Fondos suaves |
| `--colorCeleste` | `#5CE1E6` | Acento, píldoras, botón secundario, foco |
| `--colorCelesteSuave` | `#DDF8F9` | Fondos suaves, acordeón activo |
| `--colorTinta` | `#111827` | Texto, bordes marcados, footer |
| `--colorFondo` / `--colorSuperficie` | `#F9FAFB` / `#FFF` | Fondo página / tarjetas |
| `--colorBorde` | `#E5E7EB` | Bordes sutiles |
| `--colorTextoSuave` | `#6B7280` | Texto secundario |
| `--colorExito` / `--colorExitoSuave` | `#047857` / `#D1FAE5` | Estado "Confirmada" |

### Lenguaje visual
- Estilo **"neo-brutal suave"**: borde 2px tinta (`--bordeMarcado`) + **sombra desplazada sólida** (`--sombraMarcada: 4px 4px 0`).
  Hover: se "levanta" (`translate(-2px,-2px)` + sombra más grande). Active: se "hunde".
- **Escala compacta** (pedido del cliente: "todo demasiado grande"): texto base `15px` (`--bs-body-font-size: .9375rem`), header `4rem` de alto con logo `2.5rem`, botones `.85rem`, h2 máx `2.125rem`, h3 máx `1.125rem`, tarjetas con padding `1.35–1.5rem`, secciones `clamp(3rem, 6vw, 5rem)`. **La portada conserva los tamaños grandes** (override `.seccionPortada .botonMip` y `.seccionPortada .etiquetaPildora`). Respetar esta escala en vistas nuevas.
- Radios: `--radioChico .75rem`, `--radioMedio 1rem`, `--radioGrande 1.5rem`, `--radioExtraGrande 2rem`.
- Curvas: `--curvaSuave` (salidas), `--curvaRebote` (íconos que rotan/escalan).
- Tipografía fluida con `clamp()`; espaciado vertical de secciones `--espacioSeccion` (fluido).
- Bootstrap integrado vía variables (`--bs-body-font-family`, `--bs-link-color-rgb`, etc.).

### Componentes reutilizables (sección 2 del CSS)
| Clase | Qué es |
|---|---|
| `.botonMip` + `.botonPrincipal` / `.botonSecundario` / `.botonContorno` / `.botonOscuro` / `.botonClaro` | Botones de marca (combinar base + variante) |
| `.etiquetaPildora` | Badge celeste en mayúsculas |
| `.encabezadoSeccion` | Bloque centrado píldora + h2 + p al inicio de cada sección |
| `.iconoTarjeta` + `.iconoCoral` / `.iconoCeleste` / `.iconoOscuro` | Ícono cuadrado (2.5rem) con un `<i class="bi ...">` adentro; la variante define fondo y color |
| `.mensajeError` | Mensaje de validación (oculto; JS lo muestra con `display:block`) |
| `.animarEntrada` | Animación de entrada al cargar (usa `--retrasoAnimacion`) |
| `.revelarAlScroll` | Aparece al entrar en pantalla (JS agrega `.estaVisible`). Escalonar con `style="--retrasoAnimacion: .12s"` |
| `.marcaLogo` | Logo + texto "MiProfesor" (header y footer) |

### Keyframes disponibles
`aparecerDesdeAbajo`, `flotarTarjeta`, `flotarFigura`, `desplazarCinta`, `moverDegradado`, `sacudirError`.

---

## 5. Mapa de archivos (estado actual)

```
Controllers/HomeController.cs      Index (llena ViewBag.materiasDestacadas), Privacy, Error
Models/BD.cs                       VACÍO — acá van todas las consultas Dapper
Views/_ViewImports.cshtml          + @using Microsoft.AspNetCore.Http (para Session en vistas)
Views/Shared/_Layout.cshtml        Esqueleto: head (fuente, bootstrap, site.css, script jsActivo),
                                   header según sesión, <main class="contenidoPrincipal">, footer, scripts
Views/Shared/_encabezadoInvitado.cshtml   Header SIN sesión (Inicio, Catálogo, Cómo funciona, Soporte,
                                          Iniciar sesión, Crear cuenta). Offcanvas en < lg
Views/Shared/_encabezadoUsuario.cshtml    Header CON sesión (esqueleto: Inicio, Catálogo, Mi Colegio,
                                          Soporte, Panel de Control, avatar con iniciales)
Views/Shared/_piePagina.cshtml     Footer 4 columnas + derechos con año dinámico
Views/Home/Index.cshtml            Landing (ver §6)
Views/Home/Privacy.cshtml          Plantilla, envuelta en <section><div class="container-xl">
wwwroot/css/site.css               ÚNICO CSS propio
wwwroot/js/site.js                 ÚNICO JS propio
wwwroot/img/logo.png               Logo MIP original (4961 px, 452 KB) — NO usar en vistas
wwwroot/img/logoChico.png          Logo 256 px (19 KB) — el que usan las vistas y el favicon
wwwroot/fonts/                     Plus Jakarta Sans (latin + latin-ext, woff2)
wwwroot/lib/bootstrap-icons/       Bootstrap Icons (css + fuentes)
Views/Shared/_marcaLogo.cshtml     Logo + "MiProfesor" (usado en ambos headers y en el footer)
Info/systemPrompt.md               Reglas de código
Info/log.md                        Este archivo
.mcp.json                          Servidores MCP Figma y Miro
```

Se **eliminó** `Views/Shared/_Layout.cshtml.css` (CSS aislado de la plantilla que pisaba el color de los links y posicionaba el footer en absoluto). Regla: un solo CSS.

---

## 6. Landing (`Views/Home/Index.cshtml`)

Cada zona grande es una `<section>` aislada; los ítems internos son `<div>`.

| # | Sección (clase) | Contenido | Responsive |
|---|---|---|---|
| 1 | `.seccionPortada` | Píldora, h1 "Encontrá al profesor ideal para tu colegio", texto, **buscador** (`#formularioBuscador`), botones "Soy alumno" / "Quiero enseñar". Derecha: 3 tarjetas **decorativas** (`aria-hidden`) que flotan: profesor, clase confirmada, chat | < md: tarjetas apiladas. ≥ md: composición superpuesta y rotada. Texto centrado < lg, alineado a la izquierda ≥ lg |
| 2 | `.seccionCintaMaterias` | Cinta infinita con `ViewBag.materiasDestacadas` (lista duplicada para loop sin corte). Pausa en hover | Tamaño de letra fluido |
| 3 | `.seccionComoFunciona` (`#seccionComoFunciona`) | 3 pasos: Creá tu cuenta / Buscá y filtrá / Coordiná y aprendé | `col-12 col-md-4` |
| 4 | `.seccionPerfiles` | Tarjeta alumno (coral claro) y profesor (oscura) con beneficios y CTA a registro con `?rol=` | `col-12 col-lg-6` |
| 5 | `.seccionFuncionalidades` | 6 tarjetas: Filtro por colegio, Chat directo, Cancelar o reubicar, Presencial o virtual, Historial, Reseñas | `row-cols-1 row-cols-sm-2 row-cols-lg-3` |
| 6 | `.seccionPreguntasFrecuentes` | Acordeón Bootstrap (3 FAQ tomadas del prototipo de Soporte) + link a Soporte | `col-lg-9 col-xl-8` centrado |
| 7 | `.seccionLlamadoFinal` | Bloque con degradado animado + "Crear cuenta gratis" / "Ver catálogo" | Botones en columna/fila según breakpoint |

Los **textos son provisorios** (derivados de los prototipos), falta contrastarlos con Figma.

---

## 7. JavaScript (`wwwroot/js/site.js`)

Patrón: una función por módulo, todas llamadas desde `inicializarSitio()` en `DOMContentLoaded`. Cada función sale temprano si su elemento no existe (así el mismo archivo sirve para todas las páginas).

| Función | Qué hace |
|---|---|
| `inicializarEncabezadoConScroll()` | Agrega `.encabezadoConSombra` al header cuando `scrollY > 8` |
| `inicializarCierreMenuMovil()` | Cierra el offcanvas al tocar un link ancla `#...` |
| `inicializarRevelarAlScroll()` | IntersectionObserver → `.estaVisible` (fallback si no hay soporte) |
| `validarBusqueda()` | Validación DOM del buscador (vacío / < 2 caracteres) con el patrón del systemPrompt. Llamada desde `onsubmit` |
| `inicializarBuscador()` | Oculta el error al escribir. Tiene **fetch comentado** para sugerencias en vivo |

La clase `jsActivo` se pone en `<html>` con un script inline en el `<head>` del layout: los elementos `.revelarAlScroll` solo se ocultan si hay JS, así nunca queda contenido invisible.

---

## 8. Sesión y rutas preparadas (aún no existen)

**Sesión** — el layout decide el header:
```csharp
@if (Context.Session.GetString("idUsuario") == null) { <partial name="_encabezadoInvitado" /> }
else { <partial name="_encabezadoUsuario" /> }
```
Claves previstas al hacer login: `idUsuario`, `nombreUsuario`, `inicialesUsuario` (y sugerido `rolUsuario`).
Logout: `HttpContext.Session.Clear();`

**Rutas linkeadas que hoy dan 404** (todas en `HomeController` por simplicidad):
`Catalogo` (recibe `?busqueda=`), `Soporte`, `IniciarSesion`, `Registrarse` (recibe `?rol=alumno|profesor`), `QuienesSomos`, `MiColegio`, `PanelControl`.

---

## 9. Pendientes (TODO)

- [ ] Autenticar Figma y Miro y **reemplazar textos y ajustar estilo** de la landing según el prototipo (link del Figma: https://www.figma.com/design/HDhfuOx62CKtV0MSiQWDl4/MIP?node-id=0-1). Pedido explícito del cliente: que contenido y estilo se parezcan más al Figma; la **portada ya está aprobada**, ajustar el resto.
- [ ] Recibir el **`.sql`** de la BD (Tobias) y ponerlo en la raíz.
- [ ] Implementar `BD.cs` (cadena de conexión en `appsettings.json` → `ConnectionStrings`).
- [ ] `HomeController.Index`: reemplazar la lista fija por `BD.ObtenerMateriasDestacadas()`.
- [ ] Crear acciones + vistas: `Catalogo`, `Soporte`, `IniciarSesion`, `Registrarse`, `QuienesSomos`, `MiColegio`, `PanelControl`.
- [ ] Login/registro guardando las claves de sesión (§8).
- [ ] Endpoint JSON de sugerencias para el buscador (fetch ya comentado en `site.js`).
- [x] ~~Reducir `logo.png`~~ → `logoChico.png` 256 px. (Opcional: versión SVG si el diseñador la tiene en Figma.)
- [ ] Reemplazar textos de Privacy (sigue con la plantilla en inglés).

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
- Si `site.css` crece mucho, mantener **un solo archivo** (regla) pero respetar el orden de secciones y agregar un índice al inicio por página: `3.x Landing`, `3.x Catálogo`, `3.x Panel`, etc.
- Al crear vistas nuevas, **reusar** `.botonMip`, `.etiquetaPildora`, `.encabezadoSeccion`, `.iconoTarjeta`, `.revelarAlScroll` antes de inventar clases nuevas.
- ~~Header con sesión: link activo + badge de notificaciones~~ → **hecho** (`.insigniaNotificaciones` + `.pulsoNotificaciones`, lee `Session["cantidadNotificaciones"]`).
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
