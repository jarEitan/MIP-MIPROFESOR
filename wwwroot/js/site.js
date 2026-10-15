// =====================================================================
// MiProfesor (MIP) - JavaScript global (se carga en todas las páginas)
// Bootstrap 6 es ESM y ya no expone window.bootstrap: sus componentes (drawer, dialog, menu,
// tabs, acordeón) funcionan solos con los atributos data-bs-* del HTML. Acá va solo la lógica
// propia de MIP. Cada parte se arranca desde inicializarSitio(), al final del archivo.
// =====================================================================


// ================= UTILIDADES =================
// Los mensajes de error se muestran solos: el CSS oculta ".mensajeError:empty"
function mostrarMensaje(elementoMensaje, texto) {
    if (elementoMensaje) {
        elementoMensaje.textContent = texto;
    }
}

// Muestra el error y pone el foco en el campo. Devuelve false para cortar el onsubmit
function mostrarErrorEnCampo(elementoMensaje, campo, texto) {
    mostrarMensaje(elementoMensaje, texto);

    // Si el campo es un <select data-buscable>, el foco va a su campo de texto visible
    let campoVisible = campo;
    if (campo && campo.hidden && campo.nextElementSibling?.classList.contains("selectorBuscable")) {
        campoVisible = campo.nextElementSibling.querySelector("input");
    }
    if (campoVisible) {
        campoVisible.focus();
    }
    return false;
}

// Quita tildes y mayúsculas para comparar textos ("Matemática" = "matematica")
function normalizarTexto(texto) {
    return (texto || "").normalize("NFD").replace(/[̀-ͯ]/g, "").toLowerCase().trim();
}

function correoValido(correo) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(correo);
}

// Crea un elemento con clases y texto (textContent: nunca interpreta HTML)
function crearElemento(etiqueta, clases, texto) {
    const elemento = document.createElement(etiqueta);
    if (clases) {
        elemento.className = clases;
    }
    if (texto !== undefined) {
        elemento.textContent = texto;
    }
    return elemento;
}

// Snackbar del UI Kit: aviso corto abajo de la pantalla. tipo: "info" | "exito" | "error"
let temporizadorSnackbar = null;

function mostrarSnackbar(texto, tipo = "info") {
    const snackbar = document.getElementById("snackbar");
    if (!snackbar) {
        return;
    }

    snackbar.textContent = texto;
    snackbar.dataset.tipo = tipo;
    snackbar.hidden = false;

    // Se reinicia la animación aunque ya hubiera uno visible
    snackbar.classList.remove("visible");
    void snackbar.offsetWidth;
    snackbar.classList.add("visible");

    // Un aviso nuevo cancela el ocultado del anterior (también si ya se estaba yendo)
    clearTimeout(temporizadorSnackbar);
    temporizadorSnackbar = setTimeout(() => {
        snackbar.classList.remove("visible");
        temporizadorSnackbar = setTimeout(() => {
            snackbar.hidden = true;
        }, 300);
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

    const selector = crearElemento("div", esMultiple ? "selectorBuscable multiple" : "selectorBuscable");
    const etiquetasElegidas = crearElemento("div", "etiquetasElegidas");
    const campo = crearElemento("div", "campoSelector");

    const entrada = crearElemento("input", "form-control");
    entrada.type = "text";
    entrada.id = `${idBase}Buscador`;
    entrada.autocomplete = "off";
    entrada.spellcheck = false;
    entrada.setAttribute("role", "combobox");
    entrada.setAttribute("aria-autocomplete", "list");
    entrada.setAttribute("aria-expanded", "false");
    entrada.setAttribute("aria-controls", `${idBase}Lista`);

    const botonDesplegar = crearElemento("button", "desplegar");
    botonDesplegar.type = "button";
    botonDesplegar.tabIndex = -1;
    botonDesplegar.setAttribute("aria-label", "Mostrar opciones");
    botonDesplegar.innerHTML = '<i class="bi bi-chevron-down" aria-hidden="true"></i>';

    const lista = crearElemento("ul", "listaOpciones");
    lista.id = `${idBase}Lista`;
    lista.setAttribute("role", "listbox");
    lista.hidden = true;

    campo.append(entrada, botonDesplegar);
    if (esMultiple) {
        lista.setAttribute("aria-multiselectable", "true");
        selector.append(etiquetasElegidas);
    }
    selector.append(campo, lista);

    // La etiqueta del <select> pasa a apuntar al campo de texto
    const etiqueta = select.id ? document.querySelector(`label[for="${select.id}"]`) : null;
    if (etiqueta) {
        etiqueta.htmlFor = entrada.id;
    }

    select.hidden = true;
    select.tabIndex = -1;
    select.insertAdjacentElement("afterend", selector);

    let textoFiltro = "";
    let indiceActivo = -1;

    const obtenerItemsDeLista = () => Array.from(lista.querySelectorAll("[role='option']"));
    const avisarCambio = () => select.dispatchEvent(new Event("change", { bubbles: true }));

    // Muestra lo elegido: texto en el campo (simple) o etiquetas (múltiple)
    const mostrarElegidas = () => {
        entrada.placeholder = select.dataset.placeholder
            || Array.from(select.options).find(opcion => opcion.value === "")?.textContent
            || "Elegí una opción";

        if (!esMultiple) {
            const elegida = select.selectedOptions[0];
            entrada.value = elegida && elegida.value !== "" ? elegida.textContent : "";
            return;
        }

        entrada.value = "";
        etiquetasElegidas.replaceChildren();
        Array.from(select.selectedOptions).filter(opcion => opcion.value !== "").forEach(opcion => {
            const etiquetaElegida = crearElemento("span", "badge theme-accent", opcion.textContent);

            const botonQuitar = document.createElement("button");
            botonQuitar.type = "button";
            botonQuitar.setAttribute("aria-label", `Quitar ${opcion.textContent}`);
            botonQuitar.innerHTML = '<i class="bi bi-x" aria-hidden="true"></i>';
            botonQuitar.addEventListener("click", () => {
                opcion.selected = false;
                mostrarElegidas();
                if (!lista.hidden) {
                    dibujarOpciones();
                }
                avisarCambio();
            });

            etiquetaElegida.append(botonQuitar);
            etiquetasElegidas.append(etiquetaElegida);
        });
        etiquetasElegidas.hidden = etiquetasElegidas.children.length === 0;
    };

    const marcarActiva = nuevoIndice => {
        const items = obtenerItemsDeLista();
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
            lista.append(crearElemento("li", "sinCoincidencias", "No hay coincidencias"));
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
                const tilde = crearElemento("i", "bi bi-check-lg");
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

    const abrirLista = () => {
        if (!lista.hidden) {
            return;
        }

        textoFiltro = "";
        lista.hidden = false;
        selector.classList.add("abierto");
        entrada.setAttribute("aria-expanded", "true");
        dibujarOpciones();
    };

    const cerrarLista = () => {
        if (lista.hidden) {
            return;
        }

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
            cerrarLista();
            mostrarElegidas();
        }
        avisarCambio();
    };

    entrada.addEventListener("focus", () => {
        abrirLista();
        if (!esMultiple) {
            entrada.select();
        }
    });
    entrada.addEventListener("click", abrirLista);
    entrada.addEventListener("input", () => {
        abrirLista();
        textoFiltro = entrada.value;
        dibujarOpciones();
    });
    entrada.addEventListener("keydown", evento => {
        if (evento.key === "ArrowDown" || evento.key === "ArrowUp") {
            evento.preventDefault();
            if (lista.hidden) {
                abrirLista();
                return;
            }
            marcarActiva(indiceActivo + (evento.key === "ArrowDown" ? 1 : -1));
        } else if (evento.key === "Enter") {
            if (lista.hidden) {
                return;
            }
            evento.preventDefault();
            const item = obtenerItemsDeLista()[indiceActivo];
            if (item) {
                elegirOpcion(item.opcionDelSelect);
            }
        } else if (evento.key === "Escape") {
            if (lista.hidden) {
                return;
            }
            // Dentro de un diálogo, Escape cierra la lista y no el diálogo
            evento.preventDefault();
            evento.stopPropagation();
            cerrarLista();
        } else if (evento.key === "Tab") {
            cerrarLista();
        } else if (evento.key === "Backspace" && esMultiple && entrada.value === "") {
            const ultimaElegida = Array.from(select.selectedOptions).filter(opcion => opcion.value !== "").pop();
            if (!ultimaElegida) {
                return;
            }
            ultimaElegida.selected = false;
            mostrarElegidas();
            dibujarOpciones();
            avisarCambio();
        }
    });
    entrada.addEventListener("blur", cerrarLista);

    botonDesplegar.addEventListener("pointerdown", evento => evento.preventDefault());
    botonDesplegar.addEventListener("click", () => {
        if (lista.hidden) {
            entrada.focus();
            abrirLista();
        } else {
            cerrarLista();
        }
    });

    // El botón "Limpiar" de un formulario vuelve el <select> a su estado inicial: se redibuja después
    select.form?.addEventListener("reset", () => setTimeout(mostrarElegidas, 0));

    select.actualizarSelectorBuscable = () => {
        mostrarElegidas();
        if (!lista.hidden) {
            dibujarOpciones();
        }
    };
    mostrarElegidas();
}


// ================= AVISO "CUENTA NO VERIFICADA" (debajo del header) =================
// Se puede cerrar hasta la próxima sesión: se recuerda en sessionStorage y se olvida al cerrar sesión.
// sessionStorage puede estar bloqueado por el navegador: por eso los try.
function inicializarAvisoVerificacion() {
    document.querySelectorAll("form[action*='CerrarSesion']").forEach(formulario => {
        formulario.addEventListener("submit", () => {
            try {
                sessionStorage.removeItem("avisoVerificacionCerrado");
            } catch {
                // Sin sessionStorage no hay nada que olvidar
            }
        });
    });

    const avisoVerificacion = document.getElementById("avisoVerificacion");
    if (!avisoVerificacion) {
        return;
    }

    let estaCerrado = false;
    try {
        estaCerrado = sessionStorage.getItem("avisoVerificacionCerrado") === "true";
    } catch {
        // Sin sessionStorage el aviso se muestra siempre
    }
    avisoVerificacion.hidden = estaCerrado;

    document.getElementById("botonCerrarAvisoVerificacion").addEventListener("click", () => {
        avisoVerificacion.hidden = true;
        try {
            sessionStorage.setItem("avisoVerificacionCerrado", "true");
        } catch {
            // Sin sessionStorage no se puede recordar
        }
    });
}

// ================= HEADER: sombra al hacer scroll =================
function inicializarEncabezadoConScroll() {
    const encabezado = document.getElementById("encabezado");
    if (!encabezado) {
        return;
    }

    const actualizarSombraEncabezado = () => {
        encabezado.classList.toggle("conSombra", window.scrollY > 8);
    };

    actualizarSombraEncabezado();
    window.addEventListener("scroll", actualizarSombraEncabezado, { passive: true });
}


// ================= ANIMACIONES: revelar elementos al entrar en pantalla =================
// Marca con ".revelar" los títulos, tarjetas y figuras de cada sección (menos la portada)
// y les agrega ".visible" cuando entran en pantalla. Sin JS, todo se ve igual.
// Un carrusel aparece entero: sus tarjetas no se revelan solas porque las que están
// fuera de la pista quedarían invisibles al deslizarlas.
function inicializarRevelarAlScroll() {
    const elementosParaRevelar = document.querySelectorAll(
        "main section:not(.portada):not(.cinta) :is(.encabezadoSeccion, .card, figure, .accordion, .enlacesExternos, .colegios, .nav-pills, .carrusel):not(.pista > *)"
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
            if (!entrada.isIntersecting) {
                return;
            }
            entrada.target.classList.add("visible");
            observador.unobserve(entrada.target);
        });
    }, { threshold: 0.12, rootMargin: "0px 0px -30px 0px" });

    elementosParaRevelar.forEach(elemento => observadorDeVisibilidad.observe(elemento));
}


// ================= CARRUSEL: flechas de .carrusel =================
// La pista ya se desliza con el dedo o el trackpad (scroll-snap en el CSS).
// Las flechas avanzan de a una tarjeta y, desde la última, vuelven a la primera (y al revés).
// El scroll suave lo da "scroll-behavior: smooth" del CSS, que se apaga con movimiento reducido.
function inicializarCarruseles() {
    document.querySelectorAll(".carrusel").forEach(carrusel => {
        const pista = carrusel.querySelector(".pista");
        if (!pista) {
            return;
        }

        const moverCarrusel = direccion => {
            const primeraTarjeta = pista.firstElementChild;
            if (!primeraTarjeta) {
                return;
            }

            const paso = primeraTarjeta.offsetWidth + parseFloat(getComputedStyle(pista).columnGap || 0);
            const ultimaPosicion = pista.scrollWidth - pista.clientWidth;
            let destino = pista.scrollLeft + direccion * paso;

            // Margen de 2px por los redondeos del navegador
            if (direccion > 0 && pista.scrollLeft >= ultimaPosicion - 2) {
                destino = 0;
            }
            if (direccion < 0 && pista.scrollLeft <= 2) {
                destino = ultimaPosicion;
            }

            pista.scrollTo({ left: destino });
        };

        carrusel.querySelector("[data-carrusel='anterior']")?.addEventListener("click", () => moverCarrusel(-1));
        carrusel.querySelector("[data-carrusel='siguiente']")?.addEventListener("click", () => moverCarrusel(1));
    });
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

// Oculta el error apenas el usuario vuelve a escribir
function inicializarBuscador() {
    const campoBusqueda = document.getElementById("campoBusqueda");
    const mensajeErrorBusqueda = document.getElementById("mensajeErrorBusqueda");
    if (!campoBusqueda || !mensajeErrorBusqueda) {
        return;
    }

    campoBusqueda.addEventListener("input", () => mostrarMensaje(mensajeErrorBusqueda, ""));
}


// ================= REGISTRO =================
// Muestra el panel ilustrado que corresponde al rol elegido (data-solo-rol)
function inicializarRolesDeRegistro() {
    const formularioRegistro = document.getElementById("formularioRegistro");
    if (!formularioRegistro) {
        return;
    }

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
        if (!campo) {
            return;
        }

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
    const campoNombre = document.getElementById("registroNombre");
    const campoApellido = document.getElementById("registroApellido");
    const campoCorreo = document.getElementById("registroCorreo");
    const campoContrasena = document.getElementById("registroContrasena");
    const campoFechaNacimiento = document.getElementById("registroFechaNacimiento");
    const campoTerminos = document.getElementById("registroTerminos");

    if (campoNombre.value.trim().length < 2) {
        return mostrarErrorEnCampo(mensajeRegistro, campoNombre, "Ingresá tu nombre.");
    }
    if (campoApellido.value.trim().length < 2) {
        return mostrarErrorEnCampo(mensajeRegistro, campoApellido, "Ingresá tu apellido.");
    }
    if (!correoValido(campoCorreo.value.trim())) {
        return mostrarErrorEnCampo(mensajeRegistro, campoCorreo, "Ingresá un correo electrónico válido.");
    }
    if (campoContrasena.value.length < 8) {
        return mostrarErrorEnCampo(mensajeRegistro, campoContrasena, "La contraseña debe tener al menos 8 caracteres.");
    }
    if (!fechaNacimientoValida(campoFechaNacimiento.value)) {
        return mostrarErrorEnCampo(mensajeRegistro, campoFechaNacimiento, "Ingresá una fecha de nacimiento válida.");
    }
    if (!campoTerminos.checked) {
        return mostrarErrorEnCampo(mensajeRegistro, campoTerminos, "Tenés que aceptar los términos para continuar.");
    }

    mostrarMensaje(mensajeRegistro, "");
    return true;
}

// Entre 1900 y hoy ("" no es válida)
function fechaNacimientoValida(valor) {
    if (valor === "") {
        return false;
    }

    const fecha = new Date(valor + "T00:00:00");
    return !isNaN(fecha) && fecha <= new Date() && fecha.getFullYear() >= 1900;
}


// ================= INICIO DE SESIÓN =================
function validarIngreso() {
    const mensajeIngreso = document.getElementById("mensajeIngreso");
    const campoCorreo = document.getElementById("ingresoCorreo");
    const campoContrasena = document.getElementById("ingresoContrasena");

    if (!correoValido(campoCorreo.value.trim())) {
        return mostrarErrorEnCampo(mensajeIngreso, campoCorreo, "Ingresá un correo electrónico válido.");
    }
    if (campoContrasena.value === "") {
        return mostrarErrorEnCampo(mensajeIngreso, campoContrasena, "Ingresá tu contraseña.");
    }

    mostrarMensaje(mensajeIngreso, "");
    return true;
}


// ================= SOPORTE: buscador de preguntas frecuentes =================
function inicializarBuscadorDeAyuda() {
    const campoAyuda = document.getElementById("campoAyuda");
    const preguntas = document.querySelectorAll("#acordeonPreguntas details");
    if (!campoAyuda || preguntas.length === 0) {
        return;
    }

    const mensajeAyuda = document.getElementById("mensajeAyuda");
    const sinCoincidencias = document.getElementById("sinCoincidencias");

    campoAyuda.addEventListener("input", () => {
        const textoBuscado = normalizarTexto(campoAyuda.value);
        let cantidadVisible = 0;

        preguntas.forEach(pregunta => {
            const coincide = textoBuscado === "" || normalizarTexto(pregunta.textContent).includes(textoBuscado);
            pregunta.hidden = !coincide;
            if (coincide) {
                cantidadVisible++;
            }
        });

        sinCoincidencias.hidden = cantidadVisible > 0;
        mostrarMensaje(mensajeAyuda, textoBuscado === "" ? "" : `${cantidadVisible} ${cantidadVisible === 1 ? "pregunta encontrada" : "preguntas encontradas"}.`);
    });
}

function validarContacto() {
    const mensajeContacto = document.getElementById("mensajeContacto");
    const exitoContacto = document.getElementById("exitoContacto");
    const campoNombre = document.getElementById("contactoNombre");
    const campoCorreo = document.getElementById("contactoCorreo");
    const campoTipo = document.getElementById("contactoTipo");
    const campoMensaje = document.getElementById("contactoMensaje");
    exitoContacto.hidden = true;

    if (campoNombre.value.trim().length < 3) {
        return mostrarErrorEnCampo(mensajeContacto, campoNombre, "Ingresá tu nombre completo.");
    }
    if (!correoValido(campoCorreo.value.trim())) {
        return mostrarErrorEnCampo(mensajeContacto, campoCorreo, "Ingresá un correo electrónico válido.");
    }
    if (campoTipo.value === "") {
        return mostrarErrorEnCampo(mensajeContacto, campoTipo, "Elegí el tipo de consulta.");
    }
    if (campoMensaje.value.trim().length < 10) {
        return mostrarErrorEnCampo(mensajeContacto, campoMensaje, "Contanos un poco más (mínimo 10 caracteres).");
    }

    // TODO BD: guardar la consulta o enviarla por correo desde el servidor. Por ahora solo se muestra el aviso.
    mostrarMensaje(mensajeContacto, "");
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

// TODO BD: guardar el mensaje y refrescar la conversación. Por ahora solo se agrega la burbuja.
function enviarMensajeChat() {
    const campoMensaje = document.getElementById("campoMensajeChat");
    const contenedorMensajes = document.getElementById("mensajesChat");
    const texto = campoMensaje.value.trim();
    if (texto === "") {
        return false;
    }

    contenedorMensajes.appendChild(crearElemento("p", "burbuja propia", texto));
    contenedorMensajes.scrollTop = contenedorMensajes.scrollHeight;

    campoMensaje.value = "";
    campoMensaje.focus();
    return false;
}

// TODO BD: guardar los cambios. Por ahora solo se valida y se muestra el aviso.
function guardarConfiguracion() {
    const mensajeConfiguracion = document.getElementById("mensajeConfiguracion");
    const exitoConfiguracion = document.getElementById("exitoConfiguracion");
    const campoNombre = document.getElementById("configNombre");
    const campoCorreo = document.getElementById("configCorreo");
    exitoConfiguracion.hidden = true;

    if (campoNombre.value.trim().length < 3) {
        return mostrarErrorEnCampo(mensajeConfiguracion, campoNombre, "Ingresá tu nombre completo.");
    }
    if (!correoValido(campoCorreo.value.trim())) {
        return mostrarErrorEnCampo(mensajeConfiguracion, campoCorreo, "Ingresá un correo electrónico válido.");
    }

    mostrarMensaje(mensajeConfiguracion, "");
    exitoConfiguracion.hidden = false;
    return false;
}


// ================= PERFIL =================
// La vista Home/Perfil solo trae el esqueleto: los datos llegan por fetch desde PerfilesController.
// Los textos de la BD se ponen con textContent. La única excepción es "Sobre mí", que es HTML del
// editor y llega limpio desde el servidor (HtmlSanitizer solo deja negrita, listas, enlaces, etc.).
// Si el servidor responde un error, el JSON trae { mensaje }: se lanza y lo maneja el .catch.
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
    if (!seccionPerfil) {
        return;
    }

    cargarPerfil();
    inicializarCopiarEnlacePerfil();
    inicializarBotonesProximamente();
    inicializarMeGusta();
    inicializarEdicionPerfil();
}

function esPerfilPropio() {
    return document.getElementById("perfil").dataset.perfilPropio === "true";
}

// GET /Perfiles/ObtenerPerfil/5 → perfil público ({ encontrado: false } si el ID no existe)
function cargarPerfil() {
    const idPerfil = document.getElementById("perfil").dataset.idPerfil;
    const estadoPerfil = document.getElementById("estadoPerfil");

    fetch("/Perfiles/ObtenerPerfil/" + idPerfil, {
        method: "GET"
    })
    .then(respuesta => respuesta.json())
    .then(perfil => {
        if (perfil.mensaje) {
            throw new Error(perfil.mensaje);
        }

        estadoPerfil.hidden = true;
        if (!perfil.encontrado) {
            mostrarContenidoCargado(document.getElementById("perfilInexistente"));
            return;
        }

        mostrarPerfil(perfil);
        if (esPerfilPropio()) {
            cargarAvisoVerificacionPerfil();
        }
    })
    .catch((error) => {
        console.error("Error:", error);
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
    document.querySelectorAll("[data-solo-profesor]").forEach(boton => {
        boton.hidden = perfil.tipoUsuario !== "profesor";
        boton.dataset.nombreProfesor = nombreCompleto;
    });

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
    const iconoDato = crearElemento("i", `bi ${icono}`);
    iconoDato.setAttribute("aria-hidden", "true");

    const dato = document.createElement("span");
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
    cifrasPerfil.append(crearCifraPerfil("bi-heart-fill", perfil.cantidadLikes, "me gusta", "cantidadLikesPerfil"));

    // En la base, un profesor sin precio queda con 0
    if (perfil.tipoUsuario === "profesor") {
        const precio = perfil.precioHora > 0 ? `$ ${perfil.precioHora.toLocaleString("es-AR")}` : "Sin precio";
        cifrasPerfil.append(crearCifraPerfil("bi-cash-coin", precio, "por hora"));
    }
}

function crearCifraPerfil(icono, valor, detalle, idValor) {
    const iconoCifra = crearElemento("i", `bi ${icono}`);
    iconoCifra.setAttribute("aria-hidden", "true");

    const valorCifra = crearElemento("strong", "", valor);
    if (idValor) {
        valorCifra.id = idValor;
    }

    const cifra = document.createElement("li");
    cifra.append(iconoCifra, valorCifra, crearElemento("span", "", detalle));
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
        resenasPerfil.append(crearElemento("p", "vacio", "Todavía no tiene reseñas."));
        return;
    }

    resenas.forEach(resena => {
        // El nombre de quien escribió la reseña lleva a su perfil
        const autorResena = crearElemento("a", "", `${resena.nombre} ${resena.apellido}`);
        autorResena.href = `/Home/Perfil/${resena.idEmisor}`;
        if (resena.verificadoEmisor) {
            autorResena.append(" ", crearTickVerificado());
        }

        const estrellas = crearElemento("span", "estrellas");
        estrellas.setAttribute("aria-label", `${resena.puntuacion} de 5 estrellas`);
        for (let posicion = 1; posicion <= 5; posicion++) {
            const estrella = crearElemento("i", posicion <= resena.puntuacion ? "bi bi-star-fill" : "bi bi-star");
            estrella.setAttribute("aria-hidden", "true");
            estrellas.append(estrella);
        }

        const encabezadoResena = document.createElement("header");
        encabezadoResena.append(autorResena, estrellas);

        const tarjetaResena = crearElemento("div", "resena");
        tarjetaResena.append(encabezadoResena);
        if (resena.descripcion) {
            tarjetaResena.append(crearElemento("p", "", resena.descripcion));
        }
        resenasPerfil.append(tarjetaResena);
    });
}

function crearTickVerificado() {
    const tick = crearElemento("i", "bi bi-patch-check-fill tickVerificado");
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
        const textoSinDatos = perfil.tipoUsuario === "profesor"
            ? "Todavía no cargó sus materias, niveles ni colegios."
            : "Todavía no cargó su colegio ni su nivel.";
        datosPerfil.append(crearElemento("p", "vacio", textoSinDatos));
        return;
    }

    gruposConDatos.forEach(([tituloGrupo, icono, valores]) => {
        const tituloDelGrupo = document.createElement("h3");
        tituloDelGrupo.append(crearDatoConIcono(icono, tituloGrupo));

        const claseEtiqueta = tituloGrupo === "Materias" ? "badge theme-accent" : "badge badge-subtle theme-inverse";
        const etiquetas = crearElemento("div", "etiquetas");
        valores.forEach(valor => etiquetas.append(crearElemento("span", claseEtiqueta, valor)));

        const grupo = crearElemento("div", "grupo");
        grupo.append(tituloDelGrupo, etiquetas);
        datosPerfil.append(grupo);
    });
}

// ----- Aviso de verificación dentro del perfil propio -----
function cargarAvisoVerificacionPerfil() {
    pedirDatosEdicion()
    .then(datos => {
        mostrarAvisoVerificacionPerfil(datos.verificado, datos.faltantes);
    })
    .catch((error) => {
        console.error("Error:", error);
    });
}

function mostrarAvisoVerificacionPerfil(verificado, faltantes) {
    const avisoPerfil = document.getElementById("avisoVerificacionPerfil");
    if (!avisoPerfil) {
        return;
    }

    avisoPerfil.hidden = verificado || faltantes.length === 0;
    const listaFaltantes = document.getElementById("faltantesPerfil");
    listaFaltantes.replaceChildren(...faltantes.map(faltante => crearElemento("li", "", faltante.charAt(0).toUpperCase() + faltante.slice(1))));
    if (!avisoPerfil.hidden) {
        avisoPerfil.classList.add("revelar", "visible");
    }
}

// ----- Copiar enlace y botones sociales -----

// Copia la URL pública del perfil (/Home/Perfil/{id}), también cuando se entra a "Mi perfil" sin ID
function inicializarCopiarEnlacePerfil() {
    const botonCopiarEnlace = document.getElementById("botonCopiarEnlace");
    if (!botonCopiarEnlace) {
        return;
    }

    const enlacePerfil = `${window.location.origin}/Home/Perfil/${document.getElementById("perfil").dataset.idPerfil}`;
    botonCopiarEnlace.addEventListener("click", () => {
        navigator.clipboard.writeText(enlacePerfil)
        .then(() => {
            mostrarSnackbar("¡Enlace copiado! Ya lo podés compartir.", "exito");
        })
        .catch(() => {
            window.prompt("Copiá el enlace del perfil:", enlacePerfil);
        });
    });
}

// Agregar amigo, Mensaje, Reseña, Pedir clase y Reportar todavía no hacen nada
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

// ----- Me gusta (LikesController) -----
const coloresExplosionLike = ["#FF5757", "#5CE1E6", "#D51F47", "#FFB4B4"];

function inicializarMeGusta() {
    const botonMeGusta = document.getElementById("botonMeGusta");
    if (!botonMeGusta) {
        return;
    }

    const seccionPerfil = document.getElementById("perfil");
    const idPerfil = seccionPerfil.dataset.idPerfil;
    const haySesion = seccionPerfil.dataset.haySesion === "true";

    // Si ya le diste me gusta, el corazón arranca lleno (sin sesión no hay nada que averiguar).
    // Si hacés clic antes de que llegue esta respuesta, se ignora para no pisar el estado nuevo.
    let respuestaInicialVigente = true;
    if (haySesion) {
        fetch("/Likes/ObtenerLike/" + idPerfil, {
            method: "GET"
        })
        .then(respuesta => respuesta.json())
        .then(resultado => {
            if (resultado.mensaje) {
                throw new Error(resultado.mensaje);
            }
            if (respuestaInicialVigente) {
                pintarEstadoMeGusta(botonMeGusta, resultado.leGusta);
            }
        })
        .catch((error) => {
            console.error("Error:", error);
        });
    }

    botonMeGusta.addEventListener("click", () => {
        if (!haySesion) {
            window.location.href = "/Sesion/IniciarSesion";
            return;
        }
        respuestaInicialVigente = false;
        alternarMeGusta(botonMeGusta, idPerfil);
    });
}

function alternarMeGusta(botonMeGusta, idPerfil) {
    // Mientras viaja el pedido el botón queda bloqueado: dos clics seguidos no se pisan
    botonMeGusta.disabled = true;
    const token = document.querySelector("#perfil input[name='__RequestVerificationToken']");

    fetch("/Likes/AlternarLike", {
        method: "POST",
        headers: { "RequestVerificationToken": token ? token.value : "" },
        body: new URLSearchParams({ idReceptor: idPerfil })
    })
    .then(respuesta => respuesta.json())
    .then(resultado => {
        // Sin sesión, perfil propio o inexistente, error de la base: { resultado, mensaje }
        if (resultado.mensaje) {
            throw new Error(resultado.mensaje);
        }

        pintarEstadoMeGusta(botonMeGusta, resultado.leGusta);
        actualizarCantidadLikes(resultado.cantidadLikes);
        animarMeGusta(botonMeGusta, resultado.leGusta);
    })
    .catch((error) => {
        console.error("Error:", error);
        mostrarSnackbar("No pudimos guardar tu me gusta. Probá de nuevo.", "error");
    })
    .finally(() => {
        botonMeGusta.disabled = false;
    });
}

function pintarEstadoMeGusta(botonMeGusta, leGusta) {
    botonMeGusta.classList.toggle("activo", leGusta);
    botonMeGusta.setAttribute("aria-pressed", leGusta ? "true" : "false");
    const icono = botonMeGusta.querySelector(".bi");
    icono.classList.toggle("bi-heart-fill", leGusta);
    icono.classList.toggle("bi-heart", !leGusta);
}

function actualizarCantidadLikes(cantidadLikes) {
    const cantidad = document.getElementById("cantidadLikesPerfil");
    if (!cantidad) {
        return;
    }

    cantidad.textContent = cantidadLikes;
    // Se reinicia la animación de rebote
    cantidad.classList.remove("rebote");
    void cantidad.offsetWidth;
    cantidad.classList.add("rebote");
}

// El corazón "salta" y, al dar me gusta, suelta una explosión de corazoncitos con los colores de la marca
function animarMeGusta(botonMeGusta, leGusta) {
    const icono = botonMeGusta.querySelector(".bi");
    icono.classList.remove("saltoCorazon");
    void icono.offsetWidth;
    icono.classList.add("saltoCorazon");

    if (!leGusta || window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
        return;
    }

    const cantidadCorazones = 10;
    for (let numeroCorazon = 0; numeroCorazon < cantidadCorazones; numeroCorazon++) {
        const angulo = (numeroCorazon / cantidadCorazones) * 2 * Math.PI + Math.random() * 0.4;
        const distancia = 40 + Math.random() * 30;
        const corazon = crearElemento("i", "bi bi-heart-fill corazonVolador");
        corazon.setAttribute("aria-hidden", "true");
        corazon.style.setProperty("--destinoX", `${Math.cos(angulo) * distancia}px`);
        corazon.style.setProperty("--destinoY", `${Math.sin(angulo) * distancia}px`);
        corazon.style.color = coloresExplosionLike[numeroCorazon % coloresExplosionLike.length];
        corazon.style.fontSize = `${0.6 + Math.random() * 0.5}rem`;
        corazon.addEventListener("animationend", () => corazon.remove());
        botonMeGusta.append(corazon);
    }
}

// ----- Modal "Editar perfil" -----
function inicializarEdicionPerfil() {
    const dialogoEditarPerfil = document.getElementById("dialogoEditarPerfil");
    if (!dialogoEditarPerfil) {
        return;
    }

    document.querySelectorAll("[data-abrir-edicion]").forEach(boton => boton.addEventListener("click", cargarDatosEdicion));
    inicializarEditorDescripcion();
    inicializarFotosEdicion();
    inicializarTitulosEdicion();
}

// GET /Perfiles/ObtenerDatosEdicion → datos privados del usuario de la sesión
function pedirDatosEdicion() {
    return fetch("/Perfiles/ObtenerDatosEdicion", {
        method: "GET"
    })
    .then(respuesta => respuesta.json())
    .then(datos => {
        if (datos.mensaje) {
            throw new Error(datos.mensaje);
        }
        return datos;
    });
}

// GET /Perfiles/ObtenerOpcionesPerfil → materias, niveles, modalidades y colegios.
// Casi no cambian: se piden una sola vez.
function pedirOpcionesPerfil() {
    if (opcionesPerfilCargadas) {
        return Promise.resolve(opcionesPerfilCargadas);
    }

    return fetch("/Perfiles/ObtenerOpcionesPerfil", {
        method: "GET"
    })
    .then(respuesta => respuesta.json())
    .then(opciones => {
        if (opciones.mensaje) {
            throw new Error(opciones.mensaje);
        }
        opcionesPerfilCargadas = opciones;
        return opciones;
    });
}

function cargarDatosEdicion() {
    const estadoEdicion = document.getElementById("estadoEdicion");
    const contenidoEdicion = document.getElementById("contenidoEdicion");
    mostrarMensaje(document.getElementById("mensajeEditarPerfil"), "");

    Promise.all([pedirOpcionesPerfil(), pedirDatosEdicion()])
    .then(([opciones, datos]) => {
        completarFormularioEdicion(opciones, datos);
        estadoEdicion.hidden = true;
        contenidoEdicion.hidden = false;
    })
    .catch((error) => {
        console.error("Error:", error);
        estadoEdicion.hidden = false;
        contenidoEdicion.hidden = true;
        estadoEdicion.textContent = "No pudimos cargar tus datos. Cerrá el cuadro y probá de nuevo.";
    });
}

function completarFormularioEdicion(opciones, datos) {
    // Pestaña "Modificar perfil"
    if (editorDescripcion) {
        editorDescripcion.setContents([]);
        if (datos.descripcion) {
            editorDescripcion.clipboard.dangerouslyPasteHTML(datos.descripcion);
        }
        actualizarContadorDescripcion();
    }
    llenarSelectDeOpciones(document.getElementById("edicionEscuelas"), opciones.escuelas, datos.idsEscuelas);
    llenarSelectDeOpciones(document.getElementById("edicionNiveles"), opciones.niveles, datos.idsNiveles);
    llenarSelectDeOpciones(document.getElementById("edicionMaterias"), opciones.materias, datos.idsMaterias);
    llenarSelectDeOpciones(document.getElementById("edicionModalidades"), opciones.modalidades, datos.idsModalidades);

    // Precio y títulos solo están en el modal de los profesores
    const campoPrecioHora = document.getElementById("edicionPrecioHora");
    if (campoPrecioHora) {
        campoPrecioHora.value = datos.precioHora > 0 ? datos.precioHora : "";
    }
    const listaTitulos = document.getElementById("listaTitulos");
    if (listaTitulos) {
        listaTitulos.replaceChildren();
        datos.titulos.forEach(agregarTituloEdicion);
    }

    // Pestaña "Modificar cuenta"
    document.getElementById("edicionNombre").value = datos.nombre;
    document.getElementById("edicionApellido").value = datos.apellido;
    document.getElementById("edicionMail").value = datos.mail;
    document.getElementById("edicionFechaNacimiento").value = datos.fechaNacimiento ? datos.fechaNacimiento.slice(0, 10) : "";
    document.getElementById("edicionDni").value = datos.dni || "";
    document.getElementById("edicionDireccion").value = datos.direccion || "";
    document.getElementById("edicionFotoPerfil").value = "";
    document.getElementById("edicionFotoDni").value = "";
    pintarAvatar(document.getElementById("vistaPreviaFotoPerfil"), datos.nombre, datos.apellido, datos.fotoPerfil);

    const estadoFotoDni = document.getElementById("estadoFotoDni");
    estadoFotoDni.textContent = datos.tieneFotoDni
        ? "✓ Ya subiste la foto del DNI. Si elegís otra, se reemplaza."
        : "Todavía no subiste la foto del DNI.";
    estadoFotoDni.classList.toggle("cargada", datos.tieneFotoDni);

    mostrarProgresoVerificacion(datos.verificado, datos.faltantes);
}

// Llena un <select> del modal y lo convierte en selector con búsqueda.
// En los de una sola opción (alumno), "Sin elegir" permite dejarlo vacío.
function llenarSelectDeOpciones(select, opciones, idsElegidos) {
    if (!select) {
        return;
    }

    select.replaceChildren();
    if (!select.multiple) {
        select.append(new Option("Sin elegir", "", false, idsElegidos.length === 0));
    }
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
    listaFaltantes.replaceChildren(...faltantes.map(faltante => crearElemento("li", "", faltante)));
    progresoVerificacion.append(titulo, listaFaltantes);
}

// Editor de texto enriquecido (Quill 2): negrita, cursiva, subrayado, tachado, listas, cita y enlaces
function inicializarEditorDescripcion() {
    const contenedorEditor = document.getElementById("editorDescripcion");
    if (!contenedorEditor || !window.Quill) {
        return;
    }

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

function obtenerTextoDescripcion() {
    return editorDescripcion ? editorDescripcion.getText().trim() : "";
}

function actualizarContadorDescripcion() {
    const contadorDescripcion = document.getElementById("contadorDescripcion");
    const cantidadCaracteres = obtenerTextoDescripcion().length;
    contadorDescripcion.textContent = `${cantidadCaracteres} / ${largoMaximoDescripcion}`;
    contadorDescripcion.classList.toggle("excedido", cantidadCaracteres > largoMaximoDescripcion);
}

// Vista previa de la foto de perfil (se guarda recién al tocar "Guardar") y aviso de la foto del DNI
function inicializarFotosEdicion() {
    const campoFotoPerfil = document.getElementById("edicionFotoPerfil");
    const campoFotoDni = document.getElementById("edicionFotoDni");

    campoFotoPerfil.addEventListener("change", () => {
        const archivo = revisarFotoElegida(campoFotoPerfil, "La foto de perfil tiene que ser JPG, PNG o WEBP de hasta 5 MB.");
        if (!archivo) {
            return;
        }

        if (urlVistaPreviaFoto) {
            URL.revokeObjectURL(urlVistaPreviaFoto);
        }
        urlVistaPreviaFoto = URL.createObjectURL(archivo);
        pintarAvatar(document.getElementById("vistaPreviaFotoPerfil"), "", "", urlVistaPreviaFoto);
    });

    campoFotoDni.addEventListener("change", () => {
        const archivo = revisarFotoElegida(campoFotoDni, "La foto del DNI tiene que ser JPG, PNG o WEBP de hasta 5 MB.");
        if (!archivo) {
            return;
        }

        const estadoFotoDni = document.getElementById("estadoFotoDni");
        estadoFotoDni.textContent = `Nueva foto elegida: ${archivo.name}. Se sube al guardar.`;
        estadoFotoDni.classList.add("cargada");
    });
}

// Devuelve la foto elegida si es JPG, PNG o WEBP de hasta 5 MB. Si no, vacía el campo, avisa y devuelve null.
function revisarFotoElegida(campoFoto, textoError) {
    const archivo = campoFoto.files[0];
    if (!archivo) {
        return null;
    }

    const mensajeEditarPerfil = document.getElementById("mensajeEditarPerfil");
    if (!tiposDeFotoPermitidos.includes(archivo.type) || archivo.size > pesoMaximoFoto) {
        campoFoto.value = "";
        mostrarMensaje(mensajeEditarPerfil, textoError);
        return null;
    }

    mostrarMensaje(mensajeEditarPerfil, "");
    return archivo;
}

// Títulos del profesor: lista con "Agregar" y una ✕ para quitar cada uno (inputs name="titulos")
function inicializarTitulosEdicion() {
    const botonAgregarTitulo = document.getElementById("botonAgregarTitulo");
    if (!botonAgregarTitulo) {
        return;
    }

    const campoNuevoTitulo = document.getElementById("nuevoTitulo");
    const mensajeEditarPerfil = document.getElementById("mensajeEditarPerfil");

    const agregarDesdeElCampo = () => {
        // "|" es el separador de títulos en la base
        const titulo = campoNuevoTitulo.value.replaceAll("|", " ").replace(/\s+/g, " ").trim();
        if (titulo === "") {
            mostrarErrorEnCampo(mensajeEditarPerfil, campoNuevoTitulo, "Escribí el título antes de agregarlo.");
            return;
        }
        if (document.querySelectorAll("#listaTitulos li").length >= 10) {
            mostrarErrorEnCampo(mensajeEditarPerfil, campoNuevoTitulo, "Podés cargar hasta 10 títulos.");
            return;
        }

        mostrarMensaje(mensajeEditarPerfil, "");
        agregarTituloEdicion(titulo);
        campoNuevoTitulo.value = "";
        campoNuevoTitulo.focus();
    };

    botonAgregarTitulo.addEventListener("click", agregarDesdeElCampo);
    campoNuevoTitulo.addEventListener("keydown", evento => {
        if (evento.key !== "Enter") {
            return;
        }
        evento.preventDefault();
        agregarDesdeElCampo();
    });
}

function agregarTituloEdicion(titulo) {
    const campoTitulo = document.createElement("input");
    campoTitulo.type = "hidden";
    campoTitulo.name = "titulos";
    campoTitulo.value = titulo;

    const itemTitulo = document.createElement("li");
    const botonQuitar = crearElemento("button", "btn-close");
    botonQuitar.type = "button";
    botonQuitar.setAttribute("aria-label", `Quitar ${titulo}`);
    botonQuitar.addEventListener("click", () => itemTitulo.remove());

    itemTitulo.append(crearElemento("span", "", titulo), campoTitulo, botonQuitar);
    document.getElementById("listaTitulos").append(itemTitulo);
}

// Error de validación del modal: muestra la pestaña donde está el campo y le pone el foco.
// Devuelve false para cortar el onsubmit.
function mostrarErrorDeEdicion(campo, texto) {
    const pestana = campo?.closest(".tab-pane");
    if (pestana && !pestana.classList.contains("active")) {
        document.querySelector(`[data-bs-target="#${pestana.id}"]`)?.click();
    }

    // Se espera a que la pestaña se vea para poder poner el foco
    setTimeout(() => {
        mostrarErrorEnCampo(document.getElementById("mensajeEditarPerfil"), campo, texto);
    }, 50);
    return false;
}

// POST /Perfiles/GuardarPerfil (action del formulario) → guarda las dos pestañas juntas.
// El token anti-falsificación viaja dentro del FormData (campo oculto del formulario).
function guardarPerfil() {
    const formularioEditarPerfil = document.getElementById("formularioEditarPerfil");
    const mensajeEditarPerfil = document.getElementById("mensajeEditarPerfil");
    const botonGuardarPerfil = document.getElementById("botonGuardarPerfil");
    const campoNombre = document.getElementById("edicionNombre");
    const campoApellido = document.getElementById("edicionApellido");
    const campoMail = document.getElementById("edicionMail");
    const campoDni = document.getElementById("edicionDni");
    const campoFechaNacimiento = document.getElementById("edicionFechaNacimiento");
    const campoPrecioHora = document.getElementById("edicionPrecioHora");
    const dniSinPuntos = campoDni.value.replace(/[\s.\-]/g, "");
    const precioHora = campoPrecioHora ? campoPrecioHora.value : "";

    if (campoNombre.value.trim() === "") {
        return mostrarErrorDeEdicion(campoNombre, "Ingresá tu nombre.");
    }
    if (campoApellido.value.trim() === "") {
        return mostrarErrorDeEdicion(campoApellido, "Ingresá tu apellido.");
    }
    if (!correoValido(campoMail.value.trim())) {
        return mostrarErrorDeEdicion(campoMail, "Ingresá un correo electrónico válido.");
    }
    if (dniSinPuntos !== "" && !/^\d{7,8}$/.test(dniSinPuntos)) {
        return mostrarErrorDeEdicion(campoDni, "El DNI tiene que tener 7 u 8 números.");
    }
    if (campoFechaNacimiento.value !== "" && !fechaNacimientoValida(campoFechaNacimiento.value)) {
        return mostrarErrorDeEdicion(campoFechaNacimiento, "Ingresá una fecha de nacimiento válida.");
    }
    if (obtenerTextoDescripcion().length > largoMaximoDescripcion) {
        return mostrarErrorDeEdicion(document.getElementById("editorDescripcion"), "La descripción puede tener hasta 1000 caracteres.");
    }
    if (precioHora !== "" && !(Number.isInteger(Number(precioHora)) && Number(precioHora) >= 0)) {
        return mostrarErrorDeEdicion(campoPrecioHora, "Ingresá un precio por hora válido (solo números).");
    }

    // HTML del editor (vacío si no se escribió nada). getSemanticHTML() de Quill convierte cada
    // espacio en &nbsp; (y así el texto no se corta en renglones): se vuelven espacios comunes.
    document.getElementById("edicionDescripcion").value = obtenerTextoDescripcion() === ""
        ? ""
        : editorDescripcion.getSemanticHTML().replace(/&nbsp;/g, " ");

    // Los selectores van como listas de IDs separadas por coma (idsMaterias=3,7,12)
    const datosFormulario = new FormData(formularioEditarPerfil);
    formularioEditarPerfil.querySelectorAll("select[data-nombre-ids]").forEach(select => {
        const idsElegidos = Array.from(select.selectedOptions).map(opcion => opcion.value).filter(valor => valor !== "");
        datosFormulario.append(select.dataset.nombreIds, idsElegidos.join(","));
    });

    mostrarMensaje(mensajeEditarPerfil, "");
    botonGuardarPerfil.disabled = true;

    fetch(formularioEditarPerfil.action, {
        method: "POST",
        body: datosFormulario
    })
    .then(respuesta => respuesta.json())
    .then(guardado => {
        if (guardado.resultado === "mailExistente") {
            mostrarErrorDeEdicion(campoMail, guardado.mensaje);
            return;
        }
        if (guardado.resultado === "dniExistente") {
            mostrarErrorDeEdicion(campoDni, guardado.mensaje);
            return;
        }
        if (guardado.resultado !== "ok") {
            mostrarMensaje(mensajeEditarPerfil, guardado.mensaje);
            return;
        }

        formularioEditarPerfil.querySelector("[data-bs-dismiss='dialog']").click();
        mostrarSnackbar(guardado.mensaje, "exito");
        actualizarUsuarioEnEncabezado(guardado);
        mostrarAvisoVerificacionPerfil(guardado.verificado, guardado.faltantes);
        cargarPerfil();
    })
    .catch((error) => {
        console.error("Error:", error);
        mostrarMensaje(mensajeEditarPerfil, "No pudimos guardar los cambios. Revisá tu conexión e intentá de nuevo.");
    })
    .finally(() => {
        botonGuardarPerfil.disabled = false;
    });

    return false;
}

// El header se arma con la sesión al cargar la página: se actualiza a mano para no recargar
function actualizarUsuarioEnEncabezado(usuario) {
    document.querySelectorAll("#encabezado .usuario").forEach(enlaceUsuario => {
        enlaceUsuario.querySelector(".nombreUsuario").textContent = `${usuario.nombre} ${usuario.apellido}`;

        const avatar = enlaceUsuario.querySelector(".avatar");
        pintarAvatar(avatar, usuario.nombre, usuario.apellido, usuario.fotoPerfil);
        avatar.classList.toggle("theme-primary", !usuario.fotoPerfil);

        const tick = enlaceUsuario.querySelector(".tickVerificado");
        if (usuario.verificado && !tick) {
            enlaceUsuario.append(crearTickVerificado());
        }
        if (!usuario.verificado && tick) {
            tick.remove();
        }
    });
}


// ================= INICIALIZACIÓN =================
function inicializarSitio() {
    inicializarEncabezadoConScroll();
    inicializarAvisoVerificacion();
    inicializarSelectoresBuscables();
    inicializarRevelarAlScroll();
    inicializarCarruseles();
    inicializarRolesDeRegistro();
    inicializarVerContrasena();
    inicializarBuscador();
    inicializarBuscadorDeAyuda();
    inicializarAccesosDelPanel();
    inicializarPerfil();
}

document.addEventListener("DOMContentLoaded", inicializarSitio);
