-- ============================================================
-- BCSE302L - DATABASE SYSTEMS
-- Online Examination Management System
-- 05_plsql_demo_setup_and_run.sql
--
-- PURPOSE:
--   Creates a separate demonstration exam (ID 511) and questions,
--   then exercises the Review II procedures, functions, cursor and
--   triggers without deleting the original sample records.
--
-- RUN ONLY AFTER 04_plsql_objects.sql COMPILES SUCCESSFULLY.
-- Connect as DBMS_PROJECT to FREEPDB1 and use F5.
--
-- Demonstration data:
--   Exam 511 -> Course 301 (Database Systems)
--   Questions 1101-1103 -> 10 marks each, total 30
--   Student 2001 is already enrolled in Course 301.
-- ============================================================

SET DEFINE OFF;
SET SERVEROUTPUT ON SIZE UNLIMITED;

PROMPT ============================================================
PROMPT 1. PREPARE A DEMONSTRATION EXAM AND QUESTION BANK
PROMPT ============================================================

MERGE INTO exam e
USING (
    SELECT 511 AS exam_id,
           'Database Systems - PL/SQL Demonstration Exam' AS exam_title,
           TRUNC(SYSDATE) AS exam_date,
           20 AS duration_min,
           30 AS total_marks,
           12 AS pass_marks,
           'SCHEDULED' AS status,
           301 AS course_id
      FROM dual
) src
ON (e.exam_id = src.exam_id)
WHEN NOT MATCHED THEN
    INSERT (exam_id, exam_title, exam_date, duration_min,
            total_marks, pass_marks, status, course_id)
    VALUES (src.exam_id, src.exam_title, src.exam_date, src.duration_min,
            src.total_marks, src.pass_marks, src.status, src.course_id);

MERGE INTO question q
USING (
    SELECT 1101 AS question_id,
           'Which SQL statement retrieves rows from a table?' AS question_text,
           'INSERT' AS option_a, 'SELECT' AS option_b,
           'UPDATE' AS option_c, 'DELETE' AS option_d,
           'B' AS correct_option, 10 AS marks, 511 AS exam_id
      FROM dual
    UNION ALL
    SELECT 1102,
           'Which constraint uniquely identifies each row?',
           'PRIMARY KEY', 'CHECK', 'DEFAULT', 'NOT NULL',
           'A', 10, 511
      FROM dual
    UNION ALL
    SELECT 1103,
           'Which SQL operation combines rows from related tables?',
           'ORDER BY', 'GROUP BY', 'JOIN', 'DISTINCT',
           'C', 10, 511
      FROM dual
) src
ON (q.question_id = src.question_id)
WHEN NOT MATCHED THEN
    INSERT (question_id, question_text, option_a, option_b,
            option_c, option_d, correct_option, marks, exam_id)
    VALUES (src.question_id, src.question_text, src.option_a, src.option_b,
            src.option_c, src.option_d, src.correct_option, src.marks, src.exam_id);

-- Question-bank trigger allows edits while SCHEDULED; now open the exam.
UPDATE exam
   SET status = 'ONGOING'
 WHERE exam_id = 511
   AND status = 'SCHEDULED';

COMMIT;

PROMPT ============================================================
PROMPT 2. FUNCTION DEMONSTRATION: CHECK ELIGIBILITY
PROMPT ============================================================

DECLARE
    v_eligible VARCHAR2(1);
BEGIN
    v_eligible := fn_is_student_eligible(2001, 511);
    DBMS_OUTPUT.PUT_LINE('Student 2001 eligible for exam 511? ' || v_eligible);
END;
/

PROMPT ============================================================
PROMPT 3. PROCEDURE DEMONSTRATION: ENROLL STUDENT IN COURSE
PROMPT ============================================================
PROMPT Student 2001 is being enrolled in Course 310 for demonstration.

BEGIN
    pr_enroll_student(2001, 310);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20013 THEN
            DBMS_OUTPUT.PUT_LINE('Demo enrollment already exists; no duplicate inserted.');
        ELSE
            RAISE;
        END IF;
END;
/

SELECT enroll_id, student_id, course_id, enroll_date
  FROM enrollment
 WHERE student_id = 2001
   AND course_id = 310;

PROMPT ============================================================
PROMPT 4. PROCEDURE DEMONSTRATION: SUBMIT MCQ ANSWERS
PROMPT ============================================================
PROMPT Correct answers: 1101:B, 1102:A, 1103:C (expected 30/30).

BEGIN
    pr_submit_exam(2001, 511, '1101:B,1102:A,1103:C');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20023 THEN
            DBMS_OUTPUT.PUT_LINE('Demo attempt already exists; duplicate was correctly rejected.');
        ELSE
            RAISE;
        END IF;
END;
/

SELECT result_id, student_id, exam_id, score, percentage, grade, attempt_date
  FROM result
 WHERE student_id = 2001
   AND exam_id = 511;

PROMPT ============================================================
PROMPT 5. FUNCTION DEMONSTRATION: RETRIEVE RESULT PERCENTAGE
PROMPT ============================================================

DECLARE
    v_percentage NUMBER;
BEGIN
    v_percentage := fn_student_exam_percentage(2001, 511);
    DBMS_OUTPUT.PUT_LINE('Percentage for student 2001, exam 511: '
        || NVL(TO_CHAR(v_percentage), 'NO RESULT'));
END;
/

PROMPT ============================================================
PROMPT 6. EXPLICIT CURSOR DEMONSTRATION: PRINT EXAM ROSTER
PROMPT ============================================================

BEGIN
    pr_print_exam_roster(511);
END;
/

PROMPT ============================================================
PROMPT 7. TRIGGER DEMONSTRATION: QUESTION BANK LOCK
PROMPT ============================================================
PROMPT The following update is expected to be rejected because exam 511 is ONGOING.

BEGIN
    UPDATE question
       SET question_text = question_text
     WHERE question_id = 1101;

    DBMS_OUTPUT.PUT_LINE('WARNING: question guard did not reject the update.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20042 THEN
            DBMS_OUTPUT.PUT_LINE('PASS: question guard blocked modification after exam started.');
        ELSE
            RAISE;
        END IF;
END;
/

PROMPT ============================================================
PROMPT 8. TRIGGER DEMONSTRATION: EXAM COMPLETION VALIDATION
PROMPT ============================================================
PROMPT Exam 511 has 3 questions worth 10 marks each (total = 30).

UPDATE exam
   SET status = 'COMPLETED'
 WHERE exam_id = 511;

COMMIT;

SELECT exam_id, exam_title, total_marks, status
  FROM exam
 WHERE exam_id = 511;

PROMPT ============================================================
PROMPT 9. FINAL RESULT AND DEMO RECORD CHECK
PROMPT ============================================================

SELECT r.result_id, s.reg_no, s.student_name,
       e.exam_title, r.score, r.percentage, r.grade
  FROM result r
  JOIN student s ON s.student_id = r.student_id
  JOIN exam e ON e.exam_id = r.exam_id
 WHERE r.exam_id = 511
 ORDER BY s.reg_no;

PROMPT ============================================================
PROMPT PL/SQL DEMONSTRATION SCRIPT FINISHED.
PROMPT Expected first-run demo result for student 2001: 30 marks, 100%, grade A.
PROMPT The script catches the duplicate enrollment/attempt conditions on re-run.
PROMPT ============================================================
