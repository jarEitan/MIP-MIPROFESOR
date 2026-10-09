using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using MIP_MIPROFESOR.Models;

namespace MIP_MIPROFESOR.Controllers;

public class HomeController : Controller
{
    private readonly ILogger<HomeController> _logger;

    public HomeController(ILogger<HomeController> logger)
    {
        _logger = logger;
    }

    // ================= PÁGINAS PÚBLICAS =================

    public IActionResult Index()
    {
        // TODO BD: reemplazar por BD.obtenerMateriasDestacadas() y BD.obtenerProfesoresDestacados() cuando esté la base de datos.
        ViewBag.materiasDestacadas = new List<string>
        {
            "Matemática", "Física", "Química", "Biología", "Inglés", "Historia",
            "Lengua y Literatura", "Programación", "Economía", "Geografía"
        };
        ViewBag.profesoresDestacados = obtenerProfesoresDemo().Take(3).ToList();
        return View();
    }

    public IActionResult Catalogo(string? busqueda, string? colegio)
    {
        // TODO BD: reemplazar por BD.obtenerProfesores(busqueda, colegio). Hoy el filtrado se hace en el navegador (site.js).
        ViewBag.profesores = obtenerProfesoresDemo();
        ViewBag.busqueda = busqueda ?? "";
        ViewBag.colegio = colegio ?? "";
        ViewBag.materias = new List<string> { "Matemática", "Física", "Química", "Biología", "Inglés", "Historia", "Lengua y Literatura", "Programación" };
        ViewBag.colegios = new List<string> { "Belgrano Day School", "Colegio San Martín", "Nacional Buenos Aires" };
        return View();
    }

    public IActionResult Soporte()
    {
        return View();
    }

    public IActionResult QuienesSomos()
    {
        return View();
    }

    public IActionResult Registrarse(string? rol)
    {
        // TODO BD: al enviar el formulario, crear la cuenta con BD.crearCuenta(...) y guardar las claves de sesión.
        ViewBag.rol = rol == "profesor" ? "profesor" : "alumno";
        ViewBag.colegios = new List<string> { "Belgrano Day School", "Colegio San Martín", "Nacional Buenos Aires" };
        return View();
    }

    public IActionResult IniciarSesion()
    {
        // TODO BD: al enviar el formulario, validar con BD.iniciarSesion(...) y guardar las claves de sesión.
        return View();
    }

    // ================= ÁREA CON SESIÓN =================

    public IActionResult PanelControl()
    {
        // TODO BD: sin sesión → redirigir a IniciarSesion. Mientras no exista el login se simula un alumno de ejemplo
        // para poder ver el header con sesión y el panel.
        if (HttpContext.Session.GetString("idUsuario") == null)
        {
            HttpContext.Session.SetString("idUsuario", "1");
            HttpContext.Session.SetString("nombreUsuario", "Mateo Gómez");
            HttpContext.Session.SetString("inicialesUsuario", "MG");
            HttpContext.Session.SetString("cantidadNotificaciones", "1");
        }

        // TODO BD: reemplazar por BD.obtenerClasesDelUsuario(idUsuario).
        ViewBag.clasesProgramadas = obtenerClasesProgramadasDemo();
        ViewBag.clasesHistorial = obtenerHistorialDemo();
        return View();
    }

    public IActionResult MiColegio()
    {
        // TODO BD: tomar el colegio del usuario desde la sesión.
        return RedirectToAction("Catalogo", new { colegio = "Belgrano Day School" });
    }

    public IActionResult CerrarSesion()
    {
        HttpContext.Session.Clear();
        return RedirectToAction("Index");
    }

    public IActionResult Privacy()
    {
        return View();
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }

    // ================= DATOS DE EJEMPLO (TODO BD: borrar cuando exista BD.cs) =================

    private List<Profesor> obtenerProfesoresDemo()
    {
        return new List<Profesor>
        {
            new Profesor { id = 1, nombre = "Sofía Martínez", iniciales = "SM", materia = "Matemática", colegio = "Belgrano Day School", modalidad = "Presencial", nivel = "Secundaria",
                resumen = "6 años preparando exámenes de ingreso y finales. Explico paso a paso, sin apuro.", calificacion = 4.9m, cantidadResenas = 32, precioHora = 8000, verificado = true,
                temas = new List<string> { "Álgebra", "Estadística" } },
            new Profesor { id = 2, nombre = "Lucas Gómez", iniciales = "LG", materia = "Física", colegio = "Colegio San Martín", modalidad = "Virtual", nivel = "Secundaria",
                resumen = "Ingeniero y docente. Problemas resueltos en vivo y apuntes alineados al programa del colegio.", calificacion = 4.8m, cantidadResenas = 21, precioHora = 7500, verificado = true,
                temas = new List<string> { "Dinámica", "Cinemática" } },
            new Profesor { id = 3, nombre = "Camila Rossi", iniciales = "CR", materia = "Inglés", colegio = "Nacional Buenos Aires", modalidad = "Ambas", nivel = "Secundaria",
                resumen = "Conversación, gramática y preparación de exámenes internacionales en un solo lugar.", calificacion = 4.7m, cantidadResenas = 18, precioHora = 6500, verificado = false,
                temas = new List<string> { "Speaking", "First Certificate" } },
            new Profesor { id = 4, nombre = "Joaquín Fernández", iniciales = "JF", materia = "Química", colegio = "Belgrano Day School", modalidad = "Presencial", nivel = "Secundaria",
                resumen = "Laboratorio y teoría sin miedo: estequiometría, soluciones y química orgánica.", calificacion = 4.6m, cantidadResenas = 12, precioHora = 7000, verificado = false,
                temas = new List<string> { "Estequiometría", "Orgánica" } },
            new Profesor { id = 5, nombre = "Valentina Paz", iniciales = "VP", materia = "Biología", colegio = "Colegio San Martín", modalidad = "Ambas", nivel = "Secundaria",
                resumen = "Esquemas, mapas conceptuales y mucha práctica para llegar tranquilo al examen.", calificacion = 5.0m, cantidadResenas = 9, precioHora = 6800, verificado = true,
                temas = new List<string> { "Genética", "Ecología" } },
            new Profesor { id = 6, nombre = "Martín Acosta", iniciales = "MA", materia = "Programación", colegio = "Nacional Buenos Aires", modalidad = "Virtual", nivel = "Universitario",
                resumen = "Desarrollador back-end. De tu primer algoritmo a tu proyecto final de la facultad.", calificacion = 4.9m, cantidadResenas = 27, precioHora = 9000, verificado = true,
                temas = new List<string> { "C#", "Algoritmos" } },
            new Profesor { id = 7, nombre = "Lucía Benítez", iniciales = "LB", materia = "Lengua y Literatura", colegio = "Belgrano Day School", modalidad = "Virtual", nivel = "Primaria",
                resumen = "Comprensión lectora y escritura con juegos, lecturas cortas y mucha paciencia.", calificacion = 4.8m, cantidadResenas = 15, precioHora = 5500, verificado = false,
                temas = new List<string> { "Lectura", "Ortografía" } },
            new Profesor { id = 8, nombre = "Tomás Herrera", iniciales = "TH", materia = "Historia", colegio = "Colegio San Martín", modalidad = "Presencial", nivel = "Secundaria",
                resumen = "Líneas de tiempo y resúmenes claros para entender los procesos, no solo memorizar fechas.", calificacion = 4.5m, cantidadResenas = 8, precioHora = 5800, verificado = false,
                temas = new List<string> { "Argentina", "Historia Mundial" } }
        };
    }

    private List<Clase> obtenerClasesProgramadasDemo()
    {
        return new List<Clase>
        {
            new Clase { id = 1, materia = "Matemática Discreta", profesor = "Sofía Martínez", colegio = "Belgrano Day School", fecha = "Mañana, 16:00 hs", lugar = "Presencial (Biblioteca)", modalidad = "Presencial", estado = "Confirmada", icono = "bi-calculator" },
            new Clase { id = 2, materia = "Física II", profesor = "Lucas Gómez", colegio = "Colegio San Martín", fecha = "Jueves, 18:00 hs", lugar = "Virtual (Google Meet)", modalidad = "Virtual", estado = "Pendiente", icono = "bi-lightning-charge" }
        };
    }

    private List<Clase> obtenerHistorialDemo()
    {
        return new List<Clase>
        {
            new Clase { id = 10, materia = "Matemática Discreta", profesor = "Sofía Martínez", fecha = "02/10/2026", estado = "Completada" },
            new Clase { id = 11, materia = "Física I", profesor = "Lucas Gómez", fecha = "28/09/2026", estado = "Completada" },
            new Clase { id = 12, materia = "Inglés", profesor = "Camila Rossi", fecha = "21/09/2026", estado = "Cancelada" },
            new Clase { id = 13, materia = "Química", profesor = "Joaquín Fernández", fecha = "15/09/2026", estado = "Completada" },
            new Clase { id = 14, materia = "Biología", profesor = "Valentina Paz", fecha = "09/09/2026", estado = "Completada" }
        };
    }
}
