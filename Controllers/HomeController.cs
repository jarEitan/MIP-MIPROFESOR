using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using MIP_MIPROFESOR.Models;

namespace MIP_MIPROFESOR.Controllers;

public class HomeController : Controller
{
    private readonly ILogger<HomeController> _logger;

    public HomeController(ILogger<HomeController> logger)
    {
        _logger = logger;
    }

    public IActionResult Index()
    {
        // TODO BD: reemplazar por BD.ObtenerMateriasDestacadas() cuando esté la base de datos.
        ViewBag.materiasDestacadas = new List<string>
        {
            "Matemática", "Física", "Química", "Biología", "Inglés", "Historia",
            "Lengua y Literatura", "Programación", "Economía", "Geografía"
        };
        return View();
    }

    public IActionResult Privacy()
    {
        return View();
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
