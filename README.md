# 📚 Sistema de Libro de Clases Digital - Oracle PL/SQL

**Asignatura:** Taller de Base de Datos  
**Evaluación:** Parcial N°2  
**Docente:** Carlos Alberto Orellana Soto  
**Institución:** Duoc UC  
**Fecha:** 27 Octubre 2026  

---

## 👥 Integrantes del Equipo
* Alexander Oyarzun
* Nicolas Lopez
* Gerardo Vera

---

## 📝 Descripción del Proyecto
Backend para un **Sistema de Gestión Escolar (Libro de Clases Digital)** desarrollado sobre **Oracle Database**. El sistema centraliza la gestión académica de Educación Media (colegios, alumnos, profesores, matrículas, asistencia, calificaciones y anotaciones) asegurando la integridad de datos mediante lógica de negocio en **PL/SQL**.

---

## 📐 Modelo Relacional
El sistema está compuesto por **11 tablas** interrelacionadas:

![Diagrama Relacional](Diagrama_EV1_TallerBDD.png)

---

## 🚀 Orden de Ejecución
1. `creacion_usuario.sql` – Crea el usuario `desarrollador`.
2. `info_ev1.sql` – Crea las tablas e inserta los datos de prueba.
3. `script_completo_ev2.sql` – Crea todos los objetos PL/SQL de la Evaluación Parcial 2, en orden de ejecución.

> `script_completo_ev2.sql` reúne en un solo archivo todos los bloques de la EP2. Los archivos `FUNCTIONS y PROCEDURES.sql`, `PACKAGE y PACKAGE BODY CON EJEMPLOS.sql` y `TRIGGERS.sql` contienen el mismo código separado por tema, junto con sus pruebas.

---

## ⚙️ Objetos PL/SQL Desarrollados (Evaluación Parcial N°2)

| # | Objeto | Tipo | Descripción |
| :--- | :--- | :--- | :--- |
| 1 | `fn_promedio_asignatura` | Función con parámetros | Calcula el promedio ponderado de un alumno en una asignatura (1 decimal). |
| 2 | `fn_total_matriculas` | Función sin parámetros | Devuelve el total de matrículas registradas. |
| 3 | `sp_listar_alumnos_curso` | Procedimiento con parámetros | Lista los alumnos matriculados en un curso. |
| 4 | `sp_resumen_matriculas` | Procedimiento sin parámetros | Muestra la cantidad de matrículas por curso; el total usa `fn_total_matriculas`. |
| 5 | `pkg_alumnos` (specification) | Package | Declara los procedimientos y funciones públicos de consulta de alumnos. |
| 6 | `pkg_alumnos` (body) | Package Body | Implementa los elementos públicos y la función privada `fn_existe_alumno`. |
| 7 | `trg_control_horario_calificaciones` | Trigger de sentencia | Bloquea cambios en calificaciones fuera de lunes a viernes de 08:00 a 18:59. |
| 8 | `trg_validar_nota_bi` | Trigger de fila | Valida que la nota esté entre 1.0 y 7.0. |

---

## ⚡ Resumen de Bloques Anónimos PL/SQL (Evaluación Parcial N°1)

| Bloque | Objeto Principal | Problemática de Negocio | Excepción Manejada |
| :--- | :--- | :--- | :--- |
| **Bloque 1** | `RECORD` | Consulta estructurada de datos de contacto docente para notificaciones rápidas. | `NO_DATA_FOUND` |
| **Bloque 2** | `VARRAY` | Validación masiva en memoria de estados de asistencia diaria segun normativa. | `e_estado_invalido` (Definida por usuario) |
| **Bloque 3** | `CURSORES` | Generación de nómina de alumnos matriculados por curso mediante cursor explícito con parámetro. | `e_curso_vacio` (Definida por usuario) |
| **Bloque 4** | **INTEGRACIÓN**<br>*(RECORD + VARRAY + CURSOR)* | Reporte de excelencia académica: Identifica al mejor alumno por asignatura evaluando un arreglo de materias. | `e_sin_calificaciones` (Definida por usuario) |

---
