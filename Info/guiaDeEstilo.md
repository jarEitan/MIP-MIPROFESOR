# GUÍA DE ESTILO — cómo se escribe el código en MIP

> Esta guía resume **la filosofía** con la que Eitan organiza su código (sacada de `TP-Sala-de-escape`, `bootstrap` y `TP06-ARTE`), no el código ni el estilo visual de esos proyectos.
> Sirve para que quien lo toque después (humano o IA) pueda **debuggear y editar rápido** porque todo está donde espera encontrarlo.
> Se lee junto con [systemPrompt.md](systemPrompt.md) (reglas) y [log.md](log.md) (historial y estado).

---

## 1. La filosofía en una frase

**Pocas clases, muy reutilizadas, que cambian de aspecto según dónde están.**
Una clase base (`.boton`, `.card`, `.icono`) + un modificador de una palabra (`.principal`, `.coral`, `.celeste`) + selectores descendientes (`.portada .card h3`) para especializar sin inventar nombres nuevos.

---

## 2. CSS: un solo archivo, en orden fijo

`wwwroot/css/site.css` es el **único** CSS propio. Se recorre de arriba hacia abajo como se recorre la página:

| Bloque | Qué va |
|---|---|
| `0) VARIABLES Y BASE` | `@font-face`, `:root` con la marca, mapeo a los tokens `--bs-*`, escala en pantallas grandes |
| `1) HEADER` | Encabezado, logo, menú, drawer móvil, menú de usuario |
| `2) ETIQUETAS GENERALES Y COMPONENTES REUTILIZABLES` | `section`, `h1…h5`, `mark`, `a`, `.pildora`, `.boton`, `.card`, `.icono`, `.badge`, `.avatar`, formularios, `.buscador`, `.burbuja`, animaciones |
| `3) MAIN` | Una sub-sección por zona **en el orden en que aparecen en la página** (`.portada`, `.cinta`, `.pasos`, `.perfiles`, `.funciones`, `.destacados`, `.opiniones`, `.preguntas`, `.llamadoFinal`, luego cada página: `.catalogo`, `.acceso`, `.ayuda`, `.panel`, `.mision`, `.equipo`, `.identidad`, `.proceso`) |
| `4) FOOTER` | `.pie` |
| `5) ACCESIBILIDAD DE MOVIMIENTO` | `prefers-reduced-motion` |

### Comentarios
Banner de **3 líneas** para cada bloque grande, línea con guiones para cada página o componente, y un comentario de **una línea** para lo que se ve raro:

```css
/* =========================================================
   3) MAIN
   ========================================================= */

/* ---------- 3.11 Catálogo ---------- */

/* Desde lg el formulario es la tarjeta con borde */
```

Los comentarios explican **por qué** (un bug de Bootstrap, una decisión de diseño), no repiten lo que dice la regla.

### Nombres
- `camelCase`, en español, descriptivos: `.llamadoFinal`, `.enlacesExternos`, `.mensajeError`.
- Nada genérico (`hero`, `box`, `item1`). La portada es `.portada`, no `.hero`.
- Una palabra para los **modificadores**: `.boton .principal`, `.card .coral`, `.icono .celeste`.
- La zona (`<section class="catalogo">`) le da el contexto a todo lo de adentro: no hace falta repetirlo en cada hijo.

### Cómo se reutiliza (vocabulario base)

| Base | Modificadores | Se especializa con |
|---|---|---|
| `.boton` | `.principal` `.secundario` `.contorno` `.oscuro` `.claro` `.chico` | `.portada .boton`, `.llamadoFinal .boton` |
| `.card` | `.coral` `.oscura` `.estatica` (sin levitar) | `.funciones .card`, `.perfiles .card.oscura` |
| `.icono` | `.coral` `.celeste` `.oscuro` | `.pasos .icono` |
| `.pildora` | — | `.cabecera .pildora` |
| `.encabezadoSeccion` | — | píldora + h2 + p centrados al inicio de cada sección |
| `.cabecera` | `.oscura` | portada interna de Catálogo, Soporte, Quiénes somos, Privacidad |
| `.badge`, `.avatar`, `.burbuja` | — | `.chat .burbuja`, `.portada .burbuja` |

Antes de crear una clase nueva: ¿se resuelve con una existente + un selector descendiente? Si sí, no se crea.

### Bootstrap hace el layout, el CSS propio hace la marca
- Grilla, espaciado, alineación y visibilidad van **en el HTML** con utilidades de Bootstrap (`row`, `col-*`, `d-flex`, `gap-3`, `md:col-6`).
- `site.css` no repite lo que Bootstrap ya da: solo color, borde, sombra, tipografía y detalles de marca.
- Lo repetido se ata a **variables** (`--colorCoral`, `--colorTinta`, `--sombraMarcada`, `--bordeMarcado`, `--espacioSeccion`…), no a valores sueltos.

---

## 3. HTML / Razor

- `<section class="zona">` para cada zona grande y **aislada**; `<div>` para los ítems de adentro.
- Una sección = una clase propia (`<section class="pasos">`). El orden del HTML coincide con el orden del CSS.
- Partials para lo que se repite (`_marcaLogo`, `_tarjetaProfesor`, `_preguntasFrecuentes`, `_encabezadoInvitado/Usuario`, `_piePagina`).
- Los datos de prueba viven en el controlador con un comentario `// TODO BD:`; la vista nunca los inventa.
- Sesión: `@if (Context.Session.GetString("idUsuario") == null) { … }` (sintaxis de systemPrompt).
- Íconos: `<i class="bi bi-nombre" aria-hidden="true"></i>` (Bootstrap Icons local).

---

## 4. JavaScript

- Un solo archivo, `wwwroot/js/site.js`: **una función por cosa**, cada una sale temprano si su elemento no existe, y todas se llaman desde `inicializarSitio()`.
- Validación con el patrón del systemPrompt (`mensaje.innerHTML = "…"; mensaje.style.display = "block"; return false;`) mediante `mostrarMensaje` / `mostrarErrorEnCampo`.
- Los `fetch` van comentados con `TODO BD` hasta que exista el endpoint.
- Nombres de función = verbo + objeto: `validarRegistro`, `inicializarFiltrosCatalogo`, `enviarMensajeChat`.

---

## 5. Bootstrap 6 (alpha): lo que hay que saber para no perder tiempo

Versión vendorizada en `wwwroot/lib/bootstrap/dist` (**6.0.0-alpha.1**). Es alpha: puede cambiar antes de la versión final.

1. **Los breakpoints son prefijos, no sufijos**: `md:col-6`, `lg:navbar-expand`, `sm:d-none`, `lg:order-2`. (En BS5 era `col-md-6`, `order-lg-2`.) Breakpoints: sm 576 · md 768 · lg 1024 · xl 1280 · 2xl 1536.
2. **JS solo como módulo ES**: el layout lo carga con `<script type="module" src="~/lib/bootstrap/dist/js/bootstrap.bundle.min.js">`. No sirve un `<script>` común ni jQuery.
3. **Componentes nuevos**: Drawer (`<dialog class="drawer drawer-end">`, `data-bs-toggle="drawer"`) en vez de offcanvas; Dialog (`<dialog>`) en vez de modal; Menu en vez de dropdown; acordeón con `<details name="…">`; carrusel con scroll-snap (`--bs-carousel-items` se define **en el `.carousel`**, no en un ancestro).
4. **Capas (`@layer`)**: los estilos de Bootstrap están en capas, así que el CSS propio (sin capa) gana en declaraciones normales. **Pero** Bootstrap usa `!important` dentro de capas en algunos casos (por ejemplo `.lg:drawer` desde 1024px): ahí no se puede pisar. La salida es estilar el **hijo** (el `form` dentro del drawer es la tarjeta con borde), no el contenedor.
5. **El header responde al contenedor, no a la ventana**: `.navbar` es `container-type: inline-size`, por eso las reglas del header usan `@container (width >= 1024px)` y no `@media`. Con `@media` el corte difiere ~15px (ancho de la barra de scroll).
6. **Tokens**: el tema se arma con `--bs-*` y las clases `theme-*`. En `:root` se mapea `primary` = coral, `accent` = celeste, `danger` = magenta `#D51F47`, `inverse` = tinta. Los colores de enlace salen de `--bs-theme-fg`.
7. `text-danger` ya no existe como en BS5: se usa `fg-danger`.

---

## 6. Antes de dar algo por terminado

- Revisar a **390, 768, 1024, 1280 y 1920 px**: sin scroll horizontal ni errores en consola.
- Que toda clase usada en las vistas exista en `site.css` o en Bootstrap.
- Que el orden de `site.css` siga Header → generales → Main (en orden de página) → Footer.
- Agregar una entrada nueva en el **Historial de cambios** de [log.md](log.md).
