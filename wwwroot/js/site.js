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
    if (campo) campo.focus();
    return false;
}

// Quita tildes y mayúsculas para comparar textos ("Matemática" = "matematica")
function normalizarTexto(texto) {
    return (texto || "").normalize("NFD").replace(/[̀-ͯ]/g, "").toLowerCase().trim();
}

function correoValido(correo) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(correo);
}

// TODO BD: mientras no exista BD.cs, un formulario válido lleva al Panel de Control (que simula una sesión de ejemplo)
function irAlPanelDeControl() {
    window.location.href = "/Home/PanelControl";
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
// Se llama desde onsubmit del formulario. El envío va a Home/Catalogo?busqueda=...
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


// ================= CATÁLOGO: filtros en el navegador =================
// TODO BD: cuando exista BD.obtenerProfesores(...), el filtrado puede pasar al servidor.
function inicializarFiltrosCatalogo() {
    const formularioFiltros = document.getElementById("formularioFiltros");
    const listaProfesores = document.getElementById("listaProfesores");
    if (!formularioFiltros || !listaProfesores) return;

    const campoTexto = document.getElementById("filtroTexto");
    const campoMateria = document.getElementById("filtroMateria");
    const campoColegio = document.getElementById("filtroColegio");
    const textoCantidad = document.getElementById("cantidadResultados");
    const mensajeSinResultados = document.getElementById("sinResultados");
    const columnasProfesores = Array.from(listaProfesores.children);

    const aplicarFiltros = () => {
        const textoBuscado = normalizarTexto(campoTexto.value);
        const modalidadElegida = formularioFiltros.querySelector("input[name='modalidad']:checked")?.value ?? "";
        const nivelesElegidos = Array.from(formularioFiltros.querySelectorAll("input[name='nivel']:checked")).map(check => check.value);
        let cantidadVisible = 0;

        columnasProfesores.forEach(columna => {
            const tarjeta = columna.querySelector(".profesor");
            const coincideTexto = textoBuscado === "" || normalizarTexto(tarjeta.dataset.texto).includes(textoBuscado);
            const coincideMateria = campoMateria.value === "" || tarjeta.dataset.materia === campoMateria.value;
            const coincideColegio = campoColegio.value === "" || tarjeta.dataset.colegio === campoColegio.value;
            // Un profesor que dicta "Ambas" modalidades aparece en las dos
            const coincideModalidad = modalidadElegida === "" || tarjeta.dataset.modalidad === modalidadElegida || tarjeta.dataset.modalidad === "Ambas";
            const coincideNivel = nivelesElegidos.length === 0 || nivelesElegidos.includes(tarjeta.dataset.nivel);

            const visible = coincideTexto && coincideMateria && coincideColegio && coincideModalidad && coincideNivel;
            columna.hidden = !visible;
            if (visible) cantidadVisible++;
        });

        textoCantidad.textContent = cantidadVisible === 1 ? "1 profesor" : `${cantidadVisible} profesores`;
        mensajeSinResultados.hidden = cantidadVisible > 0;
    };

    formularioFiltros.addEventListener("input", aplicarFiltros);
    formularioFiltros.addEventListener("change", aplicarFiltros);
    // El reset vacía los campos DESPUÉS de este evento, por eso se espera un instante
    formularioFiltros.addEventListener("reset", () => setTimeout(aplicarFiltros, 0));

    aplicarFiltros();
}


// ================= REGISTRO =================
function inicializarRolesDeRegistro() {
    const formularioRegistro = document.getElementById("formularioRegistro");
    if (!formularioRegistro) return;

    // Muestra solo los campos que corresponden al rol elegido (data-solo-rol)
    const mostrarCamposDelRol = () => {
        const rolElegido = formularioRegistro.querySelector("input[name='rol']:checked").value;
        formularioRegistro.querySelectorAll("[data-solo-rol]").forEach(campo => {
            campo.hidden = campo.dataset.soloRol !== rolElegido;
        });
    };

    formularioRegistro.querySelectorAll("input[name='rol']").forEach(radio => radio.addEventListener("change", mostrarCamposDelRol));
    mostrarCamposDelRol();
}

function validarRegistro() {
    const mensajeRegistro = document.getElementById("mensajeRegistro");
    const campo = id => document.getElementById(id);
    const rol = document.querySelector("#formularioRegistro input[name='rol']:checked").value;

    if (campo("registroNombre").value.trim().length < 3) return mostrarErrorEnCampo(mensajeRegistro, campo("registroNombre"), "Ingresá tu nombre y apellido.");
    if (!correoValido(campo("registroCorreo").value.trim())) return mostrarErrorEnCampo(mensajeRegistro, campo("registroCorreo"), "Ingresá un correo electrónico válido.");
    if (campo("registroContrasena").value.length < 8) return mostrarErrorEnCampo(mensajeRegistro, campo("registroContrasena"), "La contraseña debe tener al menos 8 caracteres.");
    if (campo("registroColegio").value === "") return mostrarErrorEnCampo(mensajeRegistro, campo("registroColegio"), "Elegí tu colegio.");
    if (rol === "alumno" && campo("registroNivel").value === "") return mostrarErrorEnCampo(mensajeRegistro, campo("registroNivel"), "Elegí tu nivel.");
    if (rol === "profesor" && campo("registroMaterias").value.trim() === "") return mostrarErrorEnCampo(mensajeRegistro, campo("registroMaterias"), "Contanos qué materias dictás.");
    if (!campo("registroTerminos").checked) return mostrarErrorEnCampo(mensajeRegistro, campo("registroTerminos"), "Tenés que aceptar los términos para continuar.");

    mostrarMensaje(mensajeRegistro, "");
    // TODO BD: enviar el formulario (method="post") para crear la cuenta con BD.crearCuenta(...)
    irAlPanelDeControl();
    return false;
}


// ================= INICIO DE SESIÓN =================
function validarIngreso() {
    const mensajeIngreso = document.getElementById("mensajeIngreso");
    const campoCorreo = document.getElementById("ingresoCorreo");
    const campoContrasena = document.getElementById("ingresoContrasena");

    if (!correoValido(campoCorreo.value.trim())) return mostrarErrorEnCampo(mensajeIngreso, campoCorreo, "Ingresá un correo electrónico válido.");
    if (campoContrasena.value === "") return mostrarErrorEnCampo(mensajeIngreso, campoContrasena, "Ingresá tu contraseña.");

    mostrarMensaje(mensajeIngreso, "");
    // TODO BD: validar con BD.iniciarSesion(...) y guardar las claves de sesión
    irAlPanelDeControl();
    return false;
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


// ================= INICIALIZACIÓN =================
function inicializarSitio() {
    inicializarEncabezadoConScroll();
    inicializarRevelarAlScroll();
    inicializarBuscador();
    inicializarFiltrosCatalogo();
    inicializarRolesDeRegistro();
    inicializarBuscadorDeAyuda();
    inicializarAccesosDelPanel();
}

document.addEventListener("DOMContentLoaded", inicializarSitio);
