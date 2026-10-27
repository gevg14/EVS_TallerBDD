-- ======================================================================
-- SCRIPT COMPLETO DE PRUEBAS UNITARIAS PL/SQL
-- PROYECTO: LIBRO DE CLASES DIGITAL (EVALUACION PARCIAL 2)
-- Incluye: Casos de éxito y casos de error para cada bloque de código.
-- ======================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

PROMPT ======================================================================
PROMPT 1. PRUEBAS: fn_promedio_asignatura
PROMPT ======================================================================

-- 1.1 Caso Exitoso: Cálculo ponderado para Matrícula 1 y Carga 1
DECLARE
    v_prom NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Caso Exitoso ---');
    v_prom := fn_promedio_asignatura(p_id_matricula => 1, p_id_carga => 1);
    DBMS_OUTPUT.PUT_LINE('Resultado: Promedio obtenido = ' || NVL(TO_CHAR(v_prom), 'Sin notas'));
END;
/

-- 1.2 Caso de Error: Parámetro alfanumérico no convertible a NUMBER (ORA-06502)
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Caso con Error Controlado ---');
    DECLARE
        v_prom NUMBER;
    BEGIN
        EXECUTE IMMEDIATE 'BEGIN :1 := fn_promedio_asignatura(p_id_matricula => ''INVALIDO'', p_id_carga => 1); END;'
            USING OUT v_prom;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error capturado esperado: ' || SQLERRM);
    END;
END;
/


PROMPT ======================================================================
PROMPT 2. PRUEBAS: fn_total_matriculas
PROMPT ======================================================================

-- 2.1 Caso Exitoso: Conteo total de matrículas
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Caso Exitoso ---');
    DBMS_OUTPUT.PUT_LINE('Resultado: Total matrículas registradas = ' || fn_total_matriculas);
END;
/

-- 2.2 Caso de Error: Invocación pasando parámetros a una función sin argumentos (PLS-00306)
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Caso con Error Controlado ---');
    BEGIN
        EXECUTE IMMEDIATE 'DECLARE v_res NUMBER; BEGIN v_res := fn_total_matriculas(10); END;';
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error capturado esperado: ' || SQLERRM);
    END;
END;
/


PROMPT ======================================================================
PROMPT 3. PRUEBAS: sp_listar_alumnos_curso
PROMPT ======================================================================

-- 3.1 Caso Exitoso: Listar alumnos de un curso existente (Curso 1)
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Caso Exitoso ---');
    sp_listar_alumnos_curso(p_id_curso => 1);
END;
/

-- 3.2 Caso de Error: Tipo de dato incompatible en parámetro (ORA-06502)
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Caso con Error Controlado ---');
    BEGIN
        EXECUTE IMMEDIATE 'BEGIN sp_listar_alumnos_curso(p_id_curso => ''CURSO_A''); END;';
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error capturado esperado: ' || SQLERRM);
    END;
END;
/


PROMPT ======================================================================
PROMPT 4. PRUEBAS: sp_resumen_matriculas
PROMPT ======================================================================

-- 4.1 Caso Exitoso: Resumen general por curso
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Caso Exitoso ---');
    sp_resumen_matriculas;
END;
/

-- 4.2 Caso de Error: Invocación pasando parámetros a un procedimiento sin argumentos (PLS-00306)
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Caso con Error Controlado ---');
    BEGIN
        EXECUTE IMMEDIATE 'BEGIN sp_resumen_matriculas(2026); END;';
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error capturado esperado: ' || SQLERRM);
    END;
END;
/


PROMPT ======================================================================
PROMPT 5. PRUEBAS: pkg_alumnos
PROMPT ======================================================================

-- 5.1 pkg_alumnos.sp_ficha_alumno - Éxito
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- 5.1 sp_ficha_alumno: Caso Exitoso ---');
    pkg_alumnos.sp_ficha_alumno(p_id_alumno => 1);
END;
/

-- 5.2 pkg_alumnos.sp_ficha_alumno - Error (Valor alfanumérico ORA-06502)
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- 5.2 sp_ficha_alumno: Caso con Error Controlado ---');
    BEGIN
        EXECUTE IMMEDIATE 'BEGIN pkg_alumnos.sp_ficha_alumno(p_id_alumno => ''ID_INVALIDO''); END;';
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error capturado esperado: ' || SQLERRM);
    END;
END;
/

-- 5.3 pkg_alumnos.sp_listar_alumnos - Éxito
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- 5.3 sp_listar_alumnos: Caso Exitoso ---');
    pkg_alumnos.sp_listar_alumnos;
END;
/

-- 5.4 pkg_alumnos.sp_listar_alumnos - Error (Paso indebido de parámetros PLS-00306)
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- 5.4 sp_listar_alumnos: Caso con Error Controlado ---');
    BEGIN
        EXECUTE IMMEDIATE 'BEGIN pkg_alumnos.sp_listar_alumnos(''PARAM_EXTRA''); END;';
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error capturado esperado: ' || SQLERRM);
    END;
END;
/

-- 5.5 pkg_alumnos.fn_total_matriculas_alumno - Éxito
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- 5.5 fn_total_matriculas_alumno: Caso Exitoso ---');
    DBMS_OUTPUT.PUT_LINE('Total matrículas alumno 1: ' || pkg_alumnos.fn_total_matriculas_alumno(1));
END;
/

-- 5.6 pkg_alumnos.fn_total_matriculas_alumno - Error (Intento de acceso a función privada del Body PLS-00302)
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- 5.6 Acceso Privado: Caso con Error Controlado ---');
    BEGIN
        EXECUTE IMMEDIATE 'BEGIN IF pkg_alumnos.fn_existe_alumno(1) THEN NULL; END IF; END;';
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error capturado esperado: ' || SQLERRM);
    END;
END;
/

-- 5.7 pkg_alumnos.fn_total_alumnos - Éxito
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- 5.7 fn_total_alumnos: Caso Exitoso ---');
    DBMS_OUTPUT.PUT_LINE('Total alumnos registrados: ' || pkg_alumnos.fn_total_alumnos);
END;
/

-- 5.8 pkg_alumnos.fn_total_alumnos - Error (Paso indebido de parámetros PLS-00306)
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- 5.8 fn_total_alumnos: Caso con Error Controlado ---');
    BEGIN
        EXECUTE IMMEDIATE 'DECLARE v NUMBER; BEGIN v := pkg_alumnos.fn_total_alumnos(1); END;';
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error capturado esperado: ' || SQLERRM);
    END;
END;
/


PROMPT ======================================================================
PROMPT 6. PRUEBAS: trg_control_horario_calificaciones
PROMPT ======================================================================

-- 6.1 Caso Exitoso: Inserción válida (dentro del horario hábil L-V 08:00 a 18:59)
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Caso Exitoso (Dependiente del horario hábil L-V 08:00 a 18:59) ---');
    INSERT INTO calificaciones (id_matricula, id_carga, nota, ponderacion, fecha, descripcion)
    VALUES (1, 1, 6.0, 0.15, SYSDATE, 'Prueba Horario Valido');
    DBMS_OUTPUT.PUT_LINE('Registro insertado correctamente.');
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Rollback ejecutado para limpiar datos de prueba.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Aviso (Fuera de horario laboral): ' || SQLERRM);
        ROLLBACK;
END;
/

-- 6.2 Caso de Error: Manejo de excepción cuando se dispara el trigger ORA-20003
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Verificación de disparo del Trigger de Horario ---');
    INSERT INTO calificaciones (id_matricula, id_carga, nota, ponderacion, fecha, descripcion)
    VALUES (1, 1, 5.0, 0.10, SYSDATE, 'Prueba Control Horario');
    DBMS_OUTPUT.PUT_LINE('Atención: La inserción pasó (se encuentra actualmente dentro de horario permitido).');
    ROLLBACK;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Trigger activado con éxito (Error esperado): ' || SQLERRM);
        ROLLBACK;
END;
/


PROMPT ======================================================================
PROMPT 7. PRUEBAS: trg_validar_nota_bi
PROMPT ======================================================================

-- 7.1 Caso Exitoso: Inserción con nota dentro del rango 1.0 a 7.0
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Caso Exitoso ---');
    INSERT INTO calificaciones (id_matricula, id_carga, nota, ponderacion, fecha, descripcion)
    VALUES (1, 1, 5.5, 0.10, SYSDATE, 'Evaluacion Rango Valido');
    DBMS_OUTPUT.PUT_LINE('Registro con nota válida insertado exitosamente.');
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Rollback ejecutado.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Detalle ejecución: ' || SQLERRM);
        ROLLBACK;
END;
/

-- 7.2 Caso de Error: Inserción con nota inválida (ej. 7.5 > 7.0) (ORA-20002)
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Caso con Error Controlado (Nota fuera de rango) ---');
    INSERT INTO calificaciones (id_matricula, id_carga, nota, ponderacion, fecha, descripcion)
    VALUES (1, 1, 7.5, 0.10, SYSDATE, 'Evaluacion Invalida');
    ROLLBACK;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Trigger trg_validar_nota_bi activado con éxito: ' || SQLERRM);
        ROLLBACK;
END;
/

PROMPT ======================================================================
PROMPT FIN DE LA SUITE DE PRUEBAS
PROMPT ======================================================================