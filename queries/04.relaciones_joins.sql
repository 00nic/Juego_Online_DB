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