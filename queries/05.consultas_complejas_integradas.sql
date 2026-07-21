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
    WHEN r.Ratio_xp_oro BETWEEN 5 AND 10 THEN 'Eficiente'
    ELSE 'Normal' END AS Clasificación
FROM misiones m
INNER JOIN Cant_Completada c
ON m.id_mision = c.id_mision
INNER JOIN Ratio r
ON m.id_mision = r.id_mision