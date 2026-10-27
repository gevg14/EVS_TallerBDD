SET SERVEROUTPUT ON;

-- 1. Funcion CON parametros: promedio ponderado NORMALIZADO de notas existentes
-- Si no existen calificaciones, retorna NULL.
-- Calcula el promedio ponderado normalizado de las notas registradas.
-- Requiere que la matricula pertenezca al mismo curso que la carga docente.
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


-- ===========================================================================================================


-- 2. Funcion SIN parametros: total de matriculas
create or replace FUNCTION fn_total_matriculas
RETURN NUMBER
IS
    v_total NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_total FROM matriculas;
    RETURN v_total;
END fn_total_matriculas;
/


-- ===========================================================================================================


-- 3. Procedimiento CON parametros: alumnos matriculados en un curso
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


-- ===========================================================================================================


-- 4. Procedimiento SIN parametros: resumen de matriculas de todos los cursos
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
