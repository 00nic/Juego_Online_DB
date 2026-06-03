/*
MODELO DE DATOS:
- jugadores (id_jugador, nombre_jugador, nivel, experiencia, clan_id)
- clanes (id_clan, nombre_clan, fecha_creacion, lider_id)
- equipamientos (id_equipamiento, nombre_equipamiento, tipo, nivel_requerido, bono_ataque, bono_defensa)
- recompensas (id_recompensa, tipo_recompensa, descripcion_recompensa)
- monstruos (id_monstruo, nombre_monstruo, nivel_monstruo, vida, tipo_monstruo, recompensa_id)
- misiones (id_mision, nombre_mision, dificultad, recompensa_xp, recompensa_oro, recompensa_id, monstruo_id)
- jugadores_misiones (id_jugador, id_mision, fecha_completada, completada)
- jugadores_recompensas (id_jugador, id_recompensa, fecha_obtenida)
- jugadores_equipamientos (id_jugador, id_equipamiento, cantidad)
*/

-- =====================================================
-- SECCIÓN 1: CONSULTAS BÁSICAS 
-- =====================================================

-- 1.1 Selecciona todos los jugadores con nivel superior a 10
-- Tu respuesta:

SELECT * FROM jugadores where nivel > 10

-- 1.2 Muestra los nombres de los clanes creados después del 1 de enero de 2021
-- Tu respuesta:

SELECT nombre_clan FROM clanes where fecha_creacion > '2021-01-01' |

-- 1.3 Lista todos los equipamientos de tipo "arma" con nivel requerido menor a 10
-- Tu respuesta:

SELECT * FROM equipamientos where tipo = 'arma' and nivel_requerido < 10

-- 1.4 Encuentra todas las misiones de dificultad "Muy Difícil"
-- Tu respuesta:

SELECT * FROM misiones where dificultad = 'Muy Difícil'

-- 1.5 Selecciona los monstruos de tipo "dragón" con más de 500 de vida
-- Tu respuesta:

USE juego_online;
SELECT *
FROM monstruos
WHERE tipo_monstruo = 'Dragón' and vida > 5000

-- 1.6 Actualiza la experiencia del jugador "Arthorius" sumándole 500 puntos
-- Tu respuesta:

UPDATE jugadores
SET experiencia = experiencia + 500
WHERE nombre_jugador = 'Arthorius';


-- 1.7 Elimina todas las misiones completadas antes del 1 de enero de 2024
-- (de la tabla jugadores_misiones)
-- Tu respuesta:

DELETE FROM jugadores_misiones
WHERE fecha_completada < '2024-01-01' and completada = true;

-- 1.8 Muestra los 5 jugadores con mayor nivel, ordenados descendentemente
-- Tu respuesta:

SELECT nombre_jugador, nivel
FROM jugadores
ORDER BY nivel DESC
LIMIT 5;

-- 1.9 Cuenta cuántos jugadores hay en total
-- Tu respuesta:

SELECT COUNT(*) AS total_jugadores
FROM jugadores; 


-- 1.10 Lista los nombres de jugadores que contengan la letra "a" (mayúscula o minúscula)
-- Tu respuesta:

SELECT nombre_jugador
FROM jugadores
WHERE nombre_jugador LIKE '%a%';

-- =====================================================
-- SECCIÓN 2: OPERACIONES INTERMEDIAS 
-- =====================================================

-- 2.1 Clasifica a los jugadores según su nivel:
--     - Nivel 1-5: "Novato"
--     - Nivel 6-10: "Intermedio"
--     - Nivel 11-15: "Avanzado"
--     - Más de 15: "Maestro"
-- Tu respuesta:
SELECT nombre_jugador, nivel,
CASE
    WHEN nivel BETWEEN 1 AND 5 THEN 'Novato'
    WHEN nivel BETWEEN 6 AND 10 THEN 'Intermedio'
    WHEN nivel BETWEEN 11 AND 15 THEN 'Avanzado'
    ELSE 'Maestro'
END AS clasificacion
FROM jugadores
ORDER BY nivel ASC;

-- 2.2 Cuenta cuántos jugadores hay en cada clan
-- Tu respuesta:

SELECT clan_id, c.nombre_clan, COUNT(clan_id) as cantidad_jugadores
FROM jugadores j
INNER JOIN clanes c ON c.id_clan = j.clan_id
GROUP BY clan_id
ORDER BY cantidad_jugadores 

-- 2.3 Muestra los clanes que tienen más de 4 jugadores
-- Tu respuesta

SELECT clan_id, c.nombre_clan, COUNT(clan_id) as cantidad_jugadores
FROM jugadores j
INNER JOIN clanes c ON c.id_clan = j.clan_id
GROUP BY clan_id
HAVING cantidad_jugadores > 4
ORDER BY cantidad_jugadores 

-- 2.4 Calcula el nivel promedio, máximo y mínimo de todos los jugadores
-- Tu respuesta:

SELECT round(AVG(nivel)) AS nivel_promedio, 
MIN(nivel) AS nivel_mínimo, 
MAX(nivel) AS nivel_máximo
FROM jugadores

-- 2.5 Encuentra el equipamiento con mayor bono de ataque
-- Tu respuesta:
 
SELECT *
FROM equipamientos
WHERE bono_ataque = (SELECT MAX(bono_ataque) FROM equipamientos)

-- 2.6 Lista todos los tipos de monstruos únicos (sin duplicados)
-- Tu respuesta:

SELECT DISTINCT tipo_monstruo
FROM monstruos


-- 2.7 Muestra las misiones ordenadas por recompensa de oro (mayor a menor)
-- y luego por recompensa de experiencia (mayor a menor)
-- Tu respuesta:

SELECT *
FROM misiones
ORDER BY recompensa_oro DESC, recompensa_xp DESC

-- 2.8 Calcula la experiencia total y promedio por clan
-- Tu respuesta:

SELECT nombre_clan, SUM(experiencia) as Total_exp_clan, AVG(experiencia) as exp_prom_clan
FROM clanes c 
INNER JOIN jugadores j ON c.id_clan = j.clan_id
group by nombre_clan

-- 2.9 Encuentra los jugadores que NO tienen clan asignado (clan_id es NULL)
-- y muestra "Sin Clan" en lugar de NULL
-- Tu respuesta:

SELECT id_jugador, nombre_jugador, nivel, experiencia, COALESCE(clan_id, 'Sin Clan') as clan_id
FROM jugadores
WHERE clan_id IS NULL 

SELECT id_jugador, nombre_jugador, nivel, experiencia, IFNULL(clan_id, 'Sin Clan') as clan_id
FROM jugadores
WHERE clan_id IS NULL 

-- 2.10 Cuenta cuántas misiones hay de cada nivel de dificultad
-- Tu respuesta:

SELECT dificultad, COUNT(id_mision) as cant_misiones
FROM misiones
GROUP BY dificultad


-- =====================================================
-- SECCIÓN 4: RELACIONES Y JOINS
-- =====================================================

-- 4.1 INNER JOIN: Muestra todos los jugadores con el nombre de su clan
-- Tu respuesta:

SELECT * 
FROM jugadores j
INNER JOIN clanes c
ON j.clan_id = c.id_clan


-- 4.2 LEFT JOIN: Muestra todos los clanes y cuántos jugadores tienen
-- (incluye clanes sin jugadores)
-- Tu respuesta:

SELECT nombre_clan, COUNT(id_jugador) as cantidad_jugadores
FROM clanes c
LEFT JOIN jugadores j
ON j.clan_id = c.id_clan
GROUP BY id_clan

-- 4.3 Muestra todas las misiones con el nombre del monstruo que hay que derrotar
-- Tu respuesta:

SELECT mi.nombre_mision as Misión, mo.nombre_monstruo as Monstruo , mo.nivel_monstruo as Nivel
FROM misiones mi
INNER JOIN monstruos mo
ON mi.monstruo_id = mo.id_monstruo
ORDER BY Nivel

SELECT mi.nombre_mision Misión, mo.nombre_monstruo as Monstruo, mo.nivel_monstruo as Nivel
FROM misiones mi, monstruos mo
WHERE mi.monstruo_id = mo.id_monstruo
ORDER BY Nivel

-- 4.4 Lista todos los jugadores con sus misiones completadas
-- mostrando: nombre jugador, nombre misión, fecha completada
-- Tu respuesta:

SELECT nombre_jugador, nombre_mision, fecha_completada
FROM jugadores j
INNER JOIN jugadores_misiones ju
ON j.id_jugador = ju.id_jugador
INNER JOIN misiones m
ON ju.id_mision = m.id_mision
WHERE ju.completada = True
ORDER BY fecha_completada

-- 4.5 Muestra el equipamiento que tiene cada jugador
-- incluyendo: nombre jugador, nombre equipamiento, cantidad
-- Tu respuesta:

USE juego_online;
SELECT j.nombre_jugador, e.nombre_equipamiento, je.cantidad
FROM jugadores j
INNER JOIN jugadores_equipamientos je
ON j.id_jugador = je.id_jugador
INNER JOIN equipamientos e
ON e.id_equipamiento = je.id_equipamiento

USE juego_online;
SELECT j.nombre_jugador, e.nombre_equipamiento, je.cantidad
FROM jugadores j, jugadores_equipamientos je
INNER JOIN equipamientos e
ON e.id_equipamiento = je.id_equipamiento
WHERE  j.id_jugador = je.id_jugador

-- 4.6 Encuentra los jugadores que NO han completado ninguna misión
-- Tu respuesta:

SELECT *
FROM jugadores j
LEFT JOIN jugadores_misiones jm
ON j.id_jugador = jm.id_jugador
WHERE jm.id_jugador IS NULL

SELECT *
FROM jugadores j
WHERE j.id_jugador 
NOT IN (SELECT id_jugador FROM jugadores_misiones)

SELECT *
FROM jugadores j
WHERE NOT EXISTS
	(SELECT 1
		FROM jugadores_misiones jm 
		WHERE jm.id_jugador = j.id_jugador)	

-- 4.7 Muestra los clanes con el nombre de su líder
-- Tu respuesta:

SELECT nombre_clan as Nombre_Clan, nombre_jugador as Lider_Clan
FROM clanes c
INNER JOIN jugadores j
ON c.lider_id = j.id_jugador

-- 4.8 Lista las misiones con su recompensa (tipo y descripción)
-- Tu respuesta:

SELECT nombre_mision, tipo_recompensa, descripcion_recompensa
FROM misiones m 
INNER JOIN recompensas r
ON m.recompensa_id = r.id_recompensa

-- 4.9 Muestra un ranking de clanes por experiencia total de sus miembros
-- Tu respuesta:

SELECT 
	ROW_NUMBER() OVER (ORDER BY SUM(j.experiencia) DESC) AS Ranking,
	c.nombre_clan as Nombre_Clan, 
	SUM(experiencia) as Experiencia_Clan
FROM jugadores j
INNER JOIN clanes c
ON j.clan_id = c.id_clan
GROUP BY c.id_clan
ORDER BY Experiencia_Clan DESC

-- 4.10 UNION: Crea una lista combinada de:
--      - Nombres de jugadores con el texto "Jugador"
--      - Nombres de clanes con el texto "Clan"
-- Tu respuesta:

SELECT 'Jugador' AS Tipo, nombre_jugador AS Nombre
FROM jugadores
UNION 
SELECT 'Clan' AS Tipo, nombre_clan AS Nombre
FROM clanes

-- =====================================================
-- SECCIÓN 3: OPERACIONES AVANZADAS (Día 4)
-- =====================================================

-- 3.1 Usa una SUBCONSULTA para encontrar jugadores con experiencia
-- superior al promedio
-- Tu respuesta:

SELECT * 
FROM jugadores
WHERE experiencia > 
(SELECT AVG(experiencia) FROM jugadores)

-- 3.2 Usa WITH (CTE) para calcular estadísticas por clan:
--     - Nombre del clan
--     - Total de jugadores
--     - Nivel promedio
--     - Experiencia total
-- Luego muestra solo los clanes con más de 3 jugadores
-- Tu respuesta:

WITH Estadísticas_x_Clan AS (
	SELECT 
		c.nombre_clan AS Nombre_Clan,
		COUNT(j.id_jugador) AS Total_Jugadores,
        ROUND(AVG(j.nivel), 1) AS Nivel_Promedio,
        SUM(j.experiencia) AS Experiencia_Total
		FROM jugadores j
		INNER JOIN clanes c
		ON c.id_clan = j.clan_id
		WHERE j.clan_id IS NOT NULL 
		GROUP BY c.id_clan)

SELECT *
FROM Estadísticas_x_Clan 
WHERE Total_Jugadores > 3 
ORDER BY Nivel_Promedio DESC

-- 3.3 Usa ROW_NUMBER para numerar a los jugadores dentro de cada clan
-- ordenados por nivel descendente
-- Tu respuesta:

SELECT 
	ROW_NUMBER() OVER (PARTITION BY c.id_clan ORDER BY j.nivel DESC) AS Numeracion_Jugadores,
    c.nombre_clan,
    j.nombre_jugador,
    j.nivel
FROM jugadores j
INNER JOIN clanes c
ON j.clan_id = c.id_clan

-- 3.4 Usa DENSE_RANK para rankear a los jugadores globalmente por experiencia
-- Tu respuesta:

SELECT 
	DENSE_RANK() OVER (ORDER BY experiencia DESC) AS Ranking,
    nombre_jugador,
    experiencia
    FROM jugadores

-- 3.5 Usa LAG para mostrar, para cada jugador, cuál es el jugador anterior
-- en términos de experiencia (ordenado por experiencia descendente)
-- Tu respuesta:

SELECT 
    nombre_jugador,
    experiencia,
    COALESCE(LAG(nombre_jugador) OVER (ORDER BY experiencia DESC), 'Sin datos') AS Jugador_Anterior
    FROM jugadores

SELECT 
    nombre_jugador,
    experiencia,
    LAG(experiencia, 1, 0) OVER (ORDER BY experiencia DESC) AS Jugador_Anterior
    FROM jugadores


-- 3.6 Usa LEAD para mostrar el siguiente nivel de equipamiento
-- (ordenado por nivel_requerido)
-- Tu respuesta:

SELECT
nombre_equipamiento,
nivel_requerido,
COALESCE(LEAD(nombre_equipamiento) OVER (ORDER BY nivel_requerido), 'Sin datos') AS Siguiente_equipamiento
FROM equipamientos


-- 3.7 Crea un PIVOT que muestre la cantidad de misiones por dificultad
-- y por rango de recompensa de oro:
--     - Bajo: 0-100
--     - Medio: 101-300
--     - Alto: 301+
-- Tu respuesta:

SELECT 
	dificultad AS Dificultad_Mision,
    COUNT(id_mision) AS Cantidad_misiones,
    COUNT(CASE WHEN recompensa_oro BETWEEN 0 AND 100 THEN 1 END) AS Rango_Recompensa_Bajo,
    COUNT(CASE WHEN recompensa_oro BETWEEN 101 AND 300 THEN 1 END) AS Rango_Recompensa_Medio,
    COUNT(CASE WHEN recompensa_oro > 301 THEN 1 END) AS Rango_Recompensa_Alto
FROM misiones
GROUP BY dificultad WITH ROLLUP

-- 3.8 Usa window functions para calcular:
--     - El nivel de cada jugador
--     - El nivel promedio de su clan
--     - La diferencia entre su nivel y el promedio del clan
-- Tu respuesta:

SELECT 
	c.nombre_clan,
    j.nombre_jugador,
	j.nivel AS Nivel_Individual,
    ROUND(AVG(j.nivel) OVER (PARTITION BY c.id_clan), 1) AS Nivel_Promedio_Clan,
    ROUND(j.nivel - AVG(nivel) OVER (PARTITION BY c.id_clan), 1) AS Diferencia
FROM jugadores j
INNER JOIN clanes c
ON j.clan_id = c.id_clan

WITH Calculo_Base AS (
    SELECT 
        c.nombre_clan,
        j.nombre_jugador,
        j.nivel AS Nivel_Individual,
        ABS(ROUND(AVG(j.nivel) OVER (PARTITION BY c.id_clan), 1)) AS Nivel_Promedio_Clan
    FROM jugadores j
    INNER JOIN clanes c ON j.clan_id = c.id_clan
)
SELECT *, 
       (Nivel_Individual - Nivel_Promedio_Clan) AS Diferencia -- <-- Más limpio
FROM Calculo_Base;

-- 3.9 Encuentra el top 3 de jugadores con más experiencia de cada clan
-- usando ROW_NUMBER y CTE
-- Tu respuesta:

WITH Ranking_Jugadores_x_Clan AS (SELECT 
ROW_NUMBER() OVER (PARTITION BY c.id_clan ORDER BY experiencia DESC ) AS Ranking,
 c.nombre_clan, j.nombre_jugador, experiencia
FROM jugadores j
INNER JOIN clanes c
ON j.clan_id = c.id_clan)

SELECT * FROM Ranking_Jugadores_x_Clan 
WHERE Ranking IN (1, 2, 3)

-- 3.10 Calcula la suma acumulada de experiencia de los jugadores
-- ordenados por nivel ascendente
-- Tu respuesta:

SELECT 
	j.nombre_jugador,
    nivel,
    j.experiencia,
	SUM(j.experiencia) OVER (ORDER BY j.nivel, nombre_jugador) AS Experiencia_Acumulada
FROM jugadores j
ORDER BY j.nivel


-- =====================================================
-- SECCIÓN 5: CONSULTAS COMPLEJAS INTEGRADAS
-- =====================================================

-- 5.1 Encuentra el jugador más poderoso de cada clan
-- (considerando nivel + experiencia/1000)
-- Tu respuesta:

WITH Calculo_Inicial AS (
SELECT
	c.nombre_clan,
	j.nombre_jugador,
    j.clan_id,
    ROUND(nivel + (experiencia / 1000), 1) AS Poder_Jugador
FROM jugadores j
INNER JOIN clanes c
ON j.clan_id = c.id_clan
),

Ranking AS(
SELECT * , 
ROW_NUMBER() OVER (PARTITION BY clan_id order by Poder_Jugador DESC ) AS Clan_Rank
FROM Calculo_Inicial)
SELECT * FROM Ranking
WHERE Clan_Rank = 1

-- 5.2 Calcula el "poder de combate" de cada jugador sumando:
--     - Su nivel * 10
--     - Suma de bonos de ataque de su equipamiento
--     - Suma de bonos de defensa de su equipamiento
-- Muestra el top 10
-- Tu respuesta:

SELECT 
	j.nombre_jugador,
    j.nivel * 10 + SUM(bono_ataque + bono_defensa) AS Poder_de_Combate
FROM jugadores j
INNER JOIN jugadores_equipamientos je
ON j.id_jugador = je.id_jugador
INNER JOIN equipamientos e
ON je.id_equipamiento = e.id_equipamiento
GROUP BY j.id_jugador 
ORDER BY Poder_de_Combate DESC
LIMIT 10

-- 5.3 Crea un reporte de actividad de clanes que muestre:
--     - Nombre del clan
--     - Fecha de creación
--     - Nombre del líder
--     - Total de miembros
--     - Nivel promedio de miembros
--     - Total de misiones completadas por todos los miembros
-- Tu respuesta:

WITH Estadisticas_Jugadores AS 
(SELECT 
	clan_id, 
	COUNT(id_jugador) AS Miembros_Totales, 
    ROUND(AVG (j.nivel), 1) AS Nivel_Promedio
FROM jugadores j
WHERE clan_id IS NOT NULL
GROUP BY clan_id),

Estadisticas_Misiones AS (
SELECT clan_id, SUM(completada) AS Cantidad_Misiones
FROM jugadores j 
INNER JOIN jugadores_misiones jm 
ON j.id_jugador = jm.id_jugador
GROUP BY clan_id)

SELECT 
	c.nombre_clan,
    c.fecha_creacion,
    j.nombre_jugador AS Jugador_Lider,
    ej.Miembros_Totales,
    ej.Nivel_Promedio,
    em.Cantidad_Misiones
FROM jugadores j 
INNER JOIN clanes c 
ON j.id_jugador = c.lider_id 
INNER JOIN Estadisticas_Jugadores ej
ON c.id_clan = ej.clan_id
INNER JOIN Estadisticas_Misiones em
ON c.id_clan = em.clan_id


-- 5.4 Encuentra las misiones que ningún jugador ha completado aún
-- Tu respuesta:

SELECT * FROM
misiones 
WHERE id_mision NOT IN (SELECT DISTINCT id_mision AS Misiones_Completadas
FROM jugadores_misiones WHERE completada = True)

SELECT m.* FROM misiones m
LEFT JOIN jugadores_misiones jm 
ON m.id_mision = jm.id_mision AND jm.completada = True
WHERE jm.id_mision IS NULL
order by m.id_mision

-- 5.5 Muestra los jugadores "veteranos" (nivel >= 12) que tienen
-- equipamiento de nivel inferior a su nivel actual
-- Tu respuesta:
SELECT 
    j.id_jugador,
    j.nombre_jugador,
    j.nivel,
    e.nombre_equipamiento,
    e.nivel_requerido
FROM jugadores j
INNER JOIN jugadores_equipamientos je ON j.id_jugador = je.id_jugador
INNER JOIN equipamientos e ON e.id_equipamiento = je.id_equipamiento
WHERE j.nivel >= 12 AND e.nivel_requerido < j.nivel

SELECT  DISTINCT
    j.id_jugador,
    j.nombre_jugador,
    j.nivel
FROM jugadores j
INNER JOIN jugadores_equipamientos je ON j.id_jugador = je.id_jugador
INNER JOIN equipamientos e ON e.id_equipamiento = je.id_equipamiento
WHERE j.nivel >= 12 AND e.nivel_requerido < j.nivel

SELECT 
    j.id_jugador,
    j.nombre_jugador,
    j.nivel,
    MAX(e.nivel_requerido) AS Equipamiento_mayor_nivel
FROM jugadores j
INNER JOIN jugadores_equipamientos je ON j.id_jugador = je.id_jugador
INNER JOIN equipamientos e ON e.id_equipamiento = je.id_equipamiento
WHERE j.nivel >= 12 
GROUP BY j.id_jugador,
    j.nombre_jugador,
    j.nivel
HAVING MAX(e.nivel_requerido) < j.nivel


-- 5.6 Calcula qué porcentaje de misiones ha completado cada jugador
-- Tu respuesta:

SELECT 
	j.id_jugador, 
    j.nombre_jugador, 
    COUNT(jm.id_jugador) AS Misiones_Completadas, 
    ROUND( COUNT(jm.id_jugador) * 100.0 / (SELECT COUNT(id_mision) FROM misiones), 1)  AS Porcentaje_Completadas
FROM jugadores j
INNER JOIN jugadores_misiones jm
ON j.id_jugador = jm.id_jugador
WHERE jm.completada = True
GROUP BY j.id_jugador, j.nombre_jugador

-- 5.7 Encuentra los "clanes élite" que cumplen TODAS estas condiciones:
--     - Tienen más de 4 miembros
--     - El nivel promedio de sus miembros es superior a 9
--     - Fueron creados antes de 2022
-- Tu respuesta:

WITH Calculo_Clanes AS (
SELECT 
	c.id_clan, 
	ROUND(AVG(j.nivel), 1) AS Nivel_Promedio, 
    COUNT(j.id_jugador) AS Miembros_Clan 
FROM clanes c 
INNER JOIN jugadores j 
ON j.clan_id = c.id_clan 
GROUP BY c.id_clan )

SELECT 
	c.id_clan,
    c.nombre_clan,
    cl.Nivel_Promedio,
    cl.Miembros_Clan
FROM clanes c
INNER JOIN Calculo_Clanes cl
ON c.id_clan = cl.id_clan
WHERE YEAR(c.fecha_creacion) < '2022' AND cl.Nivel_Promedio > 9 AND cl.Miembros_Clan > 4


-- 5.8 Crea un ranking de monstruos por "peligrosidad" considerando:
--     - Su nivel * 2
--     - Su vida / 10
-- Muestra el top 10 más peligrosos
-- Tu respuesta:

WITH Peligrosidad AS (
SELECT 
    id_monstruo,
    nivel_monstruo * 2 + ROUND(vida / 10.00) AS Peligrosidad
FROM monstruos)

SELECT 
	ROW_NUMBER() OVER (ORDER BY p.Peligrosidad DESC) AS Ranking,
    nombre_monstruo,
    p.Peligrosidad
FROM monstruos m 
INNER JOIN 
Peligrosidad p ON p.id_monstruo = m.id_monstruo
LIMIT 10


-- 5.9 Identifica los jugadores "coleccionistas" que tienen más de 5
-- equipamientos diferentes
-- Tu respuesta:

SELECT 
	j.nombre_jugador,
    j.nivel,
    j.experiencia,
    COUNT(DISTINCT je.id_equipamiento) AS Cant_Equipamientos
FROM jugadores j
INNER JOIN jugadores_equipamientos je
ON j.id_jugador = je.id_jugador
GROUP BY j.id_jugador
HAVING Cant_Equipamientos > 5

-- 5.10 Genera un reporte de "eficiencia de misiones" que muestre:
--      - Nombre de la misión
--      - Dificultad
--      - Ratio XP/Oro
--      - Cantidad de jugadores que la completaron
--      - Clasificación: "Muy Eficiente" si ratio > 10, 
--        "Eficiente" si ratio 5-10, "Normal" si < 5
-- Tu respuesta:

WITH Cant_Completada AS (
SELECT 
	m.id_mision,
    SUM(CASE WHEN completada = 1 THEN 1 ELSE 0 END) AS Cantidad_Completada
FROM misiones m
LEFT JOIN jugadores_misiones jm
ON m.id_mision = jm.id_mision
GROUP BY id_mision ),

Ratio AS(
SELECT 
	id_mision,
	(recompensa_xp * 1.0) / NULLIF(recompensa_oro, 0) AS Ratio_xp_oro 
FROM misiones)

SELECT 
	m.nombre_mision,
    m.dificultad,
    c.Cantidad_Completada,
    ROUND(r.Ratio_xp_oro, 2) AS Ratio_xp_oro,
    CASE WHEN r.Ratio_xp_oro > 10 THEN 'Muy Eficiente'
    WHEN Ratio_xp_oro BETWEEN 5 AND 10 THEN 'Eficiente'
    ELSE 'Normal' END AS Clasificación
FROM misiones m
INNER JOIN Cant_Completada c
ON m.id_mision = c.id_mision
INNER JOIN Ratio r
ON m.id_mision = r.id_mision

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


-- 6.10 Consulta las estadísticas de uso de las tablas principales
-- usando pg_stat_user_tables
-- Tu respuesta:


-- =====================================================
-- SECCIÓN 7: DESAFÍOS FINALES
-- =====================================================

-- 7.1 DESAFÍO: Sistema de Recomendación de Misiones
-- Crea una consulta que recomiende misiones a un jugador específico:
--     - Que NO haya completado aún
--     - Que la dificultad sea apropiada para su nivel:
--       * Nivel 1-5: Fácil
--       * Nivel 6-10: Fácil o Intermedio
--       * Nivel 11-15: Cualquiera
--     - Ordenadas por recompensa de XP descendente
-- Pruébalo con el jugador id=10
-- Tu respuesta:


-- 7.2 DESAFÍO: Análisis de Progresión de Jugadores
-- Crea un reporte que muestre para cada jugador:
--     - Nombre
--     - Nivel actual
--     - Experiencia actual
--     - Experiencia necesaria para siguiente nivel (nivel * 1000)
--     - Porcentaje de progreso al siguiente nivel
--     - Clasificación: "Cerca de subir" si > 80%, "En progreso" si no
-- Tu respuesta:


-- 7.3 DESAFÍO: Sistema de Matchmaking de Clanes
-- Encuentra pares de clanes que podrían ser buenos rivales:
--     - Diferencia de nivel promedio menor a 2
--     - Diferencia en cantidad de miembros menor a 3
--     - No incluir el mismo clan dos veces
-- Tu respuesta:


-- 7.4 DESAFÍO: Detección de Jugadores Inactivos
-- Identifica jugadores "inactivos" que:
--     - No han completado ninguna misión en los últimos 30 días
--     - O no tienen ninguna misión completada
-- Muestra: nombre, nivel, última fecha de actividad (o "Nunca")
-- Tu respuesta:


-- 7.5 DESAFÍO: Sistema de Logros
-- Crea una consulta que identifique jugadores que merecen logros:
--     - "Maestro de Armas": Tiene más de 3 armas
--     - "Cazador de Dragones": Ha completado misiones contra dragones
--     - "Líder Nato": Es líder de un clan
--     - "Veterano": Nivel >= 12
-- Muestra: nombre jugador, logros obtenidos (concatenados)
-- Tu respuesta:
