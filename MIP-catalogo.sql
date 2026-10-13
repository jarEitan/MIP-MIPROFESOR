-- =====================================================================
-- MIP - Sistema de catálogo
-- Se puede ejecutar completo y más de una vez (CREATE OR ALTER).
-- No cambia ninguna tabla. Solo inserta las cuentas de prueba del final (opcional: borrar esa parte si no las querés).
-- SP nuevo: obtenerCatalogo (profesores con filtros, búsqueda y paginación).
-- Al final: cuentas de prueba (profesores y alumnos) para ver el catálogo con datos.
-- Los selectores de materia, colegio, modalidad y nivel usan obtenerOpcionesPerfil
-- (ya existente), por eso no hace falta otro SP para ellos.
-- =====================================================================
USE [MIP]
GO

-- ---------------------------------------------------------------------
-- obtenerCatalogo: una página de profesores que cumplen los filtros (todos opcionales).
--   @busqueda   texto libre: nombre, apellido, materia, colegio o título (sin importar tildes ni mayúsculas)
--   @materia    nombre exacto de una materia
--   @colegio    nombre exacto de un colegio
--   @modalidad  nombre exacto de una modalidad (Presencial o Virtual)
--   @niveles    nombres de niveles separados por coma; alcanza con que enseñe uno de ellos
--   @pagina     número de página (desde 1). Si se pasa del final, devuelve la última.
--   @porPagina  tarjetas por página: 5, 10, 15 o 20 (cualquier otro valor se toma como 10)
-- Orden: cuentas verificadas primero, luego mejor calificación y más reseñas.
-- 6 resultados:
--   1) paginación: total, pagina, porPagina, totalPaginas
--   2) profesores de la página
--   3) a 6) materias, niveles, modalidades y colegios (idUsuario, nombre) de esos profesores
-- Reseñas visibles: estado vacío o 'Aprobada'. Nunca devuelve mail, DNI, dirección ni foto del DNI.
-- ---------------------------------------------------------------------
CREATE OR ALTER PROCEDURE [dbo].[obtenerCatalogo]
    @busqueda  NVARCHAR(100) = NULL,
    @materia   NVARCHAR(100) = NULL,
    @colegio   NVARCHAR(100) = NULL,
    @modalidad NVARCHAR(100) = NULL,
    @niveles   NVARCHAR(200) = NULL,
    @pagina    INT = 1,
    @porPagina INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    SET @busqueda  = NULLIF(LTRIM(RTRIM(@busqueda)), N'');
    SET @materia   = NULLIF(LTRIM(RTRIM(@materia)), N'');
    SET @colegio   = NULLIF(LTRIM(RTRIM(@colegio)), N'');
    SET @modalidad = NULLIF(LTRIM(RTRIM(@modalidad)), N'');
    SET @niveles   = NULLIF(LTRIM(RTRIM(@niveles)), N'');
    IF @porPagina NOT IN (5, 10, 15, 20) SET @porPagina = 10;

    -- El texto buscado se toma literal: se escapan los comodines de LIKE
    DECLARE @patron NVARCHAR(250) = NULL;
    IF @busqueda IS NOT NULL
        SET @patron = N'%' + REPLACE(REPLACE(REPLACE(@busqueda, N'[', N'[[]'), N'%', N'[%]'), N'_', N'[_]') + N'%';

    -- Todos los profesores que cumplen los filtros, con su calificación, para ordenar y paginar
    CREATE TABLE #filtrados (
        idUsuario       INT PRIMARY KEY,
        verificado      BIT,
        calificacion    DECIMAL(3,2),
        cantidadResenas INT
    );

    INSERT INTO #filtrados (idUsuario, verificado, calificacion, cantidadResenas)
    SELECT u.ID, u.verificado, ISNULL(rs.calificacion, 0), ISNULL(rs.cantidadResenas, 0)
    FROM Usuarios u
    OUTER APPLY (
        SELECT CAST(AVG(CAST(r.puntuacion AS DECIMAL(3,2))) AS DECIMAL(3,2)) AS calificacion, COUNT(*) AS cantidadResenas
        FROM Resenas r
        WHERE r.idReceptor = u.ID AND (r.estado IS NULL OR r.estado = N'Aprobada')
    ) rs
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

    DECLARE @total INT = (SELECT COUNT(*) FROM #filtrados);
    DECLARE @totalPaginas INT = CASE WHEN @total = 0 THEN 1 ELSE (@total + @porPagina - 1) / @porPagina END;
    IF @pagina IS NULL OR @pagina < 1 SET @pagina = 1;
    IF @pagina > @totalPaginas SET @pagina = @totalPaginas;

    -- Solo los de la página pedida
    CREATE TABLE #pagina (idUsuario INT PRIMARY KEY, orden INT);
    INSERT INTO #pagina (idUsuario, orden)
    SELECT idUsuario, ROW_NUMBER() OVER (ORDER BY verificado DESC, calificacion DESC, cantidadResenas DESC, idUsuario)
    FROM #filtrados
    ORDER BY verificado DESC, calificacion DESC, cantidadResenas DESC, idUsuario
    OFFSET (@pagina - 1) * @porPagina ROWS FETCH NEXT @porPagina ROWS ONLY;

    -- 1) paginación
    SELECT @total AS total, @pagina AS pagina, @porPagina AS porPagina, @totalPaginas AS totalPaginas;

    -- 2) profesores de la página
    SELECT u.ID AS id, u.nombre, u.apellido, u.fotoPerfil, u.verificado,
           p.descripcion,
           ISNULL(ip.precioHora, 0) AS precioHora,
           f.calificacion, f.cantidadResenas
    FROM #pagina pg
    JOIN #filtrados f ON f.idUsuario = pg.idUsuario
    JOIN Usuarios u ON u.ID = pg.idUsuario
    LEFT JOIN Perfiles p ON p.idUsuario = u.ID
    LEFT JOIN InfoProfesores ip ON ip.idUsuario = u.ID
    ORDER BY pg.orden;

    -- 3) a 6) listas de cada profesor de la página
    SELECT um.idUsuario, m.nombre FROM #pagina pg JOIN Usuarios_Materias um ON um.idUsuario = pg.idUsuario
        JOIN Materias m ON m.ID = um.idMateria ORDER BY um.idUsuario, m.nombre;
    SELECT un.idUsuario, n.nombre FROM #pagina pg JOIN Usuarios_Niveles un ON un.idUsuario = pg.idUsuario
        JOIN Niveles n ON n.ID = un.idNivel ORDER BY un.idUsuario, n.ID;
    SELECT pm.idUsuario, mo.nombre FROM #pagina pg JOIN Profesores_Modalidades pm ON pm.idUsuario = pg.idUsuario
        JOIN Modalidades mo ON mo.ID = pm.idModalidad ORDER BY pm.idUsuario, mo.ID;
    SELECT eu.idUsuario, e.nombre FROM #pagina pg JOIN Escuelas_Usuarios eu ON eu.idUsuario = pg.idUsuario
        JOIN Escuelas e ON e.ID = eu.idEscuela ORDER BY eu.idUsuario, e.nombre;
END
GO

-- Sofía Martínez (profesor)
DECLARE @mail NVARCHAR(150), @id INT;
SET @mail = N'sofia.martinez@prueba.mip';
IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE mail = @mail)
BEGIN
    INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
    VALUES (N'Sofía', N'Martínez', @mail, N'pbkdf2$100000$3q8UgbbaqBlJ14m11Z17pQ==$7jDkPfEVCTJ+0xJilWwq4Z6D7GjlIGHh7sEIgmvkiVw=', N'30111001', N'Av. Corrientes 1010, CABA', N'privado/dni/prueba1.webp', N'profesor', '1990-03-14', 1);
    SET @id = SCOPE_IDENTITY();
    INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>6 años preparando exámenes de ingreso y finales. Explico paso a paso, sin apuro.</p>');
    INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 8000);
    INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Profesora de Matemática (UBA)');
    INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre = N'Matemática';
    INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre = N'Álgebra y Análisis';
    INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre = N'Presencial';
    INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre = N'Secundaria';
    INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre = N'Belgrano Day School';
    INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre = N'Colegio San Martín';
END
GO

-- Lucas Gómez (profesor)
DECLARE @mail NVARCHAR(150), @id INT;
SET @mail = N'lucas.gomez@prueba.mip';
IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE mail = @mail)
BEGIN
    INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
    VALUES (N'Lucas', N'Gómez', @mail, N'pbkdf2$100000$+A6t29cIXeMOAk4zIb45ng==$8k8eq64y5ZwUW5mGjPuce/gd5/G7UXmmeh7O6iOtEsA=', N'30111002', N'Av. Corrientes 1020, CABA', N'privado/dni/prueba2.webp', N'profesor', '1988-07-02', 1);
    SET @id = SCOPE_IDENTITY();
    INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Ingeniero y docente. Problemas resueltos en vivo y apuntes alineados al programa del colegio.</p>');
    INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 7500);
    INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Ingeniero Industrial (UTN)');
    INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre = N'Física';
    INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre = N'Matemática';
    INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre = N'Virtual';
    INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre = N'Secundaria';
    INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre = N'Universitario';
    INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre = N'Colegio San Martín';
END
GO

-- Camila Rossi (profesor)
DECLARE @mail NVARCHAR(150), @id INT;
SET @mail = N'camila.rossi@prueba.mip';
IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE mail = @mail)
BEGIN
    INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
    VALUES (N'Camila', N'Rossi', @mail, N'pbkdf2$100000$gIwirKyNoWMPJci6f9HF6w==$oY5gyAT5CNYsuieo/Dv8Ae9gDqvU9mln3Nv6VNXKZJo=', N'30111003', N'Av. Corrientes 1030, CABA', N'privado/dni/prueba3.webp', N'profesor', '1993-11-21', 0);
    SET @id = SCOPE_IDENTITY();
    INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Conversación, gramática y preparación de exámenes internacionales en un solo lugar.</p>');
    INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 6500);
    INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Traductora Pública de Inglés');
    INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre = N'Inglés';
    INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre = N'Presencial';
    INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre = N'Virtual';
    INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre = N'Primaria';
    INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre = N'Secundaria';
    INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre = N'Colegio Nacional de Buenos Aires';
    INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre = N'Northlands';
END
GO

-- Joaquín Fernández (profesor)
DECLARE @mail NVARCHAR(150), @id INT;
SET @mail = N'joaquin.fernandez@prueba.mip';
IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE mail = @mail)
BEGIN
    INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
    VALUES (N'Joaquín', N'Fernández', @mail, N'pbkdf2$100000$5/dSP6hM8Q7rrQq8Ek1mqg==$LHbF1OwnNLRbjgdvnK7kKK4VRKItVwoQ9/iZlOyOK+o=', N'30111004', N'Av. Corrientes 1040, CABA', N'privado/dni/prueba4.webp', N'profesor', '1991-01-30', 0);
    SET @id = SCOPE_IDENTITY();
    INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Laboratorio y teoría sin miedo: estequiometría, soluciones y química orgánica.</p>');
    INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 7000);
    INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Licenciado en Química');
    INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre = N'Química';
    INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre = N'Presencial';
    INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre = N'Secundaria';
    INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre = N'Belgrano Day School';
END
GO

-- Valentina Paz (profesor)
DECLARE @mail NVARCHAR(150), @id INT;
SET @mail = N'valentina.paz@prueba.mip';
IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE mail = @mail)
BEGIN
    INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
    VALUES (N'Valentina', N'Paz', @mail, N'pbkdf2$100000$3Gm5XzXzgiJ+Tkpl4r8NWQ==$qMi4r30G/f6HUZnb94YU8QZuzhL3hzVO57aC3hn+0Rk=', N'30111005', N'Av. Corrientes 1050, CABA', N'privado/dni/prueba5.webp', N'profesor', '1995-05-09', 1);
    SET @id = SCOPE_IDENTITY();
    INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Esquemas, mapas conceptuales y mucha práctica para llegar tranquilo al examen.</p>');
    INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 6800);
    INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Profesora de Biología');
    INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre = N'Biología';
    INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre = N'Química';
    INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre = N'Presencial';
    INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre = N'Virtual';
    INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre = N'Secundaria';
    INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre = N'Colegio San Martín';
    INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre = N'ORT Argentina';
END
GO

-- Martín Acosta (profesor)
DECLARE @mail NVARCHAR(150), @id INT;
SET @mail = N'martin.acosta@prueba.mip';
IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE mail = @mail)
BEGIN
    INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
    VALUES (N'Martín', N'Acosta', @mail, N'pbkdf2$100000$xRYe1pacNJnUb12dij0pvQ==$BwE8fg18KUPo9jrRhgJfCSsmIduAoaXML2SmXL96W1c=', N'30111006', N'Av. Corrientes 1060, CABA', N'privado/dni/prueba6.webp', N'profesor', '1987-09-17', 1);
    SET @id = SCOPE_IDENTITY();
    INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Desarrollador back-end. De tu primer algoritmo a tu proyecto final de la facultad.</p>');
    INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 9000);
    INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Analista de Sistemas');
    INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre = N'Programación';
    INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre = N'Informática';
    INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre = N'Virtual';
    INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre = N'Secundaria';
    INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre = N'Universitario';
    INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre = N'Colegio Nacional de Buenos Aires';
    INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre = N'ORT Argentina';
END
GO

-- Lucía Benítez (profesor)
DECLARE @mail NVARCHAR(150), @id INT;
SET @mail = N'lucia.benitez@prueba.mip';
IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE mail = @mail)
BEGIN
    INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
    VALUES (N'Lucía', N'Benítez', @mail, N'pbkdf2$100000$tDW8D7SROlIUmBl7hKAXAA==$S3SYK81CwPbbxfinJvYZxLKIC+UWl+xk0R1d5xufaN4=', N'30111007', N'Av. Corrientes 1070, CABA', N'privado/dni/prueba7.webp', N'profesor', '1992-02-12', 0);
    SET @id = SCOPE_IDENTITY();
    INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Comprensión lectora y escritura con juegos, lecturas cortas y mucha paciencia.</p>');
    INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 5500);
    INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Profesora de Letras');
    INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre = N'Lengua y Literatura';
    INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre = N'Virtual';
    INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre = N'Primaria';
    INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre = N'Belgrano Day School';
END
GO

-- Tomás Herrera (profesor)
DECLARE @mail NVARCHAR(150), @id INT;
SET @mail = N'tomas.herrera@prueba.mip';
IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE mail = @mail)
BEGIN
    INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
    VALUES (N'Tomás', N'Herrera', @mail, N'pbkdf2$100000$n6pKsgM6ST6Wy5e7cR5oEQ==$P82tu/KXld/eYfrko26MJk1DNw+/eW9JQKx/GSOJR2E=', N'30111008', N'Av. Corrientes 1080, CABA', N'privado/dni/prueba8.webp', N'profesor', '1989-06-25', 0);
    SET @id = SCOPE_IDENTITY();
    INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Líneas de tiempo y resúmenes claros para entender los procesos, no solo memorizar fechas.</p>');
    INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 5800);
    INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Profesor de Historia');
    INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre = N'Historia';
    INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre = N'Geografía';
    INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre = N'Presencial';
    INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre = N'Secundaria';
    INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre = N'Colegio San Martín';
END
GO

-- Agustina Lombardi (profesor)
DECLARE @mail NVARCHAR(150), @id INT;
SET @mail = N'agustina.lombardi@prueba.mip';
IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE mail = @mail)
BEGIN
    INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
    VALUES (N'Agustina', N'Lombardi', @mail, N'pbkdf2$100000$RM5WwU/hmYSfzkMkSMqVpQ==$e3lqrpoEFK0gIT09ZKq+axrbtZT+yKjdHf49F/p3JRo=', N'30111009', N'Av. Corrientes 1090, CABA', N'privado/dni/prueba9.webp', N'profesor', '1994-08-03', 1);
    SET @id = SCOPE_IDENTITY();
    INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Contadora. Te explico economía y contabilidad con casos reales y ejercicios de examen.</p>');
    INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 8500);
    INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Contadora Pública (UBA)');
    INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre = N'Economía';
    INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre = N'Contabilidad';
    INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre = N'Virtual';
    INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre = N'Secundaria';
    INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre = N'Universitario';
    INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre = N'Escuela Superior de Comercio Carlos Pellegrini';
END
GO

-- Federico Salazar (profesor)
DECLARE @mail NVARCHAR(150), @id INT;
SET @mail = N'federico.salazar@prueba.mip';
IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE mail = @mail)
BEGIN
    INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
    VALUES (N'Federico', N'Salazar', @mail, N'pbkdf2$100000$kTAPH66SEH6BlOtKO0Fl/w==$pMaosgrllJ4te4vlU1bwZCwmURxDdMoq8IG5AZyNIM4=', N'30111010', N'Av. Corrientes 1100, CABA', N'privado/dni/prueba10.webp', N'profesor', '1986-12-01', 1);
    SET @id = SCOPE_IDENTITY();
    INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Análisis, álgebra y estadística para el CBC y primeros años de facultad.</p>');
    INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 9500);
    INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Licenciado en Matemática');
    INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre = N'Matemática';
    INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre = N'Estadística';
    INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre = N'Presencial';
    INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre = N'Virtual';
    INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre = N'Universitario';
    INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre = N'Colegio Nacional de Buenos Aires';
END
GO

-- Micaela Duarte (profesor)
DECLARE @mail NVARCHAR(150), @id INT;
SET @mail = N'micaela.duarte@prueba.mip';
IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE mail = @mail)
BEGIN
    INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
    VALUES (N'Micaela', N'Duarte', @mail, N'pbkdf2$100000$RHqeGrNf6+P7lmGxSIY5HA==$wzi1DYiaQjUFKthgReN5IR76xnuvSfJ+fPobw0fb1Ds=', N'30111011', N'Av. Corrientes 1110, CABA', N'privado/dni/prueba11.webp', N'profesor', '1996-04-18', 0);
    SET @id = SCOPE_IDENTITY();
    INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Idiomas con canciones, videos y conversación desde la primera clase.</p>');
    INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 6000);
    INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Profesora de Idiomas');
    INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre = N'Francés';
    INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre = N'Portugués';
    INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre = N'Virtual';
    INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre = N'Primaria';
    INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre = N'Secundaria';
    INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre = N'Northlands';
    INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre = N'St. George''s College';
END
GO

-- Nicolás Ibarra (profesor)
DECLARE @mail NVARCHAR(150), @id INT;
SET @mail = N'nicolas.ibarra@prueba.mip';
IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE mail = @mail)
BEGIN
    INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
    VALUES (N'Nicolás', N'Ibarra', @mail, N'pbkdf2$100000$6BO9IJ+QxFoCSMWLJIr8Nw==$TzS7oW07dALtjszBNUxEpI0Q1uTJiy8hLMGm5+XAYfE=', N'30111012', N'Av. Corrientes 1120, CABA', N'privado/dni/prueba12.webp', N'profesor', '1990-10-27', 1);
    SET @id = SCOPE_IDENTITY();
    INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Física del secundario sin fórmulas de memoria: entender primero, calcular después.</p>');
    INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 7200);
    INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Profesor de Física');
    INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre = N'Física';
    INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre = N'Presencial';
    INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre = N'Secundaria';
    INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre = N'Escuela Superior de Comercio Carlos Pellegrini';
    INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre = N'Colegio Nacional de Buenos Aires';
END
GO

-- Brenda Quiroga (profesor)
DECLARE @mail NVARCHAR(150), @id INT;
SET @mail = N'brenda.quiroga@prueba.mip';
IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE mail = @mail)
BEGIN
    INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
    VALUES (N'Brenda', N'Quiroga', @mail, N'pbkdf2$100000$ZDS/LMpdX/jlE458xrqB0w==$Bi/wf0EyB3tANQ9RCnAOle9EVlUuK5SYqGuuSfEiTlo=', N'30111013', N'Av. Corrientes 1130, CABA', N'privado/dni/prueba13.webp', N'profesor', '1997-03-05', 0);
    SET @id = SCOPE_IDENTITY();
    INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Ayudo a armar trabajos prácticos y a estudiar para los orales de Filosofía y Ética.</p>');
    INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 5200);
    INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Profesora de Filosofía');
    INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre = N'Filosofía';
    INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre = N'Formación Ética y Ciudadana';
    INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre = N'Presencial';
    INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre = N'Virtual';
    INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre = N'Secundaria';
    INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre = N'Belgrano Day School';
    INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre = N'St. George''s College';
END
GO

-- Gonzalo Ferrari (profesor)
DECLARE @mail NVARCHAR(150), @id INT;
SET @mail = N'gonzalo.ferrari@prueba.mip';
IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE mail = @mail)
BEGIN
    INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
    VALUES (N'Gonzalo', N'Ferrari', @mail, N'pbkdf2$100000$jI4a7E9ZtfB1tLRbzMnCCw==$cybVuORCA2cHyYJ+2u9HTWrQ34fbMMhvbjHWOoAhPrQ=', N'30111014', N'Av. Corrientes 1140, CABA', N'privado/dni/prueba14.webp', N'profesor', '1985-01-19', 0);
    SET @id = SCOPE_IDENTITY();
    INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Guitarra, teoría musical y dibujo para los que quieren aprender haciendo.</p>');
    INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 5000);
    INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Profesor de Música');
    INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre = N'Música';
    INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre = N'Dibujo y Arte';
    INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre = N'Presencial';
    INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre = N'Primaria';
    INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre = N'Secundaria';
    INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre = N'St. George''s College';
    INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre = N'Northlands';
END
GO

-- Julieta Navarro (profesor)
DECLARE @mail NVARCHAR(150), @id INT;
SET @mail = N'julieta.navarro@prueba.mip';
IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE mail = @mail)
BEGIN
    INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
    VALUES (N'Julieta', N'Navarro', @mail, N'pbkdf2$100000$RpEObkytapP3unXwye2cyg==$mvjqRxvJRYie/Zv9mq2kxWxgs6GkrvVSbeahQc1j+zE=', N'30111015', N'Av. Corrientes 1150, CABA', N'privado/dni/prueba15.webp', N'profesor', '1991-07-30', 1);
    SET @id = SCOPE_IDENTITY();
    INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Maestra de grado. Matemática de primaria con material concreto y mucho juego.</p>');
    INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 5500);
    INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Maestra Normal Superior');
    INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre = N'Matemática';
    INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre = N'Presencial';
    INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre = N'Virtual';
    INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre = N'Primaria';
    INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre = N'Belgrano Day School';
    INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre = N'Northlands';
END
GO

-- Ramiro Vega (profesor)
DECLARE @mail NVARCHAR(150), @id INT;
SET @mail = N'ramiro.vega@prueba.mip';
IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE mail = @mail)
BEGIN
    INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
    VALUES (N'Ramiro', N'Vega', @mail, N'pbkdf2$100000$sgTyiOb7GzJmAeZ8Rm9Wrw==$FUQDXmCwA9c97iIOE69EwaSujVk2Mw0PwXjahjC5BNI=', N'30111016', N'Av. Corrientes 1160, CABA', N'privado/dni/prueba16.webp', N'profesor', '1998-05-22', 0);
    SET @id = SCOPE_IDENTITY();
    INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Estudiante avanzado de sistemas. Te ayudo con HTML, Python y trabajos prácticos.</p>');
    INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 6200);
    INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Técnico en Programación');
    INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre = N'Informática';
    INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre = N'Programación';
    INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre = N'Virtual';
    INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre = N'Secundaria';
    INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre = N'ORT Argentina';
END
GO

-- Mateo Gómez (alumno)
DECLARE @mail NVARCHAR(150), @id INT;
SET @mail = N'mateo.gomez@prueba.mip';
IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE mail = @mail)
BEGIN
    INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
    VALUES (N'Mateo', N'Gómez', @mail, N'pbkdf2$100000$JFAtYZNEiLXl4986s68wgQ==$JYJd/cFmIn4mzCW3BWUhWpNbmgwdV0Kao0SWU0M6VsA=', N'40111001', N'Av. Corrientes 2000, CABA', N'privado/dni/prueba100.webp', N'alumno', '2009-04-10', 1);
    SET @id = SCOPE_IDENTITY();
    INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Alumno de secundaria que busca ayuda para rendir bien.</p>');
    INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre = N'Secundaria';
    INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre = N'Belgrano Day School';
END
GO

-- Carolina Suárez (alumno)
DECLARE @mail NVARCHAR(150), @id INT;
SET @mail = N'carolina.suarez@prueba.mip';
IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE mail = @mail)
BEGIN
    INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
    VALUES (N'Carolina', N'Suárez', @mail, N'pbkdf2$100000$B8qR0A+mkV0BbWMigr3A8Q==$DZ3CH8JrRIGf31JGppWzNAc/bzosG5xC9afysqQ1uBo=', N'40111002', N'Av. Corrientes 2010, CABA', N'privado/dni/prueba101.webp', N'alumno', '2008-09-15', 1);
    SET @id = SCOPE_IDENTITY();
    INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Alumno de secundaria que busca ayuda para rendir bien.</p>');
    INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre = N'Secundaria';
    INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre = N'Colegio San Martín';
END
GO

-- ---------------------------------------------------------------------
-- Reseñas de prueba: Mateo y Carolina puntúan a los profesores verificados
-- (si ya existe una reseña de ese alumno a ese profesor no se repite).
-- ---------------------------------------------------------------------
INSERT INTO Resenas (idEmisor, idReceptor, estado, puntuacion, descripcion)
SELECT a.ID, p.ID, N'Aprobada', v.puntuacion, v.descripcion
FROM (VALUES
    (N'mateo.gomez@prueba.mip',     N'sofia.martinez@prueba.mip',       5, N'Explica clarísimo, aprobé el final.'),
    (N'carolina.suarez@prueba.mip', N'sofia.martinez@prueba.mip',       5, N'Muy paciente y ordenada.'),
    (N'mateo.gomez@prueba.mip',     N'lucas.gomez@prueba.mip',          5, N'Los problemas en vivo me ayudaron un montón.'),
    (N'carolina.suarez@prueba.mip', N'lucas.gomez@prueba.mip',          4, N'Muy bueno, a veces va rápido.'),
    (N'mateo.gomez@prueba.mip',     N'valentina.paz@prueba.mip',        5, N'Los esquemas son geniales.'),
    (N'mateo.gomez@prueba.mip',     N'martin.acosta@prueba.mip',        5, N'Me ayudó con mi primer proyecto.'),
    (N'carolina.suarez@prueba.mip', N'martin.acosta@prueba.mip',        5, N'Excelente profesor.'),
    (N'carolina.suarez@prueba.mip', N'agustina.lombardi@prueba.mip',    4, N'Muy buenos ejemplos.'),
    (N'mateo.gomez@prueba.mip',     N'federico.salazar@prueba.mip',     5, N'Entendí límites por fin.'),
    (N'carolina.suarez@prueba.mip', N'nicolas.ibarra@prueba.mip',       4, N'Clases dinámicas.'),
    (N'mateo.gomez@prueba.mip',     N'julieta.navarro@prueba.mip',      5, N'A mi hermana le encantó.'),
    (N'carolina.suarez@prueba.mip', N'camila.rossi@prueba.mip',         5, N'Mejoré mucho el speaking.')
) v(mailAlumno, mailProfesor, puntuacion, descripcion)
JOIN Usuarios a ON a.mail = v.mailAlumno
JOIN Usuarios p ON p.mail = v.mailProfesor
WHERE NOT EXISTS (SELECT 1 FROM Resenas r WHERE r.idEmisor = a.ID AND r.idReceptor = p.ID);
GO
