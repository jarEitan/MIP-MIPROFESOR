// Clases y notificaciones: pedir una clase (Catálogo y Perfil), responder, cancelar y reubicar desde el
// Panel de Control, y la insignia de notificaciones del header. Todo se llama con fetch a ClasesController
// y NotificacionesController. Las utilidades (pedirJson, mostrarSnackbar, crearElemento...) están en site.js.
// El servidor siempre valida las reglas (Info/log.md, entrada 2026-10-14); acá solo se ayuda a no
// elegir horarios imposibles. Todo el texto de la base se inserta con textContent, nunca como HTML.

const horaPrimeraFranja = 8;
const horaUltimaFranja = 21;
const minutosEntreFranjas = 30;
const minutosDeUnaClase = 60;
const minutosDeAnticipacionMinima = 60;

// POST con el token anti-falsificación. Devuelve { ok, cuerpo } aunque el servidor responda con error,
// porque el cuerpo trae el motivo (horario ocupado, muy cerca, etc.) y lo necesitamos para avisar.
function enviarAccionDeClase(url, datos) {
    const token = document.querySelector("input[name='__RequestVerificationToken']");
    return fetch(url, {
        method: "POST",
        headers: { "RequestVerificationToken": token ? token.value : "" },
        body: new URLSearchParams(datos)
    }).then(respuesta => {
        if (respuesta.status === 401) {
            window.location.href = "/Sesion/IniciarSesion";
            return { ok: false, cuerpo: { resultado: "sinSesion", mensaje: "Iniciá sesión para continuar." } };
        }
        return respuesta.json()
            .catch(() => ({ resultado: "error", mensaje: "No pudimos completar la acción. Probá de nuevo." }))
            .then(cuerpo => ({ ok: respuesta.ok, cuerpo }));
    });
}

// El número rojo del botón Panel de Control (oculto si es 0)
function actualizarInsigniaDeNotificaciones(cantidad) {
    const insignia = document.getElementById("insigniaNotificaciones");
    if (!insignia || cantidad === null || cantidad === undefined) return;
    insignia.textContent = cantidad;
    insignia.hidden = cantidad === 0;
    insignia.setAttribute("aria-label", `${cantidad} notificaciones`);
}

function inicializarInsigniaDeNotificaciones() {
    if (!document.getElementById("insigniaNotificaciones")) return;

    // La sesión guarda el número de la última vez que se calculó: se refresca al cargar y cada minuto
    const refrescar = () => {
        if (document.hidden) return;
        pedirJson("/Notificaciones/Contar")
            .then(resultado => actualizarInsigniaDeNotificaciones(resultado.cantidad))
            .catch(error => console.error(error));
    };
    refrescar();
    setInterval(refrescar, 60000);
}

// ----- Selector de día y hora (partial _selectorHorario) -----
function horaEnTexto(hora, minutos) {
    return `${String(hora).padStart(2, "0")}:${String(minutos).padStart(2, "0")}`;
}

function crearSelectorHorario(raiz) {
    const campoDia = raiz.querySelector("[data-campo-dia]");
    const contenedorFranjas = raiz.querySelector("[data-franjas]");
    let idOtroUsuario = null;
    let idClaseExcluir = null;
    let horaElegida = null;
    let consultaVigente = 0;

    function mostrarAyuda(texto) {
        contenedorFranjas.replaceChildren(crearElemento("p", "ayudaFranjas", texto));
    }

    // Todas las franjas del día; las ocupadas o que ya pasaron quedan deshabilitadas con el motivo
    function dibujarFranjas(dia, ocupados) {
        const limite = new Date(Date.now() + minutosDeAnticipacionMinima * 60000);
        const franjas = [];
        let hayLibres = false;

        for (let hora = horaPrimeraFranja; hora <= horaUltimaFranja; hora++) {
            for (let minutos = 0; minutos < 60; minutos += minutosEntreFranjas) {
                const texto = horaEnTexto(hora, minutos);
                const inicio = new Date(`${dia}T${texto}`);
                const fin = new Date(inicio.getTime() + minutosDeUnaClase * 60000);
                const franja = crearElemento("button", "franja", texto);
                franja.type = "button";
                franja.dataset.hora = texto;
                franja.setAttribute("aria-pressed", "false");

                const choque = ocupados.find(ocupado => new Date(ocupado.inicio) < fin && new Date(ocupado.fin) > inicio);
                if (inicio < limite) {
                    franja.disabled = true;
                    franja.title = "Tiene que empezar dentro de 1 hora o más";
                } else if (choque) {
                    franja.disabled = true;
                    franja.title = choque.de === "alumno" ? "Ya tenés una clase en este horario" : "El profesor ya tiene una clase en este horario";
                } else {
                    hayLibres = true;
                }
                franjas.push(franja);
            }
        }

        contenedorFranjas.replaceChildren(...franjas);
        if (!hayLibres) contenedorFranjas.append(crearElemento("p", "ayudaFranjas", "No quedan horarios libres este día. Probá con otro."));
        horaElegida = null;
    }

    function cargarDia() {
        const dia = campoDia.value;
        horaElegida = null;
        if (!dia) {
            mostrarAyuda("Elegí primero un día.");
            return Promise.resolve();
        }

        const consulta = ++consultaVigente;
        mostrarAyuda("Buscando horarios libres…");
        const parametros = new URLSearchParams({ idOtroUsuario, dia });
        if (idClaseExcluir) parametros.set("idClaseExcluir", idClaseExcluir);

        return pedirJson(`/Clases/HorariosOcupados?${parametros}`)
            .then(resultado => {
                if (consulta === consultaVigente) dibujarFranjas(dia, resultado.ocupados);
            })
            .catch(error => {
                console.error(error);
                if (consulta === consultaVigente) mostrarAyuda("No pudimos cargar los horarios. Probá con otro día o recargá la página.");
            });
    }

    campoDia.addEventListener("change", cargarDia);
    contenedorFranjas.addEventListener("click", evento => {
        const franja = evento.target.closest(".franja");
        if (!franja || franja.disabled) return;
        horaElegida = franja.dataset.hora;
        contenedorFranjas.querySelectorAll(".franja").forEach(otra => otra.setAttribute("aria-pressed", otra === franja ? "true" : "false"));
    });

    return {
        // Deja el selector vacío para otro profesor / otra clase
        configurar(opciones) {
            idOtroUsuario = opciones.idOtroUsuario;
            idClaseExcluir = opciones.idClaseExcluir || null;
            campoDia.value = "";
            horaElegida = null;
            mostrarAyuda("Elegí primero un día.");
        },
        // "2026-10-19T16:00" o null si falta el día o la hora
        valor() {
            return campoDia.value && horaElegida ? `${campoDia.value}T${horaElegida}` : null;
        },
        recargar: cargarDia,
        campoDia
    };
}

function abrirDialogo(idDialogo) {
    document.getElementById(idDialogo)?.showModal();
}

function cerrarDialogo(idDialogo) {
    document.getElementById(idDialogo)?.close();
}

// ----- Pedir clase (botones [data-pedir-clase] del Catálogo y del Perfil) -----
let selectorDePedido = null;

function inicializarPedidoDeClase() {
    document.addEventListener("click", evento => {
        const botonPedir = evento.target.closest("[data-pedir-clase]");
        if (!botonPedir) return;
        evento.preventDefault();
        abrirPedidoDeClase(botonPedir.dataset.idProfesor, botonPedir.dataset.nombreProfesor);
    });

    const dialogoPedir = document.getElementById("dialogoPedirClase");
    if (dialogoPedir) selectorDePedido = crearSelectorHorario(dialogoPedir.querySelector("[data-selector-horario]"));
}

function abrirPedidoDeClase(idProfesor, nombreProfesor) {
    const tipoUsuario = document.body.dataset.tipoUsuario;
    if (!tipoUsuario) {
        window.location.href = "/Sesion/IniciarSesion";
        return;
    }
    if (tipoUsuario !== "alumno" || !selectorDePedido) {
        mostrarSnackbar("Solo los alumnos pueden pedir clases.", "error");
        return;
    }

    const dialogoPedir = document.getElementById("dialogoPedirClase");
    dialogoPedir.dataset.idProfesor = idProfesor;
    document.getElementById("nombreProfesorPedido").textContent = nombreProfesor || "el profesor";
    mostrarMensaje(document.getElementById("mensajePedirClase"), "");
    selectorDePedido.configurar({ idOtroUsuario: idProfesor });
    abrirDialogo("dialogoPedirClase");
}

function enviarPedidoDeClase() {
    const mensajePedir = document.getElementById("mensajePedirClase");
    const botonEnviar = document.getElementById("botonEnviarPedido");
    const horario = selectorDePedido.valor();
    if (!horario) return mostrarErrorEnCampo(mensajePedir, selectorDePedido.campoDia, "Elegí un día y una hora de inicio.");

    mostrarMensaje(mensajePedir, "");
    botonEnviar.disabled = true;
    enviarAccionDeClase("/Clases/EnviarPedido", {
        idProfesor: document.getElementById("dialogoPedirClase").dataset.idProfesor,
        fecha: horario
    })
        .then(({ ok, cuerpo }) => {
            if (!ok) {
                mostrarMensaje(mensajePedir, cuerpo.mensaje);
                if (cuerpo.resultado?.startsWith("horarioOcupado")) selectorDePedido.recargar();
                return;
            }
            cerrarDialogo("dialogoPedirClase");
            mostrarSnackbar(cuerpo.mensaje, "exito");
            actualizarInsigniaDeNotificaciones(cuerpo.cantidadNotificaciones);
            // Desde el Historial del Panel ("Pedir otra clase") el pedido nuevo aparece en Mis clases sin recargar
            if (document.getElementById("panelTabs")) refrescarPanel().then(() => resaltarClase(cuerpo.idClase));
        })
        .catch(error => {
            console.error(error);
            mostrarMensaje(mensajePedir, "No pudimos enviar el pedido. Probá de nuevo en unos minutos.");
        })
        .finally(() => { botonEnviar.disabled = false; });

    return false;
}

// ----- Panel de Control: aceptar, rechazar, reubicar y cancelar -----
// Todo con fetch y sin recargar la página: después de cada acción se vuelve a pedir el Panel y se cambia solo
// lo que cambió (clases, historial, notificaciones, contadores y la insignia del header).
let selectorDeReubicacion = null;
let claseElegida = null;

// Si el servidor contesta alguno de estos, lo que se ve en pantalla está viejo (la otra persona ya respondió, canceló, etc.)
const resultadosDePantallaVieja = ["yaRespondida", "noSePuedeCancelar", "noSePuedeReubicar", "claseInexistente", "noEsTuClase"];

function inicializarAccionesDeClases() {
    const panel = document.getElementById("panelTabs");
    if (!panel) return;

    abrirPestanaYClase(new URLSearchParams(window.location.search));

    selectorDeReubicacion = crearSelectorHorario(document.getElementById("dialogoReubicarClase").querySelector("[data-selector-horario]"));

    // Los botones de las tarjetas se escuchan en el contenedor: siguen andando cuando el Panel se actualiza
    panel.addEventListener("click", evento => {
        const boton = evento.target.closest("[data-accion-clase]");
        if (!boton) return;

        const tarjeta = boton.closest("[data-clase]");
        claseElegida = {
            id: tarjeta.dataset.idClase,
            idOtro: tarjeta.dataset.idOtro,
            nombreOtro: tarjeta.dataset.nombreOtro,
            fechaTexto: tarjeta.dataset.fechaTexto,
            estado: tarjeta.dataset.estado,
            muyCerca: tarjeta.dataset.muyCerca === "true"
        };

        const accion = boton.dataset.accionClase;
        if (accion === "aceptar" || accion === "rechazar") responderClase(boton, accion === "aceptar");
        else if (claseElegida.muyCerca) avisarClaseCercana();
        else if (accion === "cancelar") abrirCancelacionDeClase();
        else if (accion === "reubicar") abrirReubicacionDeClase();
    });

    // Los botones de las notificaciones llevan a la pestaña y a la clase sin recargar el Panel
    document.getElementById("notificaciones").addEventListener("click", evento => {
        const enlace = evento.target.closest("a.boton[href*='/Home/PanelControl']");
        if (!enlace) return;
        evento.preventDefault();
        abrirPestanaYClase(new URL(enlace.href).searchParams);
    });

    document.getElementById("botonConfirmarCancelacion").addEventListener("click", confirmarCancelacionDeClase);
    document.getElementById("botonAbrirChatClaseCercana").addEventListener("click", () => document.getElementById("botonTabChat")?.click());
}

// Vuelve a pedir el Panel y cambia solo lo que cambió. Si la sesión venció, el servidor redirige al inicio de sesión
function refrescarPanel() {
    return fetch("/Home/PanelControl")
        .then(respuesta => {
            if (!respuesta.url.includes("/Home/PanelControl")) {
                window.location.href = respuesta.url;
                return null;
            }
            return respuesta.text();
        })
        .then(html => {
            if (html === null) return;
            const nuevo = new DOMParser().parseFromString(html, "text/html");

            ["notificaciones", "tabClases", "tabHistorial"].forEach(id => {
                const reemplazo = nuevo.getElementById(id);
                if (reemplazo) document.getElementById(id).innerHTML = reemplazo.innerHTML;
            });
            ["contadorClasesActivas", "contadorClasesCompletadas"].forEach(id => {
                const reemplazo = nuevo.getElementById(id);
                if (reemplazo) document.getElementById(id).textContent = reemplazo.textContent;
            });
            actualizarInsigniaDeNotificaciones(Number(nuevo.getElementById("insigniaNotificaciones")?.textContent ?? 0));
        })
        .catch(error => console.error(error));
}

// Las notificaciones llevan a /Home/PanelControl?tab=clases&clase=12: abre esa pestaña y resalta la clase
function abrirPestanaYClase(parametros) {
    const pestana = parametros.get("tab") === "historial" ? "Historial" : "Clases";
    const idClase = parametros.get("clase");
    if (!parametros.has("tab") && !idClase) return;

    document.getElementById(`botonTab${pestana}`)?.click();
    const destino = document.getElementById(pestana === "Historial" ? `historial-${idClase}` : `clase-${idClase}`);
    if (!destino) return;
    setTimeout(() => {
        destino.scrollIntoView({ behavior: "smooth", block: "center" });
        resaltarElemento(destino);
    }, 150);
}

// La clase que acaba de cambiar se resalta un momento (en Mis clases o, si ya terminó, en el Historial)
function resaltarClase(idClase) {
    const destino = document.getElementById(`clase-${idClase}`) || document.getElementById(`historial-${idClase}`);
    if (destino) resaltarElemento(destino);
}

function resaltarElemento(elemento) {
    elemento.classList.remove("resaltada");
    void elemento.offsetWidth;
    elemento.classList.add("resaltada");
}

// Si el servidor dice que la clase está muy próxima, se explica y se ofrece el chat
function avisarClaseCercana() {
    document.getElementById("nombreClaseCercana").textContent = claseElegida.nombreOtro;
    cerrarDialogo("dialogoCancelarClase");
    cerrarDialogo("dialogoReubicarClase");
    abrirDialogo("dialogoClaseCercana");
}

// La acción salió bien: se cierran los diálogos, se avisa y se actualiza el Panel
function accionDeClaseCompletada(mensaje) {
    cerrarDialogo("dialogoCancelarClase");
    cerrarDialogo("dialogoReubicarClase");
    mostrarSnackbar(mensaje, "exito");
    refrescarPanel().then(() => resaltarClase(claseElegida.id));
}

// La acción no se pudo: si lo que se ve ya está viejo se actualiza el Panel; si no, el motivo va en el diálogo
function accionDeClaseRechazada(cuerpo, mensajeDelDialogo) {
    if (cuerpo.resultado === "muyCerca") {
        avisarClaseCercana();
    } else if (resultadosDePantallaVieja.includes(cuerpo.resultado)) {
        cerrarDialogo("dialogoCancelarClase");
        cerrarDialogo("dialogoReubicarClase");
        mostrarSnackbar(cuerpo.mensaje, "error");
        refrescarPanel();
    } else if (mensajeDelDialogo) {
        mostrarMensaje(mensajeDelDialogo, cuerpo.mensaje);
    } else {
        mostrarSnackbar(cuerpo.mensaje, "error");
    }
}

function responderClase(boton, aceptar) {
    boton.disabled = true;
    enviarAccionDeClase("/Clases/Responder", { idClase: claseElegida.id, aceptar })
        .then(({ ok, cuerpo }) => {
            if (ok) accionDeClaseCompletada(cuerpo.mensaje);
            else accionDeClaseRechazada(cuerpo);
        })
        .catch(error => {
            console.error(error);
            mostrarSnackbar("No pudimos enviar tu respuesta. Probá de nuevo.", "error");
        })
        .finally(() => { boton.disabled = false; });
}

// Un pedido que nadie aceptó se cancela sin condiciones; una clase confirmada, avisando a la otra persona
function abrirCancelacionDeClase() {
    const esPedido = claseElegida.estado === "Pendiente";
    document.getElementById("tituloCancelarClase").textContent = esPedido ? "¿Cancelar el pedido?" : "¿Cancelar esta clase?";
    document.getElementById("textoCancelarClase").replaceChildren(
        `Vas a cancelar ${esPedido ? "tu pedido de clase" : "tu clase"} con `,
        crearElemento("strong", "", claseElegida.nombreOtro),
        ` (${claseElegida.fechaTexto}). `,
        esPedido ? "Todavía nadie lo aceptó, así que no hay ningún compromiso." : "Le avisamos a la otra persona."
    );
    mostrarMensaje(document.getElementById("mensajeCancelarClase"), "");
    abrirDialogo("dialogoCancelarClase");
}

function confirmarCancelacionDeClase() {
    const mensajeCancelar = document.getElementById("mensajeCancelarClase");
    const botonConfirmar = document.getElementById("botonConfirmarCancelacion");
    botonConfirmar.disabled = true;

    enviarAccionDeClase("/Clases/Cancelar", { idClase: claseElegida.id })
        .then(({ ok, cuerpo }) => {
            if (ok) accionDeClaseCompletada(claseElegida.estado === "Pendiente" ? "Pedido cancelado." : cuerpo.mensaje);
            else accionDeClaseRechazada(cuerpo, mensajeCancelar);
        })
        .catch(error => {
            console.error(error);
            mostrarMensaje(mensajeCancelar, "No pudimos cancelar. Probá de nuevo.");
        })
        .finally(() => { botonConfirmar.disabled = false; });
}

function abrirReubicacionDeClase() {
    document.getElementById("nombreClaseAReubicar").textContent = claseElegida.nombreOtro;
    document.getElementById("nombreQuienResponde").textContent = claseElegida.nombreOtro;
    mostrarMensaje(document.getElementById("mensajeReubicarClase"), "");
    selectorDeReubicacion.configurar({ idOtroUsuario: claseElegida.idOtro, idClaseExcluir: claseElegida.id });
    abrirDialogo("dialogoReubicarClase");
}

function enviarReubicacionDeClase() {
    const mensajeReubicar = document.getElementById("mensajeReubicarClase");
    const botonConfirmar = document.getElementById("botonConfirmarReubicacion");
    const horario = selectorDeReubicacion.valor();
    if (!horario) return mostrarErrorEnCampo(mensajeReubicar, selectorDeReubicacion.campoDia, "Elegí un día y una hora de inicio.");

    mostrarMensaje(mensajeReubicar, "");
    botonConfirmar.disabled = true;
    enviarAccionDeClase("/Clases/Reubicar", { idClase: claseElegida.id, fecha: horario })
        .then(({ ok, cuerpo }) => {
            if (ok) {
                accionDeClaseCompletada(cuerpo.mensaje);
            } else {
                accionDeClaseRechazada(cuerpo, mensajeReubicar);
                if (cuerpo.resultado?.startsWith("horarioOcupado")) selectorDeReubicacion.recargar();
            }
        })
        .catch(error => {
            console.error(error);
            mostrarMensaje(mensajeReubicar, "No pudimos cambiar el horario. Probá de nuevo.");
        })
        .finally(() => { botonConfirmar.disabled = false; });

    return false;
}


// ================= INICIALIZACIÓN =================
function inicializarClases() {
    inicializarInsigniaDeNotificaciones();
    inicializarPedidoDeClase();
    inicializarAccionesDeClases();
}

document.addEventListener("DOMContentLoaded", inicializarClases);
