using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using MIP_MIPROFESOR.Models;

namespace MIP_MIPROFESOR.Controllers;

public class HomeController : Controller
{
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
        BD bd = new BD();
        try
        {
            ViewBag.profesoresDestacados = bd.obtenerCatalogo(null, null, null, null, null, 1, 5).profesores.Take(3).ToList();
        }
        catch (Exception)
        {
            ViewBag.profesoresDestacados = new List<Profesor>();
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

    public IActionResult Privacy()
    {
        return View();
    }

    // /Home/Perfil/5 → perfil de cualquier usuario (se puede compartir la URL). Sin ID → el perfil propio.
    // /Home/Perfil?editar=true → el perfil propio con el modal "Editar perfil" abierto (botón "Completar mis datos").
    // Los datos los trae site.js con fetch a PerfilesController.
    public IActionResult Perfil(int? id, bool editar = false)
    {
        string? idUsuarioSesion = HttpContext.Session.GetString("idUsuario");

        if (id == null && idUsuarioSesion == null)
        {
            return RedirectToAction("IniciarSesion", "Sesion");
        }

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
        string? idUsuarioSesion = HttpContext.Session.GetString("idUsuario");

        if (!int.TryParse(idUsuarioSesion, out int idUsuario))
        {
            return RedirectToAction("IniciarSesion", "Sesion");
        }

        // Las notificaciones se leen ANTES de marcarlas como vistas: al entrar al Panel las novedades se ven como nuevas
        // y recién después pasan a vistas (los pedidos por responder siguen en la insignia hasta que se resuelven).
        BD bd = new BD();
        try
        {
            ViewBag.misClases = bd.obtenerMisClases(idUsuario);
            ViewBag.notificaciones = bd.obtenerNotificaciones(idUsuario);
            int cantidadNotificaciones = bd.marcarNotificacionesVistas(idUsuario);
            HttpContext.Session.SetString("cantidadNotificaciones", cantidadNotificaciones.ToString());
        }
        catch (Exception)
        {
            ViewBag.errorBD = true;
        }

        return View();
    }

    // Lleva al catálogo filtrado por el colegio del usuario
    public IActionResult MiColegio()
    {
        string? idUsuario = HttpContext.Session.GetString("idUsuario");

        if (idUsuario == null)
        {
            return RedirectToAction("IniciarSesion", "Sesion");
        }

        BD bd = new BD();
        try
        {
            DatosEdicion? datos = bd.obtenerDatosEdicion(int.Parse(idUsuario));

            if (datos != null && datos.idsEscuelas.Count > 0)
            {
                OpcionPerfil? colegio = bd.obtenerOpcionesPerfil().escuelas.FirstOrDefault(escuela => datos.idsEscuelas.Contains(escuela.id));

                if (colegio != null)
                {
                    return RedirectToAction("Index", "Catalogo", new { colegio = colegio.nombre });
                }
            }
        }
        catch (Exception)
        {
            // Si la base no responde se muestra el catálogo completo
        }

        // Todavía no cargó su colegio: catálogo completo
        return RedirectToAction("Index", "Catalogo");
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
