// =====================================================================
// MiProfesor (MIP) - JavaScript global
// Cada módulo es una función independiente que se inicializa al final.
// Para agregar funciones nuevas: crear la función y sumarla a inicializarSitio().
// =====================================================================


// ================= HEADER: sombra al hacer scroll =================
function inicializarEncabezadoConScroll() {
    const encabezadoPrincipal = document.getElementById("encabezadoPrincipal");
    if (!encabezadoPrincipal) return;

    const actualizarSombraEncabezado = () => {
        encabezadoPrincipal.classList.toggle("encabezadoConSombra", window.scrollY > 8);
    };

    actualizarSombraEncabezado();
    window.addEventListener("scroll", actualizarSombraEncabezado, { passive: true });
}


// ================= HEADER: cerrar menú móvil al tocar un enlace ancla =================
function inicializarCierreMenuMovil() {
    document.querySelectorAll(".menuNavegacion a[href*='#']").forEach(enlaceAncla => {
        enlaceAncla.addEventListener("click", () => {
            const menuAbierto = enlaceAncla.closest(".offcanvas.show");
            if (menuAbierto) bootstrap.Offcanvas.getInstance(menuAbierto)?.hide();
        });
    });
}


// ================= ANIMACIONES: revelar elementos al entrar en pantalla =================
function inicializarRevelarAlScroll() {
    const elementosParaRevelar = document.querySelectorAll(".revelarAlScroll");
    if (elementosParaRevelar.length === 0) return;

    if (!("IntersectionObserver" in window)) {
        elementosParaRevelar.forEach(elemento => elemento.classList.add("estaVisible"));
        return;
    }

    const observadorDeVisibilidad = new IntersectionObserver((entradas, observador) => {
        entradas.forEach(entrada => {
            if (!entrada.isIntersecting) return;
            entrada.target.classList.add("estaVisible");
            observador.unobserve(entrada.target);
        });
    }, { threshold: 0.15, rootMargin: "0px 0px -40px 0px" });

    elementosParaRevelar.forEach(elemento => observadorDeVisibilidad.observe(elemento));
}


// ================= LANDING: validación del buscador =================
// Se llama desde onsubmit del formulario. El envío va a Home/Catalogo?busqueda=...
function validarBusqueda() {
    const campoBusqueda = document.getElementById("campoBusqueda");
    const mensajeErrorBusqueda = document.getElementById("mensajeErrorBusqueda");
    const textoBuscado = campoBusqueda.value.trim();

    if (textoBuscado === "") {
        mensajeErrorBusqueda.innerHTML = "Escribí una materia, un profesor o un colegio para buscar.";
        mensajeErrorBusqueda.style.display = "block";
        campoBusqueda.focus();
        return false;
    }
    if (textoBuscado.length < 2) {
        mensajeErrorBusqueda.innerHTML = "La búsqueda debe tener al menos 2 caracteres.";
        mensajeErrorBusqueda.style.display = "block";
        campoBusqueda.focus();
        return false;
    }

    mensajeErrorBusqueda.style.display = "none";
    return true;
}

function inicializarBuscador() {
    const campoBusqueda = document.getElementById("campoBusqueda");
    const mensajeErrorBusqueda = document.getElementById("mensajeErrorBusqueda");
    if (!campoBusqueda || !mensajeErrorBusqueda) return;

    // Oculta el error apenas el usuario vuelve a escribir
    campoBusqueda.addEventListener("input", () => {
        mensajeErrorBusqueda.style.display = "none";
    });

    // TODO BD: sugerencias en vivo cuando exista el endpoint (ej: Home/SugerirMaterias?texto=...)
    // fetch('/Home/SugerirMaterias?texto=' + encodeURIComponent(campoBusqueda.value))
    //     .then(r => r.json())
    //     .then(d => { /* Actualizar DOM con la lista de sugerencias */ })
    //     .catch(e => console.error(e));
}


// ================= INICIALIZACIÓN =================
function inicializarSitio() {
    inicializarEncabezadoConScroll();
    inicializarCierreMenuMovil();
    inicializarRevelarAlScroll();
    inicializarBuscador();
}

document.addEventListener("DOMContentLoaded", inicializarSitio);
