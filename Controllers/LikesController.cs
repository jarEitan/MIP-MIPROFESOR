using Microsoft.AspNetCore.Mvc;
using MIP_MIPROFESOR.Models;

namespace MIP_MIPROFESOR.Controllers;

// Me gusta de los perfiles. site.js lo llama con fetch y recibe JSON.
public class LikesController : Controller
{
    // GET /Likes/ObtenerLike/5 → si el usuario de la sesión le dio me gusta al perfil 5 (sin sesión: false) y cuántos tiene
    [HttpGet]
    public IActionResult ObtenerLike(int id)
    {
        int? idEmisor = obtenerIdUsuarioSesion();

        BD bd = new BD();
        try
        {
            ResultadoLike resultado = bd.obtenerLike(idEmisor, id);
            return Json(new { leGusta = resultado.leGusta, cantidadLikes = resultado.cantidadLikes });
        }
        catch (Exception)
        {
            return StatusCode(500, new { mensaje = "No pudimos cargar los me gusta. Probá de nuevo en unos minutos." });
        }
    }

    // POST /Likes/AlternarLike → da o saca el me gusta. El emisor sale SIEMPRE de la sesión, nunca del pedido.
    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult AlternarLike(int idReceptor)
    {
        int? idEmisor = obtenerIdUsuarioSesion();

        if (idEmisor == null)
        {
            return StatusCode(401, new { resultado = "sinSesion", mensaje = "Iniciá sesión para dar me gusta." });
        }

        BD bd = new BD();
        try
        {
            ResultadoLike resultado = bd.alternarLike(idEmisor.Value, idReceptor);

            if (resultado.resultado == "mismoUsuario")
            {
                return StatusCode(400, new { resultado = resultado.resultado, mensaje = "No podés darte me gusta a vos mismo." });
            }

            if (resultado.resultado == "usuarioInexistente")
            {
                return StatusCode(404, new { resultado = resultado.resultado, mensaje = "Este perfil ya no existe." });
            }

            return Json(new { resultado = resultado.resultado, leGusta = resultado.leGusta, cantidadLikes = resultado.cantidadLikes });
        }
        catch (Exception)
        {
            return StatusCode(500, new { resultado = "errorBD", mensaje = "No pudimos guardar tu me gusta. Probá de nuevo en unos minutos." });
        }
    }

    // El ID del usuario de la sesión, o null si no hay sesión
    private int? obtenerIdUsuarioSesion()
    {
        string? idUsuario = HttpContext.Session.GetString("idUsuario");
        return int.TryParse(idUsuario, out int id) ? id : null;
    }
}
