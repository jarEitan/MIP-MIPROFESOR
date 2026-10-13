-- =====================================================================
-- MIP - Sistema de likes ("Me gusta" en los perfiles)
-- Se puede ejecutar completo y más de una vez (CREATE OR ALTER).
-- Usa la tabla Likes que ya existe (ID, idEmisor, idReceptor, UNIQUE (idEmisor, idReceptor)
-- y CHECK idEmisor <> idReceptor). No crea ni modifica tablas.
-- Contiene:
--   1. SP obtenerLike: si un usuario ya le dio "me gusta" a un perfil y cuántos tiene ese perfil.
--   2. SP alternarLike: da o saca el "me gusta" y devuelve cómo quedó (como en el TP de Red Social).
-- Pueden dar y recibir "me gusta" los alumnos y los profesores. Nadie se puede dar "me gusta" a sí mismo.
-- =====================================================================
USE [MIP]
GO

-- ---------------------------------------------------------------------
-- 1. obtenerLike: estado del botón "Me gusta" del perfil @idReceptor visto por @idEmisor.
--    Devuelve 1 fila: leGusta (1 = ya le dio me gusta) y cantidadLikes (total del perfil).
--    Si @idEmisor es NULL (visitante sin sesión), leGusta es 0.
-- ---------------------------------------------------------------------
CREATE OR ALTER PROCEDURE [dbo].[obtenerLike]
    @idEmisor INT = NULL,
    @idReceptor INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CAST(CASE WHEN EXISTS (SELECT 1 FROM Likes WHERE idEmisor = @idEmisor AND idReceptor = @idReceptor)
                     THEN 1 ELSE 0 END AS BIT) AS leGusta,
           (SELECT COUNT(*) FROM Likes WHERE idReceptor = @idReceptor) AS cantidadLikes;
END
GO

-- ---------------------------------------------------------------------
-- 2. alternarLike: si @idEmisor ya le dio me gusta a @idReceptor lo saca; si no, lo da
--    (mismo enfoque que el TP de Red Social: el servidor alterna y devuelve cómo quedó).
--    Devuelve 1 fila: resultado, leGusta (1 = quedó con me gusta) y cantidadLikes (ya actualizada).
--    resultado: ok | mismoUsuario | usuarioInexistente
-- ---------------------------------------------------------------------
CREATE OR ALTER PROCEDURE [dbo].[alternarLike]
    @idEmisor INT,
    @idReceptor INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @idEmisor = @idReceptor
    BEGIN
        SELECT N'mismoUsuario' AS resultado, CAST(0 AS BIT) AS leGusta,
               (SELECT COUNT(*) FROM Likes WHERE idReceptor = @idReceptor) AS cantidadLikes;
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE ID = @idEmisor AND tipoUsuario IN (N'alumno', N'profesor'))
       OR NOT EXISTS (SELECT 1 FROM Usuarios WHERE ID = @idReceptor AND tipoUsuario IN (N'alumno', N'profesor'))
    BEGIN
        SELECT N'usuarioInexistente' AS resultado, CAST(0 AS BIT) AS leGusta, 0 AS cantidadLikes;
        RETURN;
    END

    DECLARE @leGusta BIT;

    BEGIN TRANSACTION;

    -- UPDLOCK + HOLDLOCK: si llegan dos pedidos juntos, el segundo espera al primero
    -- y no choca contra el UNIQUE (idEmisor, idReceptor).
    IF EXISTS (SELECT 1 FROM Likes WITH (UPDLOCK, HOLDLOCK) WHERE idEmisor = @idEmisor AND idReceptor = @idReceptor)
    BEGIN
        DELETE FROM Likes WHERE idEmisor = @idEmisor AND idReceptor = @idReceptor;
        SET @leGusta = 0;
    END
    ELSE
    BEGIN
        INSERT INTO Likes (idEmisor, idReceptor) VALUES (@idEmisor, @idReceptor);
        SET @leGusta = 1;
    END

    COMMIT TRANSACTION;

    SELECT N'ok' AS resultado,
           @leGusta AS leGusta,
           (SELECT COUNT(*) FROM Likes WHERE idReceptor = @idReceptor) AS cantidadLikes;
END
GO

-- Si ya habías ejecutado la versión anterior de este script, esto borra el SP que ya no se usa.
DROP PROCEDURE IF EXISTS [dbo].[cambiarLike]
GO
