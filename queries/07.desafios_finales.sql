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

DROP PROCEDURE IF EXISTS recomendacion_misiones;
DELIMITER $$

CREATE PROCEDURE recomendacion_misiones(
	IN in_id_jugador INT)
BEGIN
	DECLARE v_nivel_jugador INT;
    
    SELECT nivel INTO v_nivel_jugador 
    FROM jugadores 
    WHERE id_jugador = in_id_jugador;
    
	SELECT nombre_mision, dificultad, recompensa_xp
	FROM misiones m
	WHERE id_mision NOT IN 
		(SELECT id_mision FROM jugadores_misiones 
			WHERE id_jugador = in_id_jugador AND completada = 1)
	AND (
		(v_nivel_jugador BETWEEN 1 AND 5 AND dificultad = 'Facil')
		OR
		(v_nivel_jugador BETWEEN 6 AND 10 AND dificultad IN ('Facil', 'Intermedio'))
		OR
		(v_nivel_jugador > 10 AND dificultad = 'Facil'))
	ORDER BY recompensa_xp;
    
END$$

CALL recomendacion_misiones(10);

-- 7.2 DESAFÍO: Análisis de Progresión de Jugadores
-- Crea un reporte que muestre para cada jugador:
--     - Nombre
--     - Nivel actual
--     - Experiencia actual
--     - Experiencia necesaria para siguiente nivel (nivel * 1000)
--     - Porcentaje de progreso al siguiente nivel
--     - Clasificación: "Cerca de subir" si > 80%, "En progreso" si no
-- Tu respuesta:

WITH Calculos_Jugadores AS (
	SELECT 
	nombre_jugador, 
	nivel, 
	experiencia, 
    nivel * 1000 AS Experiencia_necesaria,
    ROUND((experiencia * 100) / NULLIF(nivel * 1000, 0), 2) AS Porcentaje_Progreso
    FROM jugadores
)
SELECT nombre_jugador, 
	nivel, 
	experiencia, 
    Experiencia_necesaria,
    COALESCE (Porcentaje_Progreso, 0),
    CASE WHEN Porcentaje_Progreso > 80 THEN 'Cerca de subir' ELSE 'En progreso' END AS Clasificación
    FROM Calculos_Jugadores


-- 7.3 DESAFÍO: Sistema de Matchmaking de Clanes
-- Encuentra pares de clanes que podrían ser buenos rivales:
--     - Diferencia de nivel promedio menor a 2
--     - Diferencia en cantidad de miembros menor a 3
--     - No incluir el mismo clan dos veces
-- Tu respuesta:

WITH Estadisticas_Clanes AS (
SELECT 
	c.id_clan,
	ROUND(AVG(nivel), 1) AS Nivel_Promedio_Clan, 
    COUNT(id_jugador) AS Cantidad_Miembros
    FROM jugadores j
    INNER JOIN clanes c ON j.clan_id = c.id_clan
    GROUP BY c.id_clan
)

SELECT *
FROM Estadisticas_Clanes c1
INNER JOIN Estadisticas_Clanes c2
ON c1.id_clan < c2.id_clan 
WHERE ABS(c1.Nivel_Promedio_Clan - c2.Nivel_Promedio_Clan) < 2
AND ABS(c1.Cantidad_Miembros - c2.Cantidad_Miembros) < 3




-- 7.4 DESAFÍO: Detección de Jugadores Inactivos
-- Identifica jugadores "inactivos" que:
--     - No han completado ninguna misión en los últimos 30 días
--     - O no tienen ninguna misión completada
-- Muestra: nombre, nivel, última fecha de actividad (o "Nunca")
-- Tu respuesta:

WITH ultima_mision AS (
SELECT id_jugador, MAX(fecha_completada) AS Ultima_mision
FROM jugadores_misiones WHERE completada = 1 
GROUP BY id_jugador )

SELECT j.id_jugador, j.nombre_jugador, j.nivel, u.id_jugador, COALESCE(CAST( u.ultima_mision AS CHAR), 'Nunca') AS Inactividad
FROM jugadores j
LEFT JOIN
ultima_mision u
ON j.id_jugador = u.id_jugador
WHERE u.id_jugador IS NULL OR TIMESTAMPDIFF(DAY, u.ultima_mision, CURDATE()) >= 30

-- 7.5 DESAFÍO: Sistema de Logros
-- Crea una consulta que identifique jugadores que merecen logros:
--     - "Maestro de Armas": Tiene más de 3 armas
--     - "Cazador de Dragones": Ha completado misiones contra dragones
--     - "Líder Nato": Es líder de un clan
--     - "Veterano": Nivel >= 12
-- Muestra: nombre jugador, logros obtenidos (concatenados)
-- Tu respuesta:

WITH Maestro_armas AS(
SELECT j.id_jugador , SUM(cantidad) AS Cantidad_Total_Armas, 'Maestro de Armas' AS Logros
FROM jugadores_equipamientos j
INNER JOIN equipamientos e ON e.id_equipamiento = j.id_equipamiento
WHERE tipo = 'arma'
GROUP BY j.id_jugador
HAVING Cantidad_Total_Armas >= 3),

Cazador_dragones AS (
SELECT DISTINCT j.id_jugador, 'Cazador de Dragones' AS Logros
FROM jugadores_misiones j
INNER JOIN misiones m
ON j.id_mision = m.id_mision
INNER JOIN monstruos mo
ON m.monstruo_id = mo.id_monstruo
WHERE j.completada = 1 AND mo.tipo_monstruo = 'Dragón'
),

Lider_nato AS (
SELECT lider_id AS id_jugador, 'Líder Nato' AS Logros
FROM clanes 
WHERE lider_id IS NOT NULL),

Veterano AS (
SELECT id_jugador, 'Veterano' AS Logros
FROM jugadores 
WHERE nivel >= 12)

SELECT j.id_jugador, nombre_jugador, 
CASE 
	WHEN CONCAT_WS(', ', v.Logros, l.Logros, c.Logros, m.Logros) = '' THEN 'Sin logros' 
	ELSE CONCAT_WS(', ', v.Logros, l.Logros, c.Logros, m.Logros) 
END AS Logros
FROM jugadores j 
LEFT JOIN Veterano v ON j.id_jugador = v.id_jugador
LEFT JOIN Lider_nato l ON j.id_jugador = l.id_jugador
LEFT JOIN Cazador_dragones c ON j.id_jugador = c.id_jugador
LEFT JOIN Maestro_armas m ON j.id_jugador = m.id_jugador
ORDER BY j.id_jugador