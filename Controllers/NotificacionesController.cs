using Microsoft.AspNetCore.Mvc;
using MIP_MIPROFESOR.Models;

namespace MIP_MIPROFESOR.Controllers;

// Notificaciones del usuario. Se llama con fetch desde site.js para mantener al día la insignia del
// botón Panel de Control (la lista se arma en HomeController.PanelControl).
public class NotificacionesController : Controller
{
    // GET /Notificaciones/Contar → { cantidad }: solicitudes de amistad, chats con mensajes sin leer y clases que esperan respuesta
    [HttpGet]
    public IActionResult Contar()
    {
        string? idUsuario = HttpContext.Session.GetString("idUsuario");
        if (!int.TryParse(idUsuario, out int id)) return StatusCode(401, new { cantidad = 0 });

        try
        {
            int cantidad = new BD().contarNotificaciones(id);
            HttpContext.Session.SetString("cantidadNotificaciones", cantidad.ToString());
            return Json(new { cantidad = cantidad });
        }
        catch (Exception)
        {
            return StatusCode(500, new { mensaje = "No pudimos cargar las notificaciones." });
        }
    }
}
