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