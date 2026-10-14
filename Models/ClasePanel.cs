namespace MIP_MIPROFESOR.Models;

// Una fila del SP obtenerMisClases: una clase vista por el usuario de la sesión.
// grupo: pendiente | proxima | rechazada (horario rechazado que todavía no pasó) | historial.
// esperaA (en las Pendientes y las Rechazadas activas): quién tiene que mover ficha, yo | otro.
public class ClasePanel
{
    public int id { get; set; }
    public string estado { get; set; } = "";
    public string grupo { get; set; } = "";
    public DateTime fecha { get; set; }
    public DateTime fechaFin { get; set; }
    public string miRol { get; set; } = "";
    public string? esperaA { get; set; }
    public int idOtroUsuario { get; set; }
    public string nombreOtro { get; set; } = "";
    public string apellidoOtro { get; set; } = "";
    public bool puedeResponder { get; set; }
    public bool puedeCancelar { get; set; }
    public bool puedeReubicar { get; set; }
    public bool muyCerca { get; set; }
}

// Las clases del usuario (activas primero, después el historial) y los contadores del Panel de Control
public class MisClases
{
    public List<ClasePanel> clases { get; set; } = new List<ClasePanel>();
    public int pendientes { get; set; }
    public int proximas { get; set; }
    public int completadas { get; set; }
}

// El segundo resultado del SP puede traer NULL en los contadores si el usuario no tiene clases
public class ContadoresClasesCrudos
{
    public int? pendientes { get; set; }
    public int? proximas { get; set; }
    public int? completadas { get; set; }
}

// Fila de los SP enviarPedidoClase, responderPedidoClase, cancelarClase y reubicarClase.
// resultado: ok o el motivo por el que no se pudo (ver Info/log.md, entrada 2026-10-14).
public class ResultadoClase
{
    public string resultado { get; set; } = "";
    public string? estado { get; set; }
    public int? idClase { get; set; }
    public int? idOtroUsuario { get; set; }
}

// Franja ocupada que devuelve obtenerHorariosOcupados. de: profesor | alumno
public class HorarioOcupado
{
    public DateTime inicio { get; set; }
    public DateTime fin { get; set; }
    public string de { get; set; } = "";
}
