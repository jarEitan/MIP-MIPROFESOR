// Catálogo de profesores: lee los filtros del formulario, pide una página a Catalogo/Buscar con fetch
// y dibuja las tarjetas horizontales y la paginación. Los selectores con búsqueda los arma site.js.
// Todo el texto de la base se inserta con textContent, nunca como HTML.

const porPaginaPredeterminado = 10;
const coloresAvatar = ["theme-primary", "theme-accent", "theme-inverse"];

let paginaActual = 1;
let porPaginaActual = porPaginaPredeterminado;
let temporizadorBusqueda = null;
// Cada búsqueda lleva un número: si llega la respuesta de una búsqueda vieja, se descarta
let numeroDeBusqueda = 0;

function inicializarCatalogo() {
    const formularioFiltros = document.getElementById("formularioFiltros");

    // Página y cantidad por página de la URL, ya validadas por el servidor
    paginaActual = parseInt(formularioFiltros.dataset.pagina);
    porPaginaActual = parseInt(formularioFiltros.dataset.porPagina);

    // Al elegir en un selector se vuelve a buscar desde la página 1
    formularioFiltros.addEventListener("change", evento => {
        if (evento.target.tagName === "SELECT") {
            buscarProfesores(1);
        }
    });

    // Al escribir se espera a que la persona termine antes de buscar
    document.getElementById("filtroTexto").addEventListener("input", () => {
        clearTimeout(temporizadorBusqueda);
        temporizadorBusqueda = setTimeout(() => buscarProfesores(1), 400);
    });

    // El reset vacía los campos DESPUÉS de este evento, por eso se espera un instante
    formularioFiltros.addEventListener("reset", () => {
        setTimeout(() => buscarProfesores(1), 0);
    });

    document.getElementById("paginaAnterior").addEventListener("click", () => buscarProfesores(paginaActual - 1, true));
    document.getElementById("paginaSiguiente").addEventListener("click", () => buscarProfesores(paginaActual + 1, true));

    document.getElementById("tarjetasPorPagina").addEventListener("change", evento => {
        porPaginaActual = parseInt(evento.target.value);
        buscarProfesores(1);
    });

    buscarProfesores(paginaActual);
}

// Arma los parámetros de la consulta con lo que hay en el formulario
function leerFiltros() {
    const parametros = new URLSearchParams();
    const agregarSiHayValor = (nombre, valor) => {
        if (valor !== "") {
            parametros.append(nombre, valor);
        }
    };

    agregarSiHayValor("busqueda", document.getElementById("filtroTexto").value.trim());
    agregarSiHayValor("materia", document.getElementById("filtroMateria").value);
    agregarSiHayValor("colegio", document.getElementById("filtroColegio").value);
    agregarSiHayValor("modalidad", document.getElementById("filtroModalidad").value);
    Array.from(document.getElementById("filtroNivel").selectedOptions).forEach(opcion => agregarSiHayValor("nivel", opcion.value));

    return parametros;
}

// GET /Catalogo/Buscar?busqueda=...&nivel=...&pagina=2&porPagina=10 → una página de profesores
function buscarProfesores(pagina, subirALaLista) {
    const filtros = leerFiltros();

    // La URL visible guarda solo lo que no es el valor por defecto, para poder compartir la búsqueda
    const parametrosUrl = new URLSearchParams(filtros);
    if (pagina > 1) {
        parametrosUrl.set("pagina", pagina);
    }
    if (porPaginaActual !== porPaginaPredeterminado) {
        parametrosUrl.set("porPagina", porPaginaActual);
    }
    const textoUrl = parametrosUrl.toString();
    history.replaceState(null, "", textoUrl === "" ? location.pathname : location.pathname + "?" + textoUrl);

    // El servidor siempre recibe la página y la cantidad
    const consulta = new URLSearchParams(filtros);
    consulta.set("pagina", pagina);
    consulta.set("porPagina", porPaginaActual);

    const numeroDeEstaBusqueda = ++numeroDeBusqueda;
    const listaProfesores = document.getElementById("listaProfesores");
    listaProfesores.setAttribute("aria-busy", "true");

    fetch("/Catalogo/Buscar?" + consulta, {
        method: "GET"
    })
    .then(respuesta => respuesta.json())
    .then(resultado => {
        // Si mientras tanto se pidió otra búsqueda, esta respuesta ya no sirve
        if (numeroDeEstaBusqueda !== numeroDeBusqueda) {
            return;
        }
        // Si falla la base llega un 500 con { ok: false, mensaje }
        if (!resultado.ok) {
            throw new Error(resultado.mensaje);
        }

        mostrarResultados(resultado);

        if (subirALaLista) {
            listaProfesores.scrollIntoView({ behavior: "smooth", block: "start" });
        }
    })
    .catch((error) => {
        console.error("Error:", error);
        if (numeroDeEstaBusqueda === numeroDeBusqueda) {
            mostrarErrorCatalogo();
        }
    })
    .finally(() => {
        if (numeroDeEstaBusqueda === numeroDeBusqueda) {
            listaProfesores.removeAttribute("aria-busy");
        }
    });
}

function mostrarResultados(resultado) {
    paginaActual = resultado.pagina;
    porPaginaActual = resultado.porPagina;

    document.getElementById("listaProfesores").replaceChildren(...resultado.profesores.map(crearTarjetaProfesor));
    document.getElementById("errorCatalogo").hidden = true;
    document.getElementById("sinResultados").hidden = resultado.total > 0;
    document.getElementById("cantidadResultados").textContent = resultado.total === 1 ? "1 profesor" : `${resultado.total} profesores`;

    document.getElementById("paginador").hidden = resultado.total === 0;
    dibujarNumerosDePagina(resultado.pagina, resultado.totalPaginas);
    document.getElementById("paginaAnterior").disabled = resultado.pagina <= 1;
    document.getElementById("paginaSiguiente").disabled = resultado.pagina >= resultado.totalPaginas;
    document.getElementById("tarjetasPorPagina").value = resultado.porPagina;
}

// Números de página: todos si son pocos; si no, la primera, la última y las cercanas a la actual
function dibujarNumerosDePagina(pagina, totalPaginas) {
    const numeros = [];
    for (let numero = 1; numero <= totalPaginas; numero++) {
        if (numero === 1 || numero === totalPaginas || Math.abs(numero - pagina) <= 1) {
            numeros.push(numero);
        }
    }

    const elementos = [];
    numeros.forEach((numero, posicion) => {
        // Entre dos números salteados van puntos suspensivos
        if (posicion > 0 && numero - numeros[posicion - 1] > 1) {
            elementos.push(crearElemento("span", "puntos", "…"));
        }

        const boton = crearElemento("button", numero === pagina ? "numero activo" : "numero", String(numero));
        boton.type = "button";
        boton.setAttribute("aria-label", `Página ${numero}`);
        if (numero === pagina) {
            boton.setAttribute("aria-current", "page");
        } else {
            boton.addEventListener("click", () => buscarProfesores(numero, true));
        }
        elementos.push(boton);
    });

    document.getElementById("numerosPagina").replaceChildren(...elementos);
}

function mostrarErrorCatalogo() {
    document.getElementById("listaProfesores").replaceChildren();
    document.getElementById("sinResultados").hidden = true;
    document.getElementById("paginador").hidden = true;
    document.getElementById("cantidadResultados").textContent = "";
    document.getElementById("errorCatalogo").hidden = false;
}

// ================= TARJETA HORIZONTAL =================

function crearIcono(nombreIcono) {
    const icono = crearElemento("i", `bi ${nombreIcono}`);
    icono.setAttribute("aria-hidden", "true");
    return icono;
}

function crearTarjetaProfesor(profesor) {
    const urlPerfil = `/Home/Perfil/${profesor.id}`;
    const tarjeta = crearElemento("article", "card profesorFila");

    // Foto de perfil, o las iniciales sobre un color si todavía no cargó una
    const avatar = crearElemento("span", "avatar");
    if (profesor.fotoPerfil) {
        const foto = crearElemento("img");
        foto.src = profesor.fotoPerfil;
        foto.alt = `Foto de perfil de ${profesor.nombreCompleto}`;
        avatar.append(foto);
    } else {
        avatar.classList.add(coloresAvatar[profesor.id % coloresAvatar.length]);
        avatar.textContent = profesor.iniciales;
        avatar.setAttribute("aria-hidden", "true");
    }

    // Cuerpo: nombre con sellos, colegios, materias, resumen, calificación y niveles
    const cuerpo = crearElemento("div", "cuerpo");

    const nombre = crearElemento("div", "nombre");
    const titulo = crearElemento("h3");
    const enlace = crearElemento("a", "", profesor.nombreCompleto);
    enlace.href = urlPerfil;
    titulo.append(enlace);
    nombre.append(titulo);
    if (profesor.verificado) {
        const sello = crearElemento("span", "badge badge-subtle theme-success");
        sello.title = "Credenciales revisadas por el equipo de MIP";
        sello.append(crearIcono("bi-patch-check-fill"), " Verificado");
        nombre.append(sello);
    }
    // "Popular": muy bien calificado y con más de una reseña
    if (profesor.calificacion >= 4.8 && profesor.cantidadResenas >= 2) {
        nombre.append(crearElemento("span", "badge badge-subtle theme-primary", "Popular"));
    }
    cuerpo.append(nombre);

    const colegios = crearElemento("p", "colegios");
    const textoColegios = profesor.colegios.length > 0 ? profesor.colegios.join(" · ") : "Sin colegio cargado";
    colegios.append(crearIcono("bi-building"), " " + textoColegios);
    cuerpo.append(colegios);

    if (profesor.materias.length > 0) {
        const etiquetas = crearElemento("div", "etiquetas");
        profesor.materias.forEach(materia => etiquetas.append(crearElemento("span", "badge badge-subtle theme-inverse", materia)));
        cuerpo.append(etiquetas);
    }

    if (profesor.resumen !== "") {
        cuerpo.append(crearElemento("p", "resumen", profesor.resumen));
    }

    const listaDatos = crearElemento("ul", "datos");
    const calificacion = crearElemento("li");
    const textoCalificacion = profesor.cantidadResenas === 0 ? " Sin reseñas" : ` ${profesor.calificacion.toFixed(1).replace(".", ",")} (${profesor.cantidadResenas})`;
    calificacion.append(crearIcono("bi-star-fill"), textoCalificacion);
    const niveles = crearElemento("li");
    niveles.append(crearIcono("bi-mortarboard"), " " + profesor.niveles.join(", "));
    listaDatos.append(calificacion, niveles);
    cuerpo.append(listaDatos);

    // Columna derecha: modalidad, precio y botones
    const lateral = crearElemento("div", "lateral");
    lateral.append(crearElemento("span", "etiquetaModalidad", "Modalidad"));

    const modalidades = crearElemento("div", "etiquetas modalidades");
    profesor.modalidades.forEach(modalidad => modalidades.append(crearElemento("span", "badge badge-subtle theme-success", modalidad)));
    lateral.append(modalidades);

    const importe = crearElemento("p", "importe");
    importe.append(crearElemento("strong", "", `$ ${profesor.precioHora.toLocaleString("es-AR")}`), " ", crearElemento("span", "", "/ hora"));
    lateral.append(importe);

    const botonPerfil = crearElemento("a", "boton contorno chico", "Ver perfil");
    botonPerfil.href = urlPerfil;
    // Abre el diálogo "Pedir clase" (clases.js: abrirPedidoDeClase); sin sesión lleva a Iniciar sesión
    const botonPedido = crearElemento("button", "boton principal chico", "Enviar pedido");
    botonPedido.type = "button";
    botonPedido.dataset.pedirClase = "";
    botonPedido.dataset.idProfesor = profesor.id;
    botonPedido.dataset.nombreProfesor = profesor.nombreCompleto;
    lateral.append(botonPerfil, botonPedido);

    tarjeta.append(avatar, cuerpo, lateral);
    return tarjeta;
}

document.addEventListener("DOMContentLoaded", inicializarCatalogo);
