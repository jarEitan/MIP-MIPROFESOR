using Microsoft.AspNetCore.Mvc;
using MIP_MIPROFESOR.Models;

namespace MIP_MIPROFESOR.Controllers;

// Historial de clases (Panel de Control y modal "Historial" de los perfiles). Se llama con fetch y devuelve JSON.
// Quien mira sale SIEMPRE de la sesión, nunca del pedido: el SP decide qué clases puede ver.
public class HistorialController : Controller
{
    // GET /Historial/Obtener/5 → las últimas 20 clases del usuario 5 (no hace falta sesión).
    // Mirando el propio ID se ve todo el historial; mirando el de otro, solo las clases completadas.
    // No se guarda en caché: la respuesta cambia según quién mira.
    [HttpGet]
    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Obtener(int id)
    {
        string? idUsuarioSesion = HttpContext.Session.GetString("idUsuario");
        int? idVisitante = int.TryParse(idUsuarioSesion, out int idUsuario) ? idUsuario : null;

        BD bd = new BD();
        try
        {
            return Json(bd.obtenerHistorialClases(id, idVisitante));
        }
        catch (Exception)
        {
            return StatusCode(500, new { mensaje = "No pudimos cargar el historial. Probá de nuevo en unos minutos." });
        }
    }
}
