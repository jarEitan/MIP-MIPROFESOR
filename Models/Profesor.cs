namespace MIP_MIPROFESOR.Models;

public class Profesor
{
    public int id { get; set; }
    public string nombre { get; set; } = "";
    public string iniciales { get; set; } = "";
    public string materia { get; set; } = "";
    public string colegio { get; set; } = "";
    public string modalidad { get; set; } = "";
    public string nivel { get; set; } = "";
    public string resumen { get; set; } = "";
    public decimal calificacion { get; set; }
    public int cantidadResenas { get; set; }
    public int precioHora { get; set; }
    public bool verificado { get; set; }
    public List<string> temas { get; set; } = new List<string>();
}
