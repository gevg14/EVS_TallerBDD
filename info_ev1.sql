--==================================================================================================--
-------------------------- PROYECTO COLEGIO(notas,asistencia y anotaciones) --------------------------
--==================================================================================================--



-------------------------- 1. ALUMNOS --------------------------

CREATE TABLE colegios (
    id_colegio NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    rbd        VARCHAR2(20) NOT NULL UNIQUE, -- Registro Base de Datos escolar
    nombre     VARCHAR2(150) NOT NULL,
    direccion  VARCHAR2(200)
);

-------------------------- 2. NIVELES (1° medio, 2° medio,3° medio,4° medio) --------------------------

CREATE TABLE niveles (
    id_nivel NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre   VARCHAR2(50) NOT NULL UNIQUE
);

-------------------------- 3. DOCENTES --------------------------

CREATE TABLE docente (
    id_docente NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    rut        VARCHAR2(12) NOT NULL UNIQUE,
    nombres    VARCHAR2(100) NOT NULL,
    apellidos  VARCHAR2(100) NOT NULL,
    email      VARCHAR2(100),
    telefono   VARCHAR2(20)
);

-------------------------- 4. ALUMNOS --------------------------

CREATE TABLE alumnos (
    id_alumno NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    rut       VARCHAR2(12) NOT NULL UNIQUE,
    nombres   VARCHAR2(100) NOT NULL,
    apellidos VARCHAR2(100) NOT NULL,
    fecha_nac DATE,
    email     VARCHAR2(100)
);

-------------------------- 5. ASIGNATURAS --------------------------

CREATE TABLE asignaturas (
    id_asignatura NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre        VARCHAR2(100) NOT NULL UNIQUE
);

-------------------------- 6. CURSOS --------------------------

CREATE TABLE cursos (
    id_curso     NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_colegio   NUMBER NOT NULL,
    id_nivel     NUMBER NOT NULL,
    letra        CHAR(1) NOT NULL,    -- Ej: 'A'
    anio_lectivo NUMBER(4) NOT NULL,  -- Ej: 2026
    CONSTRAINT fk_curso_colegio FOREIGN KEY (id_colegio) REFERENCES colegios(id_colegio),
    CONSTRAINT fk_curso_nivel FOREIGN KEY (id_nivel) REFERENCES niveles(id_nivel),
    CONSTRAINT uq_curso UNIQUE (id_colegio, id_nivel, letra, anio_lectivo)
);

-------------------------- 7. MATRICULAS  --------------------------

CREATE TABLE matriculas (
    id_matricula NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_alumno    NUMBER NOT NULL,
    id_curso     NUMBER NOT NULL,
    fecha_matr   DATE DEFAULT SYSDATE,
    CONSTRAINT fk_matr_alumno FOREIGN KEY (id_alumno) REFERENCES alumnos(id_alumno),
    CONSTRAINT fk_matr_curso FOREIGN KEY (id_curso) REFERENCES cursos(id_curso),
    CONSTRAINT uq_alumno_curso UNIQUE (id_alumno, id_curso)
);

-------------------------- 8. CARGA DOCENTE --------------------------

CREATE TABLE carga_docente (
    id_carga      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_curso      NUMBER NOT NULL,
    id_asignatura NUMBER NOT NULL,
    id_docente    NUMBER NOT NULL,
    CONSTRAINT fk_carga_curso FOREIGN KEY (id_curso) REFERENCES cursos(id_curso),
    CONSTRAINT fk_carga_asig FOREIGN KEY (id_asignatura) REFERENCES asignaturas(id_asignatura),
    CONSTRAINT fk_carga_docente FOREIGN KEY (id_docente) REFERENCES docente(id_docente),
    CONSTRAINT uq_carga UNIQUE (id_curso, id_asignatura)
);

-------------------------- 9. ASISTENCIA  --------------------------

CREATE TABLE asistencia (
    id_asistencia NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_matricula  NUMBER NOT NULL,
    fecha         DATE NOT NULL,
    estado        VARCHAR2(15) NOT NULL CHECK (estado IN ('PRESENTE', 'AUSENTE', 'JUSTIFICADO', 'ATRASADO')),
    observacion   VARCHAR2(255),
    CONSTRAINT fk_asist_matricula FOREIGN KEY (id_matricula) REFERENCES matriculas(id_matricula),
    CONSTRAINT uq_asistencia_dia UNIQUE (id_matricula, fecha)
);

-------------------------- 10. CALIFICACIONES --------------------------

CREATE TABLE calificaciones (
    id_calificacion NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_matricula    NUMBER NOT NULL,
    id_carga        NUMBER NOT NULL, -- Asocia directamente al profesor y asignatura del curso
    nota            NUMBER(3,1) NOT NULL CHECK (nota BETWEEN 1.0 AND 7.0),
    ponderacion     NUMBER(3,2) NOT NULL CHECK (ponderacion BETWEEN 0.01 AND 1.00),
    fecha           DATE DEFAULT SYSDATE NOT NULL,
    descripcion     VARCHAR2(100), -- Ej: 'Prueba Parcial 1'
    CONSTRAINT fk_not_matricula FOREIGN KEY (id_matricula) REFERENCES matriculas(id_matricula),
    CONSTRAINT fk_not_carga FOREIGN KEY (id_carga) REFERENCES carga_docente(id_carga)
);

-------------------------- 11. ANOTACIONES --------------------------

CREATE TABLE anotaciones (
    id_anotacion NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_matricula NUMBER NOT NULL,
    id_docente   NUMBER NOT NULL, -- Registra qué profesor puso la anotación
    id_carga     NUMBER,          -- Opcional: si ocurrió durante una clase específica
    tipo         VARCHAR2(10) NOT NULL CHECK (tipo IN ('POSITIVA', 'NEGATIVA')),
    categoria    VARCHAR2(50),    -- Ej: 'Convivencia', 'Responsabilidad'
    detalle      CLOB NOT NULL,
    fecha        DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT fk_anot_matricula FOREIGN KEY (id_matricula) REFERENCES matriculas(id_matricula),
    CONSTRAINT fk_anot_docente FOREIGN KEY (id_docente) REFERENCES docente(id_docente),
    CONSTRAINT fk_anot_carga FOREIGN KEY (id_carga) REFERENCES carga_docente(id_carga)
);





COMMIT;

--==================================================================================================--
------------------------------------- FIN CREACION BDD -----------------------------------------------
--==================================================================================================--


--==================================================================================================--
---------------------------------- INSERCIÓN DE DATOS POBLADOS -------------------------------------
--==================================================================================================--

-------------------------- 1. COLEGIOS --------------------------
INSERT INTO colegios (rbd, nombre, direccion) VALUES ('12345-6', 'Liceo Bicentenario San Juan', 'Av. Bernardo O''Higgins 1234, Santiago');
INSERT INTO colegios (rbd, nombre, direccion) VALUES ('67890-1', 'Colegio Mayor de Chile', 'Av. Providencia 456, Providencia');

-------------------------- 2. NIVELES --------------------------
INSERT INTO niveles (nombre) VALUES ('1° medio');
INSERT INTO niveles (nombre) VALUES ('2° medio');
INSERT INTO niveles (nombre) VALUES ('3° medio');
INSERT INTO niveles (nombre) VALUES ('4° medio');

-------------------------- 3. DOCENTES --------------------------
INSERT INTO docente (rut, nombres, apellidos, email, telefono) VALUES ('11.222.333-4', 'Roberto Antonio', 'Gómez Bolaños', 'roberto.gomez@colegio.cl', '+56911112222');
INSERT INTO docente (rut, nombres, apellidos, email, telefono) VALUES ('12.333.444-5', 'Maria Isabel', 'López Vega', 'maria.lopez@colegio.cl', '+56922223333');
INSERT INTO docente (rut, nombres, apellidos, email, telefono) VALUES ('13.444.555-6', 'Carlos Alberto', 'Ramírez Castro', 'carlos.ramirez@colegio.cl', '+56933334444');
INSERT INTO docente (rut, nombres, apellidos, email, telefono) VALUES ('14.555.666-7', 'Patricia Elena', 'Torres Morales', 'patricia.torres@colegio.cl', '+56944445555');

-------------------------- 4. ALUMNOS --------------------------
INSERT INTO alumnos (rut, nombres, apellidos, fecha_nac, email) VALUES ('23.123.456-1', 'Matías Ignacio', 'Silva Pérez', TO_DATE('2008-03-15', 'YYYY-MM-DD'), 'matias.silva@alumnos.cl');
INSERT INTO alumnos (rut, nombres, apellidos, fecha_nac, email) VALUES ('23.234.567-2', 'Sofía Alejandra', 'González Tapia', TO_DATE('2008-07-22', 'YYYY-MM-DD'), 'sofia.gonzalez@alumnos.cl');
INSERT INTO alumnos (rut, nombres, apellidos, fecha_nac, email) VALUES ('23.345.678-3', 'Lucas Gabriel', 'Rojas Muñoz', TO_DATE('2007-11-05', 'YYYY-MM-DD'), 'lucas.rojas@alumnos.cl');
INSERT INTO alumnos (rut, nombres, apellidos, fecha_nac, email) VALUES ('23.456.789-4', 'Valentina Isidora', 'Contreras Soto', TO_DATE('2008-01-30', 'YYYY-MM-DD'), 'valentina.contreras@alumnos.cl');
INSERT INTO alumnos (rut, nombres, apellidos, fecha_nac, email) VALUES ('22.567.890-5', 'Benjamín Esteban', 'Morales Vera', TO_DATE('2007-09-12', 'YYYY-MM-DD'), 'benjamin.morales@alumnos.cl');
INSERT INTO alumnos (rut, nombres, apellidos, fecha_nac, email) VALUES ('22.678.901-6', 'Camila Andrea', 'Araya Fuentes', TO_DATE('2006-04-18', 'YYYY-MM-DD'), 'camila.araya@alumnos.cl');

-------------------------- 5. ASIGNATURAS --------------------------
INSERT INTO asignaturas (nombre) VALUES ('Matemáticas');
INSERT INTO asignaturas (nombre) VALUES ('Lenguaje y Comunicación');
INSERT INTO asignaturas (nombre) VALUES ('Historia y Ciencias Sociales');
INSERT INTO asignaturas (nombre) VALUES ('Ciencias Naturales');
INSERT INTO asignaturas (nombre) VALUES ('Inglés');

-------------------------- 6. CURSOS --------------------------
-- id_colegio = 1 (Liceo Bicentenario San Juan), anio_lectivo = 2026
-- Combinación de niveles (1° a 4° medio) con letras (A, B, C, D)
INSERT INTO cursos (id_colegio, id_nivel, letra, anio_lectivo) VALUES (1, 1, 'A', 2026); -- 1° Medio A (id_curso 1)
INSERT INTO cursos (id_colegio, id_nivel, letra, anio_lectivo) VALUES (1, 1, 'B', 2026); -- 1° Medio B (id_curso 2)
INSERT INTO cursos (id_colegio, id_nivel, letra, anio_lectivo) VALUES (1, 1, 'C', 2026); -- 1° Medio C (id_curso 3)
INSERT INTO cursos (id_colegio, id_nivel, letra, anio_lectivo) VALUES (1, 1, 'D', 2026); -- 1° Medio D (id_curso 4)

INSERT INTO cursos (id_colegio, id_nivel, letra, anio_lectivo) VALUES (1, 2, 'A', 2026); -- 2° Medio A (id_curso 5)
INSERT INTO cursos (id_colegio, id_nivel, letra, anio_lectivo) VALUES (1, 2, 'B', 2026); -- 2° Medio B (id_curso 6)
INSERT INTO cursos (id_colegio, id_nivel, letra, anio_lectivo) VALUES (1, 2, 'C', 2026); -- 2° Medio C (id_curso 7)
INSERT INTO cursos (id_colegio, id_nivel, letra, anio_lectivo) VALUES (1, 2, 'D', 2026); -- 2° Medio D (id_curso 8)

INSERT INTO cursos (id_colegio, id_nivel, letra, anio_lectivo) VALUES (1, 3, 'A', 2026); -- 3° Medio A (id_curso 9)
INSERT INTO cursos (id_colegio, id_nivel, letra, anio_lectivo) VALUES (1, 3, 'B', 2026); -- 3° Medio B (id_curso 10)
INSERT INTO cursos (id_colegio, id_nivel, letra, anio_lectivo) VALUES (1, 3, 'C', 2026); -- 3° Medio C (id_curso 11)
INSERT INTO cursos (id_colegio, id_nivel, letra, anio_lectivo) VALUES (1, 3, 'D', 2026); -- 3° Medio D (id_curso 12)

INSERT INTO cursos (id_colegio, id_nivel, letra, anio_lectivo) VALUES (1, 4, 'A', 2026); -- 4° Medio A (id_curso 13)
INSERT INTO cursos (id_colegio, id_nivel, letra, anio_lectivo) VALUES (1, 4, 'B', 2026); -- 4° Medio B (id_curso 14)
INSERT INTO cursos (id_colegio, id_nivel, letra, anio_lectivo) VALUES (1, 4, 'C', 2026); -- 4° Medio C (id_curso 15)
INSERT INTO cursos (id_colegio, id_nivel, letra, anio_lectivo) VALUES (1, 4, 'D', 2026); -- 4° Medio D (id_curso 16)

-------------------------- 7. MATRICULAS --------------------------
-- Asociamos alumnos con sus respectivos cursos
INSERT INTO matriculas (id_alumno, id_curso, fecha_matr) VALUES (1, 1, TO_DATE('2026-03-01', 'YYYY-MM-DD')); -- Matías en 1° Medio A
INSERT INTO matriculas (id_alumno, id_curso, fecha_matr) VALUES (2, 1, TO_DATE('2026-03-01', 'YYYY-MM-DD')); -- Sofía en 1° Medio A
INSERT INTO matriculas (id_alumno, id_curso, fecha_matr) VALUES (3, 5, TO_DATE('2026-03-02', 'YYYY-MM-DD')); -- Lucas en 2° Medio A
INSERT INTO matriculas (id_alumno, id_curso, fecha_matr) VALUES (4, 6, TO_DATE('2026-03-02', 'YYYY-MM-DD')); -- Valentina en 2° Medio B
INSERT INTO matriculas (id_alumno, id_curso, fecha_matr) VALUES (5, 9, TO_DATE('2026-03-03', 'YYYY-MM-DD')); -- Benjamín en 3° Medio A
INSERT INTO matriculas (id_alumno, id_curso, fecha_matr) VALUES (6, 13, TO_DATE('2026-03-03', 'YYYY-MM-DD')); -- Camila en 4° Medio A

-------------------------- 8. CARGA DOCENTE --------------------------
-- Asignación de docente y asignatura por curso
INSERT INTO carga_docente (id_curso, id_asignatura, id_docente) VALUES (1, 1, 1); -- Roberto imparte Matemáticas en 1° Medio A
INSERT INTO carga_docente (id_curso, id_asignatura, id_docente) VALUES (1, 2, 2); -- Maria imparte Lenguaje en 1° Medio A
INSERT INTO carga_docente (id_curso, id_asignatura, id_docente) VALUES (5, 3, 3); -- Carlos imparte Historia en 2° Medio A
INSERT INTO carga_docente (id_curso, id_asignatura, id_docente) VALUES (9, 4, 4); -- Patricia imparte Ciencias en 3° Medio A

-------------------------- 9. ASISTENCIA --------------------------
INSERT INTO asistencia (id_matricula, fecha, estado, observacion) VALUES (1, TO_DATE('2026-03-10', 'YYYY-MM-DD'), 'PRESENTE', NULL);
INSERT INTO asistencia (id_matricula, fecha, estado, observacion) VALUES (2, TO_DATE('2026-03-10', 'YYYY-MM-DD'), 'ATRASADO', 'Llegó 15 minutos tarde por congestión');
INSERT INTO asistencia (id_matricula, fecha, estado, observacion) VALUES (3, TO_DATE('2026-03-10', 'YYYY-MM-DD'), 'AUSENTE', 'Sin justificar');
INSERT INTO asistencia (id_matricula, fecha, estado, observacion) VALUES (4, TO_DATE('2026-03-10', 'YYYY-MM-DD'), 'JUSTIFICADO', 'Certificado médico presentado');

-------------------------- 10. CALIFICACIONES --------------------------
INSERT INTO calificaciones (id_matricula, id_carga, nota, ponderacion, fecha, descripcion) 
VALUES (1, 1, 6.5, 0.25, TO_DATE('2026-04-15', 'YYYY-MM-DD'), 'Prueba Parcial 1 - Álgebra');

INSERT INTO calificaciones (id_matricula, id_carga, nota, ponderacion, fecha, descripcion) 
VALUES (2, 1, 5.8, 0.25, TO_DATE('2026-04-15', 'YYYY-MM-DD'), 'Prueba Parcial 1 - Álgebra');

INSERT INTO calificaciones (id_matricula, id_carga, nota, ponderacion, fecha, descripcion) 
VALUES (1, 2, 7.0, 0.20, TO_DATE('2026-04-18', 'YYYY-MM-DD'), 'Control de Lectura');

-------------------------- 11. ANOTACIONES --------------------------
INSERT INTO anotaciones (id_matricula, id_docente, id_carga, tipo, categoria, detalle, fecha) 
VALUES (1, 1, 1, 'POSITIVA', 'Responsabilidad', 'Destacada participación durante la clase de Matemáticas.', TO_DATE('2026-04-15', 'YYYY-MM-DD'));

INSERT INTO anotaciones (id_matricula, id_docente, id_carga, tipo, categoria, detalle, fecha) 
VALUES (3, 3, 3, 'NEGATIVA', 'Convivencia', 'Interrumpe constantemente la clase de Historia pese a las advertencias.', TO_DATE('2026-04-10', 'YYYY-MM-DD'));

COMMIT;

