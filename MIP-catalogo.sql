-- =====================================================================
-- MIP - Sistema de catálogo
-- Se puede ejecutar completo y más de una vez (CREATE OR ALTER).
-- No cambia ninguna tabla ni inserta datos.
-- SP nuevo: obtenerCatalogo (lista de profesores con filtros y búsqueda).
-- Los selectores de materia, colegio, modalidad y nivel usan obtenerOpcionesPerfil
-- (ya existente), por eso no hace falta otro SP para ellos.
-- =====================================================================
USE [MIP]
GO

-- ---------------------------------------------------------------------
-- obtenerCatalogo: profesores que cumplen los filtros (todos opcionales).
--   @busqueda   texto libre: nombre, apellido, materia, colegio o título (sin importar tildes ni mayúsculas)
--   @materia    nombre exacto de una materia
--   @colegio    nombre exacto de un colegio
--   @modalidad  nombre exacto de una modalidad (Presencial o Virtual)
--   @niveles    nombres de niveles separados por coma; alcanza con que enseñe uno de ellos
-- Orden: cuentas verificadas primero, luego mejor calificación y más reseñas.
-- 5 resultados:
--   1) profesores  2) materias  3) niveles  4) modalidades  5) colegios
--   (cada lista trae idUsuario y nombre; los tres últimos usan el mismo orden que obtenerPerfil)
-- Reseñas visibles: estado vacío o 'Aprobada'. Nunca devuelve mail, DNI, dirección ni foto del DNI.
-- ---------------------------------------------------------------------
CREATE OR ALTER PROCEDURE [dbo].[obtenerCatalogo]
    @busqueda  NVARCHAR(100) = NULL,
    @materia   NVARCHAR(100) = NULL,
    @colegio   NVARCHAR(100) = NULL,
    @modalidad NVARCHAR(100) = NULL,
    @niveles   NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @busqueda  = NULLIF(LTRIM(RTRIM(@busqueda)), N'');
    SET @materia   = NULLIF(LTRIM(RTRIM(@materia)), N'');
    SET @colegio   = NULLIF(LTRIM(RTRIM(@colegio)), N'');
    SET @modalidad = NULLIF(LTRIM(RTRIM(@modalidad)), N'');
    SET @niveles   = NULLIF(LTRIM(RTRIM(@niveles)), N'');

    -- El texto buscado se toma literal: se escapan los comodines de LIKE
    DECLARE @patron NVARCHAR(250) = NULL;
    IF @busqueda IS NOT NULL
        SET @patron = N'%' + REPLACE(REPLACE(REPLACE(@busqueda, N'[', N'[[]'), N'%', N'[%]'), N'_', N'[_]') + N'%';

    CREATE TABLE #profesores (idUsuario INT PRIMARY KEY);

    INSERT INTO #profesores (idUsuario)
    SELECT u.ID
    FROM Usuarios u
    WHERE u.tipoUsuario = N'profesor'
      AND (@patron IS NULL
           OR (u.nombre + N' ' + u.apellido) COLLATE Latin1_General_CI_AI LIKE @patron COLLATE Latin1_General_CI_AI
           OR EXISTS (SELECT 1 FROM Usuarios_Materias um JOIN Materias m ON m.ID = um.idMateria
                      WHERE um.idUsuario = u.ID AND m.nombre COLLATE Latin1_General_CI_AI LIKE @patron COLLATE Latin1_General_CI_AI)
           OR EXISTS (SELECT 1 FROM Escuelas_Usuarios eu JOIN Escuelas e ON e.ID = eu.idEscuela
                      WHERE eu.idUsuario = u.ID AND e.nombre COLLATE Latin1_General_CI_AI LIKE @patron COLLATE Latin1_General_CI_AI)
           OR EXISTS (SELECT 1 FROM Titulos t
                      WHERE t.idUsuario = u.ID AND t.titulo COLLATE Latin1_General_CI_AI LIKE @patron COLLATE Latin1_General_CI_AI))
      AND (@materia IS NULL
           OR EXISTS (SELECT 1 FROM Usuarios_Materias um JOIN Materias m ON m.ID = um.idMateria
                      WHERE um.idUsuario = u.ID AND m.nombre = @materia))
      AND (@colegio IS NULL
           OR EXISTS (SELECT 1 FROM Escuelas_Usuarios eu JOIN Escuelas e ON e.ID = eu.idEscuela
                      WHERE eu.idUsuario = u.ID AND e.nombre = @colegio))
      AND (@modalidad IS NULL
           OR EXISTS (SELECT 1 FROM Profesores_Modalidades pm JOIN Modalidades mo ON mo.ID = pm.idModalidad
                      WHERE pm.idUsuario = u.ID AND mo.nombre = @modalidad))
      AND (@niveles IS NULL
           OR EXISTS (SELECT 1 FROM Usuarios_Niveles un JOIN Niveles n ON n.ID = un.idNivel
                      WHERE un.idUsuario = u.ID
                        AND n.nombre IN (SELECT LTRIM(RTRIM(value)) FROM STRING_SPLIT(@niveles, N','))));

    -- 1) profesores
    SELECT u.ID AS id, u.nombre, u.apellido, u.fotoPerfil, u.verificado,
           p.descripcion,
           ISNULL(ip.precioHora, 0) AS precioHora,
           ISNULL(rs.calificacion, 0) AS calificacion,
           ISNULL(rs.cantidadResenas, 0) AS cantidadResenas
    FROM #profesores f
    JOIN Usuarios u ON u.ID = f.idUsuario
    LEFT JOIN Perfiles p ON p.idUsuario = u.ID
    LEFT JOIN InfoProfesores ip ON ip.idUsuario = u.ID
    OUTER APPLY (
        SELECT CAST(AVG(CAST(r.puntuacion AS DECIMAL(3,2))) AS DECIMAL(3,2)) AS calificacion, COUNT(*) AS cantidadResenas
        FROM Resenas r
        WHERE r.idReceptor = u.ID AND (r.estado IS NULL OR r.estado = N'Aprobada')
    ) rs
    ORDER BY u.verificado DESC, ISNULL(rs.calificacion, 0) DESC, ISNULL(rs.cantidadResenas, 0) DESC, u.ID;

    -- 2) a 5) listas de cada profesor del resultado
    SELECT um.idUsuario, m.nombre FROM #profesores f JOIN Usuarios_Materias um ON um.idUsuario = f.idUsuario
        JOIN Materias m ON m.ID = um.idMateria ORDER BY um.idUsuario, m.nombre;
    SELECT un.idUsuario, n.nombre FROM #profesores f JOIN Usuarios_Niveles un ON un.idUsuario = f.idUsuario
        JOIN Niveles n ON n.ID = un.idNivel ORDER BY un.idUsuario, n.ID;
    SELECT pm.idUsuario, mo.nombre FROM #profesores f JOIN Profesores_Modalidades pm ON pm.idUsuario = f.idUsuario
        JOIN Modalidades mo ON mo.ID = pm.idModalidad ORDER BY pm.idUsuario, mo.ID;
    SELECT eu.idUsuario, e.nombre FROM #profesores f JOIN Escuelas_Usuarios eu ON eu.idUsuario = f.idUsuario
        JOIN Escuelas e ON e.ID = eu.idEscuela ORDER BY eu.idUsuario, e.nombre;
END
GO
