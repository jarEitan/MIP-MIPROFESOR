namespace MIP_MIPROFESOR.Models;

// Una fila del segundo resultado del SP obtenerHistorialClases: una clase del historial.
// dia: solo la fecha de la clase (el SP no manda la hora). estado: Completada | Cancelada | Rechazada.
// materias: las del profesor de la clase. colegios: los del alumno de la clase (separados por coma, null si no cargó).
// puntuacion: estrellas de la última reseña que el dueño del historial le dejó a la contraparte (null = no le dejó).
// puedeDarResena: solo en el historial propio, en una clase Completada y sin reseña a esa persona.
public class ClaseHistorial
{
    public int id { get; set; }
    public string estado { get; set; } = "";
    public DateTime dia { get; set; }
    public int idOtroUsuario { get; set; }
    public string nombreOtro { get; set; } = "";
    public string apellidoOtro { get; set; } = "";
    public string? fotoOtro { get; set; }
    public string tipoOtro { get; set; } = "";
    public string? materias { get; set; }
    public string? colegios { get; set; }
    public int? puntuacion { get; set; }
    public bool puedeDarResena { get; set; }
}

// El dueño del historial (primer resultado del SP) y sus últimas 20 clases.
// encontrado = false si el usuario no existe o es admin.
public class ResultadoHistorial
{
    public bool encontrado { get; set; }
    public int id { get; set; }
    public string nombre { get; set; } = "";
    public string apellido { get; set; } = "";
    public string tipoUsuario { get; set; } = "";
    public bool esPropio { get; set; }
    public List<ClaseHistorial> clases { get; set; } = new List<ClaseHistorial>();
}
