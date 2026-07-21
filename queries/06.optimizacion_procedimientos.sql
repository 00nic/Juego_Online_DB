-- =====================================================
-- SECCIÓN 6: OPTIMIZACIÓN Y PROCEDIMIENTOS 
-- =====================================================

-- 6.1 Crea un índice para optimizar búsquedas de jugadores por nivel
-- Tu respuesta:

CREATE INDEX idx_jugadores_nivel ON jugadores (nivel asc)

-- 6.2 Crea un índice compuesto para optimizar búsquedas de misiones
-- por dificultad y recompensa_oro
-- Tu respuesta:

CREATE INDEX idx_misiones_dif_recompensa 
ON misiones(dificultad, recompensa_oro)

-- 6.3 Crea un procedimiento almacenado "completar_mision" que:
--     - Reciba: id_jugador, id_mision
--     - Marque la misión como completada
--     - Actualice la experiencia del jugador sumando la recompensa_xp
--     - Inserte la fecha actual como fecha_completada
-- Tu respuesta:

DELIMITER $$

CREATE PROCEDURE completar_mision(
	IN in_id_jugador INT,
    IN in_id_mision INT)
BEGIN
    DECLARE v_recompensa_xp INT;
	DECLARE v_fecha_hoy DATE;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    
    BEGIN
        ROLLBACK;
    END;
    
    SET v_fecha_hoy = CURDATE();
    
    SELECT recompensa_xp INTO v_recompensa_xp 
	FROM misiones m 
	WHERE m.id_mision = in_id_mision;
    
    START TRANSACTION;
		
        IF EXISTS (
			SELECT 1 FROM jugadores_misiones 
            WHERE id_jugador = in_id_jugador AND id_mision = in_id_mision
		) THEN
			UPDATE  jugadores_misiones
			SET fecha_completada = v_fecha_hoy, completada = 1
			WHERE id_jugador = in_id_jugador AND id_mision = in_id_mision;
		ELSE
			INSERT INTO jugadores_misiones (id_jugador, id_mision, fecha_completada, completada)
            VALUES (in_id_jugador, in_id_mision, v_fecha_hoy, 1);
        END IF;
        
        UPDATE jugadores
        SET experiencia = experiencia + v_recompensa_xp
        WHERE id_jugador = in_id_jugador;
        
	COMMIT;
END$$

DELIMITER ;

-- 6.4 Crea un procedimiento "subir_nivel" que:
--     - Reciba: id_jugador
--     - Incremente el nivel del jugador en 1
--     - Reinicie su experiencia a 0
-- Tu respuesta:

DELIMITER $$
CREATE PROCEDURE subir_nivel (
	IN in_id_jugador INT)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    
    BEGIN
        ROLLBACK;
    END;
    START TRANSACTION;
		UPDATE jugadores 
		SET nivel = nivel + 1, experiencia = 0
        WHERE id_jugador = in_id_jugador;
	COMMIT;
END$$
DELIMITER ;

CALL subir_nivel(31)


-- 6.5 Crea una función "calcular_poder_clan" que:
--     - Reciba: id_clan
--     - Retorne: la suma de niveles de todos sus miembros
-- Tu respuesta:

DROP PROCEDURE IF EXISTS calcular_poder_clan;
DELIMITER $$
CREATE PROCEDURE calcular_poder_clan(
	IN in_id_clan INT,
    OUT out_suma_niveles INT)
BEGIN
	SELECT SUM(nivel) INTO out_suma_niveles 
    FROM jugadores j
    INNER JOIN clanes c ON j.clan_id = c.id_clan
    WHERE c.id_clan = in_id_clan;

END$$
DELIMITER ;

CALL calcular_poder_clan(3, @poder_clan);
SELECT @poder_clan AS Poder_Clan

--------------------------------------------------Funcion--------------------------------------------------
DROP FUNCTION IF EXISTS calcular_poder_clan;
DELIMITER $$
CREATE FUNCTION calcular_poder_clan(
	in_id_clan INT)
RETURNS INT
READS SQL DATA
BEGIN
	DECLARE suma_niveles INT;
	SELECT SUM(nivel) INTO suma_niveles FROM jugadores
    WHERE clan_id = in_id_clan;
    RETURN suma_niveles;
END$$
DELIMITER ;

SELECT calcular_poder_clan(3);

--------------------------------------------------Funcion más limpia--------------------------------------------------
DROP FUNCTION IF EXISTS calcular_poder_clan;
CREATE FUNCTION calcular_poder_clan(in_id_clan INT)
RETURNS INT
READS SQL DATA
BEGIN
    -- Retornamos el resultado de la consulta directamente en una sola línea
    RETURN (SELECT SUM(nivel) FROM jugadores WHERE clan_id = in_id_clan);
END$$

-- 6.6 Crea una función "puede_usar_equipamiento" que:
--     - Reciba: id_jugador, id_equipamiento
--     - Retorne: TRUE si el nivel del jugador >= nivel_requerido del equipo
--     - Retorne: FALSE en caso contrario
-- Tu respuesta:

DROP FUNCTION IF EXISTS puede_usar_equipamiento
DELIMITER $$
CREATE FUNCTION puede_usar_equipamiento(
	in_id_jugador INT,
	in_id_equipamiento INT)
RETURNS BOOLEAN
READS SQL DATA
BEGIN
	DECLARE nivel_jugador INT;
    DECLARE nivel_requerido_equipo INT;
    
    SELECT nivel INTO nivel_jugador
    FROM jugadores 
    WHERE id_jugador = in_id_jugador;
    
    SELECT nivel_requerido INTO nivel_requerido_equipo
    FROM  equipamientos
    WHERE id_equipamiento = in_id_equipamiento;
    
    IF nivel_jugador IS NULL OR nivel_requerido_equipo IS NULL THEN 
		RETURN NULL;
    ELSEIF nivel_jugador >= nivel_requerido_equipo THEN 
		RETURN TRUE;
	ELSE 
		RETURN FALSE;
	END IF;
END$$
DELIMITER ;

SELECT puede_usar_equipamiento(10, 32) AS SI_o_NO

-------------------------------Puedo también hacerlo con CASE para mostrar un mensaje más amigable-------------------------------
SELECT 
    CASE puede_usar_equipamiento(10, 21)
        WHEN 1 THEN 'Puede'
        WHEN 0 THEN 'No puede'
        ELSE 'No existe el jugador o el equipo'
    END AS Estado_Equipamiento;

---------------------------------O retornar texto directamente desde la función---------------------------------
DROP FUNCTION IF EXISTS puede_usar_equipamiento;

DELIMITER $$
CREATE FUNCTION puede_usar_equipamiento(
    in_id_jugador INT,
    in_id_equipamiento INT
)
RETURNS VARCHAR(50) -- 1. Cambiamos el tipo de retorno a texto
READS SQL DATA
BEGIN
    DECLARE v_nivel_jugador INT;
    DECLARE v_nivel_requerido INT;
    
    SELECT nivel INTO v_nivel_jugador FROM jugadores WHERE id_jugador = in_id_jugador;
    SELECT nivel_requerido INTO v_nivel_requerido FROM equipamientos WHERE id_equipamiento = in_id_equipamiento;
    
    -- 2. Ahora sí puedes usar tus textos entre comillas en el RETURN
    IF v_nivel_jugador IS NULL OR v_nivel_requerido IS NULL THEN
        RETURN 'No existe';
    ELSEIF v_nivel_jugador >= v_nivel_requerido THEN
        RETURN 'Puede';
    ELSE
        RETURN 'No puede';
    END IF;

END$$
DELIMITER ;

-- 6.7 Usa EXPLAIN ANALYZE para comparar estas dos consultas:
--     a) SELECT * FROM jugadores WHERE nivel = 10;
--     b) SELECT * FROM jugadores WHERE nivel > 5 AND nivel < 15;
-- ¿Cuál es más eficiente?
-- Tu respuesta:

'-> Index lookup on jugadores using idx_jugadores_nivel ... (cost=1.15 rows=4) (actual time=0.0486..0.0521 ...)'
'-> Filter: ((jugadores.nivel > 5) and (jugadores.nivel < 15))  (cost=3.25 rows=29) (actual time=0.102..0.138 ...)'

La consulta A es más eficiente. > El EXPLAIN ANALYZE demuestra que la Consulta A 
realiza un Index lookup aprovechando el índice idx_jugadores_nivel, 
lo que le permite procesar únicamente 4 filas con un costo de 1.15 y un tiempo de ejecución menor.
Por el contrario, la Consulta B realiza un Table scan (escaneo completo de la tabla) 
seguido de un Filter, ignorando el índice debido al rango solicitado, 
lo que eleva el costo a 3.25 (casi el triple) y duplica el tiempo de respuesta.

-- 6.8 Crea una función que retorne una tabla con los jugadores
-- de un clan específico ordenados por nivel
-- Tu respuesta:

'MySQL no permite que una función (FUNCTION) devuelva una tabla completa. 
Las funciones en MySQL están obligadas a retornar un único valor escalar 
(un número, un texto, un booleano).'
'En PostgreSQL y SQL Server sí es posible crear funciones que retornen tablas completas; usando RETURNS TABLE en PostgreSQL o TABLE TYPE en SQL Server.
pero en MySQL se recomienda usar PROCEDIMIENTOS ALMACENADOS (PROCEDURE) para este tipo de casos, o simplemente realizar una consulta directa con JOIN y WHERE.'

Dado que MySQL no soporta funciones de tabla (Table-Valued Functions) 
que permitan retornar un conjunto de registros mediante una FUNCTION, 
presento las dos alternativas estándar de la industria para resolver el requerimiento:

Alternativa A (Procedimiento Almacenado): Permite parametrizar dinámicamente 
el clan_id y escupir la tabla filtrada y ordenada directamente.

DROP PROCEDURE IF EXISTS jugadores_x_clan;
DELIMITER $$
CREATE PROCEDURE jugadores_x_clan(
	IN in_id_clan INT)
BEGIN
	SELECT nombre_jugador, nivel, experiencia
    FROM jugadores 
    WHERE clan_id = in_id_clan
    ORDER BY nivel DESC;
END$$
DELIMITER ;
CALL jugadores_x_clan(1)

--------------------------------------------------VISTA--------------------------------------------------
Alternativa B (Vista Dinámica): Abstrae la lógica de ordenamiento 
en una estructura reutilizable que luego puede ser filtrada 
por cualquier clan desde el exterior. Aunque no es tan flexible como un procedimiento,
permite consultas directas sin necesidad de parámetros.

CREATE OR REPLACE VIEW vista_ranking_jugadores AS
SELECT nombre_jugador, nivel, clan_id
FROM jugadores
ORDER BY nivel DESC;

SELECT * FROM vista_ranking_jugadores WHERE clan_id = 1;

-- 6.9 Crea un procedimiento "asignar_recompensa" que:
--     - Reciba: id_jugador, id_recompensa
--     - Inserte el registro en jugadores_recompensas
--     - Use la fecha actual
--     - Maneje el error si ya existe la recompensa para ese jugador
-- Tu respuesta:

DROP PROCEDURE IF EXISTS asignar_recompensa;
DELIMITER $$
CREATE PROCEDURE asignar_recompensa(
	IN in_id_jugador INT,
	IN in_id_recompensa INT,
	OUT respuesta TEXT)
BEGIN
	DECLARE v_fecha_actual DATE;

	DECLARE CONTINUE HANDLER FOR 1062
    BEGIN
        SET respuesta = 'Error: ya existe la recompensa para ese jugador';
    END;
    
    SET v_fecha_actual = CURDATE();
	
	INSERT INTO jugadores_recompensas (id_jugador, id_recompensa, fecha_obtenida) 
					VALUES (in_id_jugador, in_id_recompensa, v_fecha_actual);
	IF respuesta IS NULL THEN
		SET respuesta = 'Inserción realizada correctamente';
    END IF;
END$$

CALL asignar_recompensa(1, 4, @respuesta);
CALL asignar_recompensa(1, 6, @respuesta);
SELECT @respuesta AS Asignar_Recompensa;

-- 6.10 Consulta las estadísticas de uso de las tablas principales
-- usando pg_stat_user_tables
-- Tu respuesta:

SELECT 
    OBJECT_SCHEMA AS esquema, 
    OBJECT_NAME AS tabla, 
    COUNT_READ AS lecturas, 
    COUNT_WRITE AS escrituras
FROM performance_schema.table_io_waits_summary_by_table
WHERE OBJECT_SCHEMA = 'juego_online';

juego_online	misiones	                2	    0
juego_online	monstruos	                1088   	0
juego_online	jugadores	                338	    3
juego_online	equipamientos	            712	    0
juego_online	jugadores_equipamientos	    1525	0
juego_online	jugadores_misiones	        1935	2
juego_online	clanes	                    2365	0
juego_online	recompensas	                60	    0
juego_online	jugadores_recompensas	    192	    5

-- CONCLUSIÓN DEL ANÁLISIS:
-- 1. La tabla con mayor actividad de lectura es 'clanes' (2365) seguida de las tablas 
--    intermedias 'jugadores_misiones' (1935) y 'jugadores_equipamientos' (1525), 
--    lo que refleja el alto impacto de los JOINs realizados en el laboratorio.
-- 2. La tabla con mayor actividad de escritura es 'jugadores_recompensas' (5 escrituras), 
--    lo que valida la ejecución del procedimiento "asignar_recompensa" del punto anterior.