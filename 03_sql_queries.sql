-- ============================================================
-- BCSE302L - DATABASE SYSTEMS
-- Online Examination Management System
-- 03_sql_queries.sql
-- Oracle Database 26ai Free / SQL Developer
--
-- PURPOSE:
-- Demonstrates 18 meaningful SQL queries over the approved
-- eight-table schema. Covers retrieval, filtering, joins,
-- aggregation, GROUP BY, HAVING, subqueries, NOT EXISTS,
-- outer joins, CASE expressions and analytic functions.
--
-- INSTRUCTIONS:
-- 1. Connect as DBMS_PROJECT to service FREEPDB1.
-- 2. Confirm that 01_create_tables.sql and the sample-data
--    scripts completed successfully.
-- 3. Open this file in SQL Developer and press F5 (Run Script).
-- 4. Review the output for each query in the Script Output pane.
--
-- This file contains SELECT statements only. It does not modify
-- project data and is safe to run repeatedly.
-- ============================================================

SET PAGESIZE 100
SET LINESIZE 220
SET FEEDBACK ON
SET VERIFY OFF
SET DEFINE OFF

PROMPT ============================================================
PROMPT Q1. COMPLETED EXAMINATION CATALOG WITH COURSE DETAILS
PROMPT Concepts: INNER JOIN, filtering, ORDER BY
PROMPT ============================================================
SELECT e.exam_id,
       e.exam_title,
       c.course_code,
       c.course_name,
       TO_CHAR(e.exam_date, 'DD-MON-YYYY') AS exam_date,
       e.duration_min,
       e.status
  FROM exam e
  JOIN course c ON c.course_id = e.course_id
 WHERE e.status = 'COMPLETED'
 ORDER BY e.exam_date DESC, c.course_code;

PROMPT ============================================================
PROMPT Q2. ACTIVE STUDENTS WITH THEIR DEPARTMENT
PROMPT Concepts: INNER JOIN, WHERE, ORDER BY
PROMPT ============================================================
SELECT d.dept_name,
       s.student_id,
       s.reg_no,
       s.student_name,
       s.semester,
       s.email
  FROM student s
  JOIN department d ON d.dept_id = s.dept_id
 WHERE s.status = 'ACTIVE'
 ORDER BY d.dept_name, s.student_name;

PROMPT ============================================================
PROMPT Q3. COMPLETE STUDENT-COURSE ENROLLMENT ROSTER
PROMPT Concepts: multiple-table JOIN
PROMPT ============================================================
SELECT s.reg_no,
       s.student_name,
       c.course_code,
       c.course_name,
       TO_CHAR(en.enroll_date, 'DD-MON-YYYY') AS enrollment_date
  FROM enrollment en
  JOIN student s ON s.student_id = en.student_id
  JOIN course c ON c.course_id = en.course_id
 ORDER BY s.reg_no, c.course_code;

PROMPT ============================================================
PROMPT Q4. STUDENT-SAFE QUESTION PAPER VIEW FOR EXAM 501
PROMPT Concepts: projection, filtering, ORDER BY
PROMPT Note: correct_option is deliberately excluded from this view.
PROMPT ============================================================
SELECT question_id,
       question_text,
       option_a,
       option_b,
       option_c,
       option_d,
       marks
  FROM question
 WHERE exam_id = 501
 ORDER BY question_id;

PROMPT ============================================================
PROMPT Q5. QUESTION COUNT AND TOTAL QUESTION MARKS PER EXAM
PROMPT Concepts: LEFT JOIN, COUNT, SUM, GROUP BY, NVL
PROMPT ============================================================
SELECT e.exam_id,
       e.exam_title,
       COUNT(q.question_id) AS question_count,
       NVL(SUM(q.marks), 0) AS question_marks,
       e.total_marks AS configured_exam_marks
  FROM exam e
  LEFT JOIN question q ON q.exam_id = e.exam_id
 GROUP BY e.exam_id, e.exam_title, e.total_marks
 ORDER BY e.exam_id;

PROMPT ============================================================
PROMPT Q6. COURSES WITH AT LEAST TWO ENROLLMENTS
PROMPT Concepts: JOIN, GROUP BY, HAVING, COUNT
PROMPT ============================================================
SELECT c.course_code,
       c.course_name,
       COUNT(en.enroll_id) AS enrollment_count
  FROM course c
  JOIN enrollment en ON en.course_id = c.course_id
 GROUP BY c.course_code, c.course_name
HAVING COUNT(en.enroll_id) >= 2
 ORDER BY enrollment_count DESC, c.course_code;

PROMPT ============================================================
PROMPT Q7. AVERAGE, HIGHEST AND LOWEST SCORE FOR EACH EXAM
PROMPT Concepts: LEFT JOIN, AVG, MAX, MIN, GROUP BY
PROMPT ============================================================
SELECT e.exam_id,
       e.exam_title,
       ROUND(AVG(r.score), 2) AS average_score,
       MAX(r.score) AS highest_score,
       MIN(r.score) AS lowest_score,
       COUNT(r.result_id) AS attempts
  FROM exam e
  LEFT JOIN result r ON r.exam_id = e.exam_id
 GROUP BY e.exam_id, e.exam_title
 ORDER BY e.exam_id;

PROMPT ============================================================
PROMPT Q8. PASS/FAIL COUNT AND PASS PERCENTAGE PER EXAM
PROMPT Concepts: conditional aggregation, CASE, GROUP BY, NULLIF
PROMPT Pass status is calculated using EXAM.PASS_MARKS, not grade text.
PROMPT ============================================================
SELECT e.exam_id,
       e.exam_title,
       COUNT(r.result_id) AS total_attempts,
       SUM(CASE WHEN r.result_id IS NOT NULL AND r.score >= e.pass_marks
                THEN 1 ELSE 0 END) AS students_passed,
       SUM(CASE WHEN r.result_id IS NOT NULL AND r.score < e.pass_marks
                THEN 1 ELSE 0 END) AS students_failed,
       NVL(ROUND(
           100 * SUM(CASE WHEN r.result_id IS NOT NULL AND r.score >= e.pass_marks
                          THEN 1 ELSE 0 END)
             / NULLIF(COUNT(r.result_id), 0), 2
       ), 0) AS pass_percentage
  FROM exam e
  LEFT JOIN result r ON r.exam_id = e.exam_id
 GROUP BY e.exam_id, e.exam_title
 ORDER BY e.exam_id;

PROMPT ============================================================
PROMPT Q9. STUDENT TRANSCRIPT WITH EXAM, SCORE, PERCENTAGE AND GRADE
PROMPT Concepts: multiple-table JOIN, formatted date, ORDER BY
PROMPT ============================================================
SELECT s.reg_no,
       s.student_name,
       c.course_code,
       e.exam_title,
       r.score,
       r.percentage,
       r.grade,
       TO_CHAR(r.attempt_date, 'DD-MON-YYYY') AS attempt_date
  FROM result r
  JOIN student s ON s.student_id = r.student_id
  JOIN exam e ON e.exam_id = r.exam_id
  JOIN course c ON c.course_id = e.course_id
 ORDER BY s.reg_no, e.exam_date, e.exam_id;

PROMPT ============================================================
PROMPT Q10. ENROLLED STUDENTS WITHOUT A RESULT FOR A COMPLETED EXAM
PROMPT Concepts: JOIN, correlated NOT EXISTS subquery
PROMPT The seeded sample data may correctly return no rows here.
PROMPT ============================================================
SELECT s.student_id,
       s.reg_no,
       s.student_name,
       e.exam_id,
       e.exam_title
  FROM student s
  JOIN enrollment en ON en.student_id = s.student_id
  JOIN exam e ON e.course_id = en.course_id
 WHERE e.status = 'COMPLETED'
   AND NOT EXISTS (
       SELECT 1
         FROM result r
        WHERE r.student_id = s.student_id
          AND r.exam_id = e.exam_id
   )
 ORDER BY s.reg_no, e.exam_id;

PROMPT ============================================================
PROMPT Q11. STUDENTS ENROLLED IN MORE THAN ONE COURSE
PROMPT Concepts: JOIN, COUNT, GROUP BY, HAVING
PROMPT ============================================================
SELECT s.student_id,
       s.reg_no,
       s.student_name,
       COUNT(en.course_id) AS course_count
  FROM student s
  JOIN enrollment en ON en.student_id = s.student_id
 GROUP BY s.student_id, s.reg_no, s.student_name
HAVING COUNT(en.course_id) > 1
 ORDER BY course_count DESC, s.reg_no;

PROMPT ============================================================
PROMPT Q12. STUDENTS SCORING ABOVE THE AVERAGE OF THE SAME EXAM
PROMPT Concepts: correlated scalar subquery
PROMPT ============================================================
SELECT s.student_name,
       e.exam_title,
       r.score,
       ROUND((SELECT AVG(r2.score)
                FROM result r2
               WHERE r2.exam_id = r.exam_id), 2) AS exam_average
  FROM result r
  JOIN student s ON s.student_id = r.student_id
  JOIN exam e ON e.exam_id = r.exam_id
 WHERE r.score > (
       SELECT AVG(r2.score)
         FROM result r2
        WHERE r2.exam_id = r.exam_id
   )
 ORDER BY e.exam_id, r.score DESC;

PROMPT ============================================================
PROMPT Q13. TOP-SCORING STUDENT OR STUDENTS IN EACH EXAM
PROMPT Concepts: common table expression, DENSE_RANK analytic function
PROMPT ============================================================
WITH ranked_results AS (
    SELECT e.exam_id,
           e.exam_title,
           s.reg_no,
           s.student_name,
           r.score,
           DENSE_RANK() OVER (
               PARTITION BY r.exam_id
               ORDER BY r.score DESC
           ) AS score_rank
      FROM result r
      JOIN student s ON s.student_id = r.student_id
      JOIN exam e ON e.exam_id = r.exam_id
)
SELECT exam_id,
       exam_title,
       reg_no,
       student_name,
       score
  FROM ranked_results
 WHERE score_rank = 1
 ORDER BY exam_id, reg_no;

PROMPT ============================================================
PROMPT Q14. COURSES THAT DO NOT HAVE AN EXAMINATION
PROMPT Concepts: LEFT OUTER JOIN, IS NULL (anti-join)
PROMPT The seeded sample data may correctly return no rows here.
PROMPT ============================================================
SELECT c.course_id,
       c.course_code,
       c.course_name
  FROM course c
  LEFT JOIN exam e ON e.course_id = c.course_id
 WHERE e.exam_id IS NULL
 ORDER BY c.course_code;

PROMPT ============================================================
PROMPT Q15. NUMBER OF COURSES ASSIGNED TO EACH FACULTY MEMBER
PROMPT Concepts: multiple-table LEFT JOIN, COUNT, GROUP BY
PROMPT ============================================================
SELECT f.faculty_id,
       f.faculty_name,
       d.dept_name,
       COUNT(c.course_id) AS assigned_courses
  FROM faculty f
  JOIN department d ON d.dept_id = f.dept_id
  LEFT JOIN course c ON c.faculty_id = f.faculty_id
 GROUP BY f.faculty_id, f.faculty_name, d.dept_name
 ORDER BY assigned_courses DESC, f.faculty_name;

PROMPT ============================================================
PROMPT Q16. GRADE DISTRIBUTION FOR EACH EXAM
PROMPT Concepts: GROUP BY, COUNT, aggregation
PROMPT ============================================================
SELECT e.exam_id,
       e.exam_title,
       r.grade,
       COUNT(*) AS students_in_grade
  FROM result r
  JOIN exam e ON e.exam_id = r.exam_id
 GROUP BY e.exam_id, e.exam_title, r.grade
 ORDER BY e.exam_id, r.grade;

PROMPT ============================================================
PROMPT Q17. VALIDATE QUESTION MARKS AGAINST CONFIGURED EXAM MARKS
PROMPT Concepts: correlated scalar subquery, NVL, CASE expression
PROMPT A MATCH indicates that the question bank totals equal EXAM.TOTAL_MARKS.
PROMPT ============================================================
SELECT e.exam_id,
       e.exam_title,
       e.total_marks AS configured_marks,
       NVL((SELECT SUM(q.marks)
              FROM question q
             WHERE q.exam_id = e.exam_id), 0) AS question_bank_marks,
       CASE
           WHEN NVL((SELECT SUM(q.marks)
                       FROM question q
                      WHERE q.exam_id = e.exam_id), 0) = e.total_marks
           THEN 'MATCH'
           ELSE 'MISMATCH'
       END AS marks_validation
  FROM exam e
 ORDER BY e.exam_id;

PROMPT ============================================================
PROMPT Q18. DEPARTMENT-WISE EXAM PERFORMANCE SUMMARY
PROMPT Concepts: multiple-table JOIN, COUNT DISTINCT, AVG, GROUP BY
PROMPT ============================================================
SELECT d.dept_name,
       COUNT(DISTINCT s.student_id) AS students_with_results,
       COUNT(r.result_id) AS total_attempts,
       ROUND(AVG(r.percentage), 2) AS average_percentage
  FROM department d
  JOIN student s ON s.dept_id = d.dept_id
  JOIN result r ON r.student_id = s.student_id
 GROUP BY d.dept_id, d.dept_name
 ORDER BY average_percentage DESC, d.dept_name;

PROMPT ============================================================
PROMPT END OF SQL QUERY COLLECTION
PROMPT 18 meaningful Oracle SQL queries have been executed.
PROMPT Capture the actual result grids / Script Output for the report.
PROMPT ============================================================
