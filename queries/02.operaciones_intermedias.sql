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