-- =====================================================================================
-- Deshace datos-prueba.sql: borra los usuarios @seed.mip y todo lo que se agregó con él.
-- No toca los usuarios ni las clases / reseñas anteriores. Los rangos de ID son los que quedaron
-- al cargar los datos (si después se hicieron clases, reseñas o Me gusta reales, esos IDs son mayores y quedan).
-- =====================================================================================
SET NOCOUNT ON;
SET XACT_ABORT ON;
USE [MIP]
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRANSACTION;

DELETE FROM Mensajes WHERE ID BETWEEN 1 AND 164;
DELETE FROM Chats WHERE ID BETWEEN 1 AND 28;
DELETE FROM Amigos WHERE ID BETWEEN 1 AND 19;
DELETE FROM Likes WHERE ID BETWEEN 1 AND 264;
DELETE FROM Consultas_Soporte WHERE ID BETWEEN 1 AND 5;
DELETE FROM Resenas WHERE ID BETWEEN 105 AND 249;
DELETE FROM Clases WHERE ID BETWEEN 225 AND 549;

-- Lo que cuelga de los usuarios de prueba (por si se les agregó algo a mano)
DECLARE @seed TABLE (id INT PRIMARY KEY);
INSERT INTO @seed SELECT ID FROM Usuarios WHERE mail LIKE N'%@seed.mip';
DELETE FROM Mensajes WHERE idEmisor IN (SELECT id FROM @seed) OR idChat IN (SELECT ID FROM Chats WHERE idUsuario1 IN (SELECT id FROM @seed) OR idUsuario2 IN (SELECT id FROM @seed));
DELETE FROM Chats WHERE idUsuario1 IN (SELECT id FROM @seed) OR idUsuario2 IN (SELECT id FROM @seed);
DELETE FROM Amigos WHERE idUsuario1 IN (SELECT id FROM @seed) OR idUsuario2 IN (SELECT id FROM @seed);
DELETE FROM Likes WHERE idEmisor IN (SELECT id FROM @seed) OR idReceptor IN (SELECT id FROM @seed);
DELETE FROM Resenas WHERE idEmisor IN (SELECT id FROM @seed) OR idReceptor IN (SELECT id FROM @seed);
DELETE FROM Clases WHERE idEmisor IN (SELECT id FROM @seed) OR idReceptor IN (SELECT id FROM @seed);
DELETE FROM Consultas_Soporte WHERE idUsuario IN (SELECT id FROM @seed);
DELETE FROM Notificaciones WHERE idUsuario IN (SELECT id FROM @seed);
DELETE FROM Titulos WHERE idUsuario IN (SELECT id FROM @seed);
DELETE FROM Profesores_Modalidades WHERE idUsuario IN (SELECT id FROM @seed);
DELETE FROM Usuarios_Materias WHERE idUsuario IN (SELECT id FROM @seed);
DELETE FROM Usuarios_Niveles WHERE idUsuario IN (SELECT id FROM @seed);
DELETE FROM Escuelas_Usuarios WHERE idUsuario IN (SELECT id FROM @seed);
DELETE FROM InfoProfesores WHERE idUsuario IN (SELECT id FROM @seed);
DELETE FROM Perfiles WHERE idUsuario IN (SELECT id FROM @seed);
DELETE FROM Usuarios WHERE ID IN (SELECT id FROM @seed);

-- Eitan vuelve a "vio las notificaciones hoy a las 08:57"
UPDATE Notificaciones SET fecha = '2026-10-15T08:57:10.657' WHERE idUsuario = 57;

COMMIT TRANSACTION;
SELECT (SELECT COUNT(*) FROM Usuarios) AS usuarios, (SELECT COUNT(*) FROM Clases) AS clases, (SELECT COUNT(*) FROM Resenas) AS resenas,
       (SELECT COUNT(*) FROM Likes) AS likes, (SELECT COUNT(*) FROM Chats) AS chats;
GO
