-- 1. Tabla de Recompensas (La creamos primero porque misiones y monstruos la apuntan)
CREATE TABLE recompensas (
    id_recompensa INT PRIMARY KEY,
    tipo_recompensa VARCHAR2(100),  -- En Oracle se prefiere VARCHAR2
    descripcion_recompensa VARCHAR2(255)
);

-- 2. Tabla de Monstruos
CREATE TABLE monstruos (
    id_monstruo INT PRIMARY KEY,
    nombre_monstruo VARCHAR2(100),
    nivel_monstruo INT,
    vida INT,
    tipo_monstruo VARCHAR2(50),
    recompensa_id INT,
    FOREIGN KEY (recompensa_id) REFERENCES recompensas(id_recompensa)
);

-- 3. Tabla de Misiones
CREATE TABLE misiones (
    id_mision INT PRIMARY KEY,
    nombre_mision VARCHAR2(100),
    dificultad VARCHAR2(50),
    recompensa_xp INT,
    recompensa_oro INT,
    recompensa_id INT,
    monstruo_id INT,
    FOREIGN KEY (recompensa_id) REFERENCES recompensas(id_recompensa),
    FOREIGN KEY (monstruo_id) REFERENCES monstruos(id_monstruo)
);

-- 4. Tabla de Jugadores (Sin la FK de clanes por ahora, para evitar el huevo o la gallina)
CREATE TABLE jugadores (
    id_jugador INT PRIMARY KEY,
    nombre_jugador VARCHAR2(100),
    nivel INT DEFAULT 1,
    experiencia INT DEFAULT 0,
    clan_id INT
);

-- 5. Tabla de Clanes
CREATE TABLE clanes (
    id_clan INT PRIMARY KEY,
    nombre_clan VARCHAR2(100),
    fecha_creacion DATE,
    lider_id INT,
    FOREIGN KEY (lider_id) REFERENCES jugadores(id_jugador)
);

-- Ahora que existen ambas, agregamos la FK cruzada entre jugadores y clanes
ALTER TABLE jugadores
ADD CONSTRAINT fk_clan
FOREIGN KEY (clan_id) REFERENCES clanes(id_clan);

-- 6. Tabla de Equipamiento
CREATE TABLE equipamientos (
    id_equipamiento INT PRIMARY KEY,
    nombre_equipamiento VARCHAR2(100),
    tipo VARCHAR2(50),
    nivel_requerido INT,
    bono_ataque INT DEFAULT 0,
    bono_defensa INT DEFAULT 0
);

-- 7. Tabla N-N Jugadores y Misiones (Cambiamos BIT por NUMBER(1))
CREATE TABLE jugadores_misiones (
    id_jugador INT,
    id_mision INT,
    fecha_completada DATE,
    completada NUMBER(1) DEFAULT 0, -- 1 = True, 0 = False
    PRIMARY KEY (id_jugador, id_mision),
    FOREIGN KEY (id_jugador) REFERENCES jugadores(id_jugador),
    FOREIGN KEY (id_mision) REFERENCES misiones(id_mision)
);

-- 8. Tabla N-N Jugadores y Recompensas
CREATE TABLE jugadores_recompensas (
    id_jugador INT,
    id_recompensa INT,
    fecha_obtenida DATE,
    PRIMARY KEY (id_jugador, id_recompensa),
    FOREIGN KEY (id_jugador) REFERENCES jugadores(id_jugador),
    FOREIGN KEY (id_recompensa) REFERENCES recompensas(id_recompensa)
);

-- 9. Tabla N-N Jugadores y Equipamiento
CREATE TABLE jugadores_equipamientos (
    id_jugador INT,
    id_equipamiento INT,
    cantidad INT DEFAULT 1,
    PRIMARY KEY (id_jugador, id_equipamiento),
    FOREIGN KEY (id_jugador) REFERENCES jugadores(id_jugador),
    FOREIGN KEY (id_equipamiento) REFERENCES equipamientos(id_equipamiento)
);