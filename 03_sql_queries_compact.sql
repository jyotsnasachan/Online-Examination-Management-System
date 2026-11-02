-- ============================================================
-- BCSE302L - DATABASE SYSTEMS
-- Online Examination Management System
-- 03_sql_queries_compact.sql
-- Oracle Database 26ai Free / SQL Developer
--
-- Purpose: Re-run the 18 SELECT queries with compact column
-- formatting so every selected value is visible in Script Output
-- and easier to print/export for Review II evidence.
-- Read-only: this script does not insert, update or delete data.
-- Run with SQL Developer F5 (Run Script) as DBMS_PROJECT.
-- ============================================================

SET PAGESIZE 100
SET LINESIZE 150
SET FEEDBACK ON
SET VERIFY OFF
SET DEFINE OFF
SET WRAP ON
SET TRIMSPOOL ON
SET TAB OFF
SET NUMWIDTH 8
SET COLSEP ' | '

COLUMN exam_title FORMAT A30
COLUMN course_name FORMAT A28
COLUMN dept_name FORMAT A25
COLUMN student_name FORMAT A20
COLUMN faculty_name FORMAT A20
COLUMN reg_no FORMAT A12
COLUMN course_code FORMAT A12
COLUMN email FORMAT A30
COLUMN exam_date FORMAT A11
COLUMN enrollment_date FORMAT A11
COLUMN attempt_date FORMAT A11
COLUMN question_text FORMAT A48
COLUMN option_a FORMAT A14
COLUMN option_b FORMAT A14
COLUMN option_c FORMAT A14
COLUMN option_d FORMAT A14
COLUMN exam_status FORMAT A10
COLUMN student_status FORMAT A10
COLUMN grade FORMAT A5
COLUMN marks_validation FORMAT A10
COLUMN pass_percentage FORMAT 990.99
COLUMN average_score FORMAT 990.99
COLUMN highest_score FORMAT 990.99
COLUMN lowest_score FORMAT 990.99
COLUMN average_percentage FORMAT 990.99
COLUMN question_marks FORMAT 990.99
COLUMN configured_exam_marks FORMAT 990.99
COLUMN configured_marks FORMAT 990.99
COLUMN question_bank_marks FORMAT 990.99
COLUMN percentage FORMAT 990.99
COLUMN score FORMAT 990.99
COLUMN exam_average FORMAT 990.99
COLUMN duration_min FORMAT 9999
COLUMN semester FORMAT 99
COLUMN question_count FORMAT 999
COLUMN total_attempts FORMAT 999
COLUMN students_passed FORMAT 999
COLUMN students_failed FORMAT 999
COLUMN attempts FORMAT 999
COLUMN course_count FORMAT 999
COLUMN assigned_courses FORMAT 999
COLUMN students_in_grade FORMAT 999
COLUMN students_with_results FORMAT 999

PROMPT ============================================================
PROMPT Q1. COMPLETED EXAMINATION CATALOG WITH COURSE DETAILS
PROMPT Concepts: INNER JOIN, filtering, ORDER BY
PROMPT ============================================================
SELECT e.exam_id,
       SUBSTR(e.exam_title, 1, 30) AS exam_title,
       c.course_code,
       SUBSTR(c.course_name, 1, 28) AS course_name,
       TO_CHAR(e.exam_date, 'DD-MON-YYYY') AS exam_date,
       e.duration_min,
       e.status AS exam_status
  FROM exam e
  JOIN course c ON c.course_id = e.course_id
 WHERE e.status = 'COMPLETED'
 ORDER BY e.exam_date DESC, c.course_code;

PROMPT ============================================================
PROMPT Q2. ACTIVE STUDENTS WITH THEIR DEPARTMENT
PROMPT Concepts: INNER JOIN, WHERE, ORDER BY
PROMPT ============================================================
SELECT SUBSTR(d.dept_name, 1, 25) AS dept_name,
       s.reg_no,
       SUBSTR(s.student_name, 1, 20) AS student_name,
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
       SUBSTR(s.student_name, 1, 20) AS student_name,
       c.course_code,
       SUBSTR(c.course_name, 1, 28) AS course_name,
       TO_CHAR(en.enroll_date, 'DD-MON-YYYY') AS enrollment_date
  FROM enrollment en
  JOIN student s ON s.student_id = en.student_id
  JOIN course c ON c.course_id = en.course_id
 ORDER BY s.reg_no, c.course_code;

PROMPT ============================================================
PROMPT Q4. STUDENT-SAFE QUESTION PAPER VIEW FOR EXAM 501
PROMPT Concepts: projection, filtering, ORDER BY
PROMPT correct_option is deliberately excluded from this student view.
PROMPT ============================================================
SELECT q.question_id,
       SUBSTR(q.question_text, 1, 48) AS question_text,
       SUBSTR(q.option_a, 1, 14) AS option_a,
       SUBSTR(q.option_b, 1, 14) AS option_b,
       SUBSTR(q.option_c, 1, 14) AS option_c,
       SUBSTR(q.option_d, 1, 14) AS option_d,
       q.marks
  FROM question q
 WHERE q.exam_id = 501
 ORDER BY q.question_id;

PROMPT ============================================================
PROMPT Q5. QUESTION COUNT AND TOTAL QUESTION MARKS PER EXAM
PROMPT Concepts: LEFT JOIN, COUNT, SUM, GROUP BY, NVL
PROMPT ============================================================
SELECT e.exam_id,
       SUBSTR(e.exam_title, 1, 30) AS exam_title,
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
       SUBSTR(c.course_name, 1, 28) AS course_name,
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
       SUBSTR(e.exam_title, 1, 30) AS exam_title,
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
PROMPT Concepts: CASE, conditional aggregation, GROUP BY, NULLIF
PROMPT ============================================================
SELECT e.exam_id,
       SUBSTR(e.exam_title, 1, 30) AS exam_title,
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
       SUBSTR(s.student_name, 1, 20) AS student_name,
       c.course_code,
       SUBSTR(e.exam_title, 1, 30) AS exam_title,
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
PROMPT Zero rows are expected for the fully matched sample data.
PROMPT ============================================================
SELECT s.student_id,
       s.reg_no,
       SUBSTR(s.student_name, 1, 20) AS student_name,
       e.exam_id,
       SUBSTR(e.exam_title, 1, 30) AS exam_title
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
PROMPT Concepts: COUNT, GROUP BY, HAVING
PROMPT ============================================================
SELECT s.student_id,
       s.reg_no,
       SUBSTR(s.student_name, 1, 20) AS student_name,
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
SELECT SUBSTR(s.student_name, 1, 20) AS student_name,
       SUBSTR(e.exam_title, 1, 30) AS exam_title,
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
PROMPT Concepts: CTE, DENSE_RANK analytic function
PROMPT ============================================================
WITH ranked_results AS (
    SELECT e.exam_id,
           SUBSTR(e.exam_title, 1, 30) AS exam_title,
           s.reg_no,
           SUBSTR(s.student_name, 1, 20) AS student_name,
           r.score,
           DENSE_RANK() OVER (
               PARTITION BY r.exam_id
               ORDER BY r.score DESC
           ) AS score_rank
      FROM result r
      JOIN student s ON s.student_id = r.student_id
      JOIN exam e ON e.exam_id = r.exam_id
)
SELECT exam_id, exam_title, reg_no, student_name, score
  FROM ranked_results
 WHERE score_rank = 1
 ORDER BY exam_id, reg_no;

PROMPT ============================================================
PROMPT Q14. COURSES THAT DO NOT HAVE AN EXAMINATION
PROMPT Concepts: LEFT OUTER JOIN, IS NULL (anti-join)
PROMPT Zero rows are expected because every sample course has an exam.
PROMPT ============================================================
SELECT c.course_id,
       c.course_code,
       SUBSTR(c.course_name, 1, 28) AS course_name
  FROM course c
  LEFT JOIN exam e ON e.course_id = c.course_id
 WHERE e.exam_id IS NULL
 ORDER BY c.course_code;

PROMPT ============================================================
PROMPT Q15. NUMBER OF COURSES ASSIGNED TO EACH FACULTY MEMBER
PROMPT Concepts: LEFT JOIN, COUNT, GROUP BY
PROMPT ============================================================
SELECT f.faculty_id,
       SUBSTR(f.faculty_name, 1, 20) AS faculty_name,
       SUBSTR(d.dept_name, 1, 25) AS dept_name,
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
       SUBSTR(e.exam_title, 1, 30) AS exam_title,
       r.grade,
       COUNT(*) AS students_in_grade
  FROM result r
  JOIN exam e ON e.exam_id = r.exam_id
 GROUP BY e.exam_id, e.exam_title, r.grade
 ORDER BY e.exam_id, r.grade;

PROMPT ============================================================
PROMPT Q17. VALIDATE QUESTION MARKS AGAINST CONFIGURED EXAM MARKS
PROMPT Concepts: correlated scalar subquery, NVL, CASE expression
PROMPT MATCH means question-bank marks equal EXAM.TOTAL_MARKS.
PROMPT ============================================================
SELECT e.exam_id,
       SUBSTR(e.exam_title, 1, 30) AS exam_title,
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
SELECT SUBSTR(d.dept_name, 1, 25) AS dept_name,
       COUNT(DISTINCT s.student_id) AS students_with_results,
       COUNT(r.result_id) AS total_attempts,
       ROUND(AVG(r.percentage), 2) AS average_percentage
  FROM department d
  JOIN student s ON s.dept_id = d.dept_id
  JOIN result r ON r.student_id = s.student_id
 GROUP BY d.dept_id, d.dept_name
 ORDER BY average_percentage DESC, d.dept_name;

PROMPT ============================================================
PROMPT END OF COMPACT SQL QUERY COLLECTION
PROMPT 18 SELECT queries. No project data was modified.
PROMPT ============================================================
