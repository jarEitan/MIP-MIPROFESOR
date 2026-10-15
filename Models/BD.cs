using System.Data;
using Dapper;
using Microsoft.Data.SqlClient;

namespace MIP_MIPROFESOR.Models;

// Acceso a datos del sitio con Dapper. El inicio de sesión y el registro están en BDsesion.cs.
// Perfiles: stored procedures obtenerPerfil, obtenerOpcionesPerfil, obtenerDatosEdicion,
// obtenerFaltantesVerificacion y guardarPerfilCompleto de la base MIP.
// Catálogo: stored procedure obtenerCatalogo (en MIP-BD.sql).
// Likes: stored procedures obtenerLike y alternarLike (en MIP-BD.sql).
// Clases y notificaciones: stored procedures en MIP-BD.sql (reglas y estados en Info/log.md, entrada 2026-10-14).
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

    // ================= LIKES =================

    // Si idEmisor (null = visitante sin sesión) le dio me gusta al perfil idReceptor, y cuántos tiene
    public ResultadoLike obtenerLike(int? idEmisor, int idReceptor)
    {
        using (var connection = new SqlConnection(connectionString))
        {
            return connection.QuerySingle<ResultadoLike>("obtenerLike", new { idEmisor = idEmisor, idReceptor = idReceptor }, commandType: CommandType.StoredProcedure);
        }
    }

    // Da o saca el me gusta y devuelve cómo quedó. resultado: ok | mismoUsuario | usuarioInexistente
    public ResultadoLike alternarLike(int idEmisor, int idReceptor)
    {
        using (var connection = new SqlConnection(connectionString))
        {
            return connection.QuerySingle<ResultadoLike>("alternarLike", new { idEmisor = idEmisor, idReceptor = idReceptor }, commandType: CommandType.StoredProcedure);
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

    // ================= CLASES (pedidos alumno → profesor) =================
    // Reglas y estados: Info/log.md, entrada 2026-10-14. Todos los SP devuelven una fila con "resultado".

    // El alumno le pide una clase al profesor. fecha = hora de inicio
    public ResultadoClase enviarPedidoClase(int idAlumno, int idProfesor, DateTime fecha)
    {
        using (var connection = new SqlConnection(connectionString))
        {
            return connection.QuerySingle<ResultadoClase>("enviarPedidoClase", new { idAlumno = idAlumno, idProfesor = idProfesor, fecha = fecha }, commandType: CommandType.StoredProcedure);
        }
    }

    // Acepta o rechaza quien tiene que responder (el profesor a un pedido, o el alumno a un nuevo horario propuesto)
    public ResultadoClase responderPedidoClase(int idUsuario, int idClase, bool aceptar)
    {
        using (var connection = new SqlConnection(connectionString))
        {
            return connection.QuerySingle<ResultadoClase>("responderPedidoClase", new { idUsuario = idUsuario, idClase = idClase, aceptar = aceptar }, commandType: CommandType.StoredProcedure);
        }
    }

    // Cancela una clase Pendiente o Confirmada (cualquiera de los dos). muyCerca = hay que hablarlo por chat
    public ResultadoClase cancelarClase(int idUsuario, int idClase)
    {
        using (var connection = new SqlConnection(connectionString))
        {
            return connection.QuerySingle<ResultadoClase>("cancelarClase", new { idUsuario = idUsuario, idClase = idClase }, commandType: CommandType.StoredProcedure);
        }
    }

    // Cambia el horario: la clase vuelve a Pendiente y le toca responder al otro
    public ResultadoClase reubicarClase(int idUsuario, int idClase, DateTime nuevaFecha)
    {
        using (var connection = new SqlConnection(connectionString))
        {
            return connection.QuerySingle<ResultadoClase>("reubicarClase", new { idUsuario = idUsuario, idClase = idClase, nuevaFecha = nuevaFecha }, commandType: CommandType.StoredProcedure);
        }
    }

    // Clases del Panel de Control (primero las activas, después el historial) + contadores
    public MisClases obtenerMisClases(int idUsuario)
    {
        using (var connection = new SqlConnection(connectionString))
        {
            using (var tablas = connection.QueryMultiple("obtenerMisClases", new { idUsuario = idUsuario }, commandType: CommandType.StoredProcedure))
            {
                MisClases misClases = new MisClases();
                misClases.clases = tablas.Read<ClasePanel>().ToList();
                ContadoresClasesCrudos contadores = tablas.ReadFirst<ContadoresClasesCrudos>();
                misClases.pendientes = contadores.pendientes ?? 0;
                misClases.proximas = contadores.proximas ?? 0;
                misClases.completadas = contadores.completadas ?? 0;
                return misClases;
            }
        }
    }

    // Historial de clases de idUsuario (máximo 20, tope fijo en el SP). idVisitante = quien mira (null = sin sesión):
    // si es el mismo usuario ve todo su historial; si es otro, solo las clases completadas.
    public ResultadoHistorial obtenerHistorialClases(int idUsuario, int? idVisitante)
    {
        using (var connection = new SqlConnection(connectionString))
        {
            using (var tablas = connection.QueryMultiple("obtenerHistorialClases", new { idUsuario = idUsuario, idVisitante = idVisitante }, commandType: CommandType.StoredProcedure))
            {
                ResultadoHistorial? resultado = tablas.ReadFirstOrDefault<ResultadoHistorial>();
                if (resultado == null) return new ResultadoHistorial { encontrado = false };

                resultado.encontrado = true;
                resultado.clases = tablas.Read<ClaseHistorial>().ToList();
                return resultado;
            }
        }
    }

    // Franjas que el selector de horario tiene que bloquear (clases confirmadas del profesor y clases del alumno)
    public List<HorarioOcupado> obtenerHorariosOcupados(int idProfesor, int? idAlumno, DateTime desde, DateTime hasta, int? idClaseExcluir)
    {
        using (var connection = new SqlConnection(connectionString))
        {
            return connection.Query<HorarioOcupado>(
                "obtenerHorariosOcupados",
                new { idProfesor = idProfesor, idAlumno = idAlumno, desde = desde, hasta = hasta, idClaseExcluir = idClaseExcluir },
                commandType: CommandType.StoredProcedure).ToList();
        }
    }

    // ================= NOTIFICACIONES =================

    // Las notificaciones del usuario: primero las que piden una acción, después las nuevas, después las ya vistas
    public List<NotificacionUsuario> obtenerNotificaciones(int idUsuario)
    {
        using (var connection = new SqlConnection(connectionString))
        {
            return connection.Query<NotificacionUsuario>("obtenerNotificaciones", new { idUsuario = idUsuario }, commandType: CommandType.StoredProcedure).ToList();
        }
    }

    // El número de la insignia del botón Panel de Control: pedidos por responder + novedades sin ver
    public int contarNotificaciones(int idUsuario)
    {
        using (var connection = new SqlConnection(connectionString))
        {
            return connection.QuerySingle<int>("contarNotificaciones", new { idUsuario = idUsuario }, commandType: CommandType.StoredProcedure);
        }
    }

    // Las novedades pasan a vistas (se llama al abrir la lista). Devuelve lo que queda en la insignia
    public int marcarNotificacionesVistas(int idUsuario)
    {
        using (var connection = new SqlConnection(connectionString))
        {
            return connection.QuerySingle<int>("marcarNotificacionesVistas", new { idUsuario = idUsuario }, commandType: CommandType.StoredProcedure);
        }
    }
}

// Una fila (profesor, nombre) de las listas del SP obtenerCatalogo
public class ItemDeProfesor
{
    public int idUsuario { get; set; }
    public string nombre { get; set; } = "";
}
