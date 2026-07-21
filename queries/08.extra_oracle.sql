-- =====================================================
-- TRIGGERS DDL Y DML
-- =====================================================

CREATE OR REPLACE TRIGGER tg_completar_mision
AFTER INSERT OR UPDATE ON jugadores_misiones
FOR EACH ROW
DECLARE
    v_xp_ganada INT;
BEGIN
    
    IF (INSERTING AND :NEW.completada = 1) OR 
       (UPDATING AND :OLD.completada = 0 AND :NEW.completada = 1) THEN
        
        SELECT recompensa_xp INTO v_xp_ganada
        FROM misiones
        WHERE id_mision = :NEW.id_mision;
        
        UPDATE jugadores
        SET experiencia = experiencia + v_xp_ganada
        WHERE id_jugador = :NEW.id_jugador;
        
    END IF;
END;
/

INSERT INTO jugadores_misiones (id_jugador, id_mision, fecha_completada, completada)
VALUES (1, 12, SYSDATE, 1);

INSERT INTO jugadores_misiones (id_jugador, id_mision, fecha_completada, completada)
VALUES (20, 1, SYSDATE, 1);

--------------------------------------------------------------------

CREATE OR REPLACE TRIGGER tg_guardaesquema_juego
BEFORE ALTER OR DROP ON SCHEMA
BEGIN
    -- Verificamos si el objeto que intentan alterar o borrar es una de nuestras tablas críticas
    IF ORA_DICT_OBJ_NAME IN ('JUGADORES', 'CLANES', 'MISIONES', 'EQUIPAMIENTOS') THEN
        
        -- Frenamos la ejecución lanzando un error personalizado (códigos entre -20000 y -20999)
        RAISE_APPLICATION_ERROR(-20001, 
            '¡ALERTA DE SEGURIDAD!: No tienes permisos para modificar o borrar la tabla ' 
            || ORA_DICT_OBJ_NAME || ' en el entorno del juego.');
            
    END IF;
END;

DROP TABLE clanes;
ALTER TABLE equipamientos DROP COLUMN bono_ataque;

-- =====================================================
-- VISTA MATERIALIZADA
-- =====================================================
Es una foto fija de un cálculo pesado guardada en disco
como si fuera una tabla real. 
para que las consultas pesadas vuelen. 
Sacrifica frescura de datos en tiempo real 
a cambio de una velocidad brutal.

CREATE MATERIALIZED VIEW mv_ranking_clanes
BUILD IMMEDIATE
REFRESH COMPLETE
NEXT SYSDATE + (1/24) 
AS
SELECT 
    c.id_clan,
    c.nombre_clan,
    COUNT(j.id_jugador) AS total_miembros,
    ROUND(AVG(j.nivel), 2) AS nivel_promedio,
    SUM(j.experiencia) AS experiencia_total
FROM clanes c
INNER JOIN jugadores j ON c.id_clan = j.clan_id
GROUP BY c.id_clan, c.nombre_clan
ORDER BY experiencia_total DESC;

SELECT * FROM mv_ranking_clanes;

BEGIN
    DBMS_MVIEW.REFRESH('mv_ranking_clanes', 'C');
END;

INSERT INTO JUGADORES (id_jugador, nombre_jugador, nivel, experiencia, clan_id) VALUES (31, 'Nicolacito', 1, 0, 4)

-- =====================================================
-- SQL DINÁMICO con marcadores de posición, using y execute immediate
-- =====================================================
El SQL Dinámico es la capacidad de escribir código SQL 
como si fuera una simple cadena de texto (String), 
armarlo sobre la marcha usando variables y obligar 
al motor a ejecutar ese texto como si fuera una orden 
real en tiempo de ejecución.

CREATE OR REPLACE PROCEDURE contar_por_nivel(
    p_tabla       IN VARCHAR2,
    p_col_nivel   IN VARCHAR2,
    p_nivel_min   IN INT,
    p_nivel_max   IN INT
)
IS
    v_sql       VARCHAR2(1000);
    v_resultado INT;
BEGIN
    v_sql := 'SELECT COUNT(*) FROM ' || p_tabla || 
             ' WHERE ' || p_col_nivel || ' BETWEEN :min AND :max';
             
    EXECUTE IMMEDIATE v_sql INTO v_resultado USING p_nivel_min, p_nivel_max;
    
    DBMS_OUTPUT.PUT_LINE('Tabla: ' || p_tabla || ' | Rango Nivel: ' || p_nivel_min || '-' || p_nivel_max || ' | Total: ' || v_resultado);
    
END;

BEGIN
    contar_por_nivel('JUGADORES', 'NIVEL', 10, 15);
END;

BEGIN
    contar_por_nivel('MONSTRUOS', 'NIVEL_MONSTRUO', 5, 12);
END;

-- =====================================================
-- PACKAGES (Especificación + Cuerpo)
-- =====================================================

CREATE OR REPLACE PACKAGE pkg_sistema_clanes IS

    PROCEDURE crear_clan(
        p_id_clan      IN INT,
        p_nombre_clan  IN VARCHAR2,
        p_id_lider     IN INT
    );

    FUNCTION obtener_xp_clan(
        p_id_clan IN INT
    ) RETURN INT;

END pkg_sistema_clanes;

CREATE OR REPLACE PACKAGE BODY pkg_sistema_clanes IS

    PROCEDURE crear_clan(
        p_id_clan      IN INT,
        p_nombre_clan  IN VARCHAR2,
        p_id_lider     IN INT
    ) IS
    BEGIN

        INSERT INTO clanes (id_clan, nombre_clan, fecha_creacion, lider_id)
        VALUES (p_id_clan, p_nombre_clan, SYSDATE, p_id_lider);
        
        UPDATE jugadores
        SET clan_id = p_id_clan
        WHERE id_jugador = p_id_lider;
        
        COMMIT; 
    END crear_clan;

    FUNCTION obtener_xp_clan(
        p_id_clan IN INT
    ) RETURN INT IS
        v_xp_total INT := 0;
    BEGIN
        
        SELECT SUM(experiencia) INTO v_xp_total
        FROM jugadores
        WHERE clan_id = p_id_clan;
        
        RETURN NVL(v_xp_total, 0);
    END obtener_xp_clan;

END pkg_sistema_clanes;

BEGIN
    pkg_sistema_clanes.crear_clan(7, 'Orden del Fénix', 5);
END;
/

DECLARE
    v_total_xp INT;
BEGIN
    v_total_xp := pkg_sistema_clanes.obtener_xp_clan(1);
    DBMS_OUTPUT.PUT_LINE('La experiencia acumulada del Clan 1 es de: ' || v_total_xp || ' puntos.');
END;

-- =====================================================
-- TRANSACCIONES, SAVEPOINTS, ROLLBACK, COMMIT, LOCKS
-- =====================================================

DECLARE
    v_oro_comprador      INT := 1000;
    v_precio_item        INT := 500;
    v_id_vendedor        INT := 1;    -- Arthorius
    v_id_comprador       INT := 2;    -- Elora
    v_id_equipamiento    INT := 1;    -- Espada Cortante
    
    v_cantidad_vendedor  INT;
BEGIN
    
    SELECT nivel INTO v_cantidad_vendedor 
    FROM jugadores 
    WHERE id_jugador = v_id_vendedor
    FOR UPDATE;

    DBMS_OUTPUT.PUT_LINE('Paso 1: Bloqueado el vendedor de forma segura...');
    
    SAVEPOINT oro_cobrado;

    SELECT cantidad INTO v_cantidad_vendedor
    FROM jugadores_equipamientos
    WHERE id_jugador = v_id_vendedor AND id_equipamiento = v_id_equipamiento;
    
    IF v_cantidad_vendedor >= 1 THEN
        UPDATE jugadores_equipamientos
        SET cantidad = cantidad - 1
        WHERE id_jugador = v_id_vendedor AND id_equipamiento = v_id_equipamiento;
        
        UPDATE jugadores_equipamientos
        SET cantidad = cantidad + 1
        WHERE id_jugador = v_id_comprador AND id_equipamiento = v_id_equipamiento;
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('¡ÉXITO!: Intercambio completado y guardado permanentemente.');
    ELSE
        ROLLBACK TO oro_cobrado;
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('¡FALLO!: El vendedor no tenía el ítem.');
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('ERROR CRÍTICO: No se encontró el ítem en el inventario de Arthorius.');
END;
/