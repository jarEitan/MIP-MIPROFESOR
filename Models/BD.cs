using System.Data;
using Dapper;
using Microsoft.Data.SqlClient;

namespace MIP_MIPROFESOR.Models;

// Acceso a datos del sitio con Dapper. El inicio de sesión y el registro están en BDsesion.cs.
// Perfiles: stored procedures obtenerPerfil, obtenerOpcionesPerfil, obtenerDatosEdicion,
// obtenerFaltantesVerificacion y guardarPerfilCompleto de la base MIP.
// Catálogo: stored procedure obtenerCatalogo (MIP-catalogo.sql).
public class BD
{
    private static string connectionString = @"Server=localhost;Database=MIP;Integrated Security=True;TrustServerCertificate=True;";

    // ================= PERFIL PÚBLICO =================

    // Lee las 7 tablas del SP. Si el usuario no existe (o es admin), devuelve encontrado = false.
    public PerfilUsuario obtenerPerfil(int idUsuario)
    {
        using (var connection = new SqlConnection(connectionString))
        {
            using (var tablas = connection.QueryMultiple("obtenerPerfil", new { idUsuario = idUsuario }, commandType: CommandType.StoredProcedure))
            {
                PerfilUsuario? perfil = tablas.ReadFirstOrDefault<PerfilUsuario>();
                if (perfil == null) return new PerfilUsuario { encontrado = false };

                perfil.encontrado = true;
                perfil.materias = tablas.Read<string>().ToList();
                perfil.niveles = tablas.Read<string>().ToList();
                perfil.modalidades = tablas.Read<string>().ToList();
                perfil.colegios = tablas.Read<string>().ToList();
                perfil.titulos = tablas.Read<string>().ToList();
                perfil.resenas = tablas.Read<ResenaPerfil>().ToList();
                return perfil;
            }
        }
    }

    // ================= EDICIÓN DEL PERFIL PROPIO =================

    // Las 4 listas para los selectores: materias, niveles, modalidades y colegios
    public OpcionesPerfil obtenerOpcionesPerfil()
    {
        using (var connection = new SqlConnection(connectionString))
        {
            using (var tablas = connection.QueryMultiple("obtenerOpcionesPerfil", commandType: CommandType.StoredProcedure))
            {
                return new OpcionesPerfil
                {
                    materias = tablas.Read<OpcionPerfil>().ToList(),
                    niveles = tablas.Read<OpcionPerfil>().ToList(),
                    modalidades = tablas.Read<OpcionPerfil>().ToList(),
                    escuelas = tablas.Read<OpcionPerfil>().ToList()
                };
            }
        }
    }

    // Datos privados del usuario de la sesión (6 tablas). null si no existe.
    public DatosEdicion? obtenerDatosEdicion(int idUsuario)
    {
        using (var connection = new SqlConnection(connectionString))
        {
            using (var tablas = connection.QueryMultiple("obtenerDatosEdicion", new { idUsuario = idUsuario }, commandType: CommandType.StoredProcedure))
            {
                DatosEdicion? datos = tablas.ReadFirstOrDefault<DatosEdicion>();
                if (datos == null) return null;

                datos.tieneFotoDni = !string.IsNullOrWhiteSpace(datos.fotoDni);
                datos.idsMaterias = tablas.Read<int>().ToList();
                datos.idsNiveles = tablas.Read<int>().ToList();
                datos.idsModalidades = tablas.Read<int>().ToList();
                datos.idsEscuelas = tablas.Read<int>().ToList();
                datos.titulos = tablas.Read<string>().ToList();
                return datos;
            }
        }
    }

    // Textos de lo que le falta a la cuenta para estar verificada (vacía = verificada)
    public List<string> obtenerFaltantesVerificacion(int idUsuario)
    {
        using (var connection = new SqlConnection(connectionString))
        {
            return connection.Query<string>(
                "obtenerFaltantesVerificacion",
                new { idUsuario = idUsuario },
                commandType: CommandType.StoredProcedure).ToList();
        }
    }

    // Guarda las dos pestañas del modal con un solo SP y recalcula la verificación.
    // rutaFotoPerfil / rutaFotoDni en null conservan las fotos que ya tenía.
    public ResultadoGuardado guardarPerfilCompleto(int idUsuario, EdicionPerfil edicion, string? rutaFotoPerfil, string? rutaFotoDni)
    {
        using (var connection = new SqlConnection(connectionString))
        {
            return connection.QueryFirstOrDefault<ResultadoGuardado>(
                "guardarPerfilCompleto",
                new
                {
                    idUsuario = idUsuario,
                    nombre = edicion.nombre,
                    apellido = edicion.apellido,
                    mail = edicion.mail,
                    fechaNacimiento = edicion.fechaNacimiento,
                    dni = edicion.dni,
                    direccion = edicion.direccion,
                    fotoPerfil = rutaFotoPerfil,
                    fotoDni = rutaFotoDni,
                    descripcion = edicion.descripcion,
                    precioHora = edicion.precioHora,
                    idsMaterias = edicion.idsMaterias ?? "",
                    idsNiveles = edicion.idsNiveles ?? "",
                    idsModalidades = edicion.idsModalidades ?? "",
                    idsEscuelas = edicion.idsEscuelas ?? "",
                    titulos = string.Join("|", edicion.titulos)
                },
                commandType: CommandType.StoredProcedure) ?? new ResultadoGuardado { resultado = "datosInvalidos" };
        }
    }

    // ================= CATÁLOGO =================

    // Una página de profesores que cumplen los filtros (todos opcionales). niveles: nombres separados por coma.
    public ResultadoCatalogo obtenerCatalogo(string? busqueda, string? materia, string? colegio, string? modalidad, string? niveles, int pagina, int porPagina)
    {
        using (var connection = new SqlConnection(connectionString))
        {
            using (var tablas = connection.QueryMultiple(
                "obtenerCatalogo",
                new { busqueda = busqueda, materia = materia, colegio = colegio, modalidad = modalidad, niveles = niveles, pagina = pagina, porPagina = porPagina },
                commandType: CommandType.StoredProcedure))
            {
                ResultadoCatalogo resultado = tablas.ReadFirst<ResultadoCatalogo>();
                resultado.profesores = tablas.Read<Profesor>().ToList();
                var materiasPorProfesor = tablas.Read<ItemDeProfesor>().ToLookup(fila => fila.idUsuario, fila => fila.nombre);
                var nivelesPorProfesor = tablas.Read<ItemDeProfesor>().ToLookup(fila => fila.idUsuario, fila => fila.nombre);
                var modalidadesPorProfesor = tablas.Read<ItemDeProfesor>().ToLookup(fila => fila.idUsuario, fila => fila.nombre);
                var colegiosPorProfesor = tablas.Read<ItemDeProfesor>().ToLookup(fila => fila.idUsuario, fila => fila.nombre);

                foreach (Profesor profesor in resultado.profesores)
                {
                    profesor.materias = materiasPorProfesor[profesor.id].ToList();
                    profesor.niveles = nivelesPorProfesor[profesor.id].ToList();
                    profesor.modalidades = modalidadesPorProfesor[profesor.id].ToList();
                    profesor.colegios = colegiosPorProfesor[profesor.id].ToList();
                }
                return resultado;
            }
        }
    }
}

// Una fila (profesor, nombre) de las listas del SP obtenerCatalogo
public class ItemDeProfesor
{
    public int idUsuario { get; set; }
    public string nombre { get; set; } = "";
}
