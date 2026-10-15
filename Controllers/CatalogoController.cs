using Microsoft.AspNetCore.Mvc;
using MIP_MIPROFESOR.Models;

namespace MIP_MIPROFESOR.Controllers;

// Catálogo de profesores. Index arma la página con los selectores y catalogo.js trae los resultados
// con fetch a Catalogo/Buscar, que responde en JSON una página de profesores.
public class CatalogoController : Controller
{
    // /Catalogo?busqueda=...&materia=...&colegio=...&modalidad=...&nivel=Secundario 1&nivel=Secundario 2&pagina=2&porPagina=15
    // Los filtros de la URL solo preseleccionan el formulario (links de Inicio, "Mi Colegio" y búsquedas compartidas).
    [HttpGet("Catalogo")]
    public IActionResult Index(string? busqueda, string? materia, string? colegio, string? modalidad, string[]? nivel, int pagina = 1, int porPagina = 10)
    {
        ViewBag.busqueda = busqueda ?? "";
        ViewBag.materia = materia ?? "";
        ViewBag.colegio = colegio ?? "";
        ViewBag.modalidad = modalidad ?? "";
        ViewBag.nivelesElegidos = (nivel ?? new string[0]).ToList();
        ViewBag.pagina = pagina < 1 ? 1 : pagina;
        ViewBag.porPagina = new[] { 5, 10, 15, 20 }.Contains(porPagina) ? porPagina : 10;

        BD bd = new BD();
        try
        {
            OpcionesPerfil opciones = bd.obtenerOpcionesPerfil();
            ViewBag.materias = opciones.materias.Select(opcion => opcion.nombre).ToList();
            ViewBag.colegios = opciones.escuelas.Select(opcion => opcion.nombre).ToList();
            ViewBag.niveles = opciones.niveles.Select(opcion => opcion.nombre).ToList();
            ViewBag.modalidades = opciones.modalidades.Select(opcion => opcion.nombre).ToList();
        }
        catch (Exception)
        {
            // Sin las opciones la página igual carga con los selectores vacíos; catalogo.js muestra el error al buscar
            ViewBag.materias = new List<string>();
            ViewBag.colegios = new List<string>();
            ViewBag.niveles = new List<string>();
            ViewBag.modalidades = new List<string>();
        }

        return View();
    }

    // GET /Catalogo/Buscar?... (mismos filtros) → una página de resultados. Cada profesor trae lo que muestra su tarjeta.
    [HttpGet("Catalogo/Buscar")]
    public IActionResult Buscar(string? busqueda, string? materia, string? colegio, string? modalidad, string[]? nivel, int pagina = 1, int porPagina = 10)
    {
        string niveles = string.Join(",", nivel ?? new string[0]);

        BD bd = new BD();
        try
        {
            ResultadoCatalogo resultado = bd.obtenerCatalogo(busqueda, materia, colegio, modalidad, niveles, pagina, porPagina);
            return Json(new
            {
                ok = true,
                total = resultado.total,
                pagina = resultado.pagina,
                porPagina = resultado.porPagina,
                totalPaginas = resultado.totalPaginas,
                profesores = resultado.profesores.Select(profesor => new
                {
                    id = profesor.id,
                    nombreCompleto = profesor.nombreCompleto,
                    iniciales = profesor.iniciales,
                    fotoPerfil = profesor.fotoPerfil,
                    verificado = profesor.verificado,
                    resumen = profesor.resumen,
                    calificacion = profesor.calificacion,
                    cantidadResenas = profesor.cantidadResenas,
                    precioHora = profesor.precioHora,
                    materias = profesor.materias,
                    niveles = profesor.niveles,
                    modalidades = profesor.modalidades,
                    colegios = profesor.colegios
                })
            });
        }
        catch (Exception)
        {
            return StatusCode(500, new { ok = false, mensaje = "No pudimos cargar el catálogo. Probá de nuevo en un rato." });
        }
    }
}
