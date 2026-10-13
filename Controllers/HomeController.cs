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
        // TODO BD: reemplazar la lista de materias por BD.obtenerMateriasDestacadas().
        ViewBag.materiasDestacadas = new List<string>
        {
            "Matemática", "Física", "Química", "Biología", "Inglés", "Historia",
            "Lengua y Literatura", "Programación", "Economía", "Geografía"
        };
        // Los 3 primeros del catálogo: cuentas verificadas y mejor calificadas. Si la base no responde, la página igual carga.
        try
        {
            ViewBag.profesoresDestacados = new BD().obtenerCatalogo(null, null, null, null, null).Take(3).ToList();
        }
        catch (Exception)
        {
            ViewBag.profesoresDestacados = new List<Profesor>();
        }
        return View();
    }

    // Los filtros llegan por la URL (Home/Catalogo?materia=...&nivel=Primaria&nivel=Secundaria), así se pueden compartir.
    public IActionResult Catalogo(string? busqueda, string? materia, string? colegio, string? modalidad, string[]? nivel)
    {
        string[] nivelesElegidos = nivel ?? new string[0];
        ViewBag.busqueda = busqueda ?? "";
        ViewBag.materia = materia ?? "";
        ViewBag.colegio = colegio ?? "";
        ViewBag.modalidad = modalidad ?? "";
        ViewBag.nivelesElegidos = nivelesElegidos.ToList();

        try
        {
            BD bd = new BD();
            OpcionesPerfil opciones = bd.obtenerOpcionesPerfil();
            ViewBag.materias = opciones.materias.Select(opcion => opcion.nombre).ToList();
            ViewBag.colegios = opciones.escuelas.Select(opcion => opcion.nombre).ToList();
            ViewBag.niveles = opciones.niveles.Select(opcion => opcion.nombre).ToList();
            ViewBag.modalidades = opciones.modalidades.Select(opcion => opcion.nombre).ToList();
            ViewBag.profesores = bd.obtenerCatalogo(busqueda, materia, colegio, modalidad, string.Join(",", nivelesElegidos));
        }
        catch (Exception)
        {
            ViewBag.errorCatalogo = "No pudimos cargar el catálogo. Probá de nuevo en un rato.";
        }
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

    // /Home/Perfil/5 → perfil de cualquier usuario (se puede compartir la URL).
    // /Home/Perfil sin ID → el perfil propio. Los datos los trae site.js con fetch a PerfilesController.
    // /Home/Perfil?editar=true → el perfil propio con el modal "Editar perfil" ya abierto
    // (lo usa el botón "Completar mis datos" del aviso de cuenta no verificada).
    public IActionResult Perfil(int? id, bool editar = false)
    {
        string? idUsuarioSesion = HttpContext.Session.GetString("idUsuario");
        if (id == null && idUsuarioSesion == null) return RedirectToAction("IniciarSesion", "Sesion");

        int idPerfil = id ?? int.Parse(idUsuarioSesion!);
        bool esPerfilPropio = idUsuarioSesion == idPerfil.ToString();
        ViewBag.idPerfil = idPerfil;
        ViewBag.esPerfilPropio = esPerfilPropio;
        ViewBag.abrirEdicion = esPerfilPropio && editar;
        // En el perfil propio el aviso de verificación está dentro de la página, con más detalle
        ViewBag.ocultarAvisoVerificacion = esPerfilPropio;
        return View();
    }

    // ================= ÁREA CON SESIÓN =================

    public IActionResult PanelControl()
    {
        if (HttpContext.Session.GetString("idUsuario") == null) return RedirectToAction("IniciarSesion", "Sesion");

        // TODO BD: reemplazar por BD.obtenerClasesDelUsuario(idUsuario).
        ViewBag.clasesProgramadas = obtenerClasesProgramadasDemo();
        ViewBag.clasesHistorial = obtenerHistorialDemo();
        return View();
    }

    public IActionResult MiColegio()
    {
        string? idUsuario = HttpContext.Session.GetString("idUsuario");
        if (idUsuario == null) return RedirectToAction("IniciarSesion", "Sesion");

        // Si el usuario todavía no cargó su colegio, se muestra el catálogo completo
        try
        {
            BD bd = new BD();
            DatosEdicion? datos = bd.obtenerDatosEdicion(int.Parse(idUsuario));
            OpcionPerfil? colegio = datos == null ? null : bd.obtenerOpcionesPerfil().escuelas.FirstOrDefault(escuela => datos.idsEscuelas.Contains(escuela.id));
            if (colegio != null) return RedirectToAction("Catalogo", new { colegio = colegio.nombre });
        }
        catch (Exception)
        {
        }
        return RedirectToAction("Catalogo");
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

    // ================= DATOS DE EJEMPLO (TODO BD: borrar cuando exista el sistema de clases) =================

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
