-- =====================================================================================
-- DATOS DE PRUEBA para MIP (generado). Para depurar: 36 usuarios nuevos (24 alumnos, 12 profesores,
-- mail @seed.mip, contraseña Prueba123), y alrededor de 325 clases, 145 reseñas, 264 Me gusta, mensajes de chat,
-- amigos y consultas de soporte. También suma historial a los usuarios que ya existían
-- (en especial Eitan, id 57, que supera las 20 clases completadas para probar el tope de 20).
-- Para deshacerlo todo: borrar-datos-prueba.sql
-- =====================================================================================
SET NOCOUNT ON;
SET XACT_ABORT ON;
USE [MIP]
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;

IF EXISTS (SELECT 1 FROM Usuarios WHERE mail LIKE N'%@seed.mip')
    THROW 50000, N'Los datos de prueba ya están cargados. Corré borrar-datos-prueba.sql primero.', 1;

DECLARE @hash NVARCHAR(255) = (SELECT contrasena FROM Usuarios WHERE mail = N'mateo.gomez@prueba.mip');
IF @hash IS NULL THROW 50001, N'No encuentro a mateo.gomez@prueba.mip (se usa su contraseña para todos los usuarios de prueba).', 1;

DECLARE @A1 INT, @A2 INT, @A3 INT, @A4 INT, @A5 INT, @A6 INT, @A7 INT, @A8 INT, @A9 INT, @A10 INT, @A11 INT, @A12 INT, @A13 INT, @A14 INT, @A15 INT, @A16 INT, @A17 INT, @A18 INT, @A19 INT, @A20 INT, @A21 INT, @A22 INT, @A23 INT, @A24 INT, @P1 INT, @P2 INT, @P3 INT, @P4 INT, @P5 INT, @P6 INT, @P7 INT, @P8 INT, @P9 INT, @P10 INT, @P11 INT, @P12 INT;
DECLARE @minClase INT = (SELECT ISNULL(MAX(ID),0)+1 FROM Clases);
DECLARE @minResena INT = (SELECT ISNULL(MAX(ID),0)+1 FROM Resenas);
DECLARE @minMensaje INT = (SELECT ISNULL(MAX(ID),0)+1 FROM Mensajes);

BEGIN TRANSACTION;

-- ---------------------------------------------------------------- usuarios

-- Agustín Alonso (alumno)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Agustín',N'Alonso',N'agustin.alonso@seed.mip',@hash,N'50110001',N'Calle Seed 100, CABA',N'privado/dni/seed-a1.webp',N'alumno','2007-04-15',DATEADD(DAY,-143,GETDATE()),0);
SET @A1 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@A1,N'<p>Estudiante que busca ayuda para rendir bien.</p>');
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela) VALUES (@A1,19);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@A1,16);

-- Valeria Barrios (alumno)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Valeria',N'Barrios',N'valeria.barrios@seed.mip',@hash,N'50110002',N'Calle Seed 107, CABA',N'privado/dni/seed-a2.webp',N'alumno','2010-04-17',DATEADD(DAY,-128,GETDATE()),0);
SET @A2 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@A2,N'<p>Voy a rendir materias previas y necesito apoyo con <strong>Matemática</strong>.</p>');
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela) VALUES (@A2,76);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@A2,22);

-- Facundo Cardozo (alumno)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Facundo',N'Cardozo',N'facundo.cardozo@seed.mip',@hash,N'50110003',N'Calle Seed 114, CABA',N'privado/dni/seed-a3.webp',N'alumno','2007-08-22',DATEADD(DAY,-34,GETDATE()),0);
SET @A3 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@A3,N'<p>Me cuesta organizarme con los exámenes: busco clases claras y con ejercicios.</p>');
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela) VALUES (@A3,56);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@A3,18);

-- Julieta Medina (alumno)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Julieta',N'Medina',N'julieta.medina@seed.mip',@hash,N'50110004',N'Calle Seed 121, CABA',N'privado/dni/seed-a4.webp',N'alumno','2006-11-09',DATEADD(DAY,-37,GETDATE()),0);
SET @A4 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@A4,N'<p>Entro a la facultad el año que viene y quiero llegar preparado/a.</p>');
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela) VALUES (@A4,18);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@A4,19);

-- Ignacio Rivas (alumno)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Ignacio',N'Rivas',N'ignacio.rivas@seed.mip',@hash,N'50110005',N'Calle Seed 128, CABA',N'privado/dni/seed-a5.webp',N'alumno','2008-10-13',DATEADD(DAY,-65,GETDATE()),0);
SET @A5 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@A5,N'<p>Estudiante que busca ayuda para rendir bien.</p>');
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela) VALUES (@A5,39);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@A5,16);

-- Antonella Sandoval (alumno)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Antonella',N'Sandoval',N'antonella.sandoval@seed.mip',@hash,N'50110006',N'Calle Seed 135, CABA',N'privado/dni/seed-a6.webp',N'alumno','2010-08-14',DATEADD(DAY,-62,GETDATE()),0);
SET @A6 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@A6,N'<p>Voy a rendir materias previas y necesito apoyo con <strong>Matemática</strong>.</p>');
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela) VALUES (@A6,19);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@A6,23);

-- Lautaro Acuña (alumno)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Lautaro',N'Acuña',N'lautaro.acuna@seed.mip',@hash,N'50110007',N'Calle Seed 142, CABA',N'privado/dni/seed-a7.webp',N'alumno','2009-01-04',DATEADD(DAY,-204,GETDATE()),0);
SET @A7 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@A7,N'<p>Me cuesta organizarme con los exámenes: busco clases claras y con ejercicios.</p>');
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela) VALUES (@A7,27);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@A7,19);

-- Milagros Peralta (alumno)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Milagros',N'Peralta',N'milagros.peralta@seed.mip',@hash,N'50110008',N'Calle Seed 149, CABA',N'privado/dni/seed-a8.webp',N'alumno','2010-01-15',DATEADD(DAY,-162,GETDATE()),0);
SET @A8 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@A8,N'<p>Entro a la facultad el año que viene y quiero llegar preparado/a.</p>');
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela) VALUES (@A8,30);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@A8,23);

-- Joaquín Giménez (alumno)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Joaquín',N'Giménez',N'joaquin.gimenez@seed.mip',@hash,N'50110009',N'Calle Seed 156, CABA',N'privado/dni/seed-a9.webp',N'alumno','2006-08-18',DATEADD(DAY,-67,GETDATE()),0);
SET @A9 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@A9,N'<p>Estudiante que busca ayuda para rendir bien.</p>');
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela) VALUES (@A9,88);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@A9,19);

-- Sofía Correa (alumno)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Sofía',N'Correa',N'sofia.correa@seed.mip',@hash,N'50110010',N'Calle Seed 163, CABA',N'privado/dni/seed-a10.webp',N'alumno','2007-12-27',DATEADD(DAY,-54,GETDATE()),0);
SET @A10 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@A10,N'<p>Voy a rendir materias previas y necesito apoyo con <strong>Biología</strong>.</p>');
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela) VALUES (@A10,48);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@A10,20);

-- Benjamín Maldonado (alumno)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Benjamín',N'Maldonado',N'benjamin.maldonado@seed.mip',@hash,N'50110011',N'Calle Seed 170, CABA',N'privado/dni/seed-a11.webp',N'alumno','2006-01-13',DATEADD(DAY,-151,GETDATE()),0);
SET @A11 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@A11,N'<p>Me cuesta organizarme con los exámenes: busco clases claras y con ejercicios.</p>');
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela) VALUES (@A11,22);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@A11,19);

-- Delfina Ponce (alumno)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Delfina',N'Ponce',N'delfina.ponce@seed.mip',@hash,N'50110012',N'Calle Seed 177, CABA',N'privado/dni/seed-a12.webp',N'alumno','2009-10-23',DATEADD(DAY,-136,GETDATE()),0);
SET @A12 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@A12,N'<p>Entro a la facultad el año que viene y quiero llegar preparado/a.</p>');
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela) VALUES (@A12,78);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@A12,16);

-- Thiago Villarreal (alumno)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Thiago',N'Villarreal',N'thiago.villarreal@seed.mip',@hash,N'50110013',N'Calle Seed 184, CABA',N'privado/dni/seed-a13.webp',N'alumno','2008-04-02',DATEADD(DAY,-204,GETDATE()),0);
SET @A13 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@A13,N'<p>Estudiante que busca ayuda para rendir bien.</p>');
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela) VALUES (@A13,61);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@A13,18);

-- Renata Cabral (alumno)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Renata',N'Cabral',N'renata.cabral@seed.mip',@hash,N'50110014',N'Calle Seed 191, CABA',N'privado/dni/seed-a14.webp',N'alumno','2009-11-23',DATEADD(DAY,-133,GETDATE()),0);
SET @A14 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@A14,N'<p>Voy a rendir materias previas y necesito apoyo con <strong>Inglés</strong>.</p>');
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela) VALUES (@A14,82);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@A14,22);

-- Santino Ibáñez (alumno)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Santino',N'Ibáñez',N'santino.ibanez@seed.mip',@hash,N'50110015',N'Calle Seed 198, CABA',N'privado/dni/seed-a15.webp',N'alumno','2008-04-24',DATEADD(DAY,-208,GETDATE()),0);
SET @A15 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@A15,N'<p>Me cuesta organizarme con los exámenes: busco clases claras y con ejercicios.</p>');
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela) VALUES (@A15,29);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@A15,22);

-- Abril Nieto (alumno)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Abril',N'Nieto',N'abril.nieto@seed.mip',@hash,N'50110016',N'Calle Seed 205, CABA',N'privado/dni/seed-a16.webp',N'alumno','2006-12-25',DATEADD(DAY,-128,GETDATE()),0);
SET @A16 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@A16,N'<p>Entro a la facultad el año que viene y quiero llegar preparado/a.</p>');
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela) VALUES (@A16,52);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@A16,22);

-- Bruno Arias (alumno)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Bruno',N'Arias',N'bruno.arias@seed.mip',@hash,N'50110017',N'Calle Seed 212, CABA',N'privado/dni/seed-a17.webp',N'alumno','2009-09-04',DATEADD(DAY,-69,GETDATE()),0);
SET @A17 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@A17,N'<p>Estudiante que busca ayuda para rendir bien.</p>');
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela) VALUES (@A17,44);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@A17,22);

-- Catalina Bravo (alumno)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Catalina',N'Bravo',N'catalina.bravo@seed.mip',@hash,N'50110018',N'Calle Seed 219, CABA',N'privado/dni/seed-a18.webp',N'alumno','2008-11-02',DATEADD(DAY,-28,GETDATE()),0);
SET @A18 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@A18,N'<p>Voy a rendir materias previas y necesito apoyo con <strong>Historia</strong>.</p>');
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela) VALUES (@A18,47);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@A18,17);

-- Lucas Cruz (alumno)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Lucas',N'Cruz',N'lucas.cruz@seed.mip',@hash,NULL,NULL,NULL,N'alumno','2006-03-19',DATEADD(DAY,-148,GETDATE()),0);
SET @A19 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@A19,N'<p>Me cuesta organizarme con los exámenes: busco clases claras y con ejercicios.</p>');
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela) VALUES (@A19,38);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@A19,20);

-- Florencia Paz (alumno)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Florencia',N'Paz',N'florencia.paz@seed.mip',@hash,NULL,NULL,NULL,N'alumno','2008-06-04',DATEADD(DAY,-40,GETDATE()),0);
SET @A20 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@A20,N'<p>Entro a la facultad el año que viene y quiero llegar preparado/a.</p>');
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela) VALUES (@A20,43);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@A20,20);

-- Tomás Molina (alumno)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Tomás',N'Molina',N'tomas.molina@seed.mip',@hash,N'50110019',N'Calle Seed 240, CABA',N'privado/dni/seed-a21.webp',N'alumno','2010-02-19',DATEADD(DAY,-85,GETDATE()),0);
SET @A21 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@A21,N'<p>Estudiante que busca ayuda para rendir bien.</p>');
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela) VALUES (@A21,57);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@A21,22);

-- Emilia Soria (alumno)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Emilia',N'Soria',N'emilia.soria@seed.mip',@hash,N'50110020',N'Calle Seed 247, CABA',N'privado/dni/seed-a22.webp',N'alumno','2010-08-02',DATEADD(DAY,-82,GETDATE()),0);
SET @A22 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@A22,N'<p>Voy a rendir materias previas y necesito apoyo con <strong>Historia</strong>.</p>');
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela) VALUES (@A22,58);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@A22,21);

-- Gael Ledesma (alumno)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Gael',N'Ledesma',N'gael.ledesma@seed.mip',@hash,N'50110021',N'Calle Seed 254, CABA',N'privado/dni/seed-a23.webp',N'alumno','2008-04-27',DATEADD(DAY,-186,GETDATE()),0);
SET @A23 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@A23,N'<p>Me cuesta organizarme con los exámenes: busco clases claras y con ejercicios.</p>');
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela) VALUES (@A23,50);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@A23,18);

-- Pilar Franco (alumno)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Pilar',N'Franco',N'pilar.franco@seed.mip',@hash,N'50110022',N'Calle Seed 261, CABA',N'privado/dni/seed-a24.webp',N'alumno','2007-10-06',DATEADD(DAY,-218,GETDATE()),0);
SET @A24 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@A24,N'<p>Entro a la facultad el año que viene y quiero llegar preparado/a.</p>');
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela) VALUES (@A24,59);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@A24,16);

-- Roberto Maidana (profesor)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Roberto',N'Maidana',N'roberto.maidana@seed.mip',@hash,N'50110023',N'Av. Seed 2000, CABA',N'privado/dni/seed-p1.webp',N'profesor','1976-09-02',DATEADD(DAY,-131,GETDATE()),0);
SET @P1 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@P1,N'<p>Clases claras y ordenadas de <strong>Matemática</strong>. Parto de lo que ya sabés y vamos paso a paso hasta el examen.</p><ul><li>Material de práctica incluido</li><li>Seguimiento por mensaje entre clases</li></ul>');
INSERT INTO InfoProfesores (idUsuario,precioHora) VALUES (@P1,7200);
INSERT INTO Usuarios_Materias (idUsuario,idMateria) SELECT @P1,ID FROM Materias WHERE nombre=N'Matemática';
INSERT INTO Usuarios_Materias (idUsuario,idMateria) SELECT @P1,ID FROM Materias WHERE nombre=N'Física';
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P1,18);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P1,19);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P1,20);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P1,21);
INSERT INTO Profesores_Modalidades (idUsuario,idModalidad) VALUES (@P1,9);
INSERT INTO Profesores_Modalidades (idUsuario,idModalidad) VALUES (@P1,10);
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela,desde) VALUES (@P1,79,'2008-01-01');
INSERT INTO Titulos (idUsuario,titulo) VALUES (@P1,N'Profesor de Matemática y Física (UBA)');
INSERT INTO Titulos (idUsuario,titulo) VALUES (@P1,N'Ingeniero Industrial (UTN)');

-- Silvia Cano (profesor)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Silvia',N'Cano',N'silvia.cano@seed.mip',@hash,N'50110024',N'Av. Seed 2013, CABA',N'privado/dni/seed-p2.webp',N'profesor','1981-06-04',DATEADD(DAY,-64,GETDATE()),0);
SET @P2 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@P2,N'<p>Me gusta que entiendas el porqué de cada tema en <strong>Lengua y Literatura</strong>, no solo memorizarlo. Ejercicios guiados y resúmenes al cierre de cada clase.</p>');
INSERT INTO InfoProfesores (idUsuario,precioHora) VALUES (@P2,5800);
INSERT INTO Usuarios_Materias (idUsuario,idMateria) SELECT @P2,ID FROM Materias WHERE nombre=N'Lengua y Literatura';
INSERT INTO Usuarios_Materias (idUsuario,idMateria) SELECT @P2,ID FROM Materias WHERE nombre=N'Latín';
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P2,16);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P2,17);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P2,18);
INSERT INTO Profesores_Modalidades (idUsuario,idModalidad) VALUES (@P2,10);
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela,desde) VALUES (@P2,38,'2010-01-01');
INSERT INTO Titulos (idUsuario,titulo) VALUES (@P2,N'Profesora de Letras (UBA)');

-- Hernán Pilotto (profesor)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Hernán',N'Pilotto',N'hernan.pilotto@seed.mip',@hash,N'50110025',N'Av. Seed 2026, CABA',N'privado/dni/seed-p3.webp',N'profesor','1993-08-12',DATEADD(DAY,-127,GETDATE()),0);
SET @P3 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@P3,N'<p>Me gusta que entiendas el porqué de cada tema en <strong>Historia</strong>, no solo memorizarlo. Ejercicios guiados y resúmenes al cierre de cada clase.</p>');
INSERT INTO InfoProfesores (idUsuario,precioHora) VALUES (@P3,6100);
INSERT INTO Usuarios_Materias (idUsuario,idMateria) SELECT @P3,ID FROM Materias WHERE nombre=N'Historia';
INSERT INTO Usuarios_Materias (idUsuario,idMateria) SELECT @P3,ID FROM Materias WHERE nombre=N'Geografía';
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P3,18);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P3,19);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P3,20);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P3,21);
INSERT INTO Profesores_Modalidades (idUsuario,idModalidad) VALUES (@P3,9);
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela,desde) VALUES (@P3,59,'2016-01-01');
INSERT INTO Titulos (idUsuario,titulo) VALUES (@P3,N'Profesor de Historia (ISP Joaquín V. González)');

-- Natalia Ferro (profesor)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Natalia',N'Ferro',N'natalia.ferro@seed.mip',@hash,N'50110026',N'Av. Seed 2039, CABA',N'privado/dni/seed-p4.webp',N'profesor','1993-07-22',DATEADD(DAY,-155,GETDATE()),0);
SET @P4 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@P4,N'<p>Clases claras y ordenadas de <strong>Inglés</strong>. Parto de lo que ya sabés y vamos paso a paso hasta el examen.</p><ul><li>Material de práctica incluido</li><li>Seguimiento por mensaje entre clases</li></ul>');
INSERT INTO InfoProfesores (idUsuario,precioHora) VALUES (@P4,6800);
INSERT INTO Usuarios_Materias (idUsuario,idMateria) SELECT @P4,ID FROM Materias WHERE nombre=N'Inglés';
INSERT INTO Usuarios_Materias (idUsuario,idMateria) SELECT @P4,ID FROM Materias WHERE nombre=N'Portugués';
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P4,16);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P4,17);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P4,18);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P4,19);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P4,22);
INSERT INTO Profesores_Modalidades (idUsuario,idModalidad) VALUES (@P4,9);
INSERT INTO Profesores_Modalidades (idUsuario,idModalidad) VALUES (@P4,10);
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela,desde) VALUES (@P4,52,'2016-01-01');
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela,desde) VALUES (@P4,53,'2019-01-01');
INSERT INTO Titulos (idUsuario,titulo) VALUES (@P4,N'Traductora Pública de Inglés');
INSERT INTO Titulos (idUsuario,titulo) VALUES (@P4,N'Profesora de Inglés (Lenguas Vivas)');

-- Gustavo Lescano (profesor)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Gustavo',N'Lescano',N'gustavo.lescano@seed.mip',@hash,N'50110027',N'Av. Seed 2052, CABA',N'privado/dni/seed-p5.webp',N'profesor','1991-11-20',DATEADD(DAY,-34,GETDATE()),0);
SET @P5 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@P5,N'<p>Clases claras y ordenadas de <strong>Química</strong>. Parto de lo que ya sabés y vamos paso a paso hasta el examen.</p><ul><li>Material de práctica incluido</li><li>Seguimiento por mensaje entre clases</li></ul>');
INSERT INTO InfoProfesores (idUsuario,precioHora) VALUES (@P5,8200);
INSERT INTO Usuarios_Materias (idUsuario,idMateria) SELECT @P5,ID FROM Materias WHERE nombre=N'Química';
INSERT INTO Usuarios_Materias (idUsuario,idMateria) SELECT @P5,ID FROM Materias WHERE nombre=N'Biología';
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P5,19);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P5,20);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P5,21);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P5,22);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P5,23);
INSERT INTO Profesores_Modalidades (idUsuario,idModalidad) VALUES (@P5,9);
INSERT INTO Profesores_Modalidades (idUsuario,idModalidad) VALUES (@P5,10);
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela,desde) VALUES (@P5,68,'2023-01-01');
INSERT INTO Titulos (idUsuario,titulo) VALUES (@P5,N'Licenciado en Ciencias Biológicas (UBA)');

-- Mariana Spinelli (profesor)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Mariana',N'Spinelli',N'mariana.spinelli@seed.mip',@hash,N'50110028',N'Av. Seed 2065, CABA',N'privado/dni/seed-p6.webp',N'profesor','1978-09-04',DATEADD(DAY,-51,GETDATE()),0);
SET @P6 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@P6,N'<p>Más de 10 años enseñando <strong>Programación</strong> a estudiantes de secundaria y facultad.</p><p>Armamos un plan según tus fechas de examen.</p>');
INSERT INTO InfoProfesores (idUsuario,precioHora) VALUES (@P6,9500);
INSERT INTO Usuarios_Materias (idUsuario,idMateria) SELECT @P6,ID FROM Materias WHERE nombre=N'Programación';
INSERT INTO Usuarios_Materias (idUsuario,idMateria) SELECT @P6,ID FROM Materias WHERE nombre=N'Tecnología y Robótica';
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P6,20);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P6,21);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P6,22);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P6,23);
INSERT INTO Profesores_Modalidades (idUsuario,idModalidad) VALUES (@P6,10);
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela,desde) VALUES (@P6,41,'2010-01-01');
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela,desde) VALUES (@P6,33,'2006-01-01');
INSERT INTO Titulos (idUsuario,titulo) VALUES (@P6,N'Analista Universitaria de Sistemas');
INSERT INTO Titulos (idUsuario,titulo) VALUES (@P6,N'Técnica en Robótica');

-- Diego Arce (profesor)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Diego',N'Arce',N'diego.arce@seed.mip',@hash,N'50110029',N'Av. Seed 2078, CABA',N'privado/dni/seed-p7.webp',N'profesor','1974-05-21',DATEADD(DAY,-168,GETDATE()),0);
SET @P7 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@P7,N'<p>Clases claras y ordenadas de <strong>Economía</strong>. Parto de lo que ya sabés y vamos paso a paso hasta el examen.</p><ul><li>Material de práctica incluido</li><li>Seguimiento por mensaje entre clases</li></ul>');
INSERT INTO InfoProfesores (idUsuario,precioHora) VALUES (@P7,8800);
INSERT INTO Usuarios_Materias (idUsuario,idMateria) SELECT @P7,ID FROM Materias WHERE nombre=N'Economía';
INSERT INTO Usuarios_Materias (idUsuario,idMateria) SELECT @P7,ID FROM Materias WHERE nombre=N'Contabilidad';
INSERT INTO Usuarios_Materias (idUsuario,idMateria) SELECT @P7,ID FROM Materias WHERE nombre=N'Estadística';
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P7,21);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P7,22);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P7,23);
INSERT INTO Profesores_Modalidades (idUsuario,idModalidad) VALUES (@P7,9);
INSERT INTO Profesores_Modalidades (idUsuario,idModalidad) VALUES (@P7,10);
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela,desde) VALUES (@P7,33,'2006-01-01');
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela,desde) VALUES (@P7,51,'2000-01-01');
INSERT INTO Titulos (idUsuario,titulo) VALUES (@P7,N'Contador Público (UBA)');
INSERT INTO Titulos (idUsuario,titulo) VALUES (@P7,N'Licenciado en Economía');

-- Paula Ledesma (profesor)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Paula',N'Ledesma',N'paula.ledesma@seed.mip',@hash,N'50110030',N'Av. Seed 2091, CABA',N'privado/dni/seed-p8.webp',N'profesor','1989-02-28',DATEADD(DAY,-33,GETDATE()),0);
SET @P8 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@P8,N'<p>Me gusta que entiendas el porqué de cada tema en <strong>Psicología</strong>, no solo memorizarlo. Ejercicios guiados y resúmenes al cierre de cada clase.</p>');
INSERT INTO InfoProfesores (idUsuario,precioHora) VALUES (@P8,6400);
INSERT INTO Usuarios_Materias (idUsuario,idMateria) SELECT @P8,ID FROM Materias WHERE nombre=N'Psicología';
INSERT INTO Usuarios_Materias (idUsuario,idMateria) SELECT @P8,ID FROM Materias WHERE nombre=N'Sociología';
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P8,20);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P8,21);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P8,23);
INSERT INTO Profesores_Modalidades (idUsuario,idModalidad) VALUES (@P8,10);
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela,desde) VALUES (@P8,67,'2021-01-01');
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela,desde) VALUES (@P8,21,'2013-01-01');
INSERT INTO Titulos (idUsuario,titulo) VALUES (@P8,N'Licenciada en Psicología (UBA)');

-- Marcelo Ruiz (profesor)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Marcelo',N'Ruiz',N'marcelo.ruiz@seed.mip',@hash,N'50110031',N'Av. Seed 2104, CABA',N'privado/dni/seed-p9.webp',N'profesor','1989-08-19',DATEADD(DAY,-205,GETDATE()),0);
SET @P9 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@P9,N'<p>Clases claras y ordenadas de <strong>Filosofía</strong>. Parto de lo que ya sabés y vamos paso a paso hasta el examen.</p><ul><li>Material de práctica incluido</li><li>Seguimiento por mensaje entre clases</li></ul>');
INSERT INTO InfoProfesores (idUsuario,precioHora) VALUES (@P9,5500);
INSERT INTO Usuarios_Materias (idUsuario,idMateria) SELECT @P9,ID FROM Materias WHERE nombre=N'Filosofía';
INSERT INTO Usuarios_Materias (idUsuario,idMateria) SELECT @P9,ID FROM Materias WHERE nombre=N'Formación Ética';
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P9,20);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P9,21);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P9,22);
INSERT INTO Profesores_Modalidades (idUsuario,idModalidad) VALUES (@P9,9);
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela,desde) VALUES (@P9,62,'2017-01-01');
INSERT INTO Titulos (idUsuario,titulo) VALUES (@P9,N'Profesor de Filosofía (UBA)');

-- Daniela Vidal (profesor)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Daniela',N'Vidal',N'daniela.vidal@seed.mip',@hash,N'50110032',N'Av. Seed 2117, CABA',N'privado/dni/seed-p10.webp',N'profesor','1990-11-03',DATEADD(DAY,-83,GETDATE()),0);
SET @P10 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@P10,N'<p>Me gusta que entiendas el porqué de cada tema en <strong>Francés</strong>, no solo memorizarlo. Ejercicios guiados y resúmenes al cierre de cada clase.</p>');
INSERT INTO InfoProfesores (idUsuario,precioHora) VALUES (@P10,6000);
INSERT INTO Usuarios_Materias (idUsuario,idMateria) SELECT @P10,ID FROM Materias WHERE nombre=N'Francés';
INSERT INTO Usuarios_Materias (idUsuario,idMateria) SELECT @P10,ID FROM Materias WHERE nombre=N'Italiano';
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P10,16);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P10,17);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P10,18);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P10,19);
INSERT INTO Profesores_Modalidades (idUsuario,idModalidad) VALUES (@P10,9);
INSERT INTO Profesores_Modalidades (idUsuario,idModalidad) VALUES (@P10,10);
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela,desde) VALUES (@P10,79,'2020-01-01');
INSERT INTO Titulos (idUsuario,titulo) VALUES (@P10,N'Profesora de Idiomas (Lenguas Vivas)');

-- Ezequiel Montes (profesor)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Ezequiel',N'Montes',N'ezequiel.montes@seed.mip',@hash,N'50110033',N'Av. Seed 2130, CABA',N'privado/dni/seed-p11.webp',N'profesor','1987-05-01',DATEADD(DAY,-28,GETDATE()),0);
SET @P11 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@P11,N'<p>Me gusta que entiendas el porqué de cada tema en <strong>Álgebra y Análisis</strong>, no solo memorizarlo. Ejercicios guiados y resúmenes al cierre de cada clase.</p>');
INSERT INTO InfoProfesores (idUsuario,precioHora) VALUES (@P11,9000);
INSERT INTO Usuarios_Materias (idUsuario,idMateria) SELECT @P11,ID FROM Materias WHERE nombre=N'Álgebra y Análisis';
INSERT INTO Usuarios_Materias (idUsuario,idMateria) SELECT @P11,ID FROM Materias WHERE nombre=N'Matemática';
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P11,23);
INSERT INTO Profesores_Modalidades (idUsuario,idModalidad) VALUES (@P11,9);
INSERT INTO Profesores_Modalidades (idUsuario,idModalidad) VALUES (@P11,10);
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela,desde) VALUES (@P11,70,'2011-01-01');

-- Rocío Paredes (profesor)
INSERT INTO Usuarios (nombre,apellido,mail,contrasena,dni,direccion,fotoDni,tipoUsuario,fechaNacimiento,fechaInscripcion,verificado)
VALUES (N'Rocío',N'Paredes',N'rocio.paredes@seed.mip',@hash,N'50110034',N'Av. Seed 2143, CABA',N'privado/dni/seed-p12.webp',N'profesor','1998-09-05',DATEADD(DAY,-73,GETDATE()),0);
SET @P12 = SCOPE_IDENTITY();
INSERT INTO Perfiles (idUsuario,descripcion) VALUES (@P12,N'<p>Más de 10 años enseñando <strong>Música</strong> a estudiantes de secundaria y facultad.</p><p>Armamos un plan según tus fechas de examen.</p>');
INSERT INTO InfoProfesores (idUsuario,precioHora) VALUES (@P12,5200);
INSERT INTO Usuarios_Materias (idUsuario,idMateria) SELECT @P12,ID FROM Materias WHERE nombre=N'Música';
INSERT INTO Usuarios_Materias (idUsuario,idMateria) SELECT @P12,ID FROM Materias WHERE nombre=N'Teatro';
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P12,16);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P12,17);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P12,18);
INSERT INTO Usuarios_Niveles (idUsuario,idNivel) VALUES (@P12,22);
INSERT INTO Profesores_Modalidades (idUsuario,idModalidad) VALUES (@P12,9);
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela,desde) VALUES (@P12,27,'2024-01-01');
INSERT INTO Escuelas_Usuarios (idUsuario,idEscuela,desde) VALUES (@P12,74,'2025-01-01');
INSERT INTO Titulos (idUsuario,titulo) VALUES (@P12,N'Profesora de Música (Conservatorio Manuel de Falla)');

-- Verificado = no falta ningún dato (los pocos incompletos quedan sin verificar a propósito)
UPDATE Usuarios SET verificado = CASE WHEN EXISTS (SELECT 1 FROM dbo.faltantesVerificacion(ID)) THEN 0 ELSE 1 END
WHERE mail LIKE N'%@seed.mip';

-- ---------------------------------------------------------------- clases

INSERT INTO Clases (idEmisor,idReceptor,estado,fecha,fechaEmision)
VALUES
  (57,5,N'Completada',DATEADD(HOUR,18,DATEADD(DAY,-48,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,18,DATEADD(DAY,-48,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (57,5,N'Completada',DATEADD(HOUR,18,DATEADD(DAY,-42,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,18,DATEADD(DAY,-42,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (57,5,N'Completada',DATEADD(HOUR,11,DATEADD(DAY,-9,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,11,DATEADD(DAY,-9,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (57,5,N'Completada',DATEADD(HOUR,14,DATEADD(DAY,-38,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,14,DATEADD(DAY,-38,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (57,8,N'Completada',DATEADD(HOUR,12,DATEADD(DAY,-40,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,12,DATEADD(DAY,-40,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (57,8,N'Completada',DATEADD(HOUR,12,DATEADD(DAY,-76,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,12,DATEADD(DAY,-76,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (57,8,N'Completada',DATEADD(HOUR,17,DATEADD(DAY,-30,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,17,DATEADD(DAY,-30,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (57,31,N'Completada',DATEADD(HOUR,9,DATEADD(DAY,-17,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,9,DATEADD(DAY,-17,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (57,31,N'Completada',DATEADD(HOUR,20,DATEADD(DAY,-33,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,20,DATEADD(DAY,-33,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (57,9,N'Completada',DATEADD(HOUR,15,DATEADD(DAY,-101,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,15,DATEADD(DAY,-101,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (57,9,N'Completada',DATEADD(HOUR,20,DATEADD(DAY,-63,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,20,DATEADD(DAY,-63,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (57,9,N'Completada',DATEADD(HOUR,13,DATEADD(DAY,-71,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,13,DATEADD(DAY,-71,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (57,12,N'Completada',DATEADD(HOUR,15,DATEADD(DAY,-54,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,15,DATEADD(DAY,-54,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (57,12,N'Completada',DATEADD(HOUR,12,DATEADD(DAY,-33,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,12,DATEADD(DAY,-33,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (57,20,N'Completada',DATEADD(HOUR,20,DATEADD(DAY,-91,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,20,DATEADD(DAY,-91,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (57,20,N'Completada',DATEADD(HOUR,16,DATEADD(DAY,-86,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,16,DATEADD(DAY,-86,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (57,24,N'Completada',DATEADD(HOUR,13,DATEADD(DAY,-42,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,13,DATEADD(DAY,-42,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (57,24,N'Completada',DATEADD(HOUR,14,DATEADD(DAY,-101,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,14,DATEADD(DAY,-101,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (57,33,N'Completada',DATEADD(HOUR,18,DATEADD(DAY,-45,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,18,DATEADD(DAY,-45,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (57,33,N'Completada',DATEADD(HOUR,13,DATEADD(DAY,-54,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,13,DATEADD(DAY,-54,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (57,@P1,N'Completada',DATEADD(HOUR,12,DATEADD(DAY,-19,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,12,DATEADD(DAY,-19,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (57,@P1,N'Completada',DATEADD(HOUR,12,DATEADD(DAY,-62,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,12,DATEADD(DAY,-62,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (57,@P1,N'Completada',DATEADD(HOUR,13,DATEADD(DAY,-27,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,13,DATEADD(DAY,-27,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (57,@P2,N'Completada',DATEADD(HOUR,11,DATEADD(DAY,-78,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,11,DATEADD(DAY,-78,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (57,@P2,N'Completada',DATEADD(HOUR,20,DATEADD(DAY,-64,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,20,DATEADD(DAY,-64,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (57,@P3,N'Completada',DATEADD(HOUR,12,DATEADD(DAY,-157,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,12,DATEADD(DAY,-157,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (57,@P3,N'Completada',DATEADD(HOUR,15,DATEADD(DAY,-82,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,15,DATEADD(DAY,-82,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (57,58,N'Completada',DATEADD(HOUR,13,DATEADD(DAY,-12,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,13,DATEADD(DAY,-12,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (57,8,N'Rechazada',DATEADD(HOUR,9,DATEADD(DAY,-18,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,9,DATEADD(DAY,-18,CAST(CAST(GETDATE() AS DATE) AS DATETIME)))),
  (57,31,N'Cancelada',DATEADD(HOUR,12,DATEADD(DAY,-9,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-27,DATEADD(HOUR,12,DATEADD(DAY,-9,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (9,57,N'Cancelada',DATEADD(HOUR,16,DATEADD(DAY,-22,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-28,DATEADD(HOUR,16,DATEADD(DAY,-22,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (57,5,N'Confirmada',DATEADD(HOUR,12,DATEADD(DAY,2,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-11,GETDATE())),
  (57,9,N'Confirmada',DATEADD(HOUR,5,DATEADD(HOUR,DATEDIFF(HOUR,0,GETDATE()),0)),DATEADD(HOUR,-36,GETDATE())),
  (57,8,N'Pendiente',DATEADD(HOUR,19,DATEADD(DAY,4,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-2,GETDATE())),
  (12,57,N'Pendiente',DATEADD(HOUR,9,DATEADD(DAY,6,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-52,GETDATE())),
  (57,20,N'Rechazada',DATEADD(HOUR,18,DATEADD(DAY,5,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-15,GETDATE())),
  (57,58,N'Confirmada',DATEADD(HOUR,10,DATEADD(DAY,3,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-27,GETDATE())),
  (52,3,N'Completada',DATEADD(HOUR,12,DATEADD(DAY,-18,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,12,DATEADD(DAY,-18,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (55,5,N'Completada',DATEADD(HOUR,14,DATEADD(DAY,-91,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,14,DATEADD(DAY,-91,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (52,5,N'Completada',DATEADD(HOUR,17,DATEADD(DAY,-6,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,17,DATEADD(DAY,-6,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (53,5,N'Completada',DATEADD(HOUR,15,DATEADD(DAY,-77,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,15,DATEADD(DAY,-77,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (55,6,N'Completada',DATEADD(HOUR,11,DATEADD(DAY,-30,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,11,DATEADD(DAY,-30,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (55,6,N'Completada',DATEADD(HOUR,18,DATEADD(DAY,-66,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,18,DATEADD(DAY,-66,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (53,6,N'Completada',DATEADD(HOUR,17,DATEADD(DAY,-15,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,17,DATEADD(DAY,-15,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (52,6,N'Completada',DATEADD(HOUR,14,DATEADD(DAY,-40,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,14,DATEADD(DAY,-40,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (56,6,N'Completada',DATEADD(HOUR,11,DATEADD(DAY,-89,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,11,DATEADD(DAY,-89,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (56,8,N'Completada',DATEADD(HOUR,10,DATEADD(DAY,-7,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,10,DATEADD(DAY,-7,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (54,8,N'Completada',DATEADD(HOUR,9,DATEADD(DAY,-47,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,9,DATEADD(DAY,-47,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (54,8,N'Completada',DATEADD(HOUR,18,DATEADD(DAY,-34,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,18,DATEADD(DAY,-34,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (51,8,N'Completada',DATEADD(HOUR,16,DATEADD(DAY,-13,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,16,DATEADD(DAY,-13,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (55,9,N'Completada',DATEADD(HOUR,18,DATEADD(DAY,-12,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,18,DATEADD(DAY,-12,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (55,9,N'Completada',DATEADD(HOUR,13,DATEADD(DAY,-77,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,13,DATEADD(DAY,-77,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (51,9,N'Completada',DATEADD(HOUR,10,DATEADD(DAY,-66,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,10,DATEADD(DAY,-66,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (51,10,N'Completada',DATEADD(HOUR,9,DATEADD(DAY,-36,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,9,DATEADD(DAY,-36,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (53,10,N'Completada',DATEADD(HOUR,10,DATEADD(DAY,-100,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,10,DATEADD(DAY,-100,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (53,10,N'Completada',DATEADD(HOUR,18,DATEADD(DAY,-97,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,18,DATEADD(DAY,-97,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (56,10,N'Completada',DATEADD(HOUR,19,DATEADD(DAY,-89,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,19,DATEADD(DAY,-89,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (54,10,N'Completada',DATEADD(HOUR,15,DATEADD(DAY,-42,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,15,DATEADD(DAY,-42,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (54,13,N'Completada',DATEADD(HOUR,13,DATEADD(DAY,-75,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,13,DATEADD(DAY,-75,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (56,13,N'Completada',DATEADD(HOUR,18,DATEADD(DAY,-10,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,18,DATEADD(DAY,-10,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (55,13,N'Completada',DATEADD(HOUR,16,DATEADD(DAY,-78,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,16,DATEADD(DAY,-78,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (55,13,N'Completada',DATEADD(HOUR,14,DATEADD(DAY,-12,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,14,DATEADD(DAY,-12,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (54,14,N'Completada',DATEADD(HOUR,14,DATEADD(DAY,-19,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,14,DATEADD(DAY,-19,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (54,14,N'Completada',DATEADD(HOUR,19,DATEADD(DAY,-121,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,19,DATEADD(DAY,-121,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (52,14,N'Completada',DATEADD(HOUR,20,DATEADD(DAY,-50,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,20,DATEADD(DAY,-50,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (56,15,N'Completada',DATEADD(HOUR,11,DATEADD(DAY,-76,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,11,DATEADD(DAY,-76,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (53,16,N'Completada',DATEADD(HOUR,17,DATEADD(DAY,-71,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,17,DATEADD(DAY,-71,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (51,16,N'Completada',DATEADD(HOUR,10,DATEADD(DAY,-46,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,10,DATEADD(DAY,-46,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (51,16,N'Completada',DATEADD(HOUR,18,DATEADD(DAY,-122,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,18,DATEADD(DAY,-122,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (56,16,N'Completada',DATEADD(HOUR,19,DATEADD(DAY,-92,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,19,DATEADD(DAY,-92,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (54,16,N'Completada',DATEADD(HOUR,19,DATEADD(DAY,-66,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,19,DATEADD(DAY,-66,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (52,18,N'Completada',DATEADD(HOUR,14,DATEADD(DAY,-51,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,14,DATEADD(DAY,-51,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (56,18,N'Completada',DATEADD(HOUR,12,DATEADD(DAY,-48,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,12,DATEADD(DAY,-48,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (54,18,N'Completada',DATEADD(HOUR,14,DATEADD(DAY,-20,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,14,DATEADD(DAY,-20,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (53,18,N'Completada',DATEADD(HOUR,14,DATEADD(DAY,-54,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,14,DATEADD(DAY,-54,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (53,19,N'Completada',DATEADD(HOUR,15,DATEADD(DAY,-40,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,15,DATEADD(DAY,-40,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (52,19,N'Completada',DATEADD(HOUR,14,DATEADD(DAY,-36,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,14,DATEADD(DAY,-36,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (52,19,N'Completada',DATEADD(HOUR,12,DATEADD(DAY,-128,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,12,DATEADD(DAY,-128,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (56,19,N'Completada',DATEADD(HOUR,19,DATEADD(DAY,-27,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,19,DATEADD(DAY,-27,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (54,20,N'Completada',DATEADD(HOUR,12,DATEADD(DAY,-23,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,12,DATEADD(DAY,-23,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (54,20,N'Completada',DATEADD(HOUR,10,DATEADD(DAY,-130,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,10,DATEADD(DAY,-130,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (54,21,N'Completada',DATEADD(HOUR,15,DATEADD(DAY,-117,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,15,DATEADD(DAY,-117,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (54,21,N'Completada',DATEADD(HOUR,18,DATEADD(DAY,-113,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,18,DATEADD(DAY,-113,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (56,23,N'Completada',DATEADD(HOUR,17,DATEADD(DAY,-39,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,17,DATEADD(DAY,-39,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (53,23,N'Completada',DATEADD(HOUR,11,DATEADD(DAY,-39,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,11,DATEADD(DAY,-39,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (51,23,N'Completada',DATEADD(HOUR,16,DATEADD(DAY,-106,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,16,DATEADD(DAY,-106,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (51,23,N'Completada',DATEADD(HOUR,18,DATEADD(DAY,-36,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,18,DATEADD(DAY,-36,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (56,24,N'Completada',DATEADD(HOUR,18,DATEADD(DAY,-75,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,18,DATEADD(DAY,-75,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (53,24,N'Completada',DATEADD(HOUR,10,DATEADD(DAY,-92,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,10,DATEADD(DAY,-92,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (51,24,N'Completada',DATEADD(HOUR,20,DATEADD(DAY,-70,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,20,DATEADD(DAY,-70,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (52,25,N'Completada',DATEADD(HOUR,11,DATEADD(DAY,-122,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,11,DATEADD(DAY,-122,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (55,26,N'Completada',DATEADD(HOUR,14,DATEADD(DAY,-19,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,14,DATEADD(DAY,-19,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (55,28,N'Completada',DATEADD(HOUR,16,DATEADD(DAY,-23,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,16,DATEADD(DAY,-23,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (54,28,N'Completada',DATEADD(HOUR,12,DATEADD(DAY,-97,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,12,DATEADD(DAY,-97,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (54,28,N'Completada',DATEADD(HOUR,14,DATEADD(DAY,-124,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,14,DATEADD(DAY,-124,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (53,28,N'Completada',DATEADD(HOUR,16,DATEADD(DAY,-86,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,16,DATEADD(DAY,-86,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (51,28,N'Completada',DATEADD(HOUR,13,DATEADD(DAY,-93,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,13,DATEADD(DAY,-93,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (52,29,N'Completada',DATEADD(HOUR,20,DATEADD(DAY,-113,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,20,DATEADD(DAY,-113,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (56,29,N'Completada',DATEADD(HOUR,20,DATEADD(DAY,-102,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,20,DATEADD(DAY,-102,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (51,29,N'Completada',DATEADD(HOUR,11,DATEADD(DAY,-74,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,11,DATEADD(DAY,-74,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (55,30,N'Completada',DATEADD(HOUR,18,DATEADD(DAY,-86,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,18,DATEADD(DAY,-86,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (54,30,N'Completada',DATEADD(HOUR,12,DATEADD(DAY,-80,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,12,DATEADD(DAY,-80,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (56,31,N'Completada',DATEADD(HOUR,14,DATEADD(DAY,-82,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,14,DATEADD(DAY,-82,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (55,31,N'Completada',DATEADD(HOUR,17,DATEADD(DAY,-129,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,17,DATEADD(DAY,-129,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (54,31,N'Completada',DATEADD(HOUR,17,DATEADD(DAY,-48,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,17,DATEADD(DAY,-48,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (54,31,N'Completada',DATEADD(HOUR,20,DATEADD(DAY,-88,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,20,DATEADD(DAY,-88,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (52,33,N'Completada',DATEADD(HOUR,19,DATEADD(DAY,-6,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,19,DATEADD(DAY,-6,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (55,33,N'Completada',DATEADD(HOUR,20,DATEADD(DAY,-43,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,20,DATEADD(DAY,-43,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (51,33,N'Completada',DATEADD(HOUR,19,DATEADD(DAY,-92,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,19,DATEADD(DAY,-92,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (51,34,N'Completada',DATEADD(HOUR,12,DATEADD(DAY,-95,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,12,DATEADD(DAY,-95,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (53,34,N'Completada',DATEADD(HOUR,20,DATEADD(DAY,-76,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,20,DATEADD(DAY,-76,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (54,34,N'Completada',DATEADD(HOUR,18,DATEADD(DAY,-80,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,18,DATEADD(DAY,-80,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (54,34,N'Completada',DATEADD(HOUR,15,DATEADD(DAY,-56,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,15,DATEADD(DAY,-56,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (56,34,N'Completada',DATEADD(HOUR,11,DATEADD(DAY,-5,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,11,DATEADD(DAY,-5,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (51,35,N'Completada',DATEADD(HOUR,13,DATEADD(DAY,-83,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,13,DATEADD(DAY,-83,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (51,35,N'Completada',DATEADD(HOUR,19,DATEADD(DAY,-88,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,19,DATEADD(DAY,-88,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (56,35,N'Completada',DATEADD(HOUR,17,DATEADD(DAY,-10,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,17,DATEADD(DAY,-10,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (54,35,N'Completada',DATEADD(HOUR,11,DATEADD(DAY,-97,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,11,DATEADD(DAY,-97,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (52,35,N'Completada',DATEADD(HOUR,15,DATEADD(DAY,-119,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,15,DATEADD(DAY,-119,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (53,36,N'Completada',DATEADD(HOUR,13,DATEADD(DAY,-83,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,13,DATEADD(DAY,-83,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (55,36,N'Completada',DATEADD(HOUR,9,DATEADD(DAY,-43,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,9,DATEADD(DAY,-43,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (55,36,N'Completada',DATEADD(HOUR,9,DATEADD(DAY,-123,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,9,DATEADD(DAY,-123,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (52,36,N'Completada',DATEADD(HOUR,14,DATEADD(DAY,-48,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,14,DATEADD(DAY,-48,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (52,36,N'Completada',DATEADD(HOUR,11,DATEADD(DAY,-48,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,11,DATEADD(DAY,-48,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (54,36,N'Completada',DATEADD(HOUR,13,DATEADD(DAY,-13,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,13,DATEADD(DAY,-13,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (54,36,N'Completada',DATEADD(HOUR,10,DATEADD(DAY,-53,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,10,DATEADD(DAY,-53,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (51,38,N'Completada',DATEADD(HOUR,15,DATEADD(DAY,-112,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,15,DATEADD(DAY,-112,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (51,38,N'Completada',DATEADD(HOUR,19,DATEADD(DAY,-49,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,19,DATEADD(DAY,-49,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (52,38,N'Completada',DATEADD(HOUR,16,DATEADD(DAY,-52,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,16,DATEADD(DAY,-52,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (53,38,N'Completada',DATEADD(HOUR,20,DATEADD(DAY,-119,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,20,DATEADD(DAY,-119,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (54,39,N'Completada',DATEADD(HOUR,15,DATEADD(DAY,-81,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,15,DATEADD(DAY,-81,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (54,39,N'Completada',DATEADD(HOUR,18,DATEADD(DAY,-109,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,18,DATEADD(DAY,-109,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (54,40,N'Completada',DATEADD(HOUR,18,DATEADD(DAY,-17,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,18,DATEADD(DAY,-17,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (52,40,N'Completada',DATEADD(HOUR,10,DATEADD(DAY,-22,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,10,DATEADD(DAY,-22,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (55,40,N'Completada',DATEADD(HOUR,13,DATEADD(DAY,-83,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,13,DATEADD(DAY,-83,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (53,41,N'Completada',DATEADD(HOUR,16,DATEADD(DAY,-114,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,16,DATEADD(DAY,-114,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (51,43,N'Completada',DATEADD(HOUR,15,DATEADD(DAY,-48,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,15,DATEADD(DAY,-48,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (53,43,N'Completada',DATEADD(HOUR,18,DATEADD(DAY,-53,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,18,DATEADD(DAY,-53,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (53,43,N'Completada',DATEADD(HOUR,19,DATEADD(DAY,-92,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,19,DATEADD(DAY,-92,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (53,44,N'Completada',DATEADD(HOUR,11,DATEADD(DAY,-115,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,11,DATEADD(DAY,-115,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (53,44,N'Completada',DATEADD(HOUR,12,DATEADD(DAY,-122,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,12,DATEADD(DAY,-122,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (55,44,N'Completada',DATEADD(HOUR,16,DATEADD(DAY,-115,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,16,DATEADD(DAY,-115,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (55,44,N'Completada',DATEADD(HOUR,16,DATEADD(DAY,-66,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,16,DATEADD(DAY,-66,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (56,44,N'Completada',DATEADD(HOUR,15,DATEADD(DAY,-67,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,15,DATEADD(DAY,-67,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (53,45,N'Completada',DATEADD(HOUR,12,DATEADD(DAY,-83,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,12,DATEADD(DAY,-83,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (51,45,N'Completada',DATEADD(HOUR,17,DATEADD(DAY,-118,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,17,DATEADD(DAY,-118,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (51,45,N'Completada',DATEADD(HOUR,17,DATEADD(DAY,-48,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,17,DATEADD(DAY,-48,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (54,46,N'Completada',DATEADD(HOUR,19,DATEADD(DAY,-17,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,19,DATEADD(DAY,-17,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (52,46,N'Completada',DATEADD(HOUR,11,DATEADD(DAY,-114,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,11,DATEADD(DAY,-114,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (52,46,N'Completada',DATEADD(HOUR,17,DATEADD(DAY,-116,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,17,DATEADD(DAY,-116,CAST(CAST(GETDATE() AS DATE) AS DATETIME)))));

INSERT INTO Clases (idEmisor,idReceptor,estado,fecha,fechaEmision)
VALUES
  (51,49,N'Completada',DATEADD(HOUR,19,DATEADD(DAY,-6,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,19,DATEADD(DAY,-6,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (52,49,N'Completada',DATEADD(HOUR,10,DATEADD(DAY,-78,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,10,DATEADD(DAY,-78,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (52,49,N'Completada',DATEADD(HOUR,10,DATEADD(DAY,-14,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,10,DATEADD(DAY,-14,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (51,8,N'Cancelada',DATEADD(HOUR,17,DATEADD(DAY,-43,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-2,DATEADD(HOUR,17,DATEADD(DAY,-43,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (51,9,N'Rechazada',DATEADD(HOUR,11,DATEADD(DAY,-23,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,11,DATEADD(DAY,-23,CAST(CAST(GETDATE() AS DATE) AS DATETIME)))),
  (53,5,N'Cancelada',DATEADD(HOUR,20,DATEADD(DAY,-25,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-16,DATEADD(HOUR,20,DATEADD(DAY,-25,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (55,5,N'Rechazada',DATEADD(HOUR,14,DATEADD(DAY,-24,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,14,DATEADD(DAY,-24,CAST(CAST(GETDATE() AS DATE) AS DATETIME)))),
  (51,5,N'Confirmada',DATEADD(HOUR,13,DATEADD(DAY,4,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-14,GETDATE())),
  (52,8,N'Pendiente',DATEADD(HOUR,13,DATEADD(DAY,3,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-40,GETDATE())),
  (53,9,N'Confirmada',DATEADD(HOUR,15,DATEADD(DAY,6,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-6,GETDATE())),
  (31,54,N'Pendiente',DATEADD(HOUR,11,DATEADD(DAY,5,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-35,GETDATE())),
  (@A1,@P5,N'Completada',DATEADD(HOUR,15,DATEADD(DAY,-48,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,15,DATEADD(DAY,-48,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A1,@P10,N'Completada',DATEADD(HOUR,18,DATEADD(DAY,-100,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,18,DATEADD(DAY,-100,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A1,12,N'Completada',DATEADD(HOUR,12,DATEADD(DAY,-161,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,12,DATEADD(DAY,-161,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A1,4,N'Completada',DATEADD(HOUR,16,DATEADD(DAY,-23,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,16,DATEADD(DAY,-23,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A1,@P12,N'Completada',DATEADD(HOUR,20,DATEADD(DAY,-42,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,20,DATEADD(DAY,-42,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A1,9,N'Completada',DATEADD(HOUR,13,DATEADD(DAY,-26,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,13,DATEADD(DAY,-26,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A1,12,N'Completada',DATEADD(HOUR,13,DATEADD(DAY,-110,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,13,DATEADD(DAY,-110,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A1,@P5,N'Completada',DATEADD(HOUR,14,DATEADD(DAY,-149,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,14,DATEADD(DAY,-149,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A1,@P9,N'Completada',DATEADD(HOUR,15,DATEADD(DAY,-120,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,15,DATEADD(DAY,-120,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A1,4,N'Completada',DATEADD(HOUR,12,DATEADD(DAY,-108,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,12,DATEADD(DAY,-108,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A1,5,N'Completada',DATEADD(HOUR,17,DATEADD(DAY,-15,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,17,DATEADD(DAY,-15,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A1,@P1,N'Completada',DATEADD(HOUR,13,DATEADD(DAY,-71,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,13,DATEADD(DAY,-71,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A1,40,N'Completada',DATEADD(HOUR,10,DATEADD(DAY,-158,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,10,DATEADD(DAY,-158,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A1,@P6,N'Rechazada',DATEADD(HOUR,12,DATEADD(DAY,-99,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,12,DATEADD(DAY,-99,CAST(CAST(GETDATE() AS DATE) AS DATETIME)))),
  (@A1,@P3,N'Cancelada',DATEADD(HOUR,11,DATEADD(DAY,-99,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-29,DATEADD(HOUR,11,DATEADD(DAY,-99,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A1,20,N'Completada',DATEADD(HOUR,13,DATEADD(DAY,-127,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,13,DATEADD(DAY,-127,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A1,4,N'Completada',DATEADD(HOUR,19,DATEADD(DAY,-69,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,19,DATEADD(DAY,-69,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A1,@P12,N'Completada',DATEADD(HOUR,19,DATEADD(DAY,-29,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,19,DATEADD(DAY,-29,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A1,@P9,N'Completada',DATEADD(HOUR,14,DATEADD(DAY,-26,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,14,DATEADD(DAY,-26,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A1,@P5,N'Completada',DATEADD(HOUR,10,DATEADD(DAY,-4,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,10,DATEADD(DAY,-4,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A1,@P10,N'Completada',DATEADD(HOUR,12,DATEADD(DAY,-130,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,12,DATEADD(DAY,-130,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A1,@P6,N'Completada',DATEADD(HOUR,17,DATEADD(DAY,-2,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,17,DATEADD(DAY,-2,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A1,12,N'Rechazada',DATEADD(HOUR,13,DATEADD(DAY,11,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-21,GETDATE())),
  (@A2,@P8,N'Cancelada',DATEADD(HOUR,11,DATEADD(DAY,-83,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-27,DATEADD(HOUR,11,DATEADD(DAY,-83,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A2,@P6,N'Completada',DATEADD(HOUR,16,DATEADD(DAY,-14,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,16,DATEADD(DAY,-14,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A2,20,N'Completada',DATEADD(HOUR,9,DATEADD(DAY,-7,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,9,DATEADD(DAY,-7,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A2,@P4,N'Completada',DATEADD(HOUR,9,DATEADD(DAY,-118,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,9,DATEADD(DAY,-118,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A2,9,N'Completada',DATEADD(HOUR,18,DATEADD(DAY,-111,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,18,DATEADD(DAY,-111,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A2,9,N'Completada',DATEADD(HOUR,10,DATEADD(DAY,-86,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,10,DATEADD(DAY,-86,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A2,@P8,N'Cancelada',DATEADD(HOUR,13,DATEADD(DAY,-37,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-18,DATEADD(HOUR,13,DATEADD(DAY,-37,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (33,@A2,N'Cancelada',DATEADD(HOUR,13,DATEADD(DAY,-85,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-25,DATEADD(HOUR,13,DATEADD(DAY,-85,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A2,3,N'Completada',DATEADD(HOUR,11,DATEADD(DAY,-21,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,11,DATEADD(DAY,-21,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A2,@P4,N'Completada',DATEADD(HOUR,19,DATEADD(DAY,-103,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,19,DATEADD(DAY,-103,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A2,8,N'Completada',DATEADD(HOUR,15,DATEADD(DAY,-8,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,15,DATEADD(DAY,-8,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A2,3,N'Completada',DATEADD(HOUR,19,DATEADD(DAY,-107,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,19,DATEADD(DAY,-107,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A2,3,N'Completada',DATEADD(HOUR,13,DATEADD(DAY,-48,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,13,DATEADD(DAY,-48,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A2,20,N'Completada',DATEADD(HOUR,20,DATEADD(DAY,-34,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,20,DATEADD(DAY,-34,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A2,31,N'Completada',DATEADD(HOUR,14,DATEADD(DAY,-120,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,14,DATEADD(DAY,-120,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A2,8,N'Completada',DATEADD(HOUR,9,DATEADD(DAY,-91,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,9,DATEADD(DAY,-91,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A2,@P1,N'Completada',DATEADD(HOUR,12,DATEADD(DAY,-126,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,12,DATEADD(DAY,-126,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A2,45,N'Completada',DATEADD(HOUR,17,DATEADD(DAY,-22,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,17,DATEADD(DAY,-22,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A2,5,N'Cancelada',DATEADD(HOUR,15,DATEADD(DAY,-46,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-26,DATEADD(HOUR,15,DATEADD(DAY,-46,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A2,9,N'Completada',DATEADD(HOUR,14,DATEADD(DAY,-70,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,14,DATEADD(DAY,-70,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A2,3,N'Completada',DATEADD(HOUR,19,DATEADD(DAY,-86,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,19,DATEADD(DAY,-86,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A2,@P7,N'Completada',DATEADD(HOUR,16,DATEADD(DAY,-47,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,16,DATEADD(DAY,-47,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A2,9,N'Completada',DATEADD(HOUR,12,DATEADD(DAY,-109,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,12,DATEADD(DAY,-109,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A2,12,N'Pendiente',DATEADD(HOUR,20,DATEADD(DAY,20,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-55,GETDATE())),
  (@A2,@P12,N'Rechazada',DATEADD(HOUR,17,DATEADD(DAY,18,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-37,GETDATE())),
  (@A3,5,N'Completada',DATEADD(HOUR,16,DATEADD(DAY,-139,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,16,DATEADD(DAY,-139,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A3,8,N'Completada',DATEADD(HOUR,14,DATEADD(DAY,-74,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,14,DATEADD(DAY,-74,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A3,@P8,N'Completada',DATEADD(HOUR,9,DATEADD(DAY,-99,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,9,DATEADD(DAY,-99,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A3,40,N'Completada',DATEADD(HOUR,10,DATEADD(DAY,-147,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,10,DATEADD(DAY,-147,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A4,@P1,N'Cancelada',DATEADD(HOUR,16,DATEADD(DAY,-73,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-23,DATEADD(HOUR,16,DATEADD(DAY,-73,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A4,5,N'Completada',DATEADD(HOUR,18,DATEADD(DAY,-82,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,18,DATEADD(DAY,-82,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A4,5,N'Completada',DATEADD(HOUR,15,DATEADD(DAY,-143,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,15,DATEADD(DAY,-143,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A4,12,N'Completada',DATEADD(HOUR,12,DATEADD(DAY,-90,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,12,DATEADD(DAY,-90,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@P5,@A5,N'Cancelada',DATEADD(HOUR,15,DATEADD(DAY,-140,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-10,DATEADD(HOUR,15,DATEADD(DAY,-140,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A5,5,N'Completada',DATEADD(HOUR,10,DATEADD(DAY,-62,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,10,DATEADD(DAY,-62,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A5,8,N'Completada',DATEADD(HOUR,13,DATEADD(DAY,-105,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,13,DATEADD(DAY,-105,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A5,@P3,N'Completada',DATEADD(HOUR,17,DATEADD(DAY,-161,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,17,DATEADD(DAY,-161,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A5,9,N'Completada',DATEADD(HOUR,11,DATEADD(DAY,-18,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,11,DATEADD(DAY,-18,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A5,@P10,N'Completada',DATEADD(HOUR,12,DATEADD(DAY,-77,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,12,DATEADD(DAY,-77,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A5,5,N'Completada',DATEADD(HOUR,19,DATEADD(DAY,-151,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,19,DATEADD(DAY,-151,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A5,@P1,N'Completada',DATEADD(HOUR,20,DATEADD(DAY,-12,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,20,DATEADD(DAY,-12,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A5,@P5,N'Confirmada',DATEADD(HOUR,12,DATEADD(DAY,18,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-52,GETDATE())),
  (58,@A5,N'Pendiente',DATEADD(HOUR,13,DATEADD(DAY,5,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-20,GETDATE())),
  (@A6,@P6,N'Completada',DATEADD(HOUR,17,DATEADD(DAY,-116,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,17,DATEADD(DAY,-116,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A6,22,N'Completada',DATEADD(HOUR,12,DATEADD(DAY,-91,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,12,DATEADD(DAY,-91,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A6,@P12,N'Completada',DATEADD(HOUR,20,DATEADD(DAY,-145,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,20,DATEADD(DAY,-145,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A6,@P1,N'Completada',DATEADD(HOUR,20,DATEADD(DAY,-151,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,20,DATEADD(DAY,-151,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@P8,@A6,N'Rechazada',DATEADD(HOUR,20,DATEADD(DAY,-143,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,20,DATEADD(DAY,-143,CAST(CAST(GETDATE() AS DATE) AS DATETIME)))),
  (@A6,14,N'Completada',DATEADD(HOUR,14,DATEADD(DAY,-99,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,14,DATEADD(DAY,-99,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A6,9,N'Completada',DATEADD(HOUR,16,DATEADD(DAY,-72,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,16,DATEADD(DAY,-72,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A6,@P12,N'Completada',DATEADD(HOUR,18,DATEADD(DAY,-29,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,18,DATEADD(DAY,-29,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A6,@P9,N'Confirmada',DATEADD(HOUR,19,DATEADD(DAY,18,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-47,GETDATE())),
  (@A6,@P11,N'Pendiente',DATEADD(HOUR,17,DATEADD(DAY,4,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-4,GETDATE())),
  (@A7,@P6,N'Completada',DATEADD(HOUR,13,DATEADD(DAY,-95,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,13,DATEADD(DAY,-95,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A7,31,N'Completada',DATEADD(HOUR,9,DATEADD(DAY,-67,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,9,DATEADD(DAY,-67,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A7,5,N'Completada',DATEADD(HOUR,12,DATEADD(DAY,-151,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,12,DATEADD(DAY,-151,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A7,@P10,N'Confirmada',DATEADD(HOUR,20,DATEADD(DAY,4,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-12,GETDATE())),
  (@P1,@A7,N'Pendiente',DATEADD(HOUR,12,DATEADD(DAY,15,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-28,GETDATE())),
  (@A8,14,N'Completada',DATEADD(HOUR,13,DATEADD(DAY,-94,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,13,DATEADD(DAY,-94,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A8,14,N'Completada',DATEADD(HOUR,9,DATEADD(DAY,-47,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,9,DATEADD(DAY,-47,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A8,@P6,N'Completada',DATEADD(HOUR,10,DATEADD(DAY,-37,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,10,DATEADD(DAY,-37,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A8,5,N'Completada',DATEADD(HOUR,19,DATEADD(DAY,-149,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,19,DATEADD(DAY,-149,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@P4,@A8,N'Cancelada',DATEADD(HOUR,20,DATEADD(DAY,-42,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-7,DATEADD(HOUR,20,DATEADD(DAY,-42,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A8,@P8,N'Completada',DATEADD(HOUR,11,DATEADD(DAY,-96,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,11,DATEADD(DAY,-96,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A9,@P5,N'Completada',DATEADD(HOUR,18,DATEADD(DAY,-82,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,18,DATEADD(DAY,-82,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A9,8,N'Completada',DATEADD(HOUR,11,DATEADD(DAY,-157,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,11,DATEADD(DAY,-157,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A9,22,N'Completada',DATEADD(HOUR,19,DATEADD(DAY,-158,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,19,DATEADD(DAY,-158,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A9,9,N'Completada',DATEADD(HOUR,17,DATEADD(DAY,-170,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,17,DATEADD(DAY,-170,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A9,@P9,N'Completada',DATEADD(HOUR,20,DATEADD(DAY,-138,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,20,DATEADD(DAY,-138,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A9,@P10,N'Completada',DATEADD(HOUR,13,DATEADD(DAY,-137,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,13,DATEADD(DAY,-137,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A10,5,N'Cancelada',DATEADD(HOUR,19,DATEADD(DAY,-78,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-9,DATEADD(HOUR,19,DATEADD(DAY,-78,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A10,@P1,N'Completada',DATEADD(HOUR,12,DATEADD(DAY,-71,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,12,DATEADD(DAY,-71,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A10,@P5,N'Completada',DATEADD(HOUR,13,DATEADD(DAY,-40,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,13,DATEADD(DAY,-40,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A10,5,N'Completada',DATEADD(HOUR,20,DATEADD(DAY,-130,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,20,DATEADD(DAY,-130,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A10,@P2,N'Completada',DATEADD(HOUR,10,DATEADD(DAY,-36,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,10,DATEADD(DAY,-36,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A10,@P5,N'Completada',DATEADD(HOUR,18,DATEADD(DAY,-90,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,18,DATEADD(DAY,-90,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (58,@A10,N'Rechazada',DATEADD(HOUR,10,DATEADD(DAY,7,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-24,GETDATE())),
  (@A11,@P9,N'Completada',DATEADD(HOUR,10,DATEADD(DAY,-28,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,10,DATEADD(DAY,-28,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A11,5,N'Completada',DATEADD(HOUR,13,DATEADD(DAY,-146,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,13,DATEADD(DAY,-146,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A11,5,N'Completada',DATEADD(HOUR,20,DATEADD(DAY,-2,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,20,DATEADD(DAY,-2,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A11,@P6,N'Completada',DATEADD(HOUR,17,DATEADD(DAY,-93,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,17,DATEADD(DAY,-93,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A11,@P7,N'Completada',DATEADD(HOUR,17,DATEADD(DAY,-105,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,17,DATEADD(DAY,-105,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A11,4,N'Completada',DATEADD(HOUR,9,DATEADD(DAY,-34,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,9,DATEADD(DAY,-34,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A11,22,N'Rechazada',DATEADD(HOUR,16,DATEADD(DAY,16,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-38,GETDATE())),
  (40,@A11,N'Pendiente',DATEADD(HOUR,14,DATEADD(DAY,7,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-35,GETDATE())),
  (@A12,3,N'Completada',DATEADD(HOUR,13,DATEADD(DAY,-73,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,13,DATEADD(DAY,-73,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A12,@P4,N'Completada',DATEADD(HOUR,10,DATEADD(DAY,-123,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,10,DATEADD(DAY,-123,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A12,5,N'Completada',DATEADD(HOUR,19,DATEADD(DAY,-43,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,19,DATEADD(DAY,-43,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A12,8,N'Completada',DATEADD(HOUR,10,DATEADD(DAY,-75,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,10,DATEADD(DAY,-75,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A12,45,N'Completada',DATEADD(HOUR,15,DATEADD(DAY,-58,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,15,DATEADD(DAY,-58,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A12,@P12,N'Completada',DATEADD(HOUR,11,DATEADD(DAY,-69,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,11,DATEADD(DAY,-69,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A12,14,N'Completada',DATEADD(HOUR,12,DATEADD(DAY,-116,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,12,DATEADD(DAY,-116,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A12,@P7,N'Confirmada',DATEADD(HOUR,9,DATEADD(DAY,8,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-40,GETDATE())),
  (@A13,@P2,N'Completada',DATEADD(HOUR,11,DATEADD(DAY,-154,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,11,DATEADD(DAY,-154,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A13,45,N'Completada',DATEADD(HOUR,16,DATEADD(DAY,-44,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,16,DATEADD(DAY,-44,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A13,3,N'Confirmada',DATEADD(HOUR,17,DATEADD(DAY,7,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-38,GETDATE())),
  (@P1,@A13,N'Pendiente',DATEADD(HOUR,16,DATEADD(DAY,2,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-7,GETDATE())),
  (@A14,9,N'Cancelada',DATEADD(HOUR,9,DATEADD(DAY,-117,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-15,DATEADD(HOUR,9,DATEADD(DAY,-117,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@P3,@A14,N'Rechazada',DATEADD(HOUR,9,DATEADD(DAY,-114,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,9,DATEADD(DAY,-114,CAST(CAST(GETDATE() AS DATE) AS DATETIME)))),
  (@A14,@P9,N'Completada',DATEADD(HOUR,16,DATEADD(DAY,-30,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,16,DATEADD(DAY,-30,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A14,12,N'Completada',DATEADD(HOUR,20,DATEADD(DAY,-48,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,20,DATEADD(DAY,-48,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A14,3,N'Rechazada',DATEADD(HOUR,13,DATEADD(DAY,-17,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,13,DATEADD(DAY,-17,CAST(CAST(GETDATE() AS DATE) AS DATETIME)))),
  (@A14,@P2,N'Confirmada',DATEADD(HOUR,17,DATEADD(DAY,14,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-1,GETDATE())),
  (@A14,@P10,N'Confirmada',DATEADD(HOUR,18,DATEADD(DAY,16,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-60,GETDATE())),
  (@A15,45,N'Completada',DATEADD(HOUR,20,DATEADD(DAY,-58,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,20,DATEADD(DAY,-58,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A15,14,N'Completada',DATEADD(HOUR,9,DATEADD(DAY,-28,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,9,DATEADD(DAY,-28,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A15,45,N'Pendiente',DATEADD(HOUR,11,DATEADD(DAY,11,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-40,GETDATE())),
  (@A15,@P10,N'Confirmada',DATEADD(HOUR,15,DATEADD(DAY,2,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-12,GETDATE())),
  (@A16,@P7,N'Completada',DATEADD(HOUR,19,DATEADD(DAY,-15,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,19,DATEADD(DAY,-15,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A16,@P12,N'Completada',DATEADD(HOUR,9,DATEADD(DAY,-104,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,9,DATEADD(DAY,-104,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A16,@P5,N'Completada',DATEADD(HOUR,14,DATEADD(DAY,-10,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,14,DATEADD(DAY,-10,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A16,14,N'Completada',DATEADD(HOUR,20,DATEADD(DAY,-111,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,20,DATEADD(DAY,-111,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A16,33,N'Confirmada',DATEADD(HOUR,16,DATEADD(DAY,17,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-48,GETDATE())),
  (@A16,@P5,N'Pendiente',DATEADD(HOUR,9,DATEADD(DAY,14,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-5,GETDATE())),
  (@A17,@P10,N'Completada',DATEADD(HOUR,16,DATEADD(DAY,-83,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,16,DATEADD(DAY,-83,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A17,12,N'Completada',DATEADD(HOUR,17,DATEADD(DAY,-161,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,17,DATEADD(DAY,-161,CAST(CAST(GETDATE() AS DATE) AS DATETIME)))));

INSERT INTO Clases (idEmisor,idReceptor,estado,fecha,fechaEmision)
VALUES
  (@A17,8,N'Completada',DATEADD(HOUR,16,DATEADD(DAY,-25,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,16,DATEADD(DAY,-25,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A17,8,N'Completada',DATEADD(HOUR,17,DATEADD(DAY,-158,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,17,DATEADD(DAY,-158,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A17,45,N'Completada',DATEADD(HOUR,15,DATEADD(DAY,-170,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,15,DATEADD(DAY,-170,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A17,@P5,N'Cancelada',DATEADD(HOUR,20,DATEADD(DAY,-45,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-3,DATEADD(HOUR,20,DATEADD(DAY,-45,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A17,3,N'Completada',DATEADD(HOUR,15,DATEADD(DAY,-66,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,15,DATEADD(DAY,-66,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A18,9,N'Pendiente',DATEADD(HOUR,16,DATEADD(DAY,4,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-5,GETDATE())),
  (@A18,@P12,N'Confirmada',DATEADD(HOUR,9,DATEADD(DAY,8,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-2,GETDATE())),
  (@A19,8,N'Pendiente',DATEADD(HOUR,17,DATEADD(DAY,3,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-2,GETDATE())),
  (@A19,40,N'Confirmada',DATEADD(HOUR,10,DATEADD(DAY,11,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-48,GETDATE())),
  (@A20,33,N'Completada',DATEADD(HOUR,10,DATEADD(DAY,-162,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,10,DATEADD(DAY,-162,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A20,@P1,N'Completada',DATEADD(HOUR,12,DATEADD(DAY,-49,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,12,DATEADD(DAY,-49,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A20,14,N'Completada',DATEADD(HOUR,11,DATEADD(DAY,-103,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,11,DATEADD(DAY,-103,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@P1,@A20,N'Rechazada',DATEADD(HOUR,18,DATEADD(DAY,20,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(HOUR,-49,GETDATE())),
  (@A3,@P1,N'Completada',DATEADD(HOUR,15,DATEADD(DAY,-75,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,15,DATEADD(DAY,-75,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A4,@P1,N'Completada',DATEADD(HOUR,14,DATEADD(DAY,-127,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,14,DATEADD(DAY,-127,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A5,@P1,N'Completada',DATEADD(HOUR,14,DATEADD(DAY,-121,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,14,DATEADD(DAY,-121,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A6,@P1,N'Completada',DATEADD(HOUR,9,DATEADD(DAY,-149,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,9,DATEADD(DAY,-149,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A7,@P1,N'Completada',DATEADD(HOUR,20,DATEADD(DAY,-42,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,20,DATEADD(DAY,-42,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A8,@P1,N'Completada',DATEADD(HOUR,15,DATEADD(DAY,-31,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,15,DATEADD(DAY,-31,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A9,@P1,N'Completada',DATEADD(HOUR,19,DATEADD(DAY,-109,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,19,DATEADD(DAY,-109,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A10,@P1,N'Completada',DATEADD(HOUR,10,DATEADD(DAY,-133,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,10,DATEADD(DAY,-133,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A11,@P1,N'Completada',DATEADD(HOUR,13,DATEADD(DAY,-47,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,13,DATEADD(DAY,-47,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A12,@P1,N'Completada',DATEADD(HOUR,9,DATEADD(DAY,-126,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,9,DATEADD(DAY,-126,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A13,@P1,N'Completada',DATEADD(HOUR,20,DATEADD(DAY,-47,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,20,DATEADD(DAY,-47,CAST(CAST(GETDATE() AS DATE) AS DATETIME))))),
  (@A14,@P1,N'Completada',DATEADD(HOUR,17,DATEADD(DAY,-147,CAST(CAST(GETDATE() AS DATE) AS DATETIME))),DATEADD(MINUTE,60,DATEADD(HOUR,17,DATEADD(DAY,-147,CAST(CAST(GETDATE() AS DATE) AS DATETIME)))));

-- ---------------------------------------------------------------- reseñas (el orden = el orden de ID: la última es la que vale)

INSERT INTO Resenas (idEmisor,idReceptor,estado,puntuacion,descripcion)
VALUES
  (57,5,N'Aprobada',3,N'Correcto, sin más.'),
  (57,5,N'Aprobada',5,N'Muy buenos ejemplos y material.'),
  (57,8,N'Aprobada',4,N'A veces va rápido, pero responde todas las dudas.'),
  (57,9,N'Aprobada',3,N'Está bien, esperaba un poco más de práctica.'),
  (57,9,N'Aprobada',5,N'Explica clarísimo, aprobé el examen.'),
  (57,12,N'Pendiente',4,N'Muy paciente y ordenado.'),
  (57,20,N'Rechazada',2,N'Me costó seguir el ritmo de la clase.'),
  (57,33,N'Aprobada',5,N'Excelente profesor, lo recomiendo.'),
  (57,@P1,N'Aprobada',5,N'Excelente profesor, lo recomiendo.'),
  (57,@P3,N'Aprobada',4,N'Muy paciente y ordenado.'),
  (@A1,@P5,N'Aprobada',5,N'Muy buenos ejemplos y material.'),
  (@A1,@P10,N'Aprobada',4,N'Muy paciente y ordenado.'),
  (@A1,12,N'Aprobada',3,N'Explica bien pero llegó tarde una vez.'),
  (@A1,4,N'Rechazada',4,N'A veces va rápido, pero responde todas las dudas.'),
  (@A1,9,N'Aprobada',2,N'No me terminó de convencer.'),
  (@A1,@P9,N'Aprobada',1,N'No volvería a tomar clases.'),
  (@A1,@P9,N'Aprobada',5,N'Las clases son dinámicas y entretenidas.'),
  (@A1,5,N'Aprobada',3,N'Está bien, esperaba un poco más de práctica.'),
  (@A1,5,N'Aprobada',5,N'Explica clarísimo, aprobé el examen.'),
  (@A1,@P1,N'Aprobada',4,N'A veces va rápido, pero responde todas las dudas.'),
  (@A1,20,N'Aprobada',5,N'Explica clarísimo, aprobé el examen.'),
  (@A1,@P6,N'Aprobada',2,N'Me costó seguir el ritmo de la clase.'),
  (@A1,@P6,N'Aprobada',5,N'Excelente profesor, lo recomiendo.'),
  (@A2,@P6,N'Aprobada',3,N'Explica bien pero llegó tarde una vez.'),
  (@A2,@P6,N'Aprobada',2,N'No me terminó de convencer.'),
  (@A2,20,N'Aprobada',2,N'Me costó seguir el ritmo de la clase.'),
  (@A2,8,N'Aprobada',5,N'Excelente profesor, lo recomiendo.'),
  (@A2,@P1,N'Aprobada',5,N'Excelente profesor, lo recomiendo.'),
  (@A2,45,N'Aprobada',5,N'Explica clarísimo, aprobé el examen.'),
  (@A2,@P7,N'Aprobada',4,N'Buena onda y puntual.'),
  (@A3,5,N'Aprobada',5,N'Muy buenos ejemplos y material.'),
  (@A3,8,N'Pendiente',4,N'Muy paciente y ordenado.'),
  (@A3,@P8,N'Aprobada',3,N'Está bien, esperaba un poco más de práctica.'),
  (@A3,40,N'Aprobada',3,N'Correcto, sin más.'),
  (@A5,5,N'Aprobada',1,N'No volvería a tomar clases.'),
  (@A5,8,N'Aprobada',3,N'Correcto, sin más.'),
  (@A5,@P3,N'Aprobada',1,N'No volvería a tomar clases.'),
  (@A5,@P1,N'Aprobada',4,N'Buena onda y puntual.'),
  (@A6,@P12,N'Aprobada',3,N'Correcto, sin más.'),
  (@A6,@P1,N'Aprobada',5,N'Las clases son dinámicas y entretenidas.'),
  (@A6,9,N'Aprobada',5,N'Explica clarísimo, aprobé el examen.'),
  (@A7,5,N'Aprobada',5,N'Muy buenos ejemplos y material.'),
  (@A8,14,N'Aprobada',5,N'Las clases son dinámicas y entretenidas.'),
  (@A8,@P6,N'Aprobada',5,N'Explica clarísimo, aprobé el examen.'),
  (@A8,5,N'Aprobada',1,N'No volvería a tomar clases.'),
  (@A8,@P8,N'Aprobada',5,N'Muy buenos ejemplos y material.'),
  (@A9,8,N'Aprobada',4,N'Me ayudó un montón antes del final.'),
  (@A9,22,N'Aprobada',3,N'Correcto, sin más.'),
  (@A9,9,N'Aprobada',4,N'Muy paciente y ordenado.'),
  (@A9,@P9,N'Aprobada',2,N'Me costó seguir el ritmo de la clase.'),
  (@A9,@P10,N'Aprobada',4,N'Me ayudó un montón antes del final.'),
  (@A11,@P9,N'Aprobada',5,N'Explica clarísimo, aprobé el examen.'),
  (@A11,5,N'Aprobada',3,N'Está bien, esperaba un poco más de práctica.'),
  (@A11,@P6,N'Aprobada',5,N'Excelente profesor, lo recomiendo.'),
  (@A11,4,N'Aprobada',5,N'Las clases son dinámicas y entretenidas.'),
  (@A11,4,N'Aprobada',3,N'Explica bien pero llegó tarde una vez.'),
  (@A12,3,N'Rechazada',4,N'A veces va rápido, pero responde todas las dudas.'),
  (@A12,5,N'Aprobada',3,N'Explica bien pero llegó tarde una vez.'),
  (@A12,8,N'Aprobada',5,N'Explica clarísimo, aprobé el examen.'),
  (@A12,45,N'Aprobada',5,N'Explica clarísimo, aprobé el examen.'),
  (@A12,14,N'Aprobada',5,N'Muy buenos ejemplos y material.'),
  (@A13,@P2,N'Aprobada',5,N'Excelente profesor, lo recomiendo.'),
  (@A14,12,N'Aprobada',4,N'Muy paciente y ordenado.'),
  (@A15,45,N'Aprobada',5,N'Las clases son dinámicas y entretenidas.'),
  (@A15,14,N'Aprobada',5,N'Excelente profesor, lo recomiendo.'),
  (@A16,@P7,N'Aprobada',5,N'Excelente profesor, lo recomiendo.'),
  (@A16,@P12,N'Aprobada',5,N'Excelente profesor, lo recomiendo.'),
  (@A16,@P5,N'Aprobada',5,N'Excelente profesor, lo recomiendo.'),
  (@A17,@P10,N'Aprobada',2,N'No me terminó de convencer.'),
  (@A17,@P10,N'Aprobada',2,N'Me costó seguir el ritmo de la clase.'),
  (@A17,8,N'Aprobada',1,N'No volvería a tomar clases.'),
  (@A20,33,N'Aprobada',5,N'Excelente profesor, lo recomiendo.'),
  (@A20,@P1,N'Aprobada',4,N'A veces va rápido, pero responde todas las dudas.'),
  (@A20,14,N'Aprobada',5,N'Explica clarísimo, aprobé el examen.'),
  (@A4,@P1,N'Aprobada',3,N'Correcto, sin más.'),
  (@A7,@P1,N'Aprobada',5,N'Las clases son dinámicas y entretenidas.'),
  (@A8,@P1,N'Aprobada',5,N'Muy buenos ejemplos y material.'),
  (@A9,@P1,N'Aprobada',4,N'Buena onda y puntual.'),
  (@A12,@P1,N'Aprobada',5,N'Excelente profesor, lo recomiendo.'),
  (51,9,N'Aprobada',3,N'Bajó un poco el nivel en las últimas clases.'),
  (53,10,N'Aprobada',5,N'Mejoró muchísimo, excelente.'),
  (31,57,N'Aprobada',5,N'Estudiante puntual y con ganas de aprender.'),
  (33,57,N'Aprobada',5,N'Estudiante puntual y con ganas de aprender.'),
  (@P1,57,N'Aprobada',3,N'Estudiante puntual y con ganas de aprender.'),
  (@P2,57,N'Aprobada',4,N'Le falta constancia pero va mejorando.'),
  (3,52,N'Aprobada',4,N'Muy dedicado, hizo toda la tarea.'),
  (6,55,N'Aprobada',5,N'Estudiante puntual y con ganas de aprender.'),
  (6,52,N'Aprobada',3,N'Le falta constancia pero va mejorando.'),
  (8,54,N'Aprobada',5,N'Estudiante puntual y con ganas de aprender.'),
  (9,55,N'Aprobada',5,N'Participa y pregunta, da gusto enseñarle.'),
  (10,53,N'Aprobada',3,N'Estudiante puntual y con ganas de aprender.'),
  (13,55,N'Aprobada',3,N'Muy dedicado, hizo toda la tarea.'),
  (16,53,N'Aprobada',4,N'Muy dedicado, hizo toda la tarea.'),
  (16,51,N'Aprobada',3,N'Participa y pregunta, da gusto enseñarle.'),
  (16,56,N'Aprobada',3,N'Estudiante puntual y con ganas de aprender.'),
  (18,52,N'Aprobada',4,N'Participa y pregunta, da gusto enseñarle.'),
  (19,53,N'Aprobada',5,N'Le falta constancia pero va mejorando.'),
  (19,52,N'Aprobada',3,N'Muy dedicado, hizo toda la tarea.'),
  (21,54,N'Aprobada',3,N'Muy dedicado, hizo toda la tarea.'),
  (23,51,N'Aprobada',5,N'Participa y pregunta, da gusto enseñarle.'),
  (24,56,N'Aprobada',4,N'Muy dedicado, hizo toda la tarea.'),
  (24,51,N'Aprobada',4,N'Le falta constancia pero va mejorando.'),
  (25,52,N'Aprobada',5,N'Estudiante puntual y con ganas de aprender.'),
  (26,55,N'Aprobada',5,N'Muy dedicado, hizo toda la tarea.'),
  (28,53,N'Aprobada',3,N'Muy dedicado, hizo toda la tarea.'),
  (29,56,N'Aprobada',5,N'Estudiante puntual y con ganas de aprender.'),
  (31,56,N'Aprobada',4,N'Participa y pregunta, da gusto enseñarle.'),
  (31,54,N'Aprobada',5,N'Muy dedicado, hizo toda la tarea.'),
  (34,51,N'Aprobada',5,N'Participa y pregunta, da gusto enseñarle.'),
  (36,55,N'Aprobada',5,N'Le falta constancia pero va mejorando.'),
  (38,52,N'Aprobada',3,N'Muy dedicado, hizo toda la tarea.'),
  (39,54,N'Aprobada',3,N'Estudiante puntual y con ganas de aprender.'),
  (40,55,N'Aprobada',4,N'Muy dedicado, hizo toda la tarea.'),
  (46,54,N'Aprobada',3,N'Muy dedicado, hizo toda la tarea.'),
  (49,51,N'Aprobada',3,N'Estudiante puntual y con ganas de aprender.'),
  (9,@A1,N'Aprobada',4,N'Muy dedicado, hizo toda la tarea.'),
  (40,@A1,N'Aprobada',5,N'Le falta constancia pero va mejorando.'),
  (@P6,@A1,N'Aprobada',3,N'Participa y pregunta, da gusto enseñarle.'),
  (3,@A2,N'Aprobada',5,N'Le falta constancia pero va mejorando.'),
  (8,@A2,N'Aprobada',5,N'Le falta constancia pero va mejorando.'),
  (@P8,@A3,N'Aprobada',5,N'Estudiante puntual y con ganas de aprender.'),
  (40,@A3,N'Aprobada',5,N'Participa y pregunta, da gusto enseñarle.'),
  (5,@A4,N'Aprobada',5,N'Muy dedicado, hizo toda la tarea.'),
  (8,@A5,N'Aprobada',5,N'Muy dedicado, hizo toda la tarea.'),
  (@P6,@A6,N'Aprobada',3,N'Le falta constancia pero va mejorando.'),
  (31,@A7,N'Aprobada',5,N'Participa y pregunta, da gusto enseñarle.'),
  (14,@A8,N'Aprobada',5,N'Estudiante puntual y con ganas de aprender.'),
  (@P6,@A8,N'Aprobada',4,N'Muy dedicado, hizo toda la tarea.'),
  (5,@A8,N'Aprobada',4,N'Participa y pregunta, da gusto enseñarle.'),
  (@P8,@A8,N'Aprobada',5,N'Participa y pregunta, da gusto enseñarle.'),
  (@P1,@A10,N'Aprobada',5,N'Estudiante puntual y con ganas de aprender.'),
  (@P9,@A11,N'Aprobada',5,N'Muy dedicado, hizo toda la tarea.'),
  (@P7,@A11,N'Aprobada',5,N'Estudiante puntual y con ganas de aprender.'),
  (8,@A12,N'Aprobada',3,N'Participa y pregunta, da gusto enseñarle.'),
  (14,@A12,N'Aprobada',4,N'Muy dedicado, hizo toda la tarea.'),
  (45,@A13,N'Aprobada',4,N'Muy dedicado, hizo toda la tarea.'),
  (@P9,@A14,N'Aprobada',3,N'Le falta constancia pero va mejorando.'),
  (14,@A15,N'Aprobada',4,N'Participa y pregunta, da gusto enseñarle.'),
  (14,@A16,N'Aprobada',5,N'Muy dedicado, hizo toda la tarea.'),
  (@P10,@A17,N'Aprobada',4,N'Estudiante puntual y con ganas de aprender.'),
  (12,@A17,N'Aprobada',4,N'Le falta constancia pero va mejorando.'),
  (3,@A17,N'Aprobada',3,N'Participa y pregunta, da gusto enseñarle.'),
  (@P1,@A20,N'Aprobada',3,N'Estudiante puntual y con ganas de aprender.'),
  (@P1,@A7,N'Aprobada',5,N'Le falta constancia pero va mejorando.'),
  (@P1,@A11,N'Aprobada',4,N'Muy dedicado, hizo toda la tarea.');

-- ---------------------------------------------------------------- me gusta

INSERT INTO Likes (idEmisor,idReceptor)
VALUES
  (52,40),
  (6,@A5),
  (55,57),
  (@A20,25),
  (6,@A7),
  (@A16,@P12),
  (@A21,24),
  (@A4,4),
  (@A8,3),
  (55,20),
  (55,@P7),
  (@A10,9),
  (@A1,@P11),
  (@A5,11),
  (@A12,22),
  (56,37),
  (@A6,9),
  (51,16),
  (@A15,23),
  (@A5,@P7),
  (@A15,32),
  (@A12,@A23),
  (28,@A18),
  (@A18,@P5),
  (@A13,10),
  (@A2,57),
  (@A18,@P7),
  (@A5,41),
  (56,3),
  (@A24,25),
  (41,@A17),
  (@A19,@P3),
  (@A24,34),
  (@A10,57),
  (@A14,30),
  (@A10,11),
  (@A9,20),
  (@A20,@A19),
  (@A22,41),
  (@A8,@P3),
  (@A6,20),
  (@A19,7),
  (55,43),
  (@A13,58),
  (40,@A20),
  (@A15,43),
  (@A17,40),
  (@A9,50),
  (@A20,29),
  (@A10,50),
  (@A19,@P9),
  (@A4,@P2),
  (50,56),
  (57,34),
  (@A22,@P12),
  (@A4,@A12),
  (@A8,16),
  (51,57),
  (@A11,33),
  (@A8,25),
  (@A1,12),
  (@A13,42),
  (57,6),
  (17,@A9),
  (51,29),
  (@A20,4),
  (24,@A3),
  (34,@A4),
  (@A6,@P4),
  (53,57),
  (55,@P11),
  (@A9,43),
  (55,@P2),
  (56,7),
  (24,@A18),
  (@A9,15),
  (@P12,57),
  (@A19,39),
  (@A23,25),
  (@A15,11),
  (@A3,@P3),
  (@A7,@P5),
  (57,@P2),
  (17,@A7),
  (52,12),
  (@A15,@P7),
  (51,22),
  (18,53),
  (@A24,4),
  (56,46),
  (@P10,57),
  (55,@A22),
  (@A9,45),
  (@A20,24),
  (@A14,9),
  (@A19,23),
  (@A22,@P5),
  (@A1,44),
  (@A8,11),
  (45,@A5),
  (@A22,@P7),
  (@A11,28),
  (57,47),
  (56,@P10),
  (@A8,@P7),
  (@A23,18),
  (@A14,36),
  (@A6,54),
  (@A13,37),
  (52,14),
  (@A2,29),
  (@A16,36),
  (@A2,38),
  (@A6,26),
  (@A17,28),
  (55,@P1),
  (@A18,13),
  (57,31),
  (57,@P4),
  (@A3,@P10),
  (57,49),
  (54,@P3),
  (@A4,8),
  (@A23,@P7),
  (@P10,@A23),
  (@A16,29),
  (36,@A24),
  (@A5,6),
  (57,@P1),
  (@A11,48),
  (@A16,38),
  (57,58),
  (@A17,21),
  (@A9,31),
  (16,@A1),
  (@A13,@P5),
  (@A14,4),
  (54,7),
  (51,38),
  (51,@A6),
  (@A3,57),
  (51,47),
  (@A10,58),
  (55,@A1),
  (@A1,48),
  (@A1,57),
  (@A20,40),
  (@A18,42),
  (@A2,24),
  (@A16,@P4);

INSERT INTO Likes (idEmisor,idReceptor)
VALUES
  (@A24,47),
  (@A9,24),
  (@A1,@P7),
  (@A17,23),
  (@A7,20),
  (57,8),
  (@P12,@A13),
  (@A1,24),
  (51,31),
  (@A15,38),
  (@A22,@P2),
  (6,@A1),
  (54,9),
  (@A14,15),
  (54,@P10),
  (52,57),
  (@A2,17),
  (@A20,42),
  (@A19,47),
  (@A9,17),
  (52,20),
  (54,39),
  (@A24,58),
  (52,@P7),
  (@A10,@P8),
  (@A24,3),
  (@A1,@P12),
  (@A6,@P3),
  (@A14,@P11),
  (@A4,@P6),
  (57,19),
  (@A1,@A21),
  (56,@P2),
  (@A15,40),
  (@A1,34),
  (@A11,9),
  (51,42),
  (@A14,@A12),
  (@A11,@P10),
  (@A3,@A5),
  (55,21),
  (@A16,26),
  (33,55),
  (54,32),
  (@A8,22),
  (@A17,18),
  (@A9,28),
  (57,3),
  (@A14,47),
  (@A17,@P10),
  (@A7,24),
  (57,12),
  (@A15,33),
  (@A9,46),
  (@A11,11),
  (@A19,24),
  (@A4,53),
  (@A24,26),
  (53,17),
  (53,@P3),
  (55,14),
  (@A1,@P2),
  (@A7,54),
  (@A7,@P11),
  (@A5,5),
  (@A14,31),
  (@A7,@A16),
  (@A1,11),
  (57,5),
  (@A15,@P8),
  (@A22,@A17),
  (@A7,26),
  (@A6,21),
  (57,14),
  (@A10,39),
  (@A23,49),
  (@A19,8),
  (@A10,@P6),
  (@A1,20),
  (@A6,30),
  (35,@A24),
  (@P3,@A17),
  (@A23,@P1),
  (@A20,21),
  (@A17,41),
  (30,@A18),
  (@A9,5),
  (@A21,38),
  (@A1,4),
  (53,46),
  (@A12,27),
  (57,7),
  (@A22,44),
  (@A23,42),
  (@A17,@A23),
  (@A1,40),
  (@A14,@A1),
  (52,47),
  (@A14,@P3),
  (@A13,33),
  (@A22,19),
  (@A14,@P8),
  (@A9,16),
  (@A24,48),
  (51,5),
  (@A21,49),
  (48,52),
  (51,14),
  (@A14,44),
  (@A1,15),
  (@A8,37),
  (57,9),
  (@A11,@P11),
  (@A1,33);

-- ---------------------------------------------------------------- mensajes de chat
-- Cada conversación en orden (del más viejo al más nuevo). Los últimos mensajes seguidos de la misma persona
-- quedan 'No visto' en dos de cada tres chats (sirven para probar las notificaciones y el chat); el resto, 'Visto'.

INSERT INTO Mensajes (idEmisor,idReceptor,contenido,estado,fechaEnvio) VALUES
  (57,5,N'Hola, ¿tenés lugar para una clase esta semana?',N'Visto',DATEADD(MINUTE,-19477,GETDATE())),
  (5,57,N'Hola, sí. ¿Qué día te viene bien?',N'Visto',DATEADD(MINUTE,-19194,GETDATE())),
  (57,5,N'El jueves a la tarde si puede ser.',N'Visto',DATEADD(MINUTE,-15866,GETDATE())),
  (5,57,N'Perfecto, te mando el pedido. Traé los ejercicios que te cuesten.',N'Visto',DATEADD(MINUTE,-8821,GETDATE())),
  (57,5,N'Genial, gracias. Nos vemos.',N'No visto',DATEADD(MINUTE,-6888,GETDATE()));

INSERT INTO Mensajes (idEmisor,idReceptor,contenido,estado,fechaEnvio) VALUES
  (57,8,N'Hola, ¿tenés lugar para una clase esta semana?',N'Visto',DATEADD(MINUTE,-27531,GETDATE())),
  (8,57,N'Hola, sí. ¿Qué día te viene bien?',N'Visto',DATEADD(MINUTE,-25345,GETDATE())),
  (57,8,N'El jueves a la tarde si puede ser.',N'Visto',DATEADD(MINUTE,-21288,GETDATE())),
  (8,57,N'Perfecto, te mando el pedido. Traé los ejercicios que te cuesten.',N'Visto',DATEADD(MINUTE,-12555,GETDATE())),
  (57,8,N'Genial, gracias. Nos vemos.',N'Visto',DATEADD(MINUTE,-7731,GETDATE())),
  (8,57,N'Acordate de repasar el tema 3 antes de la clase.',N'Visto',DATEADD(MINUTE,-1372,GETDATE())),
  (57,8,N'Dale, lo reviso hoy.',N'No visto',DATEADD(MINUTE,-425,GETDATE()));

INSERT INTO Mensajes (idEmisor,idReceptor,contenido,estado,fechaEnvio) VALUES
  (57,9,N'Hola, ¿tenés lugar para una clase esta semana?',N'Visto',DATEADD(MINUTE,-27574,GETDATE())),
  (9,57,N'Hola, sí. ¿Qué día te viene bien?',N'Visto',DATEADD(MINUTE,-24798,GETDATE())),
  (57,9,N'El jueves a la tarde si puede ser.',N'Visto',DATEADD(MINUTE,-20980,GETDATE())),
  (9,57,N'Perfecto, te mando el pedido. Traé los ejercicios que te cuesten.',N'Visto',DATEADD(MINUTE,-1019,GETDATE()));

INSERT INTO Mensajes (idEmisor,idReceptor,contenido,estado,fechaEnvio) VALUES
  (57,12,N'Hola, ¿tenés lugar para una clase esta semana?',N'Visto',DATEADD(MINUTE,-27127,GETDATE())),
  (12,57,N'Hola, sí. ¿Qué día te viene bien?',N'Visto',DATEADD(MINUTE,-19363,GETDATE())),
  (57,12,N'El jueves a la tarde si puede ser.',N'Visto',DATEADD(MINUTE,-18211,GETDATE())),
  (12,57,N'Perfecto, te mando el pedido. Traé los ejercicios que te cuesten.',N'Visto',DATEADD(MINUTE,-11943,GETDATE())),
  (57,12,N'Genial, gracias. Nos vemos.',N'No visto',DATEADD(MINUTE,-6732,GETDATE()));

INSERT INTO Mensajes (idEmisor,idReceptor,contenido,estado,fechaEnvio) VALUES
  (57,24,N'Hola, ¿tenés lugar para una clase esta semana?',N'Visto',DATEADD(MINUTE,-22038,GETDATE())),
  (24,57,N'Hola, sí. ¿Qué día te viene bien?',N'Visto',DATEADD(MINUTE,-14476,GETDATE())),
  (57,24,N'El jueves a la tarde si puede ser.',N'Visto',DATEADD(MINUTE,-9007,GETDATE())),
  (24,57,N'Perfecto, te mando el pedido. Traé los ejercicios que te cuesten.',N'No visto',DATEADD(MINUTE,-3711,GETDATE()));

INSERT INTO Mensajes (idEmisor,idReceptor,contenido,estado,fechaEnvio) VALUES
  (57,@P2,N'Hola, ¿tenés lugar para una clase esta semana?',N'Visto',DATEADD(MINUTE,-27807,GETDATE())),
  (@P2,57,N'Hola, sí. ¿Qué día te viene bien?',N'Visto',DATEADD(MINUTE,-23190,GETDATE())),
  (57,@P2,N'El jueves a la tarde si puede ser.',N'Visto',DATEADD(MINUTE,-18322,GETDATE())),
  (@P2,57,N'Perfecto, te mando el pedido. Traé los ejercicios que te cuesten.',N'Visto',DATEADD(MINUTE,-17144,GETDATE())),
  (57,@P2,N'Genial, gracias. Nos vemos.',N'Visto',DATEADD(MINUTE,-16181,GETDATE())),
  (@P2,57,N'Acordate de repasar el tema 3 antes de la clase.',N'Visto',DATEADD(MINUTE,-14169,GETDATE()));

INSERT INTO Mensajes (idEmisor,idReceptor,contenido,estado,fechaEnvio) VALUES
  (57,58,N'Hola, ¿tenés lugar para una clase esta semana?',N'Visto',DATEADD(MINUTE,-12799,GETDATE())),
  (58,57,N'Hola, sí. ¿Qué día te viene bien?',N'Visto',DATEADD(MINUTE,-10075,GETDATE())),
  (57,58,N'El jueves a la tarde si puede ser.',N'Visto',DATEADD(MINUTE,-3957,GETDATE())),
  (58,57,N'Perfecto, te mando el pedido. Traé los ejercicios que te cuesten.',N'Visto',DATEADD(MINUTE,-3623,GETDATE())),
  (57,58,N'Genial, gracias. Nos vemos.',N'Visto',DATEADD(MINUTE,-3577,GETDATE())),
  (58,57,N'Acordate de repasar el tema 3 antes de la clase.',N'No visto',DATEADD(MINUTE,-410,GETDATE()));

INSERT INTO Mensajes (idEmisor,idReceptor,contenido,estado,fechaEnvio) VALUES
  (53,6,N'Hola, ¿tenés lugar para una clase esta semana?',N'Visto',DATEADD(MINUTE,-26911,GETDATE())),
  (6,53,N'Hola, sí. ¿Qué día te viene bien?',N'Visto',DATEADD(MINUTE,-23192,GETDATE())),
  (53,6,N'El jueves a la tarde si puede ser.',N'Visto',DATEADD(MINUTE,-13881,GETDATE())),
  (6,53,N'Perfecto, te mando el pedido. Traé los ejercicios que te cuesten.',N'Visto',DATEADD(MINUTE,-13589,GETDATE())),
  (53,6,N'Genial, gracias. Nos vemos.',N'Visto',DATEADD(MINUTE,-4832,GETDATE())),
  (6,53,N'Acordate de repasar el tema 3 antes de la clase.',N'No visto',DATEADD(MINUTE,-3347,GETDATE()));

INSERT INTO Mensajes (idEmisor,idReceptor,contenido,estado,fechaEnvio) VALUES
  (56,8,N'Hola, ¿tenés lugar para una clase esta semana?',N'Visto',DATEADD(MINUTE,-21839,GETDATE())),
  (8,56,N'Hola, sí. ¿Qué día te viene bien?',N'Visto',DATEADD(MINUTE,-21175,GETDATE())),
  (56,8,N'El jueves a la tarde si puede ser.',N'Visto',DATEADD(MINUTE,-16953,GETDATE())),
  (8,56,N'Perfecto, te mando el pedido. Traé los ejercicios que te cuesten.',N'Visto',DATEADD(MINUTE,-11198,GETDATE())),
  (56,8,N'Genial, gracias. Nos vemos.',N'Visto',DATEADD(MINUTE,-3355,GETDATE()));

INSERT INTO Mensajes (idEmisor,idReceptor,contenido,estado,fechaEnvio) VALUES
  (56,13,N'Hola, ¿tenés lugar para una clase esta semana?',N'Visto',DATEADD(MINUTE,-28678,GETDATE())),
  (13,56,N'Hola, sí. ¿Qué día te viene bien?',N'Visto',DATEADD(MINUTE,-21149,GETDATE())),
  (56,13,N'El jueves a la tarde si puede ser.',N'Visto',DATEADD(MINUTE,-18844,GETDATE())),
  (13,56,N'Perfecto, te mando el pedido. Traé los ejercicios que te cuesten.',N'Visto',DATEADD(MINUTE,-16469,GETDATE())),
  (56,13,N'Genial, gracias. Nos vemos.',N'Visto',DATEADD(MINUTE,-10284,GETDATE())),
  (13,56,N'Acordate de repasar el tema 3 antes de la clase.',N'No visto',DATEADD(MINUTE,-2356,GETDATE()));

INSERT INTO Mensajes (idEmisor,idReceptor,contenido,estado,fechaEnvio) VALUES
  (54,16,N'Hola, ¿tenés lugar para una clase esta semana?',N'Visto',DATEADD(MINUTE,-17999,GETDATE())),
  (16,54,N'Hola, sí. ¿Qué día te viene bien?',N'Visto',DATEADD(MINUTE,-15885,GETDATE())),
  (54,16,N'El jueves a la tarde si puede ser.',N'No visto',DATEADD(MINUTE,-15130,GETDATE()));

INSERT INTO Mensajes (idEmisor,idReceptor,contenido,estado,fechaEnvio) VALUES
  (52,19,N'Hola, ¿tenés lugar para una clase esta semana?',N'Visto',DATEADD(MINUTE,-28330,GETDATE())),
  (19,52,N'Hola, sí. ¿Qué día te viene bien?',N'Visto',DATEADD(MINUTE,-24224,GETDATE())),
  (52,19,N'El jueves a la tarde si puede ser.',N'Visto',DATEADD(MINUTE,-24224,GETDATE())),
  (19,52,N'Perfecto, te mando el pedido. Traé los ejercicios que te cuesten.',N'Visto',DATEADD(MINUTE,-20556,GETDATE())),
  (52,19,N'Genial, gracias. Nos vemos.',N'Visto',DATEADD(MINUTE,-18333,GETDATE())),
  (19,52,N'Acordate de repasar el tema 3 antes de la clase.',N'Visto',DATEADD(MINUTE,-11451,GETDATE())),
  (52,19,N'Dale, lo reviso hoy.',N'Visto',DATEADD(MINUTE,-9298,GETDATE())),
  (19,52,N'Cualquier duda me escribís.',N'Visto',DATEADD(MINUTE,-405,GETDATE()));

INSERT INTO Mensajes (idEmisor,idReceptor,contenido,estado,fechaEnvio) VALUES
  (56,24,N'Hola, ¿tenés lugar para una clase esta semana?',N'Visto',DATEADD(MINUTE,-24438,GETDATE())),
  (24,56,N'Hola, sí. ¿Qué día te viene bien?',N'Visto',DATEADD(MINUTE,-13262,GETDATE())),
  (56,24,N'El jueves a la tarde si puede ser.',N'Visto',DATEADD(MINUTE,-12467,GETDATE())),
  (24,56,N'Perfecto, te mando el pedido. Traé los ejercicios que te cuesten.',N'Visto',DATEADD(MINUTE,-10072,GETDATE())),
  (56,24,N'Genial, gracias. Nos vemos.',N'Visto',DATEADD(MINUTE,-4662,GETDATE())),
  (24,56,N'Acordate de repasar el tema 3 antes de la clase.',N'Visto',DATEADD(MINUTE,-809,GETDATE())),
  (56,24,N'Dale, lo reviso hoy.',N'No visto',DATEADD(MINUTE,-480,GETDATE()));

INSERT INTO Mensajes (idEmisor,idReceptor,contenido,estado,fechaEnvio) VALUES
  (54,28,N'Hola, ¿tenés lugar para una clase esta semana?',N'Visto',DATEADD(MINUTE,-27135,GETDATE())),
  (28,54,N'Hola, sí. ¿Qué día te viene bien?',N'Visto',DATEADD(MINUTE,-22980,GETDATE())),
  (54,28,N'El jueves a la tarde si puede ser.',N'Visto',DATEADD(MINUTE,-16160,GETDATE())),
  (28,54,N'Perfecto, te mando el pedido. Traé los ejercicios que te cuesten.',N'Visto',DATEADD(MINUTE,-15538,GETDATE())),
  (54,28,N'Genial, gracias. Nos vemos.',N'Visto',DATEADD(MINUTE,-3292,GETDATE())),
  (28,54,N'Acordate de repasar el tema 3 antes de la clase.',N'No visto',DATEADD(MINUTE,-1619,GETDATE()));

INSERT INTO Mensajes (idEmisor,idReceptor,contenido,estado,fechaEnvio) VALUES
  (52,33,N'Hola, ¿tenés lugar para una clase esta semana?',N'Visto',DATEADD(MINUTE,-25691,GETDATE())),
  (33,52,N'Hola, sí. ¿Qué día te viene bien?',N'Visto',DATEADD(MINUTE,-18255,GETDATE())),
  (52,33,N'El jueves a la tarde si puede ser.',N'Visto',DATEADD(MINUTE,-12491,GETDATE())),
  (33,52,N'Perfecto, te mando el pedido. Traé los ejercicios que te cuesten.',N'Visto',DATEADD(MINUTE,-9494,GETDATE())),
  (52,33,N'Genial, gracias. Nos vemos.',N'Visto',DATEADD(MINUTE,-1239,GETDATE()));

INSERT INTO Mensajes (idEmisor,idReceptor,contenido,estado,fechaEnvio) VALUES
  (54,34,N'Hola, ¿tenés lugar para una clase esta semana?',N'Visto',DATEADD(MINUTE,-21526,GETDATE())),
  (34,54,N'Hola, sí. ¿Qué día te viene bien?',N'Visto',DATEADD(MINUTE,-20126,GETDATE())),
  (54,34,N'El jueves a la tarde si puede ser.',N'Visto',DATEADD(MINUTE,-17671,GETDATE())),
  (34,54,N'Perfecto, te mando el pedido. Traé los ejercicios que te cuesten.',N'Visto',DATEADD(MINUTE,-13141,GETDATE())),
  (54,34,N'Genial, gracias. Nos vemos.',N'No visto',DATEADD(MINUTE,-1812,GETDATE()));

INSERT INTO Mensajes (idEmisor,idReceptor,contenido,estado,fechaEnvio) VALUES
  (56,35,N'Hola, ¿tenés lugar para una clase esta semana?',N'Visto',DATEADD(MINUTE,-26319,GETDATE())),
  (35,56,N'Hola, sí. ¿Qué día te viene bien?',N'Visto',DATEADD(MINUTE,-26277,GETDATE())),
  (56,35,N'El jueves a la tarde si puede ser.',N'Visto',DATEADD(MINUTE,-24261,GETDATE())),
  (35,56,N'Perfecto, te mando el pedido. Traé los ejercicios que te cuesten.',N'Visto',DATEADD(MINUTE,-20047,GETDATE())),
  (56,35,N'Genial, gracias. Nos vemos.',N'Visto',DATEADD(MINUTE,-9669,GETDATE())),
  (35,56,N'Acordate de repasar el tema 3 antes de la clase.',N'Visto',DATEADD(MINUTE,-8875,GETDATE())),
  (56,35,N'Dale, lo reviso hoy.',N'No visto',DATEADD(MINUTE,-5798,GETDATE()));

INSERT INTO Mensajes (idEmisor,idReceptor,contenido,estado,fechaEnvio) VALUES
  (54,39,N'Hola, ¿tenés lugar para una clase esta semana?',N'Visto',DATEADD(MINUTE,-26905,GETDATE())),
  (39,54,N'Hola, sí. ¿Qué día te viene bien?',N'Visto',DATEADD(MINUTE,-26248,GETDATE())),
  (54,39,N'El jueves a la tarde si puede ser.',N'Visto',DATEADD(MINUTE,-18940,GETDATE())),
  (39,54,N'Perfecto, te mando el pedido. Traé los ejercicios que te cuesten.',N'Visto',DATEADD(MINUTE,-11024,GETDATE())),
  (54,39,N'Genial, gracias. Nos vemos.',N'Visto',DATEADD(MINUTE,-8589,GETDATE())),
  (39,54,N'Acordate de repasar el tema 3 antes de la clase.',N'Visto',DATEADD(MINUTE,-1811,GETDATE()));

INSERT INTO Mensajes (idEmisor,idReceptor,contenido,estado,fechaEnvio) VALUES
  (51,43,N'Hola, ¿tenés lugar para una clase esta semana?',N'Visto',DATEADD(MINUTE,-23708,GETDATE())),
  (43,51,N'Hola, sí. ¿Qué día te viene bien?',N'Visto',DATEADD(MINUTE,-20303,GETDATE())),
  (51,43,N'El jueves a la tarde si puede ser.',N'Visto',DATEADD(MINUTE,-12577,GETDATE())),
  (43,51,N'Perfecto, te mando el pedido. Traé los ejercicios que te cuesten.',N'Visto',DATEADD(MINUTE,-10409,GETDATE())),
  (51,43,N'Genial, gracias. Nos vemos.',N'Visto',DATEADD(MINUTE,-5915,GETDATE())),
  (43,51,N'Acordate de repasar el tema 3 antes de la clase.',N'No visto',DATEADD(MINUTE,-4227,GETDATE()));

INSERT INTO Mensajes (idEmisor,idReceptor,contenido,estado,fechaEnvio) VALUES
  (55,44,N'Hola, ¿tenés lugar para una clase esta semana?',N'Visto',DATEADD(MINUTE,-21566,GETDATE())),
  (44,55,N'Hola, sí. ¿Qué día te viene bien?',N'Visto',DATEADD(MINUTE,-21526,GETDATE())),
  (55,44,N'El jueves a la tarde si puede ser.',N'Visto',DATEADD(MINUTE,-21103,GETDATE())),
  (44,55,N'Perfecto, te mando el pedido. Traé los ejercicios que te cuesten.',N'Visto',DATEADD(MINUTE,-17075,GETDATE())),
  (55,44,N'Genial, gracias. Nos vemos.',N'Visto',DATEADD(MINUTE,-4892,GETDATE())),
  (44,55,N'Acordate de repasar el tema 3 antes de la clase.',N'No visto',DATEADD(MINUTE,-3414,GETDATE()));

INSERT INTO Mensajes (idEmisor,idReceptor,contenido,estado,fechaEnvio) VALUES
  (53,45,N'Hola, ¿tenés lugar para una clase esta semana?',N'Visto',DATEADD(MINUTE,-19991,GETDATE())),
  (45,53,N'Hola, sí. ¿Qué día te viene bien?',N'Visto',DATEADD(MINUTE,-19054,GETDATE())),
  (53,45,N'El jueves a la tarde si puede ser.',N'Visto',DATEADD(MINUTE,-18809,GETDATE())),
  (45,53,N'Perfecto, te mando el pedido. Traé los ejercicios que te cuesten.',N'Visto',DATEADD(MINUTE,-14360,GETDATE())),
  (53,45,N'Genial, gracias. Nos vemos.',N'Visto',DATEADD(MINUTE,-13009,GETDATE()));

INSERT INTO Mensajes (idEmisor,idReceptor,contenido,estado,fechaEnvio) VALUES
  (52,46,N'Hola, ¿tenés lugar para una clase esta semana?',N'Visto',DATEADD(MINUTE,-24208,GETDATE())),
  (46,52,N'Hola, sí. ¿Qué día te viene bien?',N'Visto',DATEADD(MINUTE,-20463,GETDATE())),
  (52,46,N'El jueves a la tarde si puede ser.',N'No visto',DATEADD(MINUTE,-15089,GETDATE()));

INSERT INTO Mensajes (idEmisor,idReceptor,contenido,estado,fechaEnvio) VALUES
  (51,5,N'Hola, ¿tenés lugar para una clase esta semana?',N'Visto',DATEADD(MINUTE,-28051,GETDATE())),
  (5,51,N'Hola, sí. ¿Qué día te viene bien?',N'Visto',DATEADD(MINUTE,-27858,GETDATE())),
  (51,5,N'El jueves a la tarde si puede ser.',N'Visto',DATEADD(MINUTE,-22155,GETDATE())),
  (5,51,N'Perfecto, te mando el pedido. Traé los ejercicios que te cuesten.',N'Visto',DATEADD(MINUTE,-19816,GETDATE())),
  (51,5,N'Genial, gracias. Nos vemos.',N'Visto',DATEADD(MINUTE,-17731,GETDATE())),
  (5,51,N'Acordate de repasar el tema 3 antes de la clase.',N'Visto',DATEADD(MINUTE,-11698,GETDATE())),
  (51,5,N'Dale, lo reviso hoy.',N'Visto',DATEADD(MINUTE,-8100,GETDATE())),
  (5,51,N'Cualquier duda me escribís.',N'No visto',DATEADD(MINUTE,-5394,GETDATE()));

INSERT INTO Mensajes (idEmisor,idReceptor,contenido,estado,fechaEnvio) VALUES
  (@A2,45,N'Hola, ¿tenés lugar para una clase esta semana?',N'Visto',DATEADD(MINUTE,-25749,GETDATE())),
  (45,@A2,N'Hola, sí. ¿Qué día te viene bien?',N'Visto',DATEADD(MINUTE,-24924,GETDATE())),
  (@A2,45,N'El jueves a la tarde si puede ser.',N'Visto',DATEADD(MINUTE,-22691,GETDATE())),
  (45,@A2,N'Perfecto, te mando el pedido. Traé los ejercicios que te cuesten.',N'Visto',DATEADD(MINUTE,-17974,GETDATE())),
  (@A2,45,N'Genial, gracias. Nos vemos.',N'Visto',DATEADD(MINUTE,-16001,GETDATE())),
  (45,@A2,N'Acordate de repasar el tema 3 antes de la clase.',N'Visto',DATEADD(MINUTE,-7171,GETDATE())),
  (@A2,45,N'Dale, lo reviso hoy.',N'Visto',DATEADD(MINUTE,-4180,GETDATE())),
  (45,@A2,N'Cualquier duda me escribís.',N'Visto',DATEADD(MINUTE,-122,GETDATE()));

INSERT INTO Mensajes (idEmisor,idReceptor,contenido,estado,fechaEnvio) VALUES
  (@A3,8,N'Hola, ¿tenés lugar para una clase esta semana?',N'Visto',DATEADD(MINUTE,-28619,GETDATE())),
  (8,@A3,N'Hola, sí. ¿Qué día te viene bien?',N'Visto',DATEADD(MINUTE,-24875,GETDATE())),
  (@A3,8,N'El jueves a la tarde si puede ser.',N'Visto',DATEADD(MINUTE,-19636,GETDATE())),
  (8,@A3,N'Perfecto, te mando el pedido. Traé los ejercicios que te cuesten.',N'Visto',DATEADD(MINUTE,-15022,GETDATE())),
  (@A3,8,N'Genial, gracias. Nos vemos.',N'Visto',DATEADD(MINUTE,-3626,GETDATE())),
  (8,@A3,N'Acordate de repasar el tema 3 antes de la clase.',N'No visto',DATEADD(MINUTE,-2353,GETDATE()));

INSERT INTO Mensajes (idEmisor,idReceptor,contenido,estado,fechaEnvio) VALUES
  (@A4,@P1,N'Hola, ¿tenés lugar para una clase esta semana?',N'Visto',DATEADD(MINUTE,-27329,GETDATE())),
  (@P1,@A4,N'Hola, sí. ¿Qué día te viene bien?',N'Visto',DATEADD(MINUTE,-23275,GETDATE())),
  (@A4,@P1,N'El jueves a la tarde si puede ser.',N'Visto',DATEADD(MINUTE,-22272,GETDATE())),
  (@P1,@A4,N'Perfecto, te mando el pedido. Traé los ejercicios que te cuesten.',N'Visto',DATEADD(MINUTE,-17341,GETDATE())),
  (@A4,@P1,N'Genial, gracias. Nos vemos.',N'Visto',DATEADD(MINUTE,-6848,GETDATE())),
  (@P1,@A4,N'Acordate de repasar el tema 3 antes de la clase.',N'Visto',DATEADD(MINUTE,-3437,GETDATE())),
  (@A4,@P1,N'Dale, lo reviso hoy.',N'No visto',DATEADD(MINUTE,-3067,GETDATE()));

INSERT INTO Mensajes (idEmisor,idReceptor,contenido,estado,fechaEnvio) VALUES
  (@A4,12,N'Hola, ¿tenés lugar para una clase esta semana?',N'Visto',DATEADD(MINUTE,-27203,GETDATE())),
  (12,@A4,N'Hola, sí. ¿Qué día te viene bien?',N'Visto',DATEADD(MINUTE,-21421,GETDATE())),
  (@A4,12,N'El jueves a la tarde si puede ser.',N'Visto',DATEADD(MINUTE,-17641,GETDATE())),
  (12,@A4,N'Perfecto, te mando el pedido. Traé los ejercicios que te cuesten.',N'Visto',DATEADD(MINUTE,-12595,GETDATE())),
  (@A4,12,N'Genial, gracias. Nos vemos.',N'Visto',DATEADD(MINUTE,-10687,GETDATE())),
  (12,@A4,N'Acordate de repasar el tema 3 antes de la clase.',N'Visto',DATEADD(MINUTE,-7813,GETDATE()));

INSERT INTO Mensajes (idEmisor,idReceptor,contenido,estado,fechaEnvio) VALUES
  (@A6,@P1,N'Hola, ¿tenés lugar para una clase esta semana?',N'Visto',DATEADD(MINUTE,-28582,GETDATE())),
  (@P1,@A6,N'Hola, sí. ¿Qué día te viene bien?',N'Visto',DATEADD(MINUTE,-26820,GETDATE())),
  (@A6,@P1,N'El jueves a la tarde si puede ser.',N'Visto',DATEADD(MINUTE,-22860,GETDATE())),
  (@P1,@A6,N'Perfecto, te mando el pedido. Traé los ejercicios que te cuesten.',N'Visto',DATEADD(MINUTE,-18284,GETDATE())),
  (@A6,@P1,N'Genial, gracias. Nos vemos.',N'Visto',DATEADD(MINUTE,-15612,GETDATE())),
  (@P1,@A6,N'Acordate de repasar el tema 3 antes de la clase.',N'Visto',DATEADD(MINUTE,-9202,GETDATE())),
  (@A6,@P1,N'Dale, lo reviso hoy.',N'Visto',DATEADD(MINUTE,-4501,GETDATE())),
  (@P1,@A6,N'Cualquier duda me escribís.',N'No visto',DATEADD(MINUTE,-4214,GETDATE()));

-- ---------------------------------------------------------------- amigos

INSERT INTO Amigos (idUsuario1,idUsuario2,estado)
VALUES
  (57,@A15,N'Aceptada'),
  (@A10,@A24,N'Pendiente'),
  (51,@A22,N'Aceptada'),
  (53,@A13,N'Aceptada'),
  (@A16,54,N'Aceptada'),
  (57,51,N'Aceptada'),
  (@A11,@A6,N'Pendiente'),
  (@A13,@A3,N'Aceptada'),
  (57,@A23,N'Aceptada'),
  (@A22,@A19,N'Aceptada'),
  (@A15,@A13,N'Pendiente'),
  (@A4,@A12,N'Pendiente'),
  (57,@A1,N'Aceptada'),
  (@A6,@A15,N'Aceptada'),
  (55,@A7,N'Aceptada'),
  (@A2,57,N'Aceptada'),
  (51,52,N'Pendiente'),
  (57,@A3,N'Pendiente'),
  (52,57,N'Pendiente');

-- ---------------------------------------------------------------- consultas de soporte

INSERT INTO Consultas_Soporte (idUsuario,nombre,correo,tipo,mensaje,estado,fecha)
VALUES
  (NULL,N'Visitante Seed',N'visitante@seed.mip',N'otro',N'No me llega el correo de verificación.',N'Pendiente',DATEADD(DAY,-16,GETDATE())),
  (@A1,N'Agustín Alonso',N'agustin.alonso@seed.mip',N'clases',N'Mi profesor no se conectó a la clase del martes.',N'Pendiente',DATEADD(DAY,-8,GETDATE())),
  (@A2,N'Valeria Barrios',N'valeria.barrios@seed.mip',N'sugerencia',N'Estaría bueno poder filtrar profesores por precio.',N'Resuelta',DATEADD(DAY,-11,GETDATE())),
  (@P2,N'Silvia Cano',N'silvia.cano@seed.mip',N'cuenta',N'Quiero cambiar el mail de mi cuenta.',N'Pendiente',DATEADD(DAY,-15,GETDATE())),
  (57,N'Eitan Glaz',N'eitugz@gmail.com',N'sugerencia',N'Me gustaría ver las reseñas que dejé desde mi perfil.',N'Pendiente',DATEADD(DAY,-24,GETDATE()));


COMMIT TRANSACTION;

-- ---------------------------------------------------------------- resumen
DECLARE @maxClase INT = (SELECT MAX(ID) FROM Clases), @maxResena INT = (SELECT MAX(ID) FROM Resenas), @maxMensaje INT = (SELECT MAX(ID) FROM Mensajes);
PRINT CONCAT(N'Clases agregadas: ID ', @minClase, N' a ', @maxClase);
PRINT CONCAT(N'Reseñas agregadas: ID ', @minResena, N' a ', @maxResena);
PRINT CONCAT(N'Mensajes agregados: ID ', @minMensaje, N' a ', @maxMensaje);
SELECT estado, COUNT(*) AS clases FROM Clases GROUP BY estado ORDER BY clases DESC;
SELECT (SELECT COUNT(*) FROM Usuarios WHERE mail LIKE N'%@seed.mip') AS usuariosSeed,
       (SELECT COUNT(*) FROM Resenas) AS resenas, (SELECT COUNT(*) FROM Likes) AS likes,
       (SELECT COUNT(*) FROM Mensajes) AS mensajes,
       (SELECT COUNT(*) FROM Mensajes WHERE estado = N'No visto') AS mensajesSinLeer;
GO
