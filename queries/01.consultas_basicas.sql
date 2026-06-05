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
