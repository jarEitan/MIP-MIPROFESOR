// Historial de clases: la pestaña "Historial" del Panel de Control (el historial propio) y el modal
// "Historial" del Perfil (el de cualquier usuario). Los dos piden los datos con fetch a HistorialController
// y dibujan la MISMA tabla con dibujarHistorial(). Se carga solo en esas dos páginas, después de site.js y clases.js.
// Qué clases se ven y cuántas (máximo 20) lo decide el SP obtenerHistorialClases, no esta página.
// Todo lo que viene de la base se inserta con textContent, nunca como HTML.

const textoDarResenaPendiente = "«Dar reseña» va a estar disponible muy pronto.";

// ----- Datos -----
// GET /Historial/Obtener/5. Si la base falla llega { mensaje } en vez del historial: se pasa al .catch de quien lo pidió.
function pedirHistorial(idUsuario) {
    return fetch("/Historial/Obtener/" + idUsuario, {
        method: "GET"
    })
    .then(respuesta => respuesta.json())
    .then(resultado => {
        if (resultado.mensaje) {
            throw new Error(resultado.mensaje);
        }

        return resultado;
    });
}

// ----- Dibujo de la tabla (lo comparten el Panel y el modal) -----
// esPanel: historial propio dentro del Panel. Suma la columna "Acción" (Pedir otra clase, solo alumnos)
// y le pone id a cada fila para que las notificaciones puedan resaltarla.
function dibujarHistorial(contenedor, resultado, esPanel) {
    contenedor.replaceChildren();

    if (!resultado.encontrado) {
        contenedor.append(crearEstadoVacioHistorial("Este usuario no existe", "Revisá que el enlace esté completo."));
        return;
    }

    if (resultado.clases.length === 0 && resultado.esPropio) {
        contenedor.append(crearEstadoVacioHistorial("Todavía no hay clases en tu historial", "Las clases completadas, canceladas y rechazadas aparecen acá."));
        return;
    }

    if (resultado.clases.length === 0) {
        contenedor.append(crearEstadoVacioHistorial("Todavía no tiene clases completadas", "Cuando termine sus primeras clases, van a aparecer acá."));
        return;
    }

    const conAccion = esPanel && resultado.tipoUsuario === "alumno";
    // La contraparte de un alumno es un profesor, y al revés
    const columnaContraparte = resultado.tipoUsuario === "alumno" ? "Profesor" : "Alumno";
    const columnas = [columnaContraparte, "Materia", "Colegio", "Puntuación", "Día"];

    if (conAccion) {
        columnas.push("Acción");
    }

    const filaTitulos = crearElemento("tr");

    columnas.forEach(columna => {
        const titulo = crearElemento("th", "", columna);
        titulo.scope = "col";
        filaTitulos.append(titulo);
    });

    const encabezado = crearElemento("thead");
    encabezado.append(filaTitulos);

    const cuerpoTabla = crearElemento("tbody");
    resultado.clases.forEach(clase => cuerpoTabla.append(crearFilaHistorial(clase, columnaContraparte, conAccion, esPanel)));

    const tabla = crearElemento("table", "table");
    tabla.append(encabezado, cuerpoTabla);

    const tarjeta = crearElemento("div", "card estatica tabla");
    tarjeta.append(tabla);
    contenedor.append(tarjeta);

    // El SP nunca manda más de 20: si llegaron 20 puede haber más viejas que no se pueden ver
    if (resultado.clases.length >= 20) {
        contenedor.append(crearElemento("p", "notaHistorial", "Se muestran las 20 clases más recientes."));
    }
}

function crearFilaHistorial(clase, columnaContraparte, conAccion, esPanel) {
    const nombreOtro = `${clase.nombreOtro} ${clase.apellidoOtro}`;
    const fila = crearElemento("tr");

    if (esPanel) {
        fila.id = `historial-${clase.id}`;
    }

    // La contraparte lleva a su perfil
    const enlace = crearElemento("a", "", nombreOtro);
    enlace.href = `/Home/Perfil/${clase.idOtroUsuario}`;
    const nombreEnNegrita = crearElemento("strong");
    nombreEnNegrita.append(enlace);
    const celdaContraparte = crearCeldaHistorial(columnaContraparte);
    celdaContraparte.append(nombreEnNegrita);

    // Cancelada y Rechazada solo aparecen en el historial propio: se marcan al lado del día
    const diaYEstado = crearElemento("span", "", new Date(clase.dia).toLocaleDateString("es-AR", { day: "2-digit", month: "2-digit", year: "numeric" }));

    if (clase.estado !== "Completada") {
        diaYEstado.append(" ", crearElemento("span", "badge badge-subtle theme-danger", clase.estado));
    }

    const celdaDia = crearCeldaHistorial("Día");
    celdaDia.append(diaYEstado);

    fila.append(
        celdaContraparte,
        crearCeldaHistorial("Materia", clase.materias || "–"),
        crearCeldaHistorial("Colegio", clase.colegios || "–"),
        crearCeldaPuntuacionHistorial(clase, nombreOtro),
        celdaDia
    );

    if (conAccion) {
        // Abre el diálogo "Pedir una clase" (clases.js) ya con ese profesor
        const botonPedir = crearElemento("button", "boton principal chico");
        botonPedir.type = "button";
        botonPedir.dataset.pedirClase = "";
        botonPedir.dataset.idProfesor = clase.idOtroUsuario;
        botonPedir.dataset.nombreProfesor = nombreOtro;
        botonPedir.append(crearIconoHistorial("bi-calendar-plus"), " Pedir otra clase");
        const celdaAccion = crearCeldaHistorial("Acción");
        celdaAccion.append(botonPedir);
        fila.append(celdaAccion);
    }

    return fila;
}

// Las estrellas de la última reseña; si no hay, "Dar reseña" (solo en el historial propio) o un guion
function crearCeldaPuntuacionHistorial(clase, nombreOtro) {
    const celda = crearCeldaHistorial("Puntuación");

    if (clase.puntuacion) {
        const estrellas = crearElemento("span", "estrellas");
        estrellas.setAttribute("aria-label", `${clase.puntuacion} de 5 estrellas`);

        for (let posicion = 1; posicion <= 5; posicion++) {
            estrellas.append(crearIconoHistorial(posicion <= clase.puntuacion ? "bi-star-fill" : "bi-star"));
        }

        celda.append(estrellas);
    } else if (clase.puedeDarResena) {
        const botonResena = crearElemento("button", "boton contorno chico");
        botonResena.type = "button";
        botonResena.dataset.darResena = "";
        botonResena.dataset.idUsuario = clase.idOtroUsuario;
        botonResena.setAttribute("aria-label", `Dar reseña a ${nombreOtro}`);
        botonResena.append(crearIconoHistorial("bi-star"), " Dar reseña");
        celda.append(botonResena);
    } else {
        celda.textContent = "–";
    }

    return celda;
}

// data-etiqueta: en celulares cada fila se apila y esa etiqueta se muestra al lado del valor (CSS)
function crearCeldaHistorial(etiqueta, texto) {
    const celda = crearElemento("td", "", texto);
    celda.dataset.etiqueta = etiqueta;
    return celda;
}

function crearIconoHistorial(nombreIcono) {
    const icono = crearElemento("i", `bi ${nombreIcono}`);
    icono.setAttribute("aria-hidden", "true");
    return icono;
}

function crearEstadoVacioHistorial(titulo, texto) {
    const tarjeta = crearElemento("div", "card estatica estadoVacio");
    const icono = crearElemento("span", "icono celeste");
    icono.append(crearIconoHistorial("bi-clock-history"));
    tarjeta.append(icono, crearElemento("h3", "", titulo), crearElemento("p", "", texto));
    return tarjeta;
}

// ----- Historial propio (pestaña del Panel de Control) -----
let historialPropioEnCurso = null;

// Siempre vuelve a pedir los datos (también lo llama clases.js después de aceptar, cancelar, etc.)
function cargarHistorialPropio() {
    const contenedor = document.getElementById("contenidoHistorialPanel");

    historialPropioEnCurso = pedirHistorial(contenedor.dataset.idUsuario)
    .then(resultado => {
        dibujarHistorial(contenedor, resultado, true);
    })
    .catch((error) => {
        console.error("Error:", error);
        const errorCarga = crearElemento("div", "card estatica estadoVacio");
        errorCarga.append(crearElemento("p", "", "No pudimos cargar tu historial. Probá de nuevo en unos minutos."));
        contenedor.replaceChildren(errorCarga);
    });

    return historialPropioEnCurso;
}

// El historial que ya está cargando o cargado; si todavía nadie lo pidió, lo pide. Sirve para resaltar una fila
// cuando se llega desde una notificación (la fila recién existe cuando termina el fetch).
function esperarHistorialPropio() {
    return historialPropioEnCurso || cargarHistorialPropio();
}

// ----- Historial de un perfil (modal) -----
let consultaHistorialPerfilVigente = 0;

function mostrarEstadoHistorialPerfil(texto, cargando) {
    const estado = document.getElementById("estadoHistorial");
    estado.hidden = false;
    estado.classList.toggle("cargando", cargando);

    if (cargando) {
        estado.replaceChildren(crearIconoHistorial("bi-arrow-repeat"), ` ${texto}`);
    } else {
        estado.replaceChildren(texto);
    }
}

function abrirHistorialDelPerfil() {
    const contenedor = document.getElementById("contenidoHistorialPerfil");
    const idPerfil = document.getElementById("perfil").dataset.idPerfil;

    document.getElementById("nombreHistorial").textContent = document.getElementById("nombrePerfil").textContent;
    document.getElementById("avisoHistorial").hidden = true;
    contenedor.replaceChildren();
    mostrarEstadoHistorialPerfil("Cargando historial…", true);
    abrirDialogo("dialogoHistorial");

    // Si se cierra y se vuelve a abrir antes de que llegue la respuesta, solo vale la última consulta
    const consulta = ++consultaHistorialPerfilVigente;

    pedirHistorial(idPerfil)
    .then(resultado => {
        if (consulta !== consultaHistorialPerfilVigente) {
            return;
        }

        document.getElementById("estadoHistorial").hidden = true;
        dibujarHistorial(contenedor, resultado, false);
    })
    .catch((error) => {
        console.error("Error:", error);

        if (consulta === consultaHistorialPerfilVigente) {
            mostrarEstadoHistorialPerfil("No pudimos cargar el historial. Probá de nuevo en unos minutos.", false);
        }
    });
}

// "Dar reseña" todavía no hace nada. Dentro del modal el snackbar quedaría detrás (el diálogo está en la capa de arriba),
// así que ahí el aviso va dentro del mismo modal (solo existe en el Perfil).
function avisarDarResenaPendiente(botonResena) {
    if (botonResena.closest("dialog")) {
        const avisoHistorial = document.getElementById("avisoHistorial");
        avisoHistorial.textContent = textoDarResenaPendiente;
        avisoHistorial.hidden = false;
        return;
    }

    mostrarSnackbar(textoDarResenaPendiente);
}


// ================= INICIALIZACIÓN =================
function inicializarHistorial() {
    // Los botones "Dar reseña" se crean con fetch: se escuchan en el documento
    document.addEventListener("click", evento => {
        const botonResena = evento.target.closest("[data-dar-resena]");

        if (botonResena) {
            avisarDarResenaPendiente(botonResena);
        }
    });

    document.getElementById("botonHistorial")?.addEventListener("click", abrirHistorialDelPerfil);

    if (document.getElementById("contenidoHistorialPanel")) {
        esperarHistorialPropio();
    }
}

document.addEventListener("DOMContentLoaded", inicializarHistorial);
