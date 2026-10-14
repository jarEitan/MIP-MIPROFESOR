using System.Globalization;
using Microsoft.AspNetCore.Mvc;
using MIP_MIPROFESOR.Models;

namespace MIP_MIPROFESOR.Controllers;

// Pedidos de clase entre alumno y profesor. Se llaman con fetch desde site.js y devuelven JSON.
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
        if (idUsuario == null) return StatusCode(401, new { resultado = "sinSesion", mensaje = "Iniciá sesión para pedir clases." });
        if (tipoUsuario != "alumno" && tipoUsuario != "profesor") return StatusCode(403, new { resultado = "sinPermiso", mensaje = "Tu cuenta no puede pedir clases." });
        if (!DateTime.TryParseExact(dia, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out DateTime desde))
            return StatusCode(400, new { resultado = "fechaInvalida", mensaje = "Elegí un día válido." });

        int idProfesor = tipoUsuario == "profesor" ? idUsuario.Value : idOtroUsuario;
        int idAlumno = tipoUsuario == "alumno" ? idUsuario.Value : idOtroUsuario;

        try
        {
            List<HorarioOcupado> ocupados = new BD().obtenerHorariosOcupados(idProfesor, idAlumno, desde, desde.AddDays(1), idClaseExcluir);
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
        catch (Exception)
        {
            return StatusCode(500, new { resultado = "errorBD", mensaje = "No pudimos cargar los horarios. Probá de nuevo en unos minutos." });
        }
    }

    // POST /Clases/EnviarPedido → el alumno de la sesión le pide una clase al profesor
    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult EnviarPedido(int idProfesor, string fecha)
    {
        int? idAlumno = obtenerIdUsuarioSesion();
        if (idAlumno == null) return StatusCode(401, new { resultado = "sinSesion", mensaje = "Iniciá sesión para pedir una clase." });
        if (HttpContext.Session.GetString("tipoUsuario") != "alumno") return StatusCode(403, new { resultado = "sinPermiso", mensaje = "Solo los alumnos pueden pedir clases." });
        if (!leerFecha(fecha, out DateTime fechaClase)) return StatusCode(400, new { resultado = "fechaInvalida", mensaje = "Elegí un día y una hora válidos." });

        return ejecutar(() => new BD().enviarPedidoClase(idAlumno.Value, idProfesor, fechaClase), "Pedido enviado. Te avisamos cuando el profesor responda.");
    }

    // POST /Clases/Responder → acepta o rechaza quien tiene que responder
    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Responder(int idClase, bool aceptar)
    {
        int? idUsuario = obtenerIdUsuarioSesion();
        if (idUsuario == null) return StatusCode(401, new { resultado = "sinSesion", mensaje = "Iniciá sesión para responder." });

        return ejecutar(() => new BD().responderPedidoClase(idUsuario.Value, idClase, aceptar), aceptar ? "Clase confirmada." : "Rechazaste ese horario. La otra persona puede proponer otro o cancelar la clase.");
    }

    // POST /Clases/Cancelar
    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Cancelar(int idClase)
    {
        int? idUsuario = obtenerIdUsuarioSesion();
        if (idUsuario == null) return StatusCode(401, new { resultado = "sinSesion", mensaje = "Iniciá sesión para cancelar una clase." });

        return ejecutar(() => new BD().cancelarClase(idUsuario.Value, idClase), "Clase cancelada.");
    }

    // POST /Clases/Reubicar → cualquiera de los dos propone otro horario; le toca responder al otro
    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Reubicar(int idClase, string fecha)
    {
        int? idUsuario = obtenerIdUsuarioSesion();
        if (idUsuario == null) return StatusCode(401, new { resultado = "sinSesion", mensaje = "Iniciá sesión para cambiar el horario." });
        if (!leerFecha(fecha, out DateTime fechaClase)) return StatusCode(400, new { resultado = "fechaInvalida", mensaje = "Elegí un día y una hora válidos." });

        return ejecutar(() => new BD().reubicarClase(idUsuario.Value, idClase, fechaClase), "Pedimos confirmar el nuevo horario.");
    }

    // Llama al SP, traduce el resultado a un código HTTP y un mensaje, y devuelve la insignia actualizada
    private IActionResult ejecutar(Func<ResultadoClase> accion, string mensajeExito)
    {
        ResultadoClase resultado;
        try
        {
            resultado = accion();
        }
        catch (Exception)
        {
            return StatusCode(500, new { resultado = "errorBD", mensaje = "No pudimos completar la acción. Probá de nuevo en unos minutos." });
        }

        bool exito = resultado.resultado == "ok";
        return StatusCode(codigoHttp(resultado.resultado), new
        {
            resultado = resultado.resultado,
            estado = resultado.estado,
            idClase = resultado.idClase,
            idOtroUsuario = resultado.idOtroUsuario,
            mensaje = exito ? mensajeExito : mensajeDeError(resultado.resultado),
            cantidadNotificaciones = actualizarInsigniaDeSesion()
        });
    }

    private static int codigoHttp(string resultado)
    {
        switch (resultado)
        {
            case "ok": return 200;
            case "claseInexistente":
            case "profesorInexistente":
            case "alumnoInexistente": return 404;
            case "noEsTuClase": return 403;
            case "fechaInvalida": return 400;
            default: return 409; // choques de horario, ya respondida, muy cerca, estado que no admite el cambio
        }
    }

    private static string mensajeDeError(string resultado)
    {
        switch (resultado)
        {
            case "fechaInvalida": return "Elegí un horario que empiece dentro de 1 hora o más y dentro de los próximos 90 días.";
            case "horarioOcupadoAlumno": return "Ya tenés una clase en ese horario. Elegí otro.";
            case "horarioOcupadoProfesor": return "El profesor ya tiene una clase confirmada en ese horario. Elegí otro.";
            case "horarioOcupado": return "Ya hay otra clase confirmada en ese horario, no se puede aceptar.";
            case "profesorInexistente": return "Ese profesor ya no existe.";
            case "alumnoInexistente": return "Solo los alumnos pueden pedir clases.";
            case "claseInexistente": return "Esa clase ya no existe.";
            case "noEsTuClase": return "Esta acción no la podés hacer vos en esta clase.";
            case "yaRespondida": return "Este pedido ya fue respondido o venció.";
            case "noSePuedeCancelar": return "Esta clase ya no se puede cancelar. Si te toca responder, aceptá, rechazá o proponé otro horario.";
            case "noSePuedeReubicar": return "Esta clase ya no se puede reubicar.";
            case "mismoHorario": return "Elegí un horario distinto al actual.";
            case "muyCerca": return "La clase empieza en menos de 24 horas: coordinalo por chat con la otra persona.";
            default: return "No pudimos completar la acción.";
        }
    }

    // Después de cada acción cambian las notificaciones: se actualiza el número de la insignia en la sesión
    private int? actualizarInsigniaDeSesion()
    {
        int? idUsuario = obtenerIdUsuarioSesion();
        if (idUsuario == null) return null;

        try
        {
            int cantidad = new BD().contarNotificaciones(idUsuario.Value);
            HttpContext.Session.SetString("cantidadNotificaciones", cantidad.ToString());
            return cantidad;
        }
        catch (Exception)
        {
            return null;
        }
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
