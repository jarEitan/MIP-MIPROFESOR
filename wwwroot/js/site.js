// =====================================================================
// MiProfesor (MIP) - JavaScript global
// Cada módulo es una función independiente que se inicializa al final.
// Para agregar funciones nuevas: crear la función y sumarla a inicializarSitio().
//
// Bootstrap 6 es ESM y ya no expone window.bootstrap: sus componentes (drawer,
// dialog, menu, tabs, carrusel, acordeón) funcionan solos con los atributos
// data-bs-* del HTML. Acá solo va la lógica propia de MIP.
// =====================================================================


// ================= UTILIDADES =================
// Los mensajes de error se muestran solos: el CSS oculta ".mensajeError:empty"
function mostrarMensaje(elementoMensaje, texto) {
    if (elementoMensaje) elementoMensaje.textContent = texto;
}

function mostrarErrorEnCampo(elementoMensaje, campo, texto) {
    mostrarMensaje(elementoMensaje, texto);
    // Si el campo es un <select data-buscable>, el foco va a su campo de texto visible
    const campoVisible = campo && campo.hidden && campo.nextElementSibling?.classList.contains("selectorBuscable")
        ? campo.nextElementSibling.querySelector("input")
        : campo;
    if (campoVisible) campoVisible.focus();
    return false;
}

// Quita tildes y mayúsculas para comparar textos ("Matemática" = "matematica")
function normalizarTexto(texto) {
    return (texto || "").normalize("NFD").replace(/[̀-ͯ]/g, "").toLowerCase().trim();
}

function correoValido(correo) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(correo);
}

// fetch que devuelve el JSON o falla si el servidor respondió con error (401, 404, 500...)
function pedirJson(url, opciones) {
    return fetch(url, opciones).then(respuesta => {
        if (!respuesta.ok) throw new Error(`Error ${respuesta.status} en ${url}`);
        return respuesta.json();
    });
}

// Snackbar del UI Kit: aviso corto abajo de la pantalla. tipo: "info" | "exito" | "error"
let temporizadorSnackbar = null;

function mostrarSnackbar(texto, tipo = "info") {
    const snackbar = document.getElementById("snackbar");
    if (!snackbar) return;

    snackbar.textContent = texto;
    snackbar.dataset.tipo = tipo;
    snackbar.hidden = false;
    // Se reinicia la animación aunque ya hubiera uno visible
    snackbar.classList.remove("visible");
    void snackbar.offsetWidth;
    snackbar.classList.add("visible");

    clearTimeout(temporizadorSnackbar);
    temporizadorSnackbar = setTimeout(() => {
        snackbar.classList.remove("visible");
        setTimeout(() => { snackbar.hidden = true; }, 300);
    }, 3200);
}


// ================= COMPONENTE: SELECTOR CON BÚSQUEDA =================
// Convierte cualquier <select data-buscable> (simple o "multiple") en un campo con una lista que se
// puede scrollear y que se va filtrando mientras se escribe. El <select> original queda oculto y
// sigue mandando: formularios y filtros leen su value / selectedOptions y escuchan su "change".
//   data-placeholder="..."  texto del campo vacío (si no, el de la opción con value="")
//   En el simple, la opción value="" ("Todas las materias", "Sin elegir") sirve para borrar la elección.
//   En el múltiple, lo elegido se muestra como etiquetas con una ✕ para quitarlo.
// Si las opciones cambian por JS, volver a llamar a crearSelectorBuscable(select).
let contadorSelectoresBuscables = 0;

function inicializarSelectoresBuscables() {
    document.querySelectorAll("select[data-buscable]").forEach(crearSelectorBuscable);
}

function crearSelectorBuscable(select) {
    // Ya estaba armado: solo se redibuja con las opciones nuevas
    if (select.actualizarSelectorBuscable) {
        select.actualizarSelectorBuscable();
        return;
    }

    const esMultiple = select.multiple;
    const idBase = select.id || `selectorBuscable${++contadorSelectoresBuscables}`;

    const selector = document.createElement("div");
    selector.className = esMultiple ? "selectorBuscable multiple" : "selectorBuscable";

    const etiquetasElegidas = document.createElement("div");
    etiquetasElegidas.className = "etiquetasElegidas";

    const campo = document.createElement("div");
    campo.className = "campoSelector";

    const entrada = document.createElement("input");
    entrada.type = "text";
    entrada.className = "form-control";
    entrada.id = `${idBase}Buscador`;
    entrada.autocomplete = "off";
    entrada.spellcheck = false;
    entrada.setAttribute("role", "combobox");
    entrada.setAttribute("aria-autocomplete", "list");
    entrada.setAttribute("aria-expanded", "false");
    entrada.setAttribute("aria-controls", `${idBase}Lista`);

    const botonDesplegar = document.createElement("button");
    botonDesplegar.type = "button";
    botonDesplegar.className = "desplegar";
    botonDesplegar.tabIndex = -1;
    botonDesplegar.setAttribute("aria-label", "Mostrar opciones");
    botonDesplegar.innerHTML = '<i class="bi bi-chevron-down" aria-hidden="true"></i>';

    const lista = document.createElement("ul");
    lista.className = "listaOpciones";
    lista.id = `${idBase}Lista`;
    lista.setAttribute("role", "listbox");
    if (esMultiple) lista.setAttribute("aria-multiselectable", "true");
    lista.hidden = true;

    campo.append(entrada, botonDesplegar);
    if (esMultiple) selector.append(etiquetasElegidas);
    selector.append(campo, lista);

    // La etiqueta del <select> pasa a apuntar al campo de texto
    const etiqueta = select.id ? document.querySelector(`label[for="${select.id}"]`) : null;
    if (etiqueta) etiqueta.htmlFor = entrada.id;

    select.hidden = true;
    select.tabIndex = -1;
    select.insertAdjacentElement("afterend", selector);

    let textoFiltro = "";
    let indiceActivo = -1;

    const textoPlaceholder = () => select.dataset.placeholder
        || Array.from(select.options).find(opcion => opcion.value === "")?.textContent
        || "Elegí una opción";
    const itemsDeLista = () => Array.from(lista.querySelectorAll("[role='option']"));
    const avisarCambio = () => select.dispatchEvent(new Event("change", { bubbles: true }));

    // Muestra lo elegido: texto en el campo (simple) o etiquetas (múltiple)
    const mostrarElegidas = () => {
        entrada.placeholder = textoPlaceholder();
        if (!esMultiple) {
            const elegida = select.selectedOptions[0];
            entrada.value = elegida && elegida.value !== "" ? elegida.textContent : "";
            return;
        }

        entrada.value = "";
        etiquetasElegidas.replaceChildren();
        Array.from(select.selectedOptions).filter(opcion => opcion.value !== "").forEach(opcion => {
            const etiquetaElegida = document.createElement("span");
            etiquetaElegida.className = "badge theme-accent";
            etiquetaElegida.textContent = opcion.textContent;

            const botonQuitar = document.createElement("button");
            botonQuitar.type = "button";
            botonQuitar.setAttribute("aria-label", `Quitar ${opcion.textContent}`);
            botonQuitar.innerHTML = '<i class="bi bi-x" aria-hidden="true"></i>';
            botonQuitar.addEventListener("click", () => {
                opcion.selected = false;
                mostrarElegidas();
                if (!lista.hidden) dibujarOpciones();
                avisarCambio();
            });

            etiquetaElegida.append(botonQuitar);
            etiquetasElegidas.append(etiquetaElegida);
        });
        etiquetasElegidas.hidden = etiquetasElegidas.children.length === 0;
    };

    const marcarActiva = nuevoIndice => {
        const items = itemsDeLista();
        if (items.length === 0) {
            indiceActivo = -1;
            entrada.removeAttribute("aria-activedescendant");
            return;
        }
        indiceActivo = Math.max(0, Math.min(nuevoIndice, items.length - 1));
        items.forEach((item, posicion) => item.classList.toggle("activa", posicion === indiceActivo));
        entrada.setAttribute("aria-activedescendant", items[indiceActivo].id);
        items[indiceActivo].scrollIntoView({ block: "nearest" });
    };

    const dibujarOpciones = () => {
        lista.replaceChildren();
        const filtro = normalizarTexto(textoFiltro);
        // La opción vacía ("Todas las materias") solo aparece en el simple y cuando no se está buscando
        const coincidencias = Array.from(select.options).filter(opcion =>
            !opcion.disabled
            && !(opcion.value === "" && (esMultiple || filtro !== ""))
            && normalizarTexto(opcion.textContent).includes(filtro));

        // Primero las que tienen una palabra que empieza con lo escrito ("ort" → "ORT" antes que "Northlands")
        if (filtro !== "") {
            const empiezaConElFiltro = opcion => normalizarTexto(opcion.textContent).split(/\s+/).some(palabra => palabra.startsWith(filtro));
            coincidencias.sort((opcionA, opcionB) => Number(empiezaConElFiltro(opcionB)) - Number(empiezaConElFiltro(opcionA)));
        }

        if (coincidencias.length === 0) {
            const sinCoincidencias = document.createElement("li");
            sinCoincidencias.className = "sinCoincidencias";
            sinCoincidencias.textContent = "No hay coincidencias";
            lista.append(sinCoincidencias);
            marcarActiva(-1);
            return;
        }

        coincidencias.forEach((opcion, posicion) => {
            const item = document.createElement("li");
            item.id = `${lista.id}Opcion${posicion}`;
            item.setAttribute("role", "option");
            item.setAttribute("aria-selected", String(opcion.selected));
            item.classList.toggle("vacia", opcion.value === "");
            item.textContent = opcion.textContent;
            if (opcion.selected && opcion.value !== "") {
                const tilde = document.createElement("i");
                tilde.className = "bi bi-check-lg";
                tilde.setAttribute("aria-hidden", "true");
                item.append(tilde);
            }
            // pointerdown no saca el foco del campo, así la lista no se cierra antes del click
            item.addEventListener("pointerdown", evento => evento.preventDefault());
            item.addEventListener("click", () => elegirOpcion(opcion));
            item.opcionDelSelect = opcion;
            lista.append(item);
        });

        const posicionElegida = coincidencias.findIndex(opcion => opcion.selected);
        marcarActiva(textoFiltro === "" && posicionElegida >= 0 ? posicionElegida : 0);
    };

    const abrir = () => {
        if (!lista.hidden) return;
        textoFiltro = "";
        lista.hidden = false;
        selector.classList.add("abierto");
        entrada.setAttribute("aria-expanded", "true");
        dibujarOpciones();
    };

    const cerrar = () => {
        if (lista.hidden) return;
        lista.hidden = true;
        selector.classList.remove("abierto");
        entrada.setAttribute("aria-expanded", "false");
        entrada.removeAttribute("aria-activedescendant");
        textoFiltro = "";
        mostrarElegidas();
    };

    const elegirOpcion = opcion => {
        if (esMultiple) {
            opcion.selected = !opcion.selected;
            textoFiltro = "";
            mostrarElegidas();
            dibujarOpciones();
        } else {
            select.value = opcion.value;
            cerrar();
            mostrarElegidas();
        }
        avisarCambio();
    };

    entrada.addEventListener("focus", () => {
        abrir();
        if (!esMultiple) entrada.select();
    });
    entrada.addEventListener("click", abrir);
    entrada.addEventListener("input", () => {
        abrir();
        textoFiltro = entrada.value;
        dibujarOpciones();
    });
    entrada.addEventListener("keydown", evento => {
        if (evento.key === "ArrowDown" || evento.key === "ArrowUp") {
            evento.preventDefault();
            if (lista.hidden) { abrir(); return; }
            marcarActiva(indiceActivo + (evento.key === "ArrowDown" ? 1 : -1));
        } else if (evento.key === "Enter") {
            if (lista.hidden) return;
            evento.preventDefault();
            const item = itemsDeLista()[indiceActivo];
            if (item) elegirOpcion(item.opcionDelSelect);
        } else if (evento.key === "Escape") {
            if (lista.hidden) return;
            // Dentro de un diálogo, Escape cierra la lista y no el diálogo
            evento.preventDefault();
            evento.stopPropagation();
            cerrar();
        } else if (evento.key === "Tab") {
            cerrar();
        } else if (evento.key === "Backspace" && esMultiple && entrada.value === "") {
            const ultimaElegida = Array.from(select.selectedOptions).filter(opcion => opcion.value !== "").pop();
            if (!ultimaElegida) return;
            ultimaElegida.selected = false;
            mostrarElegidas();
            dibujarOpciones();
            avisarCambio();
        }
    });
    entrada.addEventListener("blur", cerrar);

    botonDesplegar.addEventListener("pointerdown", evento => evento.preventDefault());
    botonDesplegar.addEventListener("click", () => {
        if (lista.hidden) {
            entrada.focus();
            abrir();
        } else {
            cerrar();
        }
    });

    // El botón "Limpiar" de un formulario vuelve el <select> a su estado inicial: se redibuja después
    select.form?.addEventListener("reset", () => setTimeout(mostrarElegidas, 0));

    select.actualizarSelectorBuscable = () => {
        mostrarElegidas();
        if (!lista.hidden) dibujarOpciones();
    };
    mostrarElegidas();
}


// ================= AVISO "CUENTA NO VERIFICADA" (debajo del header) =================
// Se puede cerrar hasta la próxima sesión: se recuerda en sessionStorage y se olvida al cerrar sesión.
function inicializarAvisoVerificacion() {
    document.querySelectorAll("form[action*='CerrarSesion']").forEach(formulario => {
        formulario.addEventListener("submit", () => {
            try { sessionStorage.removeItem("avisoVerificacionCerrado"); } catch (error) { /* sin sessionStorage */ }
        });
    });

    const avisoVerificacion = document.getElementById("avisoVerificacion");
    if (!avisoVerificacion) return;

    let estaCerrado = false;
    try { estaCerrado = sessionStorage.getItem("avisoVerificacionCerrado") === "true"; } catch (error) { /* sin sessionStorage */ }
    avisoVerificacion.hidden = estaCerrado;

    document.getElementById("botonCerrarAvisoVerificacion").addEventListener("click", () => {
        avisoVerificacion.hidden = true;
        try { sessionStorage.setItem("avisoVerificacionCerrado", "true"); } catch (error) { /* sin sessionStorage */ }
    });
}

// ================= HEADER: sombra al hacer scroll =================
function inicializarEncabezadoConScroll() {
    const encabezado = document.getElementById("encabezado");
    if (!encabezado) return;

    const actualizarSombraEncabezado = () => {
        encabezado.classList.toggle("conSombra", window.scrollY > 8);
    };

    actualizarSombraEncabezado();
    window.addEventListener("scroll", actualizarSombraEncabezado, { passive: true });
}


// ================= ANIMACIONES: revelar elementos al entrar en pantalla =================
// Marca con ".revelar" los títulos, tarjetas y figuras de cada sección (menos la portada)
// y les agrega ".visible" cuando entran en pantalla. Sin JS, todo se ve igual.
function inicializarRevelarAlScroll() {
    const elementosParaRevelar = document.querySelectorAll(
        "main section:not(.portada):not(.cinta) :is(.encabezadoSeccion, .card, figure, .accordion, .enlacesExternos, .colegios, .nav-pills)"
    );

    elementosParaRevelar.forEach(elemento => {
        // Escalona las tarjetas hermanas para que entren una tras otra
        const posicion = Array.from(elemento.parentElement.children).indexOf(elemento);
        elemento.style.setProperty("--retraso", `${Math.min(posicion, 5) * 0.08}s`);
        elemento.classList.add("revelar");
    });

    if (!("IntersectionObserver" in window)) {
        elementosParaRevelar.forEach(elemento => elemento.classList.add("visible"));
        return;
    }

    const observadorDeVisibilidad = new IntersectionObserver((entradas, observador) => {
        entradas.forEach(entrada => {
            if (!entrada.isIntersecting) return;
            entrada.target.classList.add("visible");
            observador.unobserve(entrada.target);
        });
    }, { threshold: 0.12, rootMargin: "0px 0px -30px 0px" });

    elementosParaRevelar.forEach(elemento => observadorDeVisibilidad.observe(elemento));
}


// ================= INICIO: validación del buscador =================
// Se llama desde onsubmit del formulario. El envío va a Catalogo?busqueda=...
function validarBusqueda() {
    const campoBusqueda = document.getElementById("campoBusqueda");
    const mensajeErrorBusqueda = document.getElementById("mensajeErrorBusqueda");
    const textoBuscado = campoBusqueda.value.trim();

    if (textoBuscado === "") {
        return mostrarErrorEnCampo(mensajeErrorBusqueda, campoBusqueda, "Escribí una materia, un profesor o un colegio para buscar.");
    }
    if (textoBuscado.length < 2) {
        return mostrarErrorEnCampo(mensajeErrorBusqueda, campoBusqueda, "La búsqueda debe tener al menos 2 caracteres.");
    }

    mostrarMensaje(mensajeErrorBusqueda, "");
    return true;
}

function inicializarBuscador() {
    const campoBusqueda = document.getElementById("campoBusqueda");
    const mensajeErrorBusqueda = document.getElementById("mensajeErrorBusqueda");
    if (!campoBusqueda || !mensajeErrorBusqueda) return;

    // Oculta el error apenas el usuario vuelve a escribir
    campoBusqueda.addEventListener("input", () => mostrarMensaje(mensajeErrorBusqueda, ""));

    // TODO BD: sugerencias en vivo cuando exista el endpoint (ej: Home/SugerirMaterias?texto=...)
}


// ================= REGISTRO =================
// Muestra el panel ilustrado que corresponde al rol elegido (data-solo-rol)
function inicializarRolesDeRegistro() {
    const formularioRegistro = document.getElementById("formularioRegistro");
    if (!formularioRegistro) return;

    const mostrarPanelDelRol = () => {
        const rolElegido = formularioRegistro.querySelector("input[name='tipoUsuario']:checked").value;
        document.querySelectorAll("[data-solo-rol]").forEach(panel => {
            panel.hidden = panel.dataset.soloRol !== rolElegido;
        });
    };

    formularioRegistro.querySelectorAll("input[name='tipoUsuario']").forEach(radio => radio.addEventListener("change", mostrarPanelDelRol));
    mostrarPanelDelRol();
}

// Botón del ojo: alterna entre ocultar y mostrar la contraseña
function inicializarVerContrasena() {
    document.querySelectorAll("[data-ver-contrasena]").forEach(boton => {
        const campo = document.getElementById(boton.dataset.verContrasena);
        if (!campo) return;

        boton.addEventListener("click", () => {
            const seMuestra = campo.type === "password";
            campo.type = seMuestra ? "text" : "password";
            boton.setAttribute("aria-pressed", String(seMuestra));
            boton.setAttribute("aria-label", seMuestra ? "Ocultar contraseña" : "Mostrar contraseña");
            boton.querySelector(".bi").className = seMuestra ? "bi bi-eye-slash" : "bi bi-eye";
        });
    });
}

function validarRegistro() {
    const mensajeRegistro = document.getElementById("mensajeRegistro");
    const campo = id => document.getElementById(id);

    if (campo("registroNombre").value.trim().length < 2) return mostrarErrorEnCampo(mensajeRegistro, campo("registroNombre"), "Ingresá tu nombre.");
    if (campo("registroApellido").value.trim().length < 2) return mostrarErrorEnCampo(mensajeRegistro, campo("registroApellido"), "Ingresá tu apellido.");
    if (!correoValido(campo("registroCorreo").value.trim())) return mostrarErrorEnCampo(mensajeRegistro, campo("registroCorreo"), "Ingresá un correo electrónico válido.");
    if (campo("registroContrasena").value.length < 8) return mostrarErrorEnCampo(mensajeRegistro, campo("registroContrasena"), "La contraseña debe tener al menos 8 caracteres.");
    if (!fechaNacimientoValida(campo("registroFechaNacimiento").value)) return mostrarErrorEnCampo(mensajeRegistro, campo("registroFechaNacimiento"), "Ingresá una fecha de nacimiento válida.");
    if (!campo("registroTerminos").checked) return mostrarErrorEnCampo(mensajeRegistro, campo("registroTerminos"), "Tenés que aceptar los términos para continuar.");

    mostrarMensaje(mensajeRegistro, "");
    return true;
}

function fechaNacimientoValida(valor) {
    if (valor === "") return false;
    const fecha = new Date(valor + "T00:00:00");
    return !isNaN(fecha) && fecha <= new Date() && fecha.getFullYear() >= 1900;
}


// ================= INICIO DE SESIÓN =================
function validarIngreso() {
    const mensajeIngreso = document.getElementById("mensajeIngreso");
    const campoCorreo = document.getElementById("ingresoCorreo");
    const campoContrasena = document.getElementById("ingresoContrasena");

    if (!correoValido(campoCorreo.value.trim())) return mostrarErrorEnCampo(mensajeIngreso, campoCorreo, "Ingresá un correo electrónico válido.");
    if (campoContrasena.value === "") return mostrarErrorEnCampo(mensajeIngreso, campoContrasena, "Ingresá tu contraseña.");

    mostrarMensaje(mensajeIngreso, "");
    return true;
}


// ================= SOPORTE: buscador de preguntas frecuentes =================
function inicializarBuscadorDeAyuda() {
    const campoAyuda = document.getElementById("campoAyuda");
    const preguntas = document.querySelectorAll("#acordeonPreguntas details");
    if (!campoAyuda || preguntas.length === 0) return;

    const mensajeAyuda = document.getElementById("mensajeAyuda");
    const sinCoincidencias = document.getElementById("sinCoincidencias");

    campoAyuda.addEventListener("input", () => {
        const textoBuscado = normalizarTexto(campoAyuda.value);
        let cantidadVisible = 0;

        preguntas.forEach(pregunta => {
            const coincide = textoBuscado === "" || normalizarTexto(pregunta.textContent).includes(textoBuscado);
            pregunta.hidden = !coincide;
            if (coincide) cantidadVisible++;
        });

        sinCoincidencias.hidden = cantidadVisible > 0;
        mostrarMensaje(mensajeAyuda, textoBuscado === "" ? "" : `${cantidadVisible} ${cantidadVisible === 1 ? "pregunta encontrada" : "preguntas encontradas"}.`);
    });
}

function validarContacto() {
    const mensajeContacto = document.getElementById("mensajeContacto");
    const exitoContacto = document.getElementById("exitoContacto");
    const campo = id => document.getElementById(id);
    exitoContacto.hidden = true;

    if (campo("contactoNombre").value.trim().length < 3) return mostrarErrorEnCampo(mensajeContacto, campo("contactoNombre"), "Ingresá tu nombre completo.");
    if (!correoValido(campo("contactoCorreo").value.trim())) return mostrarErrorEnCampo(mensajeContacto, campo("contactoCorreo"), "Ingresá un correo electrónico válido.");
    if (campo("contactoTipo").value === "") return mostrarErrorEnCampo(mensajeContacto, campo("contactoTipo"), "Elegí el tipo de consulta.");
    if (campo("contactoMensaje").value.trim().length < 10) return mostrarErrorEnCampo(mensajeContacto, campo("contactoMensaje"), "Contanos un poco más (mínimo 10 caracteres).");

    mostrarMensaje(mensajeContacto, "");
    // TODO BD: guardar la consulta (BD.guardarConsulta) o enviarla por correo desde el servidor
    exitoContacto.hidden = false;
    document.getElementById("formularioContacto").reset();
    return false;
}


// ================= PANEL DE CONTROL =================
// Los accesos rápidos (data-abrir-tab="tabChat") activan la pestaña con ese id
function inicializarAccesosDelPanel() {
    document.querySelectorAll("[data-abrir-tab]").forEach(acceso => {
        acceso.addEventListener("click", () => {
            const idPestana = acceso.dataset.abrirTab;
            document.getElementById(idPestana.replace(/^tab/, "botonTab"))?.click();
        });
    });
}

function enviarMensajeChat() {
    const campoMensaje = document.getElementById("campoMensajeChat");
    const contenedorMensajes = document.getElementById("mensajesChat");
    const texto = campoMensaje.value.trim();
    if (texto === "") return false;

    // TODO BD: guardar el mensaje con BD.enviarMensaje(...) y refrescar la conversación
    const burbuja = document.createElement("p");
    burbuja.className = "burbuja propia";
    burbuja.textContent = texto;
    contenedorMensajes.appendChild(burbuja);
    contenedorMensajes.scrollTop = contenedorMensajes.scrollHeight;

    campoMensaje.value = "";
    campoMensaje.focus();
    return false;
}

function guardarConfiguracion() {
    const mensajeConfiguracion = document.getElementById("mensajeConfiguracion");
    const exitoConfiguracion = document.getElementById("exitoConfiguracion");
    const campoNombre = document.getElementById("configNombre");
    const campoCorreo = document.getElementById("configCorreo");
    exitoConfiguracion.hidden = true;

    if (campoNombre.value.trim().length < 3) return mostrarErrorEnCampo(mensajeConfiguracion, campoNombre, "Ingresá tu nombre completo.");
    if (!correoValido(campoCorreo.value.trim())) return mostrarErrorEnCampo(mensajeConfiguracion, campoCorreo, "Ingresá un correo electrónico válido.");

    mostrarMensaje(mensajeConfiguracion, "");
    // TODO BD: guardar con BD.actualizarPerfil(...)
    exitoConfiguracion.hidden = false;
    return false;
}


// ================= PERFIL =================
// La vista Home/Perfil solo trae el esqueleto: los datos llegan por fetch desde PerfilesController.
// Los textos de la BD se ponen con textContent. La única excepción es "Sobre mí", que es HTML del
// editor y llega limpio desde el servidor (HtmlSanitizer solo deja negrita, listas, enlaces, etc.).
const nombresDeTipoUsuario = { alumno: "Alumno", profesor: "Profesor", admin: "Administrador" };
const largoMaximoDescripcion = 1000;
const pesoMaximoFoto = 5 * 1024 * 1024;
const tiposDeFotoPermitidos = ["image/jpeg", "image/png", "image/webp"];

let editorDescripcion = null;
let opcionesPerfilCargadas = null;
let urlVistaPreviaFoto = null;
let edicionYaAbiertaSola = false;

function inicializarPerfil() {
    const seccionPerfil = document.getElementById("perfil");
    if (!seccionPerfil) return;

    cargarPerfil();
    inicializarCopiarEnlacePerfil();
    inicializarBotonesProximamente();
    inicializarEdicionPerfil();
}

function esPerfilPropio() {
    return document.getElementById("perfil").dataset.perfilPropio === "true";
}

function cargarPerfil() {
    const seccionPerfil = document.getElementById("perfil");
    const estadoPerfil = document.getElementById("estadoPerfil");

    pedirJson(`/Perfiles/ObtenerPerfil/${seccionPerfil.dataset.idPerfil}`)
        .then(perfil => {
            estadoPerfil.hidden = true;
            if (!perfil.encontrado) {
                mostrarContenidoCargado(document.getElementById("perfilInexistente"));
                return;
            }
            mostrarPerfil(perfil);
            if (esPerfilPropio()) cargarAvisoVerificacionPerfil();
        })
        .catch(error => {
            console.error(error);
            estadoPerfil.textContent = "No pudimos cargar el perfil. Revisá tu conexión y recargá la página.";
        });
}

function mostrarPerfil(perfil) {
    const nombreCompleto = `${perfil.nombre} ${perfil.apellido}`;
    document.title = `${nombreCompleto} | MiProfesor (MIP)`;

    pintarAvatar(document.getElementById("avatarPerfil"), perfil.nombre, perfil.apellido, perfil.fotoPerfil);
    document.getElementById("tipoPerfil").textContent = nombresDeTipoUsuario[perfil.tipoUsuario] || "Usuario";
    document.getElementById("nombrePerfil").textContent = nombreCompleto;
    document.getElementById("tickPerfil").hidden = !perfil.verificado;
    document.getElementById("estadoVerificadoPerfil").hidden = !perfil.verificado;
    document.getElementById("datosTitularPerfil").replaceChildren(...crearDatosTitular(perfil));

    // "Pedir clase" solo tiene sentido en el perfil de un profesor
    document.querySelectorAll("[data-solo-profesor]").forEach(boton => { boton.hidden = perfil.tipoUsuario !== "profesor"; });

    mostrarCifrasPerfil(perfil);
    mostrarDescripcionPerfil(perfil.descripcion);
    mostrarResenasPerfil(perfil.resenas);
    mostrarDatosPerfil(perfil);
    mostrarContenidoCargado(document.getElementById("contenidoPerfil"));

    // Desde el aviso "Completar mis datos" se llega con ?editar=true: el modal se abre solo una vez
    const botonEditar = document.querySelector("button[data-abrir-edicion]");
    if (document.getElementById("perfil").dataset.editarAlCargar === "true" && !edicionYaAbiertaSola && botonEditar) {
        edicionYaAbiertaSola = true;
        botonEditar.click();
    }
}

// Lo que llega por fetch aparece después de inicializarRevelarAlScroll(): se marca visible
// a mano (la transición de .revelar igual se ve) para no depender del IntersectionObserver
function mostrarContenidoCargado(contenido) {
    contenido.hidden = false;
    [contenido, ...contenido.querySelectorAll(".revelar")].forEach(elemento => elemento.classList.add("visible"));
}

// Foto de perfil o, si no tiene, la primera letra del nombre y del apellido
function pintarAvatar(avatar, nombre, apellido, fotoPerfil) {
    avatar.replaceChildren();
    if (fotoPerfil) {
        const foto = document.createElement("img");
        foto.src = fotoPerfil;
        foto.alt = `Foto de perfil de ${nombre} ${apellido}`;
        avatar.append(foto);
        return;
    }
    avatar.textContent = ((nombre || "").charAt(0) + (apellido || "").charAt(0)).toUpperCase() || "?";
}

// "Colegio Nacional de Buenos Aires y 2 más · Miembro desde octubre de 2026"
function crearDatosTitular(perfil) {
    const partes = [];
    if (perfil.colegios.length > 0) {
        const colegios = perfil.colegios.length > 1 ? `${perfil.colegios[0]} y ${perfil.colegios.length - 1} más` : perfil.colegios[0];
        partes.push(crearDatoConIcono("bi-building", colegios));
    }
    const fechaInscripcion = new Date(perfil.fechaInscripcion).toLocaleDateString("es-AR", { month: "long", year: "numeric" });
    partes.push(crearDatoConIcono("bi-calendar3", `Miembro desde ${fechaInscripcion}`));
    return partes;
}

function crearDatoConIcono(icono, texto) {
    const dato = document.createElement("span");
    const iconoDato = document.createElement("i");
    iconoDato.className = `bi ${icono}`;
    iconoDato.setAttribute("aria-hidden", "true");
    dato.append(iconoDato, ` ${texto}`);
    return dato;
}

function mostrarCifrasPerfil(perfil) {
    const cifrasPerfil = document.getElementById("cifrasPerfil");
    cifrasPerfil.replaceChildren();

    const calificacion = perfil.cantidadResenas > 0 && perfil.calificacion !== null
        ? perfil.calificacion.toLocaleString("es-AR", { minimumFractionDigits: 1, maximumFractionDigits: 1 })
        : "–";
    const textoResenas = perfil.cantidadResenas === 1 ? "1 reseña" : `${perfil.cantidadResenas} reseñas`;
    cifrasPerfil.append(crearCifraPerfil("bi-star-fill", calificacion, textoResenas));
    cifrasPerfil.append(crearCifraPerfil("bi-heart-fill", perfil.cantidadLikes, "me gusta"));

    // En la base, un profesor sin precio queda con 0
    if (perfil.tipoUsuario === "profesor") {
        const precio = perfil.precioHora > 0 ? `$ ${perfil.precioHora.toLocaleString("es-AR")}` : "Sin precio";
        cifrasPerfil.append(crearCifraPerfil("bi-cash-coin", precio, "por hora"));
    }
}

function crearCifraPerfil(icono, valor, detalle) {
    const cifra = document.createElement("li");
    const iconoCifra = document.createElement("i");
    iconoCifra.className = `bi ${icono}`;
    iconoCifra.setAttribute("aria-hidden", "true");
    const valorCifra = document.createElement("strong");
    valorCifra.textContent = valor;
    const detalleCifra = document.createElement("span");
    detalleCifra.textContent = detalle;
    cifra.append(iconoCifra, valorCifra, detalleCifra);
    return cifra;
}

function mostrarDescripcionPerfil(descripcion) {
    const descripcionPerfil = document.getElementById("descripcionPerfil");
    if (descripcion) {
        descripcionPerfil.classList.remove("vacio");
        // HTML limpiado en el servidor (PerfilesController.ObtenerPerfil)
        descripcionPerfil.innerHTML = descripcion;
        descripcionPerfil.querySelectorAll("a").forEach(enlace => {
            enlace.target = "_blank";
            enlace.rel = "noopener noreferrer nofollow";
        });
        return;
    }
    descripcionPerfil.classList.add("vacio");
    descripcionPerfil.textContent = esPerfilPropio()
        ? "Todavía no escribiste nada sobre vos. Tocá «Editar perfil» para contarle a los demás quién sos."
        : "Todavía no escribió una descripción.";
}

function mostrarResenasPerfil(resenas) {
    const resenasPerfil = document.getElementById("resenasPerfil");
    resenasPerfil.replaceChildren();

    if (resenas.length === 0) {
        const sinResenas = document.createElement("p");
        sinResenas.className = "vacio";
        sinResenas.textContent = "Todavía no tiene reseñas.";
        resenasPerfil.append(sinResenas);
        return;
    }

    resenas.forEach(resena => {
        const tarjetaResena = document.createElement("div");
        tarjetaResena.className = "resena";

        // El nombre de quien escribió la reseña lleva a su perfil
        const autorResena = document.createElement("a");
        autorResena.href = `/Home/Perfil/${resena.idEmisor}`;
        autorResena.textContent = `${resena.nombre} ${resena.apellido}`;
        if (resena.verificadoEmisor) autorResena.append(" ", crearTickVerificado());

        const estrellas = document.createElement("span");
        estrellas.className = "estrellas";
        estrellas.setAttribute("aria-label", `${resena.puntuacion} de 5 estrellas`);
        for (let posicion = 1; posicion <= 5; posicion++) {
            const estrella = document.createElement("i");
            estrella.className = posicion <= resena.puntuacion ? "bi bi-star-fill" : "bi bi-star";
            estrella.setAttribute("aria-hidden", "true");
            estrellas.append(estrella);
        }

        const encabezadoResena = document.createElement("header");
        encabezadoResena.append(autorResena, estrellas);
        tarjetaResena.append(encabezadoResena);

        if (resena.descripcion) {
            const textoResena = document.createElement("p");
            textoResena.textContent = resena.descripcion;
            tarjetaResena.append(textoResena);
        }
        resenasPerfil.append(tarjetaResena);
    });
}

function crearTickVerificado() {
    const tick = document.createElement("i");
    tick.className = "bi bi-patch-check-fill tickVerificado";
    tick.title = "Cuenta verificada";
    tick.setAttribute("aria-label", "Cuenta verificada");
    return tick;
}

// Grupos de etiquetas: los profesores muestran materias, modalidades y títulos además de niveles y colegios
function mostrarDatosPerfil(perfil) {
    const datosPerfil = document.getElementById("datosPerfil");
    datosPerfil.replaceChildren();

    const gruposDeDatos = perfil.tipoUsuario === "profesor"
        ? [["Materias", "bi-book", perfil.materias], ["Niveles", "bi-mortarboard", perfil.niveles], ["Modalidad", "bi-laptop", perfil.modalidades], ["Colegios", "bi-building", perfil.colegios], ["Títulos", "bi-award", perfil.titulos]]
        : [["Colegio", "bi-building", perfil.colegios], ["Nivel", "bi-mortarboard", perfil.niveles]];

    const gruposConDatos = gruposDeDatos.filter(([, , valores]) => valores.length > 0);
    if (gruposConDatos.length === 0) {
        const sinDatos = document.createElement("p");
        sinDatos.className = "vacio";
        sinDatos.textContent = perfil.tipoUsuario === "profesor"
            ? "Todavía no cargó sus materias, niveles ni colegios."
            : "Todavía no cargó su colegio ni su nivel.";
        datosPerfil.append(sinDatos);
        return;
    }

    gruposConDatos.forEach(([tituloGrupo, icono, valores]) => {
        const grupo = document.createElement("div");
        grupo.className = "grupo";
        const tituloDelGrupo = document.createElement("h3");
        tituloDelGrupo.append(crearDatoConIcono(icono, tituloGrupo));
        const etiquetas = document.createElement("div");
        etiquetas.className = "etiquetas";
        valores.forEach(valor => {
            const etiqueta = document.createElement("span");
            etiqueta.className = tituloGrupo === "Materias" ? "badge theme-accent" : "badge badge-subtle theme-inverse";
            etiqueta.textContent = valor;
            etiquetas.append(etiqueta);
        });
        grupo.append(tituloDelGrupo, etiquetas);
        datosPerfil.append(grupo);
    });
}

// ----- Aviso de verificación dentro del perfil propio -----
function cargarAvisoVerificacionPerfil() {
    pedirJson("/Perfiles/ObtenerDatosEdicion")
        .then(datos => mostrarAvisoVerificacionPerfil(datos.verificado, datos.faltantes))
        .catch(error => console.error(error));
}

function mostrarAvisoVerificacionPerfil(verificado, faltantes) {
    const avisoPerfil = document.getElementById("avisoVerificacionPerfil");
    if (!avisoPerfil) return;

    avisoPerfil.hidden = verificado || faltantes.length === 0;
    const listaFaltantes = document.getElementById("faltantesPerfil");
    listaFaltantes.replaceChildren(...faltantes.map(faltante => {
        const itemFaltante = document.createElement("li");
        itemFaltante.textContent = faltante.charAt(0).toUpperCase() + faltante.slice(1);
        return itemFaltante;
    }));
    if (!avisoPerfil.hidden) avisoPerfil.classList.add("revelar", "visible");
}

// ----- Copiar enlace y botones sociales -----

// Copia la URL pública del perfil (/Home/Perfil/{id}), también cuando se entra a "Mi perfil" sin ID
function inicializarCopiarEnlacePerfil() {
    const botonCopiarEnlace = document.getElementById("botonCopiarEnlace");
    if (!botonCopiarEnlace) return;

    const enlacePerfil = `${window.location.origin}/Home/Perfil/${document.getElementById("perfil").dataset.idPerfil}`;
    botonCopiarEnlace.addEventListener("click", () => {
        navigator.clipboard.writeText(enlacePerfil)
            .then(() => mostrarSnackbar("¡Enlace copiado! Ya lo podés compartir.", "exito"))
            .catch(() => window.prompt("Copiá el enlace del perfil:", enlacePerfil));
    });
}

// Me gusta, Agregar amigo, Mensaje, Reseña, Pedir clase y Reportar todavía no hacen nada
function inicializarBotonesProximamente() {
    const haySesion = document.getElementById("perfil").dataset.haySesion === "true";

    document.querySelectorAll("[data-proximamente]").forEach(boton => {
        boton.addEventListener("click", evento => {
            evento.preventDefault();
            if (!haySesion) {
                window.location.href = "/Sesion/IniciarSesion";
                return;
            }
            mostrarSnackbar(`«${boton.dataset.proximamente}» va a estar disponible muy pronto.`);
        });
    });
}

// ----- Modal "Editar perfil" -----
function inicializarEdicionPerfil() {
    const dialogoEditarPerfil = document.getElementById("dialogoEditarPerfil");
    if (!dialogoEditarPerfil) return;

    document.querySelectorAll("[data-abrir-edicion]").forEach(boton => boton.addEventListener("click", cargarDatosEdicion));
    inicializarEditorDescripcion();
    inicializarFotosEdicion();
    inicializarTitulosEdicion();
}

function cargarDatosEdicion() {
    const estadoEdicion = document.getElementById("estadoEdicion");
    const contenidoEdicion = document.getElementById("contenidoEdicion");
    mostrarMensaje(document.getElementById("mensajeEditarPerfil"), "");

    // Las opciones casi no cambian: se piden una sola vez
    const pedidoOpciones = opcionesPerfilCargadas
        ? Promise.resolve(opcionesPerfilCargadas)
        : pedirJson("/Perfiles/ObtenerOpcionesPerfil").then(opciones => (opcionesPerfilCargadas = opciones));

    Promise.all([pedidoOpciones, pedirJson("/Perfiles/ObtenerDatosEdicion")])
        .then(([opciones, datos]) => {
            completarFormularioEdicion(opciones, datos);
            estadoEdicion.hidden = true;
            contenidoEdicion.hidden = false;
        })
        .catch(error => {
            console.error(error);
            estadoEdicion.hidden = false;
            contenidoEdicion.hidden = true;
            estadoEdicion.textContent = "No pudimos cargar tus datos. Cerrá el cuadro y probá de nuevo.";
        });
}

function completarFormularioEdicion(opciones, datos) {
    const campo = id => document.getElementById(id);

    // Modificar perfil
    if (editorDescripcion) {
        editorDescripcion.setContents([]);
        if (datos.descripcion) editorDescripcion.clipboard.dangerouslyPasteHTML(datos.descripcion);
        actualizarContadorDescripcion();
    }
    llenarSelectDeOpciones(campo("edicionEscuelas"), opciones.escuelas, datos.idsEscuelas);
    llenarSelectDeOpciones(campo("edicionNiveles"), opciones.niveles, datos.idsNiveles);
    llenarSelectDeOpciones(campo("edicionMaterias"), opciones.materias, datos.idsMaterias);
    llenarSelectDeOpciones(campo("edicionModalidades"), opciones.modalidades, datos.idsModalidades);
    if (campo("edicionPrecioHora")) campo("edicionPrecioHora").value = datos.precioHora > 0 ? datos.precioHora : "";
    if (campo("listaTitulos")) {
        campo("listaTitulos").replaceChildren();
        datos.titulos.forEach(agregarTituloEdicion);
    }

    // Modificar cuenta
    campo("edicionNombre").value = datos.nombre;
    campo("edicionApellido").value = datos.apellido;
    campo("edicionMail").value = datos.mail;
    campo("edicionFechaNacimiento").value = datos.fechaNacimiento ? datos.fechaNacimiento.slice(0, 10) : "";
    campo("edicionDni").value = datos.dni || "";
    campo("edicionDireccion").value = datos.direccion || "";
    campo("edicionFotoPerfil").value = "";
    campo("edicionFotoDni").value = "";
    pintarAvatar(campo("vistaPreviaFotoPerfil"), datos.nombre, datos.apellido, datos.fotoPerfil);
    campo("estadoFotoDni").textContent = datos.tieneFotoDni
        ? "✓ Ya subiste la foto del DNI. Si elegís otra, se reemplaza."
        : "Todavía no subiste la foto del DNI.";
    campo("estadoFotoDni").classList.toggle("cargada", datos.tieneFotoDni);

    mostrarProgresoVerificacion(datos.verificado, datos.faltantes);
}

// Llena un <select> del modal y lo convierte en selector con búsqueda.
// En los de una sola opción (alumno), "Sin elegir" permite dejarlo vacío.
function llenarSelectDeOpciones(select, opciones, idsElegidos) {
    if (!select) return;

    select.replaceChildren();
    if (!select.multiple) select.append(new Option("Sin elegir", "", false, idsElegidos.length === 0));
    opciones.forEach(opcion => {
        const estaElegida = idsElegidos.includes(opcion.id);
        select.append(new Option(opcion.nombre, opcion.id, estaElegida, estaElegida));
    });
    crearSelectorBuscable(select);
}

// Arriba del modal: verde si ya está verificada; amarillo con lo que falta si no
function mostrarProgresoVerificacion(verificado, faltantes) {
    const progresoVerificacion = document.getElementById("progresoVerificacion");
    progresoVerificacion.replaceChildren();
    progresoVerificacion.classList.toggle("verificada", verificado);

    const titulo = document.createElement("p");
    if (verificado) {
        titulo.append(crearTickVerificado(), " Tu cuenta está verificada.");
        progresoVerificacion.append(titulo);
        return;
    }

    titulo.textContent = faltantes.length === 1
        ? "Te falta 1 dato para verificar tu cuenta:"
        : `Te faltan ${faltantes.length} datos para verificar tu cuenta:`;
    const listaFaltantes = document.createElement("ul");
    listaFaltantes.replaceChildren(...faltantes.map(faltante => {
        const itemFaltante = document.createElement("li");
        itemFaltante.textContent = faltante;
        return itemFaltante;
    }));
    progresoVerificacion.append(titulo, listaFaltantes);
}

// Editor de texto enriquecido (Quill 2): negrita, cursiva, subrayado, tachado, listas, cita y enlaces
function inicializarEditorDescripcion() {
    const contenedorEditor = document.getElementById("editorDescripcion");
    if (!contenedorEditor || !window.Quill) return;

    editorDescripcion = new Quill(contenedorEditor, {
        theme: "snow",
        placeholder: "Contá quién sos, qué te gusta y qué estás buscando…",
        modules: {
            toolbar: [
                ["bold", "italic", "underline", "strike"],
                [{ list: "ordered" }, { list: "bullet" }],
                ["blockquote", "link"],
                ["clean"]
            ]
        }
    });
    editorDescripcion.on("text-change", actualizarContadorDescripcion);
}

function textoDeLaDescripcion() {
    return editorDescripcion ? editorDescripcion.getText().trim() : "";
}

function actualizarContadorDescripcion() {
    const contadorDescripcion = document.getElementById("contadorDescripcion");
    const cantidadCaracteres = textoDeLaDescripcion().length;
    contadorDescripcion.textContent = `${cantidadCaracteres} / ${largoMaximoDescripcion}`;
    contadorDescripcion.classList.toggle("excedido", cantidadCaracteres > largoMaximoDescripcion);
}

// Vista previa de la foto de perfil (se guarda recién al tocar "Guardar") y aviso de la foto del DNI
function inicializarFotosEdicion() {
    const campoFotoPerfil = document.getElementById("edicionFotoPerfil");
    const campoFotoDni = document.getElementById("edicionFotoDni");
    const mensajeEditarPerfil = document.getElementById("mensajeEditarPerfil");

    campoFotoPerfil.addEventListener("change", () => {
        const archivo = campoFotoPerfil.files[0];
        if (!archivo) return;
        if (!fotoValida(archivo)) {
            campoFotoPerfil.value = "";
            mostrarMensaje(mensajeEditarPerfil, "La foto de perfil tiene que ser JPG, PNG o WEBP de hasta 5 MB.");
            return;
        }
        mostrarMensaje(mensajeEditarPerfil, "");
        if (urlVistaPreviaFoto) URL.revokeObjectURL(urlVistaPreviaFoto);
        urlVistaPreviaFoto = URL.createObjectURL(archivo);
        pintarAvatar(document.getElementById("vistaPreviaFotoPerfil"), "", "", urlVistaPreviaFoto);
    });

    campoFotoDni.addEventListener("change", () => {
        const archivo = campoFotoDni.files[0];
        if (!archivo) return;
        if (!fotoValida(archivo)) {
            campoFotoDni.value = "";
            mostrarMensaje(mensajeEditarPerfil, "La foto del DNI tiene que ser JPG, PNG o WEBP de hasta 5 MB.");
            return;
        }
        mostrarMensaje(mensajeEditarPerfil, "");
        const estadoFotoDni = document.getElementById("estadoFotoDni");
        estadoFotoDni.textContent = `Nueva foto elegida: ${archivo.name}. Se sube al guardar.`;
        estadoFotoDni.classList.add("cargada");
    });
}

function fotoValida(archivo) {
    return tiposDeFotoPermitidos.includes(archivo.type) && archivo.size <= pesoMaximoFoto;
}

// Títulos del profesor: lista con "Agregar" y una ✕ para quitar cada uno (inputs name="titulos")
function inicializarTitulosEdicion() {
    const botonAgregarTitulo = document.getElementById("botonAgregarTitulo");
    if (!botonAgregarTitulo) return;

    const campoNuevoTitulo = document.getElementById("nuevoTitulo");
    const agregarDesdeElCampo = () => {
        const titulo = campoNuevoTitulo.value.replaceAll("|", " ").replace(/\s+/g, " ").trim();
        const mensajeEditarPerfil = document.getElementById("mensajeEditarPerfil");
        if (titulo === "") return mostrarErrorEnCampo(mensajeEditarPerfil, campoNuevoTitulo, "Escribí el título antes de agregarlo.");
        if (document.querySelectorAll("#listaTitulos li").length >= 10) return mostrarErrorEnCampo(mensajeEditarPerfil, campoNuevoTitulo, "Podés cargar hasta 10 títulos.");
        mostrarMensaje(mensajeEditarPerfil, "");
        agregarTituloEdicion(titulo);
        campoNuevoTitulo.value = "";
        campoNuevoTitulo.focus();
        return true;
    };

    botonAgregarTitulo.addEventListener("click", agregarDesdeElCampo);
    campoNuevoTitulo.addEventListener("keydown", evento => {
        if (evento.key !== "Enter") return;
        evento.preventDefault();
        agregarDesdeElCampo();
    });
}

function agregarTituloEdicion(titulo) {
    const itemTitulo = document.createElement("li");
    const textoTitulo = document.createElement("span");
    textoTitulo.textContent = titulo;

    const campoTitulo = document.createElement("input");
    campoTitulo.type = "hidden";
    campoTitulo.name = "titulos";
    campoTitulo.value = titulo;

    const botonQuitar = document.createElement("button");
    botonQuitar.type = "button";
    botonQuitar.className = "btn-close";
    botonQuitar.setAttribute("aria-label", `Quitar ${titulo}`);
    botonQuitar.addEventListener("click", () => itemTitulo.remove());

    itemTitulo.append(textoTitulo, campoTitulo, botonQuitar);
    document.getElementById("listaTitulos").append(itemTitulo);
}

// Muestra la pestaña donde está un campo (para los errores de validación)
function mostrarPestanaDelCampo(campo) {
    const pestana = campo?.closest(".tab-pane");
    if (!pestana || pestana.classList.contains("active")) return;
    document.querySelector(`[data-bs-target="#${pestana.id}"]`)?.click();
}

function errorEnCampoDeEdicion(campo, texto) {
    mostrarPestanaDelCampo(campo);
    // Se espera a que la pestaña se vea para poder poner el foco
    setTimeout(() => mostrarErrorEnCampo(document.getElementById("mensajeEditarPerfil"), campo, texto), 50);
    return false;
}

function guardarPerfil() {
    const formularioEditarPerfil = document.getElementById("formularioEditarPerfil");
    const mensajeEditarPerfil = document.getElementById("mensajeEditarPerfil");
    const botonGuardarPerfil = document.getElementById("botonGuardarPerfil");
    const campo = id => document.getElementById(id);
    const campoPrecioHora = campo("edicionPrecioHora");
    const dniSinPuntos = campo("edicionDni").value.replace(/[\s.\-]/g, "");

    if (campo("edicionNombre").value.trim() === "") return errorEnCampoDeEdicion(campo("edicionNombre"), "Ingresá tu nombre.");
    if (campo("edicionApellido").value.trim() === "") return errorEnCampoDeEdicion(campo("edicionApellido"), "Ingresá tu apellido.");
    if (!correoValido(campo("edicionMail").value.trim())) return errorEnCampoDeEdicion(campo("edicionMail"), "Ingresá un correo electrónico válido.");
    if (dniSinPuntos !== "" && !/^\d{7,8}$/.test(dniSinPuntos)) return errorEnCampoDeEdicion(campo("edicionDni"), "El DNI tiene que tener 7 u 8 números.");
    if (campo("edicionFechaNacimiento").value !== "" && !fechaNacimientoValida(campo("edicionFechaNacimiento").value)) return errorEnCampoDeEdicion(campo("edicionFechaNacimiento"), "Ingresá una fecha de nacimiento válida.");
    if (textoDeLaDescripcion().length > largoMaximoDescripcion) return errorEnCampoDeEdicion(campo("editorDescripcion"), "La descripción puede tener hasta 1000 caracteres.");
    if (campoPrecioHora && campoPrecioHora.value !== "" && !(Number.isInteger(Number(campoPrecioHora.value)) && Number(campoPrecioHora.value) >= 0)) {
        return errorEnCampoDeEdicion(campoPrecioHora, "Ingresá un precio por hora válido (solo números).");
    }

    // HTML del editor (vacío si no se escribió nada) y listas de IDs separadas por coma
    // getSemanticHTML() de Quill convierte cada espacio en &nbsp; (y el texto no se corta en renglones)
    campo("edicionDescripcion").value = textoDeLaDescripcion() === "" ? "" : editorDescripcion.getSemanticHTML().replace(/&nbsp;/g, " ");
    const datosFormulario = new FormData(formularioEditarPerfil);
    formularioEditarPerfil.querySelectorAll("select[data-nombre-ids]").forEach(select => {
        const idsElegidos = Array.from(select.selectedOptions).map(opcion => opcion.value).filter(valor => valor !== "");
        datosFormulario.append(select.dataset.nombreIds, idsElegidos.join(","));
    });

    mostrarMensaje(mensajeEditarPerfil, "");
    botonGuardarPerfil.disabled = true;

    pedirJson(formularioEditarPerfil.action, { method: "POST", body: datosFormulario })
        .then(respuesta => {
            if (respuesta.resultado === "mailExistente") return errorEnCampoDeEdicion(campo("edicionMail"), respuesta.mensaje);
            if (respuesta.resultado === "dniExistente") return errorEnCampoDeEdicion(campo("edicionDni"), respuesta.mensaje);
            if (respuesta.resultado !== "ok") {
                mostrarMensaje(mensajeEditarPerfil, respuesta.mensaje);
                return;
            }

            formularioEditarPerfil.querySelector("[data-bs-dismiss='dialog']").click();
            mostrarSnackbar(respuesta.mensaje, "exito");
            actualizarUsuarioEnEncabezado(respuesta);
            mostrarAvisoVerificacionPerfil(respuesta.verificado, respuesta.faltantes);
            cargarPerfil();
        })
        .catch(error => {
            console.error(error);
            mostrarMensaje(mensajeEditarPerfil, "No pudimos guardar los cambios. Revisá tu conexión e intentá de nuevo.");
        })
        .finally(() => { botonGuardarPerfil.disabled = false; });

    return false;
}

// El header se arma con la sesión al cargar la página: se actualiza a mano para no recargar
function actualizarUsuarioEnEncabezado(usuario) {
    document.querySelectorAll("#encabezado .usuario").forEach(enlaceUsuario => {
        enlaceUsuario.querySelector(".nombreUsuario").textContent = `${usuario.nombre} ${usuario.apellido}`;

        const avatar = enlaceUsuario.querySelector(".avatar");
        pintarAvatar(avatar, usuario.nombre, usuario.apellido, usuario.fotoPerfil);
        avatar.classList.toggle("theme-primary", !usuario.fotoPerfil);

        let tick = enlaceUsuario.querySelector(".tickVerificado");
        if (usuario.verificado && !tick) enlaceUsuario.append(crearTickVerificado());
        if (!usuario.verificado && tick) tick.remove();
    });
}


// ================= INICIALIZACIÓN =================
function inicializarSitio() {
    inicializarEncabezadoConScroll();
    inicializarAvisoVerificacion();
    inicializarSelectoresBuscables();
    inicializarRevelarAlScroll();
    inicializarRolesDeRegistro();
    inicializarVerContrasena();
    inicializarBuscador();
    inicializarBuscadorDeAyuda();
    inicializarAccesosDelPanel();
    inicializarPerfil();
}

document.addEventListener("DOMContentLoaded", inicializarSitio);
