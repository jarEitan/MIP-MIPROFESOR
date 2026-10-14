namespace MIP_MIPROFESOR.Models;

// Una fila del SP obtenerNotificaciones. tipo: pedidoPorResponder | propuestaPorResponder | pedidoAceptado |
// pedidoRechazado | pedidoVencido | pedidoCancelado | claseCompletada.
// destino (a dónde lleva el botón): panelClases | panelHistorial | catalogo.
public class NotificacionUsuario
{
    public int idClase { get; set; }
    public string tipo { get; set; } = "";
    public string titulo { get; set; } = "";
    public string mensaje { get; set; } = "";
    public string textoBoton { get; set; } = "";
    public string destino { get; set; } = "";
    public bool requiereAccion { get; set; }
    public bool esNueva { get; set; }
    public DateTime fechaNovedad { get; set; }
}
