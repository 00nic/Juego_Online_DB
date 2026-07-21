-- =====================================================
-- SECCIÓN 3: OPERACIONES AVANZADAS
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