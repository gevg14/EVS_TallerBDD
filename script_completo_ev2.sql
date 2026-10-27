-- ======================================================================
-- LIBRO DE CLASES DIGITAL - EVALUACION PARCIAL 2 (TALLER DE BASE DE DATOS)
-- Script completo de objetos PL/SQL, en orden de ejecucion.
-- ======================================================================

SET SERVEROUTPUT ON;


-- ======================================================================
-- 1. FUNCION CON PARAMETROS: fn_promedio_asignatura
-- ======================================================================

create or replace FUNCTION fn_promedio_asignatura (
    p_id_matricula IN matriculas.id_matricula%TYPE, -- ID de la matricula
    p_id_carga IN carga_docente.id_carga%TYPE -- Apunta a curso, asignatura y docente
) RETURN NUMBER
IS
    v_promedio NUMBER;
BEGIN
    SELECT ROUND(
        SUM(c.nota * c.ponderacion) / NULLIF(SUM(c.ponderacion), 0), 1) -- Suma ponderada de notas / suma de ponderaciones, redondeado a 1 decimal
    INTO v_promedio                                                     -- El NULLIF evita división por cero si no hay ponderaciones
    FROM calificaciones c                                               -- NULLIF = Si ambos valores (SUM(c.ponderacion) y 0) son iguales, retorna NULL, evitando error de división por cero, si son distintos, retorna el primer valor (SUM(c.ponderacion))
    JOIN matriculas m ON m.id_matricula = c.id_matricula
    JOIN carga_docente cd ON cd.id_carga = c.id_carga
    WHERE c.id_matricula = p_id_matricula
      AND c.id_carga = p_id_carga
      AND m.id_curso = cd.id_curso;

    RETURN v_promedio;
END fn_promedio_asignatura;
/


-- ======================================================================
-- 2. FUNCION SIN PARAMETROS: fn_total_matriculas
-- ======================================================================

create or replace FUNCTION fn_total_matriculas
RETURN NUMBER
IS
    v_total NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_total FROM matriculas;
    RETURN v_total;
END fn_total_matriculas;
/


-- ======================================================================
-- 3. PROCEDIMIENTO CON PARAMETROS: sp_listar_alumnos_curso
-- ======================================================================

create or replace PROCEDURE sp_listar_alumnos_curso (
    p_id_curso IN cursos.id_curso%TYPE
)
IS
    v_existe NUMBER; -- Variable para verificar si existe el curso
    v_contador NUMBER := 0; -- Variable para contar alumnos
BEGIN
    SELECT COUNT(*) INTO v_existe
    FROM cursos
    WHERE id_curso = p_id_curso;

    IF v_existe = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No existe el curso ID ' || p_id_curso); -- Si la variable v_existe es 0, significa que no existe el curso con el ID proporcionado
        RETURN;
    END IF;

    DBMS_OUTPUT.PUT_LINE('ALUMNOS DEL CURSO ID ' || p_id_curso);
    FOR r IN (
        SELECT a.id_alumno, a.nombres, a.apellidos
        FROM matriculas m
        JOIN alumnos a ON a.id_alumno = m.id_alumno
        WHERE m.id_curso = p_id_curso
        ORDER BY a.apellidos, a.nombres
    ) LOOP
        v_contador := v_contador + 1; -- En cada iteracion del bucle, incrementamos el contador de alumnos
        DBMS_OUTPUT.PUT_LINE(r.id_alumno || ' - ' || r.nombres || ' ' || r.apellidos);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Total matriculados: ' || v_contador);
END sp_listar_alumnos_curso;
/


-- ======================================================================
-- 4. PROCEDIMIENTO SIN PARAMETROS: sp_resumen_matriculas
-- ======================================================================

create or replace PROCEDURE sp_resumen_matriculas
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('RESUMEN DE MATRICULAS POR CURSO');
    FOR r IN (
        SELECT c.id_curso, n.nombre AS nivel, c.letra, c.anio_lectivo, -- Seleccionamos el id del curso, el nombre del nivel (1ero medio), la letra y el año lectivo
               COUNT(m.id_matricula) AS cantidad -- Contamos la cantidad de matriculas por curso
        FROM cursos c
        JOIN niveles n ON n.id_nivel = c.id_nivel
        LEFT JOIN matriculas m ON m.id_curso = c.id_curso --LEFT JOIN para mostrar cursos incluso si no tienen alumnos matriculados
        GROUP BY c.id_curso, n.nombre, c.letra, c.anio_lectivo -- Agrupamos lo que usaremos para usar el COUNT
        ORDER BY c.anio_lectivo, c.id_curso -- Ordenamos por año lectivo y id del curso
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Curso ' || r.id_curso || ' (' || r.nivel || ' ' ||
            r.letra || ', ' || r.anio_lectivo || '): ' || r.cantidad || ' matricula(s)');
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('TOTAL GENERAL: ' || fn_total_matriculas);
END sp_resumen_matriculas;
/


-- ======================================================================
-- 5. PACKAGE (ESPECIFICACION): pkg_alumnos
-- ======================================================================

CREATE OR REPLACE PACKAGE pkg_alumnos
IS

    -- Mostrar ficha de un alumno y sus matriculas
    PROCEDURE sp_ficha_alumno(
        p_id_alumno IN alumnos.id_alumno%TYPE
    );

    -- Listar todos los alumnos
    PROCEDURE sp_listar_alumnos;

    -- Contar matriculas de un alumno
    FUNCTION fn_total_matriculas_alumno(
        p_id_alumno IN alumnos.id_alumno%TYPE
    ) RETURN NUMBER;

    -- Contar todos los alumnos
    FUNCTION fn_total_alumnos
    RETURN NUMBER;

END pkg_alumnos;
/


-- ======================================================================
-- 6. PACKAGE BODY (CUERPO): pkg_alumnos
-- ======================================================================

CREATE OR REPLACE PACKAGE BODY pkg_alumnos
IS

    -- ==================================================================
    -- FUNCION PRIVADA: VERIFICAR SI EXISTE UN ALUMNO
    -- No aparece en la specification, por lo que solo puede utilizarse
    -- dentro de este package.
    -- ==================================================================

    FUNCTION fn_existe_alumno(
        p_id_alumno IN alumnos.id_alumno%TYPE
    ) RETURN BOOLEAN
    IS
        v_cantidad NUMBER;
    BEGIN

        SELECT COUNT(*)
        INTO v_cantidad
        FROM alumnos
        WHERE id_alumno = p_id_alumno;

        -- TRUE si el alumno existe (la PRIMARY KEY de id_alumno impide duplicados)
        RETURN v_cantidad > 0;

    END fn_existe_alumno;


    -- ==================================================================
    -- 1. PROCEDIMIENTO PUBLICO CON PARAMETROS
    -- MOSTRAR FICHA DE UN ALUMNO Y SUS MATRICULAS
    -- ==================================================================

    PROCEDURE sp_ficha_alumno(
        p_id_alumno IN alumnos.id_alumno%TYPE
    )
    IS
        v_total_matriculas NUMBER;
    BEGIN

        -- Validar que el alumno exista
        IF NOT fn_existe_alumno(p_id_alumno) THEN
            DBMS_OUTPUT.PUT_LINE(
                'No existe el alumno con ID: ' || p_id_alumno
            );
            RETURN;
        END IF;

        DBMS_OUTPUT.PUT_LINE('====================================');
        DBMS_OUTPUT.PUT_LINE('FICHA DEL ALUMNO');
        DBMS_OUTPUT.PUT_LINE('====================================');

        -- Mostrar los datos personales
        FOR datos IN (
            SELECT
                id_alumno,
                rut,
                nombres,
                apellidos,
                fecha_nac,
                email
            FROM alumnos
            WHERE id_alumno = p_id_alumno
        )
        LOOP

            DBMS_OUTPUT.PUT_LINE('ID: ' || datos.id_alumno);
            DBMS_OUTPUT.PUT_LINE('RUT: ' || datos.rut);
            DBMS_OUTPUT.PUT_LINE('Nombre: ' || datos.nombres || ' ' || datos.apellidos);
            DBMS_OUTPUT.PUT_LINE('Fecha de nacimiento: ' || TO_CHAR(datos.fecha_nac, 'DD/MM/YYYY'));
            DBMS_OUTPUT.PUT_LINE('Email: ' || datos.email);

        END LOOP;

        DBMS_OUTPUT.PUT_LINE('------------------------------------');
        DBMS_OUTPUT.PUT_LINE('MATRICULAS DEL ALUMNO');
        DBMS_OUTPUT.PUT_LINE('------------------------------------');

        -- Obtener los cursos en los que esta matriculado
        FOR datos IN (
            SELECT
                m.id_matricula,
                m.fecha_matr,
                c.id_curso,
                n.nombre AS nivel,
                c.letra,
                c.anio_lectivo
            FROM matriculas m
            JOIN cursos c
                ON c.id_curso = m.id_curso
            JOIN niveles n
                ON n.id_nivel = c.id_nivel
            WHERE m.id_alumno = p_id_alumno
            ORDER BY c.anio_lectivo, c.id_curso
        )
        LOOP

            DBMS_OUTPUT.PUT_LINE('Matricula ID: ' || datos.id_matricula);
            DBMS_OUTPUT.PUT_LINE('Curso: ' || datos.nivel || ' ' ||datos.letra || ' (' || datos.anio_lectivo || ')');
            DBMS_OUTPUT.PUT_LINE('Fecha de matricula: ' || TO_CHAR(datos.fecha_matr, 'DD/MM/YYYY'));

        END LOOP;

        -- Total de matriculas desde la funcion publica del package
        v_total_matriculas := fn_total_matriculas_alumno(p_id_alumno);

        -- Mostrar mensaje si no tiene matriculas
        IF v_total_matriculas = 0 THEN
            DBMS_OUTPUT.PUT_LINE(
                'El alumno no tiene matriculas registradas'
            );
        END IF;

        DBMS_OUTPUT.PUT_LINE(
            'TOTAL DE MATRICULAS: ' || v_total_matriculas
        );

    END sp_ficha_alumno;


    -- ==================================================================
    -- 2. PROCEDIMIENTO PUBLICO SIN PARAMETROS
    -- LISTAR TODOS LOS ALUMNOS REGISTRADOS
    -- ==================================================================

    PROCEDURE sp_listar_alumnos
    IS
    BEGIN

        DBMS_OUTPUT.PUT_LINE('====================================');
        DBMS_OUTPUT.PUT_LINE('LISTADO GENERAL DE ALUMNOS');
        DBMS_OUTPUT.PUT_LINE('====================================');

        -- Recorrer todos los alumnos registrados
        FOR datos IN (
            SELECT
                id_alumno,
                rut,
                nombres,
                apellidos
            FROM alumnos
            ORDER BY apellidos, nombres
        )
        LOOP

            DBMS_OUTPUT.PUT_LINE('ID: ' || datos.id_alumno);
            DBMS_OUTPUT.PUT_LINE('Nombre: ' || datos.nombres);
            DBMS_OUTPUT.PUT_LINE('Apellido: ' || datos.apellidos);
            DBMS_OUTPUT.PUT_LINE('RUT: ' || datos.rut);

        END LOOP;

        -- Mostrar el total de alumnos
        DBMS_OUTPUT.PUT_LINE('------------------------------------');
        DBMS_OUTPUT.PUT_LINE('TOTAL DE ALUMNOS: ' || fn_total_alumnos);

    END sp_listar_alumnos;


    -- ==================================================================
    -- 3. FUNCION PUBLICA CON PARAMETROS
    -- CONTAR LAS MATRICULAS DE UN ALUMNO
    -- ==================================================================

    FUNCTION fn_total_matriculas_alumno(
        p_id_alumno IN alumnos.id_alumno%TYPE
    ) RETURN NUMBER
    IS
        v_total NUMBER;
    BEGIN

        -- Contar las matriculas asociadas al alumno
        SELECT COUNT(*)
        INTO v_total
        FROM matriculas
        WHERE id_alumno = p_id_alumno;

        -- Devolver la cantidad encontrada
        RETURN v_total;

    END fn_total_matriculas_alumno;


    -- ==================================================================
    -- 4. FUNCION PUBLICA SIN PARAMETROS
    -- CONTAR TODOS LOS ALUMNOS REGISTRADOS
    -- ==================================================================

    FUNCTION fn_total_alumnos
    RETURN NUMBER
    IS
        v_total NUMBER;
    BEGIN

        -- Contar todos los alumnos
        SELECT COUNT(*)
        INTO v_total
        FROM alumnos;

        -- Devolver el total de alumnos
        RETURN v_total;

    END fn_total_alumnos;

END pkg_alumnos;
/


-- ======================================================================
-- 7. TRIGGER A NIVEL DE SENTENCIA: trg_control_horario_calificaciones
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
-- 8. TRIGGER A NIVEL DE FILA: trg_validar_nota_bi
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
