SET SERVEROUTPUT ON;

-- ======================================================================
-- 1. TRIGGER A NIVEL DE SENTENCIA (STATEMENT)
-- Tabla asociada: CALIFICACIONES
-- Propósito: Controlar la seguridad del sistema restringiendo cambios masivos o individuales fuera del horario laboral administrativo.
-- ======================================================================
CREATE OR REPLACE TRIGGER trg_control_horario_calificaciones
BEFORE INSERT OR UPDATE OR DELETE ON calificaciones
DECLARE
    v_operacion VARCHAR2(10);
BEGIN
    -- Bloquea modificaciones los fines de semana (Sábado/Domingo) o fuera de 08:00 a 18:59 hrs
    IF TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH') IN ('SAT', 'SUN')
       OR TO_NUMBER(TO_CHAR(SYSDATE, 'HH24')) NOT BETWEEN 8 AND 18 THEN
        v_operacion := CASE WHEN INSERTING THEN 'INSERTAR'
                            WHEN UPDATING  THEN 'MODIFICAR'
                            ELSE 'ELIMINAR' END;
        RAISE_APPLICATION_ERROR(
            -20003,
            'Seguridad: No se permite ' || v_operacion || ' calificaciones fuera del horario (Lunes a Viernes de 08:00 a 18:59 hrs).'
        );
    END IF;
END trg_control_horario_calificaciones;
/

-- ======================================================================
-- 2. TRIGGER A NIVEL DE FILA (FOR EACH ROW)
-- Tabla asociada: CALIFICACIONES
-- Propósito: Garantizar la integridad de datos validando que las notas ingresadas o modificadas pertenezcan al rango de 1.0 a 7.0.
-- ======================================================================
CREATE OR REPLACE TRIGGER trg_validar_nota_bi
BEFORE INSERT OR UPDATE OF nota ON calificaciones
FOR EACH ROW
BEGIN
    IF :NEW.nota < 1.0 OR :NEW.nota > 7.0 THEN
        RAISE_APPLICATION_ERROR(
            -20002, 
            'Error de negocio: La nota ingresada (' || :NEW.nota || ') debe estar entre 1.0 y 7.0.'
        );
    END IF;
END trg_validar_nota_bi;
/

-- ======================================================================
-- PRUEBAS DE EVALUACIÓN Y VERIFICACIÓN
-- ======================================================================

-- Prueba 1: Nota inválida (Debe fallar con error -20002)
-- INSERT INTO calificaciones (id_matricula, id_carga, nota, ponderacion, descripcion) 
-- VALUES (1, 1, 8.5, 0.20, 'Evaluación fuera de rango');

-- Prueba 2: Nota válida (Debe insertarse correctamente si se ejecuta dentro del horario)
-- INSERT INTO calificaciones (id_matricula, id_carga, nota, ponderacion, descripcion) 
-- VALUES (1, 1, 6.5, 0.20, 'Prueba exitosa');
