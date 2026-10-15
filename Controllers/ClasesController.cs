using System.Globalization;
using Microsoft.AspNetCore.Mvc;
using MIP_MIPROFESOR.Models;

namespace MIP_MIPROFESOR.Controllers;

// Pedidos de clase entre alumno y profesor. Se llaman con fetch desde clases.js y devuelven JSON.
// El usuario sale SIEMPRE de la sesión, nunca del pedido. Reglas: Info/log.md, entrada 2026-10-14
public class ClasesController : Controller
{
    private const string formatoFecha = "yyyy-MM-ddTHH:mm";

    // GET /Clases/HorariosOcupados?idOtroUsuario=5&dia=2026-10-19&idClaseExcluir=3
    // Franjas ocupadas de ese día para bloquearlas en el selector. idOtroUsuario es el profesor (si pide
    // un alumno) o el alumno (si reubica un profesor). idClaseExcluir: la clase que se está moviendo.
    [HttpGet]
    public IActionResult HorariosOcupados(int idOtroUsuario, string dia, int? idClaseExcluir)
    {
        int? idUsuario = obtenerIdUsuarioSesion();
        string tipoUsuario = HttpContext.Session.GetString("tipoUsuario") ?? "";

        if (idUsuario == null)
        {
            return StatusCode(401, new { resultado = "sinSesion", mensaje = "Iniciá sesión para pedir clases." });
        }

        if (tipoUsuario != "alumno" && tipoUsuario != "profesor")
        {
            return StatusCode(403, new { resultado = "sinPermiso", mensaje = "Tu cuenta no puede pedir clases." });
        }

        if (!DateTime.TryParseExact(dia, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out DateTime desde))
        {
            return StatusCode(400, new { resultado = "fechaInvalida", mensaje = "Elegí un día válido." });
        }

        int idProfesor = tipoUsuario == "profesor" ? idUsuario.Value : idOtroUsuario;
        int idAlumno = tipoUsuario == "alumno" ? idUsuario.Value : idOtroUsuario;
        BD bd = new BD();
        List<HorarioOcupado> ocupados;

        try
        {
            ocupados = bd.obtenerHorariosOcupados(idProfesor, idAlumno, desde, desde.AddDays(1), idClaseExcluir);
        }
        catch (Exception)
        {
            return StatusCode(500, new { resultado = "errorBD", mensaje = "No pudimos cargar los horarios. Probá de nuevo en unos minutos." });
        }

        return Json(new
        {
            ocupados = ocupados.Select(horario => new
            {
                inicio = horario.inicio.ToString(formatoFecha, CultureInfo.InvariantCulture),
                fin = horario.fin.ToString(formatoFecha, CultureInfo.InvariantCulture),
                de = horario.de
            })
        });
    }

    // POST /Clases/EnviarPedido → el alumno de la sesión le pide una clase al profesor
    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult EnviarPedido(int idProfesor, string fecha)
    {
        int? idAlumno = obtenerIdUsuarioSesion();

        if (idAlumno == null)
        {
            return StatusCode(401, new { resultado = "sinSesion", mensaje = "Iniciá sesión para pedir una clase." });
        }

        if (HttpContext.Session.GetString("tipoUsuario") != "alumno")
        {
            return StatusCode(403, new { resultado = "sinPermiso", mensaje = "Solo los alumnos pueden pedir clases." });
        }

        if (!leerFecha(fecha, out DateTime fechaClase))
        {
            return StatusCode(400, new { resultado = "fechaInvalida", mensaje = "Elegí un día y una hora válidos." });
        }

        BD bd = new BD();
        ResultadoClase resultado;

        try
        {
            resultado = bd.enviarPedidoClase(idAlumno.Value, idProfesor, fechaClase);
        }
        catch (Exception)
        {
            return respuestaErrorBD();
        }

        return responderResultado(bd, idAlumno.Value, resultado, "Pedido enviado. Te avisamos cuando el profesor responda.");
    }

    // POST /Clases/Responder → acepta o rechaza quien tiene que responder
    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Responder(int idClase, bool aceptar)
    {
        int? idUsuario = obtenerIdUsuarioSesion();

        if (idUsuario == null)
        {
            return StatusCode(401, new { resultado = "sinSesion", mensaje = "Iniciá sesión para responder." });
        }

        BD bd = new BD();
        ResultadoClase resultado;

        try
        {
            resultado = bd.responderPedidoClase(idUsuario.Value, idClase, aceptar);
        }
        catch (Exception)
        {
            return respuestaErrorBD();
        }

        string mensajeExito = aceptar ? "Clase confirmada." : "Rechazaste ese horario. La otra persona puede proponer otro o cancelar la clase.";
        return responderResultado(bd, idUsuario.Value, resultado, mensajeExito);
    }

    // POST /Clases/Cancelar
    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Cancelar(int idClase)
    {
        int? idUsuario = obtenerIdUsuarioSesion();

        if (idUsuario == null)
        {
            return StatusCode(401, new { resultado = "sinSesion", mensaje = "Iniciá sesión para cancelar una clase." });
        }

        BD bd = new BD();
        ResultadoClase resultado;

        try
        {
            resultado = bd.cancelarClase(idUsuario.Value, idClase);
        }
        catch (Exception)
        {
            return respuestaErrorBD();
        }

        return responderResultado(bd, idUsuario.Value, resultado, "Clase cancelada.");
    }

    // POST /Clases/Reubicar → cualquiera de los dos propone otro horario; le toca responder al otro
    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Reubicar(int idClase, string fecha)
    {
        int? idUsuario = obtenerIdUsuarioSesion();

        if (idUsuario == null)
        {
            return StatusCode(401, new { resultado = "sinSesion", mensaje = "Iniciá sesión para cambiar el horario." });
        }

        if (!leerFecha(fecha, out DateTime fechaClase))
        {
            return StatusCode(400, new { resultado = "fechaInvalida", mensaje = "Elegí un día y una hora válidos." });
        }

        BD bd = new BD();
        ResultadoClase resultado;

        try
        {
            resultado = bd.reubicarClase(idUsuario.Value, idClase, fechaClase);
        }
        catch (Exception)
        {
            return respuestaErrorBD();
        }

        return responderResultado(bd, idUsuario.Value, resultado, "Pedimos confirmar el nuevo horario.");
    }

    // Traduce el resultado del SP a un código HTTP y un mensaje, y devuelve la insignia actualizada
    private IActionResult responderResultado(BD bd, int idUsuario, ResultadoClase resultado, string mensajeExito)
    {
        // Después de cada acción cambian las notificaciones: se guarda el número nuevo de la insignia en la sesión
        int? cantidadNotificaciones;

        try
        {
            int cantidad = bd.contarNotificaciones(idUsuario);
            HttpContext.Session.SetString("cantidadNotificaciones", cantidad.ToString());
            cantidadNotificaciones = cantidad;
        }
        catch (Exception)
        {
            // La acción ya se hizo: si no se pudo contar, la insignia queda como estaba
            cantidadNotificaciones = null;
        }

        return StatusCode(codigoHttp(resultado.resultado), new
        {
            resultado = resultado.resultado,
            estado = resultado.estado,
            idClase = resultado.idClase,
            idOtroUsuario = resultado.idOtroUsuario,
            mensaje = resultado.resultado == "ok" ? mensajeExito : mensajeDeError(resultado.resultado),
            cantidadNotificaciones = cantidadNotificaciones
        });
    }

    private IActionResult respuestaErrorBD()
    {
        return StatusCode(500, new { resultado = "errorBD", mensaje = "No pudimos completar la acción. Probá de nuevo en unos minutos." });
    }

    private static int codigoHttp(string resultado)
    {
        return resultado switch
        {
            "ok" => 200,
            "claseInexistente" or "profesorInexistente" or "alumnoInexistente" => 404,
            "noEsTuClase" => 403,
            "fechaInvalida" => 400,
            _ => 409 // choques de horario, ya respondida, muy cerca, estado que no admite el cambio
        };
    }

    private static string mensajeDeError(string resultado)
    {
        return resultado switch
        {
            "fechaInvalida" => "Elegí un horario que empiece dentro de 1 hora o más y dentro de los próximos 90 días.",
            "horarioOcupadoAlumno" => "Ya tenés una clase en ese horario. Elegí otro.",
            "horarioOcupadoProfesor" => "El profesor ya tiene una clase confirmada en ese horario. Elegí otro.",
            "horarioOcupado" => "Ya hay otra clase confirmada en ese horario, no se puede aceptar.",
            "profesorInexistente" => "Ese profesor ya no existe.",
            "alumnoInexistente" => "Solo los alumnos pueden pedir clases.",
            "claseInexistente" => "Esa clase ya no existe.",
            "noEsTuClase" => "Esta acción no la podés hacer vos en esta clase.",
            "yaRespondida" => "Este pedido ya fue respondido o venció.",
            "noSePuedeCancelar" => "Esta clase ya no se puede cancelar. Si te toca responder, aceptá, rechazá o proponé otro horario.",
            "noSePuedeReubicar" => "Esta clase ya no se puede reubicar.",
            "mismoHorario" => "Elegí un horario distinto al actual.",
            "muyCerca" => "La clase empieza en menos de 24 horas: coordinalo por chat con la otra persona.",
            _ => "No pudimos completar la acción."
        };
    }

    private static bool leerFecha(string? fecha, out DateTime fechaClase)
    {
        return DateTime.TryParseExact(fecha, formatoFecha, CultureInfo.InvariantCulture, DateTimeStyles.None, out fechaClase);
    }

    private int? obtenerIdUsuarioSesion()
    {
        string? idUsuario = HttpContext.Session.GetString("idUsuario");
        return int.TryParse(idUsuario, out int id) ? id : null;
    }
}
