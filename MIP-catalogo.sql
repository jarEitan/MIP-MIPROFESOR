-- =====================================================================
-- MIP - Sistema de catálogo
-- Se puede ejecutar completo y más de una vez.
-- Contiene:
--   1. Niveles nuevos (Secundario 1 a 6, Terciario, Universitario), materias unificadas y escuelas/universidades de CABA.
--   2. SP obtenerCatalogo (profesores con filtros, búsqueda y paginación).
--   3. Cuentas de prueba: 48 profesores y 6 alumnos, con reseñas (solo para desarrollo).
-- Los selectores de materia, colegio, modalidad y nivel usan obtenerOpcionesPerfil (ya existente).
-- Ejecutar DESPUÉS de perfiles-completo.sql.
-- =====================================================================
USE [MIP]
GO

-- ---------------------------------------------------------------------
-- 1a. Niveles: se reemplazan Primaria / Secundaria / Universitario por la lista nueva.
--     Si ya existe "Secundario 1" no se toca nada (el script ya se ejecutó).
--     Los niveles elegidos antes por los usuarios se borran, porque ya no existen;
--     cada usuario tiene que volver a elegir el suyo en su perfil.
-- ---------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM Niveles WHERE nombre = N'Secundario 1')
BEGIN
    DELETE FROM Usuarios_Niveles;
    DELETE FROM Niveles;
END
GO
INSERT INTO Niveles (nombre)
SELECT v.nombre FROM (VALUES
    (N'Secundario 1'),
    (N'Secundario 2'),
    (N'Secundario 3'),
    (N'Secundario 4'),
    (N'Secundario 5'),
    (N'Secundario 6'),
    (N'Terciario'),
    (N'Universitario')
) v(nombre)
WHERE NOT EXISTS (SELECT 1 FROM Niveles n WHERE n.nombre = v.nombre);
GO

-- ---------------------------------------------------------------------
-- 1b. Materias del secundario de la Ciudad (diseño curricular de CABA), del terciario y de la universidad.
--     Las que solo cambian de nombre se unificaron en una:
--       Historia (argentina, mundial, latinoamericana) · Geografía · Lengua y Literatura (incluye Literatura y Comunicación)
--       Formación Ética y Ciudadana (incluye Construcción de Ciudadanía) · Tecnología y Robótica (incluye Educación Tecnológica)
--       Programación e Informática · Contabilidad y Administración · Dibujo y Arte (Plástica, Visual y Dibujo)
--     "Programación" e "Informática" se unen en una sola; los usuarios que tenían alguna quedan con la unificada.
-- ---------------------------------------------------------------------
UPDATE Materias SET nombre = N'Programación e Informática' WHERE nombre = N'Programación'
    AND NOT EXISTS (SELECT 1 FROM Materias WHERE nombre = N'Programación e Informática');
UPDATE Materias SET nombre = N'Contabilidad y Administración' WHERE nombre = N'Contabilidad'
    AND NOT EXISTS (SELECT 1 FROM Materias WHERE nombre = N'Contabilidad y Administración');
GO
IF EXISTS (SELECT 1 FROM Materias WHERE nombre = N'Informática') AND EXISTS (SELECT 1 FROM Materias WHERE nombre = N'Programación e Informática')
BEGIN
    DECLARE @idVieja INT = (SELECT ID FROM Materias WHERE nombre = N'Informática');
    DECLARE @idUnica INT = (SELECT ID FROM Materias WHERE nombre = N'Programación e Informática');
    UPDATE Usuarios_Materias SET idMateria = @idUnica
        WHERE idMateria = @idVieja
          AND NOT EXISTS (SELECT 1 FROM Usuarios_Materias x WHERE x.idUsuario = Usuarios_Materias.idUsuario AND x.idMateria = @idUnica);
    DELETE FROM Usuarios_Materias WHERE idMateria = @idVieja;
    DELETE FROM Materias WHERE ID = @idVieja;
END
GO
INSERT INTO Materias (nombre)
SELECT v.nombre FROM (VALUES
    (N'Matemática'),
    (N'Álgebra y Análisis'),
    (N'Estadística'),
    (N'Geometría y Dibujo Técnico'),
    (N'Física'),
    (N'Química'),
    (N'Biología'),
    (N'Anatomía y Fisiología'),
    (N'Ciencias Naturales'),
    (N'Ciencias de la Tierra'),
    (N'Lengua y Literatura'),
    (N'Latín'),
    (N'Inglés'),
    (N'Francés'),
    (N'Portugués'),
    (N'Italiano'),
    (N'Alemán'),
    (N'Historia'),
    (N'Geografía'),
    (N'Ciencias Políticas'),
    (N'Derecho'),
    (N'Sociología'),
    (N'Psicología'),
    (N'Antropología'),
    (N'Filosofía'),
    (N'Formación Ética y Ciudadana'),
    (N'Economía'),
    (N'Contabilidad y Administración'),
    (N'Programación e Informática'),
    (N'Tecnología y Robótica'),
    (N'Música'),
    (N'Dibujo y Arte'),
    (N'Teatro'),
    (N'Educación Física'),
    (N'Comunicación y Medios')
) v(nombre)
WHERE NOT EXISTS (SELECT 1 FROM Materias m WHERE m.nombre = v.nombre);
GO

-- ---------------------------------------------------------------------
-- 1c. El sistema funciona solo en la Ciudad de Buenos Aires: se sacan los colegios que están fuera
--     de CABA (Northlands es de Olivos y St. George's College de Quilmes) y a los usuarios que los
--     tenían elegidos se les quita ese colegio.
-- ---------------------------------------------------------------------
DELETE FROM Escuelas_Usuarios WHERE idEscuela IN (SELECT ID FROM Escuelas WHERE nombre IN (N'Northlands', N'St. George''s College'));
DELETE FROM Escuelas WHERE nombre IN (N'Northlands', N'St. George''s College');
GO

-- ---------------------------------------------------------------------
-- 1d. Escuelas, institutos y universidades de la Ciudad de Buenos Aires.
--     Una sola entrada por institución: si tiene varias sedes (UTN, UBA, ORT...) es un solo nombre.
--     No se duplican por nombre; se pueden agregar más.
-- ---------------------------------------------------------------------
INSERT INTO Escuelas (nombre)
SELECT v.nombre FROM (VALUES
    (N'Liceo Nº 1 José de San Martín'),
    (N'Colegio Mariano Moreno'),
    (N'Colegio Nicolás Avellaneda'),
    (N'Escuela Normal Superior Nº 1 Presidente Roque Sáenz Peña'),
    (N'Escuela Normal Superior Nº 2 Mariano Acosta'),
    (N'Escuela Normal Superior Nº 9 Domingo Faustino Sarmiento'),
    (N'Escuela Normal Superior Nº 10 Juan Bautista Alberdi'),
    (N'Escuela Normal Superior Nº 11 Ricardo Levene'),
    (N'Escuela Normal Superior en Lenguas Vivas Juan Ramón Fernández'),
    (N'Escuela Normal Superior en Lenguas Vivas Sofía Spangenberg'),
    (N'Escuela Técnica Otto Krause'),
    (N'Escuela Técnica Raggio'),
    (N'Escuela de Educación Media Nº 1 Hipólito Vieytes'),
    (N'Colegio del Salvador'),
    (N'Colegio Champagnat'),
    (N'Colegio Marianista'),
    (N'Colegio Jesús María'),
    (N'Colegio Santa Unión de los Sagrados Corazones'),
    (N'Colegio San Cirano'),
    (N'Colegio Esquiú'),
    (N'Instituto Libre de Segunda Enseñanza (ILSE)'),
    (N'Colegio Pestalozzi'),
    (N'Colegio Sagrado Corazón'),
    (N'Colegio Santa Catalina'),
    (N'Colegio Mater Admirabilis'),
    (N'Colegio San Agustín'),
    (N'Colegio San José'),
    (N'Colegio La Salle'),
    (N'Escuela Normal Superior Nº 4 Estanislao Zeballos'),
    (N'Escuela Normal Superior Nº 3 Bernardino Rivadavia'),
    (N'Escuela Normal Superior Nº 5 Juan Bautista Alberdi'),
    (N'Instituto Superior de Enseñanza Radiofónica (ISER)'),
    (N'Instituto Superior del Profesorado Joaquín V. González'),
    (N'Instituto de Enseñanza Superior en Lenguas Vivas Juan Ramón Fernández'),
    (N'Conservatorio Superior de Música Manuel de Falla'),
    (N'Instituto Tecnológico Beltrán'),
    (N'Escuela Superior de Hotelería y Turismo'),
    (N'Instituto Superior de Formación Docente Nº 1 Dr. Joaquín V. González'),
    (N'Instituto Superior de Educación Física Romero Brest'),
    (N'Instituto Vocacional de Arte Manuel Belgrano'),
    (N'Escuela Nacional de Danzas Aurora Lubroth'),
    (N'Instituto Superior de Arte del Teatro Colón'),
    (N'Universidad de Buenos Aires (UBA)'),
    (N'Universidad Tecnológica Nacional (UTN)'),
    (N'Pontificia Universidad Católica Argentina (UCA)'),
    (N'Universidad del Salvador (USAL)'),
    (N'Universidad Argentina de la Empresa (UADE)'),
    (N'Universidad de Belgrano'),
    (N'Universidad de Palermo'),
    (N'Universidad Torcuato Di Tella'),
    (N'Universidad Abierta Interamericana (UAI)'),
    (N'Universidad de Ciencias Empresariales y Sociales (UCES)'),
    (N'Universidad CAECE'),
    (N'Universidad Argentina John F. Kennedy'),
    (N'Universidad de Flores (UFLO)'),
    (N'Universidad Maimónides'),
    (N'Universidad Favaloro'),
    (N'Universidad ISALUD'),
    (N'Universidad del Cine (FUC)'),
    (N'Universidad del Museo Social Argentino (UMSA)'),
    (N'Universidad Nacional de las Artes (UNA)'),
    (N'Instituto Tecnológico de Buenos Aires (ITBA)'),
    (N'Instituto Universitario Hospital Italiano (IUHI)'),
    (N'Universidad del CEMA (UCEMA)'),
    (N'Universidad Hebrea Argentina Bar Ilán'),
    (N'Universidad de la Ciudad de Buenos Aires')
) v(nombre)
WHERE NOT EXISTS (SELECT 1 FROM Escuelas e WHERE e.nombre = v.nombre);
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

-- ---------------------------------------------------------------------
-- 3. CUENTAS DE PRUEBA (solo para desarrollo; borrarlas antes de publicar el sitio)
--    Mails @prueba.mip, contraseña  Prueba123.
--    Cada ejecución las borra y las vuelve a crear, así quedan siempre con los niveles y escuelas actuales.
--    Sin fotos: el sitio muestra las iniciales.
-- ---------------------------------------------------------------------
DECLARE @pruebas TABLE (id INT PRIMARY KEY);
INSERT INTO @pruebas SELECT ID FROM Usuarios WHERE mail LIKE N'%@prueba.mip';

DELETE FROM Mensajes WHERE idEmisor IN (SELECT id FROM @pruebas) OR idChat IN (SELECT ID FROM Chats WHERE idUsuario1 IN (SELECT id FROM @pruebas) OR idUsuario2 IN (SELECT id FROM @pruebas));
DELETE FROM Chats WHERE idUsuario1 IN (SELECT id FROM @pruebas) OR idUsuario2 IN (SELECT id FROM @pruebas);
DELETE FROM Likes WHERE idEmisor IN (SELECT id FROM @pruebas) OR idReceptor IN (SELECT id FROM @pruebas);
DELETE FROM Amigos WHERE idUsuario1 IN (SELECT id FROM @pruebas) OR idUsuario2 IN (SELECT id FROM @pruebas);
DELETE FROM Resenas WHERE idEmisor IN (SELECT id FROM @pruebas) OR idReceptor IN (SELECT id FROM @pruebas);
DELETE FROM Clases WHERE idEmisor IN (SELECT id FROM @pruebas) OR idReceptor IN (SELECT id FROM @pruebas);
DELETE FROM Notificaciones WHERE idUsuario IN (SELECT id FROM @pruebas);
DELETE FROM Consultas_Soporte WHERE idUsuario IN (SELECT id FROM @pruebas);
DELETE FROM Escuelas_Usuarios WHERE idUsuario IN (SELECT id FROM @pruebas);
DELETE FROM Usuarios_Niveles WHERE idUsuario IN (SELECT id FROM @pruebas);
DELETE FROM Usuarios_Materias WHERE idUsuario IN (SELECT id FROM @pruebas);
DELETE FROM Profesores_Modalidades WHERE idUsuario IN (SELECT id FROM @pruebas);
DELETE FROM Titulos WHERE idUsuario IN (SELECT id FROM @pruebas);
DELETE FROM InfoProfesores WHERE idUsuario IN (SELECT id FROM @pruebas);
DELETE FROM Perfiles WHERE idUsuario IN (SELECT id FROM @pruebas);
DELETE FROM Usuarios WHERE ID IN (SELECT id FROM @pruebas);
GO

-- Sofía Martínez (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Sofía', N'Martínez', N'sofia.martinez@prueba.mip', N'pbkdf2$100000$h6jG7fmaYV0L+i29N59EtA==$L+dn+bnPssbmc3y5MCQY6HXH83GghYOXjUqYpz+kRTA=', N'30111001', N'Av. Corrientes 1010, CABA', N'privado/dni/prueba1.webp', N'profesor', '1975-01-01', 1);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>6 años preparando exámenes de ingreso y finales. Explico paso a paso, sin apuro.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 8000);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Profesora de Matemática (UBA)');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Matemática', N'Álgebra y Análisis');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Presencial');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 3', N'Secundario 4', N'Secundario 5');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Belgrano Day School', N'Colegio San Martín');
GO

-- Lucas Gómez (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Lucas', N'Gómez', N'lucas.gomez@prueba.mip', N'pbkdf2$100000$3vu5YrSN6LMMNprP8FeUVA==$khMNko7KGEVfnnDIZHj94xx/GcVI9MJ59IOB2JRG79w=', N'30111002', N'Av. Corrientes 1020, CABA', N'privado/dni/prueba2.webp', N'profesor', '1978-02-08', 1);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Ingeniero y docente. Problemas resueltos en vivo y apuntes alineados al programa del colegio.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 7500);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Ingeniero Industrial (UTN)');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Física', N'Matemática');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Virtual');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 4', N'Secundario 5', N'Secundario 6', N'Universitario');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Colegio San Martín', N'Universidad Tecnológica Nacional (UTN)');
GO

-- Camila Rossi (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Camila', N'Rossi', N'camila.rossi@prueba.mip', N'pbkdf2$100000$A83Ixi2FPtA7uQiqM+iDpQ==$JWPxrAMGscUyeUp92HA6KzKTvvL3wDuL6TT5eYbQtZw=', N'30111003', N'Av. Corrientes 1030, CABA', N'privado/dni/prueba3.webp', N'profesor', '1981-03-15', 0);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Conversación, gramática y preparación de exámenes internacionales en un solo lugar.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 6500);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Traductora Pública de Inglés');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Inglés');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Presencial', N'Virtual');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 1', N'Secundario 2', N'Secundario 3');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Colegio Nacional de Buenos Aires', N'Colegio San Martín');
GO

-- Joaquín Fernández (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Joaquín', N'Fernández', N'joaquin.fernandez@prueba.mip', N'pbkdf2$100000$nmGeglXKhWs6PofbQ9BTAw==$v4Ozsp27SpENG/r9ItQiBHnA8CROIHidqTRTphT3qhk=', N'30111004', N'Av. Corrientes 1040, CABA', N'privado/dni/prueba4.webp', N'profesor', '1984-04-22', 0);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Laboratorio y teoría sin miedo: estequiometría, soluciones y química orgánica.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 7000);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Licenciado en Química');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Química');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Presencial');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 4', N'Secundario 5');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Belgrano Day School');
GO

-- Valentina Paz (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Valentina', N'Paz', N'valentina.paz@prueba.mip', N'pbkdf2$100000$c/bdzVkHwuf9o+AT4ypvMA==$VFvr/Z5UZinsIR8uTATsQi6kZONAKMnfFUn1erDgfpk=', N'30111005', N'Av. Corrientes 1050, CABA', N'privado/dni/prueba5.webp', N'profesor', '1987-05-01', 1);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Esquemas, mapas conceptuales y mucha práctica para llegar tranquilo al examen.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 6800);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Profesora de Biología');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Biología', N'Química');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Presencial', N'Virtual');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 3', N'Secundario 4', N'Secundario 5');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Colegio San Martín', N'ORT Argentina');
GO

-- Martín Acosta (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Martín', N'Acosta', N'martin.acosta@prueba.mip', N'pbkdf2$100000$a9KIgHZjf1AupemNbEdEdg==$0+w96GvfppY6Q3cFVMyRnuAehshhXhP2CB4A/EA9mjA=', N'30111006', N'Av. Corrientes 1060, CABA', N'privado/dni/prueba6.webp', N'profesor', '1990-06-08', 1);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Desarrollador back-end. De tu primer algoritmo a tu proyecto final de la facultad.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 9000);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Analista de Sistemas');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Programación e Informática');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Virtual');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 5', N'Secundario 6', N'Universitario');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Colegio Nacional de Buenos Aires', N'ORT Argentina', N'Universidad Tecnológica Nacional (UTN)');
GO

-- Lucía Benítez (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Lucía', N'Benítez', N'lucia.benitez@prueba.mip', N'pbkdf2$100000$oVtrNceT2L0B1zI7hx6SMA==$SQsi2blGZ9NPVPDABL+vjAwQ2DPJvL57tCfujIOzuj0=', N'30111007', N'Av. Corrientes 1070, CABA', N'privado/dni/prueba7.webp', N'profesor', '1993-07-15', 0);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Comprensión lectora y escritura con juegos, lecturas cortas y mucha paciencia.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 5500);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Profesora de Letras');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Lengua y Literatura');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Virtual');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 1', N'Secundario 2');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Belgrano Day School');
GO

-- Tomás Herrera (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Tomás', N'Herrera', N'tomas.herrera@prueba.mip', N'pbkdf2$100000$aYdPLBXbmjqnQHIVz/30Nw==$WfxYSbSRsdaWuPD9Avmzbw9Lu+sQQ7LZFvalGttqgp4=', N'30111008', N'Av. Corrientes 1080, CABA', N'privado/dni/prueba8.webp', N'profesor', '1996-08-22', 0);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Líneas de tiempo y resúmenes claros para entender los procesos, no solo memorizar fechas.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 5800);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Profesor de Historia');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Historia', N'Geografía');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Presencial');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 3', N'Secundario 4');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Colegio San Martín');
GO

-- Agustina Lombardi (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Agustina', N'Lombardi', N'agustina.lombardi@prueba.mip', N'pbkdf2$100000$cYuF86S4YvusS/jQ2MTcSg==$aGUs6sM55IQqgE2u7gbm3PAANV7VzGWpfLngzeDn0C0=', N'30111009', N'Av. Corrientes 1090, CABA', N'privado/dni/prueba9.webp', N'profesor', '1999-09-01', 1);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Contadora. Te explico economía y contabilidad con casos reales y ejercicios de examen.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 8500);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Contadora Pública (UBA)');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Economía', N'Contabilidad y Administración');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Virtual');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 5', N'Secundario 6', N'Universitario');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Escuela Superior de Comercio Carlos Pellegrini', N'Universidad de Buenos Aires (UBA)');
GO

-- Federico Salazar (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Federico', N'Salazar', N'federico.salazar@prueba.mip', N'pbkdf2$100000$6QrgLSHJP4pwGD1A2AJP6A==$HydWNOeHgkZImCRdDe82EDsrujv8Fsr1DObr3HZTCNU=', N'30111010', N'Av. Corrientes 1100, CABA', N'privado/dni/prueba10.webp', N'profesor', '1977-10-08', 1);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Análisis, álgebra y estadística para el CBC y primeros años de facultad.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 9500);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Licenciado en Matemática');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Matemática', N'Estadística');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Presencial', N'Virtual');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Universitario');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Colegio Nacional de Buenos Aires', N'Universidad de Buenos Aires (UBA)');
GO

-- Micaela Duarte (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Micaela', N'Duarte', N'micaela.duarte@prueba.mip', N'pbkdf2$100000$xGbmbd8S5/5MDf0GbdT+kg==$P0xZwtKGtMNMoVsMZUAzQ3hqFBcvl+14YdBlz7+OZGU=', N'30111011', N'Av. Corrientes 1110, CABA', N'privado/dni/prueba11.webp', N'profesor', '1980-11-15', 0);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Idiomas con canciones, videos y conversación desde la primera clase.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 6000);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Profesora de Idiomas');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Francés', N'Portugués');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Virtual');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 1', N'Secundario 2', N'Secundario 3');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Colegio San Martín', N'Belgrano Day School');
GO

-- Nicolás Ibarra (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Nicolás', N'Ibarra', N'nicolas.ibarra@prueba.mip', N'pbkdf2$100000$rMnaE+iC3CWe/+HG5b43OA==$CMCmv3Mb3MD4A7WxCTQyFHeag/ToD61QLHlz8WLSjsI=', N'30111012', N'Av. Corrientes 1120, CABA', N'privado/dni/prueba12.webp', N'profesor', '1983-12-22', 1);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Física del secundario sin fórmulas de memoria: entender primero, calcular después.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 7200);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Profesor de Física');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Física');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Presencial');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 4', N'Secundario 5', N'Secundario 6');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Escuela Superior de Comercio Carlos Pellegrini', N'Colegio Nacional de Buenos Aires');
GO

-- Brenda Quiroga (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Brenda', N'Quiroga', N'brenda.quiroga@prueba.mip', N'pbkdf2$100000$v5hJU7jyaCcdGnCbBDpk/g==$Y3o5knsZ0C3e6Q/UOPuwnw/6UgTUtNoYkmpNolrZVLo=', N'30111013', N'Av. Corrientes 1130, CABA', N'privado/dni/prueba13.webp', N'profesor', '1986-01-01', 0);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Ayudo a armar trabajos prácticos y a estudiar para los orales de Filosofía y Ética.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 5200);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Profesora de Filosofía');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Filosofía', N'Formación Ética y Ciudadana');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Presencial', N'Virtual');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 5', N'Secundario 6');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Belgrano Day School');
GO

-- Gonzalo Ferrari (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Gonzalo', N'Ferrari', N'gonzalo.ferrari@prueba.mip', N'pbkdf2$100000$psJ76D8GnGBQquRhdi/vyg==$hbod6NsFdXOQW4PI2elMQd5MsWM7wAZbqoatfxS8elo=', N'30111014', N'Av. Corrientes 1140, CABA', N'privado/dni/prueba14.webp', N'profesor', '1989-02-08', 0);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Guitarra, teoría musical y dibujo para los que quieren aprender haciendo.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 5000);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Profesor de Música');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Música', N'Dibujo y Arte');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Presencial');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 1', N'Secundario 2', N'Terciario');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Belgrano Day School', N'Colegio San Martín', N'Conservatorio Superior de Música Manuel de Falla');
GO

-- Julieta Navarro (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Julieta', N'Navarro', N'julieta.navarro@prueba.mip', N'pbkdf2$100000$YQKF91eIYEIt9m8rntzwaQ==$ksXVOpTi41H24GnhKbNj/Fr3B+Tc4jwkyoMbf5VHpt0=', N'30111015', N'Av. Corrientes 1150, CABA', N'privado/dni/prueba15.webp', N'profesor', '1992-03-15', 1);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Maestra de grado. Matemática de los primeros años con material concreto y mucho juego.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 5500);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Maestra Normal Superior');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Matemática');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Presencial', N'Virtual');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 1', N'Secundario 2');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Belgrano Day School', N'Colegio San Martín');
GO

-- Ramiro Vega (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Ramiro', N'Vega', N'ramiro.vega@prueba.mip', N'pbkdf2$100000$toqt1vV8atO7oV7x2qg9yA==$zgk41cgfd8AKMJrn2Jj7YEPGF7HOjQbTTzaCqMNpMGk=', N'30111016', N'Av. Corrientes 1160, CABA', N'privado/dni/prueba16.webp', N'profesor', '1995-04-22', 0);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Estudiante avanzado de sistemas. Te ayudo con HTML, Python y trabajos prácticos.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 6200);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Técnico en Programación');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Programación e Informática');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Virtual');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 4', N'Secundario 5');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'ORT Argentina');
GO

-- Anabela Domínguez (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Anabela', N'Domínguez', N'anabela.dominguez@prueba.mip', N'pbkdf2$100000$QWRyfmqvX6NrlG4R7n25dQ==$Kyw4lpHpWfNXoE5j0jk16j81KlpTuy2CMkoKvL0cy0g=', N'30111017', N'Av. Corrientes 1170, CABA', N'privado/dni/prueba17.webp', N'profesor', '1998-05-01', 1);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Matemática con ejercicios graduados: de lo básico a los problemas de examen.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 9500);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Profesor de Matemática');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Matemática');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Presencial');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 3', N'Secundario 4', N'Secundario 5');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Escuela Normal Superior en Lenguas Vivas Sofía Spangenberg', N'Colegio San Agustín');
GO

-- Bruno Ibáñez (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Bruno', N'Ibáñez', N'bruno.ibanez@prueba.mip', N'pbkdf2$100000$Djydxh7soy2yGpyl4WpVAA==$yLM5pTL4fEcDQROePq4KTgOKuYvu772Cwmle9UZ8zto=', N'30111018', N'Av. Corrientes 1180, CABA', N'privado/dni/prueba18.webp', N'profesor', '1976-06-08', 0);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Física y matemática con experimentos caseros y problemas resueltos.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 5000);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Licenciado en Física');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Física', N'Matemática');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Presencial', N'Virtual');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 5', N'Secundario 6', N'Terciario');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Escuela Normal Superior Nº 2 Mariano Acosta', N'Escuela Nacional de Danzas Aurora Lubroth');
GO

-- Cecilia Núñez (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Cecilia', N'Núñez', N'cecilia.nunez@prueba.mip', N'pbkdf2$100000$07txnEU86POtXaTssvp/og==$1kpHsGvXrTRs/51iNGUnk8jLPtzhvInsE5lMlBZyess=', N'30111019', N'Av. Corrientes 1190, CABA', N'privado/dni/prueba19.webp', N'profesor', '1979-07-15', 0);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Ciencias naturales con esquemas y repaso antes de cada prueba.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 6000);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Profesor de Ciencias Naturales');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Química', N'Biología');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Virtual');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 1', N'Secundario 2', N'Secundario 3', N'Secundario 4', N'Secundario 5', N'Secundario 6');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Escuela Normal Superior Nº 1 Presidente Roque Sáenz Peña', N'Colegio Nacional de Buenos Aires');
GO

-- Damián Sosa (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Damián', N'Sosa', N'damian.sosa@prueba.mip', N'pbkdf2$100000$0DWgFHwQBOWvMgcei2Ioow==$QmgDxO+/LXXQURL9hIDpYgzvg2+Xtgtb/6UqYF05bsQ=', N'30111020', N'Av. Corrientes 1200, CABA', N'privado/dni/prueba20.webp', N'profesor', '1982-08-22', 1);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Inglés para el colegio, exámenes internacionales y conversación.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 7500);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Profesora de Inglés');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Inglés');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Virtual');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 4', N'Secundario 5', N'Secundario 6');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Escuela Normal Superior Nº 9 Domingo Faustino Sarmiento');
GO

-- Elena Yáñez (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Elena', N'Yáñez', N'elena.yanez@prueba.mip', N'pbkdf2$100000$KT8mELhXZhnOpjQ+7cJ18A==$jb392uxZz9LxG4fFVcKXWdt2pRb2XJh5wXk5Oxkj+lM=', N'30111021', N'Av. Corrientes 1210, CABA', N'privado/dni/prueba21.webp', N'profesor', '1985-09-01', 0);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Lectura, escritura y comprensión de textos, con foco en los trabajos del colegio.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 7500);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Profesora de Letras');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Lengua y Literatura');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Presencial');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Terciario', N'Universitario');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Escuela Normal Superior Nº 2 Mariano Acosta', N'Colegio Marianista', N'Instituto de Enseñanza Superior en Lenguas Vivas Juan Ramón Fernández', N'Universidad del Museo Social Argentino (UMSA)');
GO

-- Fabricio Delgado (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Fabricio', N'Delgado', N'fabricio.delgado@prueba.mip', N'pbkdf2$100000$ElEsxhK7edGXaUjk8JHunA==$LaaBuhLnv9+Nvviw5+niwnuc3/xH4Jg8pSpPKjoA8wQ=', N'30111022', N'Av. Corrientes 1220, CABA', N'privado/dni/prueba22.webp', N'profesor', '1988-10-08', 0);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Historia y geografía con mapas, líneas de tiempo y resúmenes claros.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 5000);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Profesor de Historia');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Historia', N'Geografía');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Presencial', N'Virtual');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 1', N'Secundario 2', N'Secundario 3');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'ORT Argentina');
GO

-- Gimena Bustos (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Gimena', N'Bustos', N'gimena.bustos@prueba.mip', N'pbkdf2$100000$3KT0yBAopmq3FewzwJ0jvA==$sLfCURY6gYjclLxAJuK6eTBgmC+dSkIxKk/arKmbNiQ=', N'30111023', N'Av. Corrientes 1230, CABA', N'privado/dni/prueba23.webp', N'profesor', '1991-11-15', 1);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Programación desde cero: lógica, Python y proyectos pequeños.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 9000);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Técnico Universitario en Programación');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Programación e Informática');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Presencial', N'Virtual');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 1', N'Secundario 2');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Escuela Normal Superior Nº 1 Presidente Roque Sáenz Peña');
GO

-- Hernán Giménez (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Hernán', N'Giménez', N'hernan.gimenez@prueba.mip', N'pbkdf2$100000$8zrNdGQzAcOxzRhAO0FD8Q==$WMJJWyJDQdqVip0GZIU98BqSCgm2VteNe/6UHDRqFWA=', N'30111024', N'Av. Corrientes 1240, CABA', N'privado/dni/prueba24.webp', N'profesor', '1994-12-22', 0);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Economía y contabilidad explicadas con ejemplos de la vida diaria.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 8500);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Licenciado en Administración');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Economía', N'Contabilidad y Administración');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Virtual');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Universitario');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Colegio San Agustín', N'Escuela Normal Superior Nº 1 Presidente Roque Sáenz Peña', N'Colegio Champagnat', N'Universidad Tecnológica Nacional (UTN)');
GO

-- Irina Luna (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Irina', N'Luna', N'irina.luna@prueba.mip', N'pbkdf2$100000$UG6dWh4ydWE/38yrUvmGPg==$xPLKM8zwKLCjdWMMIFk6gke3Njm64HEm+grzrMZF0+k=', N'30111025', N'Av. Corrientes 1250, CABA', N'privado/dni/prueba25.webp', N'profesor', '1997-01-01', 0);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Estadística y análisis para los primeros años de facultad.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 7500);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Licenciada en Estadística');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Estadística', N'Álgebra y Análisis');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Presencial');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 3', N'Secundario 4', N'Secundario 5');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Colegio San Cirano');
GO

-- Julián Quintana (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Julián', N'Quintana', N'julian.quintana@prueba.mip', N'pbkdf2$100000$GZQXjG1n1GoSPlCS8/urjg==$d4zXkpBsj7OoR74eQrTzQDWuuMej7kQI71q0IgZrclM=', N'30111026', N'Av. Corrientes 1260, CABA', N'privado/dni/prueba26.webp', N'profesor', '1975-02-08', 1);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Psicología y sociología para el secundario y el CBC, con casos y resúmenes.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 9000);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Licenciada en Psicología');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Psicología', N'Sociología');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Presencial');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 5', N'Secundario 6', N'Terciario');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Belgrano Day School', N'Instituto de Enseñanza Superior en Lenguas Vivas Juan Ramón Fernández');
GO

-- Karina Villalba (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Karina', N'Villalba', N'karina.villalba@prueba.mip', N'pbkdf2$100000$KGCy8X1EJb6HWFkf5mPNXA==$HcnrA0T2vCtmInBxfI76vJqQbm9Vb4ETkwlXfxuUvDk=', N'30111027', N'Av. Corrientes 1270, CABA', N'privado/dni/prueba27.webp', N'profesor', '1978-03-15', 0);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Derecho y ciencias políticas para el secundario y primeros años de facultad.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 5000);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Abogado (UBA)');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Derecho', N'Ciencias Políticas');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Presencial', N'Virtual');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 1', N'Secundario 2', N'Secundario 3', N'Secundario 4', N'Secundario 5', N'Secundario 6');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Colegio San Martín', N'Escuela Técnica Raggio');
GO

-- Leandro Benavídez (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Leandro', N'Benavídez', N'leandro.benavidez@prueba.mip', N'pbkdf2$100000$dPrwRQzzAebA4UAOjjkFDQ==$TbKlBBu6+TFSpAv6hl6XW3jkwNjJeMqg3cz3HexhQs4=', N'30111028', N'Av. Corrientes 1280, CABA', N'privado/dni/prueba28.webp', N'profesor', '1981-04-22', 0);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Italiano y alemán desde cero, con conversación y gramática.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 5000);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Profesora de Idiomas');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Italiano', N'Alemán');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Virtual');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 4', N'Secundario 5', N'Secundario 6');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'ORT Argentina', N'Escuela de Educación Media Nº 1 Hipólito Vieytes', N'Colegio Santa Catalina');
GO

-- Marina Godoy (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Marina', N'Godoy', N'marina.godoy@prueba.mip', N'pbkdf2$100000$7laH10iy9ivj2Ra3n/YIlQ==$A2AyloKM9J911qMyq/AccOUqAMUKXCC2vJ4/OHf9Nro=', N'30111029', N'Av. Corrientes 1290, CABA', N'privado/dni/prueba29.webp', N'profesor', '1984-05-01', 1);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Tecnología, electrónica y robótica con proyectos que se arman en clase.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 8000);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Ingeniero Electrónico');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Tecnología y Robótica');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Virtual');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Terciario', N'Universitario');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Escuela Normal Superior Nº 2 Mariano Acosta', N'ORT Argentina', N'Escuela Normal Superior Nº 1 Presidente Roque Sáenz Peña', N'Instituto Superior de Arte del Teatro Colón', N'Universidad de Palermo');
GO

-- Nahuel Escobar (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Nahuel', N'Escobar', N'nahuel.escobar@prueba.mip', N'pbkdf2$100000$hwqMD99dVjzx5BWC4XgISw==$RXcM5T0BsvKGKjRuH1RvelVCmu9cSf80RdadNkNEhGs=', N'30111030', N'Av. Corrientes 1300, CABA', N'privado/dni/prueba30.webp', N'profesor', '1987-06-08', 0);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Educación física, anatomía y apoyo para exámenes de ingreso a profesorados.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 8000);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Profesor de Educación Física');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Educación Física', N'Anatomía y Fisiología');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Presencial');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 1', N'Secundario 2', N'Secundario 3');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Belgrano Day School', N'Colegio La Salle', N'Instituto Libre de Segunda Enseñanza (ILSE)');
GO

-- Olivia Juárez (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Olivia', N'Juárez', N'olivia.juarez@prueba.mip', N'pbkdf2$100000$moiDd1t+laK6J+NDqPup7A==$CnR/rYBCsHzqk3LHHb3AGl5+p7ogDUSDbIwW1Vr8XFY=', N'30111031', N'Av. Corrientes 1310, CABA', N'privado/dni/prueba31.webp', N'profesor', '1990-07-15', 0);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Ciencias naturales de los primeros años con experimentos y esquemas.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 6000);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Profesora de Ciencias Naturales');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Ciencias Naturales', N'Biología');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Presencial', N'Virtual');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 1', N'Secundario 2');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Escuela Normal Superior Nº 3 Bernardino Rivadavia', N'Colegio Santa Catalina', N'Colegio Esquiú');
GO

-- Pablo Ortega (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Pablo', N'Ortega', N'pablo.ortega@prueba.mip', N'pbkdf2$100000$Bc9pwg3ax7ubecHdbu/NHQ==$GWPXfmkYfVql75JStmtHegYEFV5UkBt834stKPNVj7w=', N'30111032', N'Av. Corrientes 1320, CABA', N'privado/dni/prueba32.webp', N'profesor', '1993-08-22', 1);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Latín y literatura con análisis de textos paso a paso.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 9000);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Profesora de Letras Clásicas');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Latín', N'Lengua y Literatura');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Presencial', N'Virtual');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Universitario');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Colegio Marianista', N'Pontificia Universidad Católica Argentina (UCA)');
GO

-- Romina Torres (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Romina', N'Torres', N'romina.torres@prueba.mip', N'pbkdf2$100000$0dhP9kvlHHbFMcKwaSTnsQ==$NCrdy8vD7yxiTyCyGyegHMCqvA4ikLAzHeXFMbU/VXQ=', N'30111033', N'Av. Corrientes 1330, CABA', N'privado/dni/prueba33.webp', N'profesor', '1996-09-01', 0);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Filosofía para entender y discutir, no solo memorizar.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 7000);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Profesor de Filosofía');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Filosofía');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Virtual');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 3', N'Secundario 4', N'Secundario 5');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Escuela Superior de Comercio Carlos Pellegrini', N'Instituto Superior de Enseñanza Radiofónica (ISER)');
GO

-- Santiago Zárate (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Santiago', N'Zárate', N'santiago.zarate@prueba.mip', N'pbkdf2$100000$1MHPym7OV/MezLBZ4/BjgQ==$7+C0Wa+W0V7sLZEjQuDatuOx0Ra34u2eznwp0zymvmM=', N'30111034', N'Av. Corrientes 1340, CABA', N'privado/dni/prueba34.webp', N'profesor', '1999-10-08', 0);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Francés con conversación y preparación para el DELF.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 8500);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Profesora de Francés');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Francés');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Presencial');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 5', N'Secundario 6', N'Terciario');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Escuela Normal Superior Nº 4 Estanislao Zeballos', N'Colegio San Cirano', N'Escuela Normal Superior Nº 2 Mariano Acosta', N'Instituto de Enseñanza Superior en Lenguas Vivas Juan Ramón Fernández');
GO

-- Tamara Esposito (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Tamara', N'Esposito', N'tamara.esposito@prueba.mip', N'pbkdf2$100000$E3+CgCmo8XSZqNHz0PQgAw==$AhhD0IbHBgwQ8mWyiwgPM51GWwYaYKVOqyIIxDA7Rto=', N'30111035', N'Av. Corrientes 1350, CABA', N'privado/dni/prueba35.webp', N'profesor', '1977-11-15', 1);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Dibujo y arte para trabajos prácticos y carpetas de arte.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 5500);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Profesora de Artes Visuales');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Dibujo y Arte');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Presencial');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 1', N'Secundario 2', N'Secundario 3', N'Secundario 4', N'Secundario 5', N'Secundario 6');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Escuela Técnica Otto Krause', N'Colegio Pestalozzi');
GO

-- Ulises Castro (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Ulises', N'Castro', N'ulises.castro@prueba.mip', N'pbkdf2$100000$vpBtXTnVwTxVUlLiAuonkg==$IK0TV0pu8Et2BGkCw3EoXncO76l4gcdVTklhNg5k1FQ=', N'30111036', N'Av. Corrientes 1360, CABA', N'privado/dni/prueba36.webp', N'profesor', '1980-12-22', 0);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Matemática con ejercicios graduados: de lo básico a los problemas de examen.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 9500);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Profesor de Matemática');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Matemática');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Presencial', N'Virtual');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 4', N'Secundario 5', N'Secundario 6');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Colegio San José', N'Colegio Nicolás Avellaneda');
GO

-- Vanesa Herrero (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Vanesa', N'Herrero', N'vanesa.herrero@prueba.mip', N'pbkdf2$100000$aUElwd2W3xa94eNuueDehw==$Qt7Ru8TQB8qHjK8JEh4maMwy/lbrGhaOF7RuxQt+TwM=', N'30111037', N'Av. Corrientes 1370, CABA', N'privado/dni/prueba37.webp', N'profesor', '1983-01-01', 0);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Física y matemática con experimentos caseros y problemas resueltos.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 7000);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Licenciado en Física');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Física', N'Matemática');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Virtual');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Terciario', N'Universitario');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Colegio San Martín', N'Instituto Superior de Arte del Teatro Colón', N'Universidad CAECE');
GO

-- Walter Medina (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Walter', N'Medina', N'walter.medina@prueba.mip', N'pbkdf2$100000$+omyNpkw58tCwUXvmk7/Gw==$1Sl60hKczrSa2vyYRe1d9q1vlyEXXM4T3B9L7E+blbw=', N'30111038', N'Av. Corrientes 1380, CABA', N'privado/dni/prueba38.webp', N'profesor', '1986-02-08', 1);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Ciencias naturales con esquemas y repaso antes de cada prueba.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 5000);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Profesor de Ciencias Naturales');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Química', N'Biología');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Virtual');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 1', N'Secundario 2', N'Secundario 3');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Colegio Sagrado Corazón', N'Instituto Superior de Enseñanza Radiofónica (ISER)', N'Escuela Normal Superior Nº 3 Bernardino Rivadavia');
GO

-- Ximena Ramos (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Ximena', N'Ramos', N'ximena.ramos@prueba.mip', N'pbkdf2$100000$wVp8Dyy50roq6B0dumZG6A==$8/OiJPuDP9xO5IiyWxKx/DwVop3L6iJ1uS2MUqBSrXg=', N'30111039', N'Av. Corrientes 1390, CABA', N'privado/dni/prueba39.webp', N'profesor', '1989-03-15', 0);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Inglés para el colegio, exámenes internacionales y conversación.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 8000);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Profesora de Inglés');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Inglés');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Presencial');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 1', N'Secundario 2');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Colegio Santa Unión de los Sagrados Corazones');
GO

-- Yamila Weiss (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Yamila', N'Weiss', N'yamila.weiss@prueba.mip', N'pbkdf2$100000$XRTPVp+xf8pyURFIzasYNw==$HTVgnkPmTahMxAY+FXmb9qENkJP3w63Vr3Cc529GHw8=', N'30111040', N'Av. Corrientes 1400, CABA', N'privado/dni/prueba40.webp', N'profesor', '1992-04-22', 0);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Lectura, escritura y comprensión de textos, con foco en los trabajos del colegio.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 9000);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Profesora de Letras');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Lengua y Literatura');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Presencial', N'Virtual');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Universitario');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Escuela Normal Superior Nº 2 Mariano Acosta', N'Escuela Normal Superior Nº 1 Presidente Roque Sáenz Peña', N'Colegio Esquiú', N'Instituto Universitario Hospital Italiano (IUHI)');
GO

-- Zoe Cabrera (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Zoe', N'Cabrera', N'zoe.cabrera@prueba.mip', N'pbkdf2$100000$xhpT7QpleiuxEleMT7QMaA==$m9zJDNb+n8Nd+ASp4n56ffi7wq2XfXNo011oEIsdWuI=', N'30111041', N'Av. Corrientes 1410, CABA', N'privado/dni/prueba41.webp', N'profesor', '1995-05-01', 1);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Historia y geografía con mapas, líneas de tiempo y resúmenes claros.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 9500);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Profesor de Historia');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Historia', N'Geografía');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Presencial', N'Virtual');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 3', N'Secundario 4', N'Secundario 5');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Escuela Normal Superior Nº 4 Estanislao Zeballos', N'Colegio San Cirano', N'Colegio Mater Admirabilis');
GO

-- Axel Álvarez (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Axel', N'Álvarez', N'axel.alvarez@prueba.mip', N'pbkdf2$100000$s+63hMGNhE3DXhd/5zkh6A==$JI3dnUWLsF47JMFZZooLtOsEMaslPLlmGvrt4jU00XE=', N'30111042', N'Av. Corrientes 1420, CABA', N'privado/dni/prueba42.webp', N'profesor', '1998-06-08', 0);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Programación desde cero: lógica, Python y proyectos pequeños.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 5500);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Técnico Universitario en Programación');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Programación e Informática');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Virtual');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 5', N'Secundario 6', N'Terciario');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Colegio Mariano Moreno', N'Escuela Normal Superior Nº 3 Bernardino Rivadavia', N'Instituto Superior de Formación Docente Nº 1 Dr. Joaquín V. González');
GO

-- Bianca Figueroa (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Bianca', N'Figueroa', N'bianca.figueroa@prueba.mip', N'pbkdf2$100000$EWCQR5Cx77HiLP+OoILxWQ==$+IZXTFfcH0ZI+EhNqRLoTwbmhNUbjYWcTKagYnk2OCA=', N'30111043', N'Av. Corrientes 1430, CABA', N'privado/dni/prueba43.webp', N'profesor', '1976-07-15', 0);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Economía y contabilidad explicadas con ejemplos de la vida diaria.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 6000);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Licenciado en Administración');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Economía', N'Contabilidad y Administración');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Presencial');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 1', N'Secundario 2', N'Secundario 3', N'Secundario 4', N'Secundario 5', N'Secundario 6');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Escuela Normal Superior Nº 11 Ricardo Levene', N'Instituto Superior de Enseñanza Radiofónica (ISER)', N'Escuela Normal Superior Nº 1 Presidente Roque Sáenz Peña');
GO

-- Candela Katz (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Candela', N'Katz', N'candela.katz@prueba.mip', N'pbkdf2$100000$msItVXPK6xt1k5+FA30FZg==$b79dFarDnyLEsCMmLl/mRQep78sheS5ahkBK2JiieKo=', N'30111044', N'Av. Corrientes 1440, CABA', N'privado/dni/prueba44.webp', N'profesor', '1979-08-22', 1);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Estadística y análisis para los primeros años de facultad.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 7500);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Licenciada en Estadística');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Estadística', N'Álgebra y Análisis');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Presencial');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 4', N'Secundario 5', N'Secundario 6');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Escuela Normal Superior en Lenguas Vivas Juan Ramón Fernández', N'Colegio Marianista');
GO

-- Dante Peralta (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Dante', N'Peralta', N'dante.peralta@prueba.mip', N'pbkdf2$100000$vSaMkzdmX815lPWANkNItA==$OZOZrFVuIO+fnJpNASQo3hHJHw44oadhxhNA+U7M6LE=', N'30111045', N'Av. Corrientes 1450, CABA', N'privado/dni/prueba45.webp', N'profesor', '1982-09-01', 0);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Psicología y sociología para el secundario y el CBC, con casos y resúmenes.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 7500);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Licenciada en Psicología');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Psicología', N'Sociología');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Presencial', N'Virtual');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Terciario', N'Universitario');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Instituto Superior de Enseñanza Radiofónica (ISER)', N'Escuela Normal Superior Nº 9 Domingo Faustino Sarmiento', N'Conservatorio Superior de Música Manuel de Falla', N'Universidad Favaloro');
GO

-- Emilia Urquiza (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Emilia', N'Urquiza', N'emilia.urquiza@prueba.mip', N'pbkdf2$100000$+f4KaJ9Nawa9WOLCflr7MA==$UXsn2IDg8IUbslSVurniAJ9CgHcCkmzVomQUOdGsUf8=', N'30111046', N'Av. Corrientes 1460, CABA', N'privado/dni/prueba46.webp', N'profesor', '1985-10-08', 0);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Derecho y ciencias políticas para el secundario y primeros años de facultad.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 8500);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Abogado (UBA)');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Derecho', N'Ciencias Políticas');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Virtual');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 1', N'Secundario 2', N'Secundario 3');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Colegio Santa Unión de los Sagrados Corazones', N'Escuela Normal Superior en Lenguas Vivas Juan Ramón Fernández', N'Colegio La Salle');
GO

-- Franco Aguirre (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Franco', N'Aguirre', N'franco.aguirre@prueba.mip', N'pbkdf2$100000$TqPOvAc+lvrqwS19Q61m8Q==$IBCvgo9oyhR6U5NLW7DiJyWT5Ch7zoOuRstiCKrzLiw=', N'30111047', N'Av. Corrientes 1470, CABA', N'privado/dni/prueba47.webp', N'profesor', '1988-11-15', 1);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Italiano y alemán desde cero, con conversación y gramática.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 9500);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Profesora de Idiomas');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Italiano', N'Alemán');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Virtual');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 1', N'Secundario 2');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Colegio San José', N'Colegio Sagrado Corazón');
GO

-- Guadalupe Funes (profesor)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Guadalupe', N'Funes', N'guadalupe.funes@prueba.mip', N'pbkdf2$100000$h607EIAB62lsGsRWenjWhg==$Tj9PPofPsCNbAmXrUyh4dPhLNfTqWiiP/CrEKt8BB50=', N'30111048', N'Av. Corrientes 1480, CABA', N'privado/dni/prueba48.webp', N'profesor', '1991-12-22', 0);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Tecnología, electrónica y robótica con proyectos que se arman en clase.</p>');
INSERT INTO InfoProfesores (idUsuario, precioHora) VALUES (@id, 5500);
INSERT INTO Titulos (idUsuario, titulo) VALUES (@id, N'Ingeniero Electrónico');
INSERT INTO Usuarios_Materias (idUsuario, idMateria) SELECT @id, ID FROM Materias WHERE nombre IN (N'Tecnología y Robótica');
INSERT INTO Profesores_Modalidades (idUsuario, idModalidad) SELECT @id, ID FROM Modalidades WHERE nombre IN (N'Presencial');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Universitario');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Colegio Champagnat', N'Escuela Normal Superior en Lenguas Vivas Sofía Spangenberg', N'Pontificia Universidad Católica Argentina (UCA)');
GO

-- Mateo Gómez (alumno)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Mateo', N'Gómez', N'mateo.gomez@prueba.mip', N'pbkdf2$100000$jx4qikVTD7wV1gZyM1wLkw==$qw5TDD043U6iqPQy9YYvgYg68J89Mu+eM8gTSsR8SVU=', N'40111001', N'Av. Corrientes 2000, CABA', N'privado/dni/prueba100.webp', N'alumno', '2005-01-10', 1);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Estudiante que busca ayuda para rendir bien.</p>');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 3');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Belgrano Day School');
GO

-- Carolina Suárez (alumno)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Carolina', N'Suárez', N'carolina.suarez@prueba.mip', N'pbkdf2$100000$2+mu2SQGWZYjp0xT0BdgUQ==$FslM7xMy8B04J1DFvHCxKAvqcnc73njpEfv/6KY4VUw=', N'40111002', N'Av. Corrientes 2010, CABA', N'privado/dni/prueba101.webp', N'alumno', '2006-02-11', 1);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Estudiante que busca ayuda para rendir bien.</p>');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 4');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Colegio San Martín');
GO

-- Tomás Pereyra (alumno)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Tomás', N'Pereyra', N'tomas.pereyra@prueba.mip', N'pbkdf2$100000$iOOVXwWBM6pxWCDmwhaNcw==$1z+cCNCy+1rkGR3nUEizNZN6Ik+RgXmQmhutgq7ifMg=', N'40111003', N'Av. Corrientes 2020, CABA', N'privado/dni/prueba102.webp', N'alumno', '2007-03-12', 1);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Estudiante que busca ayuda para rendir bien.</p>');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 5');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Colegio Nacional de Buenos Aires');
GO

-- Lara Giménez (alumno)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Lara', N'Giménez', N'lara.gimenez@prueba.mip', N'pbkdf2$100000$VFxCZWTIGivoSG1UaImeMg==$uaBT20HC9nk+Pa2pbwNLUk4Dhr6CdlYgwSt8Oc3Cbic=', N'40111004', N'Av. Corrientes 2030, CABA', N'privado/dni/prueba103.webp', N'alumno', '2008-04-13', 1);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Estudiante que busca ayuda para rendir bien.</p>');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Secundario 2');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Escuela Superior de Comercio Carlos Pellegrini');
GO

-- Bautista Romero (alumno)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Bautista', N'Romero', N'bautista.romero@prueba.mip', N'pbkdf2$100000$0tsAn1jddzhMi5BPFrYuYA==$FinGcO9zMH6DOs2LWfZriZi76sNzOqU69bqkSEP+s48=', N'40111005', N'Av. Corrientes 2040, CABA', N'privado/dni/prueba104.webp', N'alumno', '2005-05-14', 1);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Estudiante que busca ayuda para rendir bien.</p>');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Universitario');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Universidad de Buenos Aires (UBA)');
GO

-- Martina Ledesma (alumno)
DECLARE @id INT;
INSERT INTO Usuarios (nombre, apellido, mail, contrasena, dni, direccion, fotoDni, tipoUsuario, fechaNacimiento, verificado)
VALUES (N'Martina', N'Ledesma', N'martina.ledesma@prueba.mip', N'pbkdf2$100000$tVg5QKodal894JfocHemug==$O56jYghcuWgRdUtCfvhj9A5OCEHidT4BP7lqN7y/Qu0=', N'40111006', N'Av. Corrientes 2050, CABA', N'privado/dni/prueba105.webp', N'alumno', '2006-06-15', 1);
SET @id = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario, descripcion) VALUES (@id, N'<p>Estudiante que busca ayuda para rendir bien.</p>');
INSERT INTO Usuarios_Niveles (idUsuario, idNivel) SELECT @id, ID FROM Niveles WHERE nombre IN (N'Universitario');
INSERT INTO Escuelas_Usuarios (idUsuario, idEscuela) SELECT @id, ID FROM Escuelas WHERE nombre IN (N'Universidad Tecnológica Nacional (UTN)');
GO

-- ---------------------------------------------------------------------
-- Reseñas de prueba (algunos profesores quedan sin reseñas a propósito)
-- ---------------------------------------------------------------------
INSERT INTO Resenas (idEmisor, idReceptor, estado, puntuacion, descripcion)
SELECT a.ID, p.ID, N'Aprobada', v.puntuacion, v.descripcion
FROM (VALUES
    (N'carolina.suarez@prueba.mip', N'sofia.martinez@prueba.mip', 5, N'Me ayudó un montón antes del final.'),
    (N'bautista.romero@prueba.mip', N'camila.rossi@prueba.mip', 4, N'Explica clarísimo, aprobé el examen.'),
    (N'carolina.suarez@prueba.mip', N'camila.rossi@prueba.mip', 4, N'Buena onda y puntual.'),
    (N'tomas.pereyra@prueba.mip', N'camila.rossi@prueba.mip', 5, N'Muy buenos ejemplos y material.'),
    (N'bautista.romero@prueba.mip', N'joaquin.fernandez@prueba.mip', 5, N'Explica clarísimo, aprobé el examen.'),
    (N'tomas.pereyra@prueba.mip', N'joaquin.fernandez@prueba.mip', 5, N'Buena onda y puntual.'),
    (N'carolina.suarez@prueba.mip', N'joaquin.fernandez@prueba.mip', 5, N'Buena onda y puntual.'),
    (N'martina.ledesma@prueba.mip', N'joaquin.fernandez@prueba.mip', 5, N'Muy paciente y ordenado.'),
    (N'martina.ledesma@prueba.mip', N'martin.acosta@prueba.mip', 4, N'Muy paciente y ordenado.'),
    (N'lara.gimenez@prueba.mip', N'martin.acosta@prueba.mip', 4, N'A veces va rápido, pero responde todas las dudas.'),
    (N'mateo.gomez@prueba.mip', N'martin.acosta@prueba.mip', 4, N'Muy paciente y ordenado.'),
    (N'bautista.romero@prueba.mip', N'lucia.benitez@prueba.mip', 3, N'Explica clarísimo, aprobé el examen.'),
    (N'mateo.gomez@prueba.mip', N'lucia.benitez@prueba.mip', 5, N'Las clases son dinámicas y entretenidas.'),
    (N'mateo.gomez@prueba.mip', N'tomas.herrera@prueba.mip', 4, N'Buena onda y puntual.'),
    (N'tomas.pereyra@prueba.mip', N'tomas.herrera@prueba.mip', 4, N'Excelente profesor, lo recomiendo.'),
    (N'martina.ledesma@prueba.mip', N'tomas.herrera@prueba.mip', 4, N'Muy buenos ejemplos y material.'),
    (N'lara.gimenez@prueba.mip', N'tomas.herrera@prueba.mip', 5, N'Muy paciente y ordenado.'),
    (N'lara.gimenez@prueba.mip', N'micaela.duarte@prueba.mip', 4, N'Muy paciente y ordenado.'),
    (N'martina.ledesma@prueba.mip', N'micaela.duarte@prueba.mip', 4, N'Muy paciente y ordenado.'),
    (N'bautista.romero@prueba.mip', N'micaela.duarte@prueba.mip', 5, N'Muy buenos ejemplos y material.'),
    (N'lara.gimenez@prueba.mip', N'nicolas.ibarra@prueba.mip', 5, N'Explica clarísimo, aprobé el examen.'),
    (N'carolina.suarez@prueba.mip', N'nicolas.ibarra@prueba.mip', 4, N'Muy buenos ejemplos y material.'),
    (N'martina.ledesma@prueba.mip', N'brenda.quiroga@prueba.mip', 5, N'Explica clarísimo, aprobé el examen.'),
    (N'tomas.pereyra@prueba.mip', N'gonzalo.ferrari@prueba.mip', 4, N'Las clases son dinámicas y entretenidas.'),
    (N'mateo.gomez@prueba.mip', N'gonzalo.ferrari@prueba.mip', 4, N'Me ayudó un montón antes del final.'),
    (N'martina.ledesma@prueba.mip', N'gonzalo.ferrari@prueba.mip', 5, N'Muy buenos ejemplos y material.'),
    (N'lara.gimenez@prueba.mip', N'gonzalo.ferrari@prueba.mip', 5, N'Me ayudó un montón antes del final.'),
    (N'carolina.suarez@prueba.mip', N'ramiro.vega@prueba.mip', 4, N'Me ayudó un montón antes del final.'),
    (N'martina.ledesma@prueba.mip', N'ramiro.vega@prueba.mip', 5, N'A veces va rápido, pero responde todas las dudas.'),
    (N'lara.gimenez@prueba.mip', N'ramiro.vega@prueba.mip', 4, N'Explica clarísimo, aprobé el examen.'),
    (N'tomas.pereyra@prueba.mip', N'ramiro.vega@prueba.mip', 3, N'Excelente profesor, lo recomiendo.'),
    (N'tomas.pereyra@prueba.mip', N'anabela.dominguez@prueba.mip', 5, N'Muy buenos ejemplos y material.'),
    (N'carolina.suarez@prueba.mip', N'anabela.dominguez@prueba.mip', 4, N'Muy paciente y ordenado.'),
    (N'martina.ledesma@prueba.mip', N'anabela.dominguez@prueba.mip', 4, N'Muy paciente y ordenado.'),
    (N'lara.gimenez@prueba.mip', N'bruno.ibanez@prueba.mip', 4, N'Muy buenos ejemplos y material.'),
    (N'lara.gimenez@prueba.mip', N'cecilia.nunez@prueba.mip', 5, N'Explica clarísimo, aprobé el examen.'),
    (N'martina.ledesma@prueba.mip', N'elena.yanez@prueba.mip', 5, N'Muy paciente y ordenado.'),
    (N'tomas.pereyra@prueba.mip', N'elena.yanez@prueba.mip', 5, N'Me ayudó un montón antes del final.'),
    (N'mateo.gomez@prueba.mip', N'elena.yanez@prueba.mip', 5, N'Las clases son dinámicas y entretenidas.'),
    (N'martina.ledesma@prueba.mip', N'fabricio.delgado@prueba.mip', 5, N'Buena onda y puntual.'),
    (N'tomas.pereyra@prueba.mip', N'fabricio.delgado@prueba.mip', 5, N'Buena onda y puntual.'),
    (N'mateo.gomez@prueba.mip', N'fabricio.delgado@prueba.mip', 5, N'Muy paciente y ordenado.'),
    (N'carolina.suarez@prueba.mip', N'gimena.bustos@prueba.mip', 4, N'Explica clarísimo, aprobé el examen.'),
    (N'bautista.romero@prueba.mip', N'hernan.gimenez@prueba.mip', 5, N'Las clases son dinámicas y entretenidas.'),
    (N'bautista.romero@prueba.mip', N'julian.quintana@prueba.mip', 5, N'Las clases son dinámicas y entretenidas.'),
    (N'lara.gimenez@prueba.mip', N'julian.quintana@prueba.mip', 3, N'Explica clarísimo, aprobé el examen.'),
    (N'tomas.pereyra@prueba.mip', N'julian.quintana@prueba.mip', 5, N'Muy paciente y ordenado.'),
    (N'mateo.gomez@prueba.mip', N'julian.quintana@prueba.mip', 5, N'Las clases son dinámicas y entretenidas.'),
    (N'carolina.suarez@prueba.mip', N'karina.villalba@prueba.mip', 4, N'Me ayudó un montón antes del final.'),
    (N'martina.ledesma@prueba.mip', N'karina.villalba@prueba.mip', 4, N'Me ayudó un montón antes del final.'),
    (N'mateo.gomez@prueba.mip', N'karina.villalba@prueba.mip', 5, N'Muy buenos ejemplos y material.'),
    (N'bautista.romero@prueba.mip', N'leandro.benavidez@prueba.mip', 4, N'Explica clarísimo, aprobé el examen.'),
    (N'lara.gimenez@prueba.mip', N'leandro.benavidez@prueba.mip', 5, N'Muy buenos ejemplos y material.'),
    (N'martina.ledesma@prueba.mip', N'marina.godoy@prueba.mip', 5, N'Las clases son dinámicas y entretenidas.'),
    (N'bautista.romero@prueba.mip', N'marina.godoy@prueba.mip', 5, N'Las clases son dinámicas y entretenidas.'),
    (N'lara.gimenez@prueba.mip', N'marina.godoy@prueba.mip', 5, N'Explica clarísimo, aprobé el examen.'),
    (N'carolina.suarez@prueba.mip', N'olivia.juarez@prueba.mip', 4, N'Las clases son dinámicas y entretenidas.'),
    (N'bautista.romero@prueba.mip', N'olivia.juarez@prueba.mip', 4, N'A veces va rápido, pero responde todas las dudas.'),
    (N'mateo.gomez@prueba.mip', N'olivia.juarez@prueba.mip', 5, N'Muy paciente y ordenado.'),
    (N'mateo.gomez@prueba.mip', N'pablo.ortega@prueba.mip', 5, N'Explica clarísimo, aprobé el examen.'),
    (N'tomas.pereyra@prueba.mip', N'pablo.ortega@prueba.mip', 4, N'Me ayudó un montón antes del final.'),
    (N'lara.gimenez@prueba.mip', N'pablo.ortega@prueba.mip', 4, N'Explica clarísimo, aprobé el examen.'),
    (N'martina.ledesma@prueba.mip', N'pablo.ortega@prueba.mip', 3, N'A veces va rápido, pero responde todas las dudas.'),
    (N'mateo.gomez@prueba.mip', N'romina.torres@prueba.mip', 5, N'Me ayudó un montón antes del final.'),
    (N'martina.ledesma@prueba.mip', N'romina.torres@prueba.mip', 5, N'Excelente profesor, lo recomiendo.'),
    (N'lara.gimenez@prueba.mip', N'romina.torres@prueba.mip', 5, N'A veces va rápido, pero responde todas las dudas.'),
    (N'carolina.suarez@prueba.mip', N'romina.torres@prueba.mip', 5, N'Me ayudó un montón antes del final.'),
    (N'tomas.pereyra@prueba.mip', N'santiago.zarate@prueba.mip', 4, N'Buena onda y puntual.'),
    (N'bautista.romero@prueba.mip', N'santiago.zarate@prueba.mip', 3, N'Buena onda y puntual.'),
    (N'carolina.suarez@prueba.mip', N'santiago.zarate@prueba.mip', 5, N'Muy buenos ejemplos y material.'),
    (N'lara.gimenez@prueba.mip', N'santiago.zarate@prueba.mip', 3, N'Me ayudó un montón antes del final.'),
    (N'mateo.gomez@prueba.mip', N'ulises.castro@prueba.mip', 3, N'Las clases son dinámicas y entretenidas.'),
    (N'carolina.suarez@prueba.mip', N'ulises.castro@prueba.mip', 5, N'Muy buenos ejemplos y material.'),
    (N'tomas.pereyra@prueba.mip', N'ulises.castro@prueba.mip', 4, N'Excelente profesor, lo recomiendo.'),
    (N'lara.gimenez@prueba.mip', N'vanesa.herrero@prueba.mip', 4, N'Muy paciente y ordenado.'),
    (N'lara.gimenez@prueba.mip', N'walter.medina@prueba.mip', 4, N'Buena onda y puntual.'),
    (N'carolina.suarez@prueba.mip', N'walter.medina@prueba.mip', 5, N'Buena onda y puntual.'),
    (N'bautista.romero@prueba.mip', N'walter.medina@prueba.mip', 4, N'Buena onda y puntual.'),
    (N'tomas.pereyra@prueba.mip', N'ximena.ramos@prueba.mip', 4, N'Muy paciente y ordenado.'),
    (N'mateo.gomez@prueba.mip', N'zoe.cabrera@prueba.mip', 5, N'A veces va rápido, pero responde todas las dudas.'),
    (N'tomas.pereyra@prueba.mip', N'zoe.cabrera@prueba.mip', 5, N'Explica clarísimo, aprobé el examen.'),
    (N'tomas.pereyra@prueba.mip', N'axel.alvarez@prueba.mip', 5, N'Muy paciente y ordenado.'),
    (N'bautista.romero@prueba.mip', N'axel.alvarez@prueba.mip', 3, N'Me ayudó un montón antes del final.'),
    (N'martina.ledesma@prueba.mip', N'axel.alvarez@prueba.mip', 3, N'Muy paciente y ordenado.'),
    (N'tomas.pereyra@prueba.mip', N'bianca.figueroa@prueba.mip', 4, N'Excelente profesor, lo recomiendo.'),
    (N'mateo.gomez@prueba.mip', N'bianca.figueroa@prueba.mip', 4, N'Buena onda y puntual.'),
    (N'lara.gimenez@prueba.mip', N'candela.katz@prueba.mip', 5, N'A veces va rápido, pero responde todas las dudas.'),
    (N'carolina.suarez@prueba.mip', N'candela.katz@prueba.mip', 5, N'Muy buenos ejemplos y material.'),
    (N'mateo.gomez@prueba.mip', N'franco.aguirre@prueba.mip', 5, N'Muy paciente y ordenado.'),
    (N'carolina.suarez@prueba.mip', N'franco.aguirre@prueba.mip', 4, N'Explica clarísimo, aprobé el examen.')
) v(mailAlumno, mailProfesor, puntuacion, descripcion)
JOIN Usuarios a ON a.mail = v.mailAlumno
JOIN Usuarios p ON p.mail = v.mailProfesor;
GO
