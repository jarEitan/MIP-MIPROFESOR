using Microsoft.AspNetCore.Mvc;
using MIP_MIPROFESOR.Models;

namespace MIP_MIPROFESOR.Controllers;

// Notificaciones del usuario. site.js lo llama con fetch para mantener al día la insignia del botón
// Panel de Control (la lista se arma en HomeController.PanelControl).
public class NotificacionesController : Controller
{
    // GET /Notificaciones/Contar → { cantidad }: pedidos por responder + novedades que todavía no vio
    [HttpGet]
    public IActionResult Contar()
    {
        string? idUsuarioSesion = HttpContext.Session.GetString("idUsuario");

        if (!int.TryParse(idUsuarioSesion, out int idUsuario))
        {
            return StatusCode(401, new { cantidad = 0 });
        }

        BD bd = new BD();
        try
        {
            int cantidad = bd.contarNotificaciones(idUsuario);
            HttpContext.Session.SetString("cantidadNotificaciones", cantidad.ToString());
            return Json(new { cantidad = cantidad });
        }
        catch (Exception)
        {
            return StatusCode(500, new { mensaje = "No pudimos cargar las notificaciones." });
        }
    }
}
