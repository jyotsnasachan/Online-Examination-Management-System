-- ============================================================
-- BCSE302L - DATABASE SYSTEMS
-- Online Examination Management System
-- 06_dml_demonstration.sql
--
-- PURPOSE:
--   Demonstrate INSERT, UPDATE and DELETE for Review II.
--
-- IMPORTANT:
--   1. Run as DBMS_PROJECT in FREEPDB1 using SQL Developer (F5).
--   2. Uses one dedicated demonstration student only:
--      STUDENT_ID = 2999, REG_NO = DEMO-DML-2999.
--   3. Does not modify the original 10 sample students.
--   4. The demonstration student is deleted at the end.
--   5. Do not use ID 2999 for any other project data.
--   6. If this script stops part-way through, inspect STUDENT_ID 2999
--      before rerunning; do not delete a row that has child records.
-- ============================================================

SET DEFINE OFF;
SET SERVEROUTPUT ON SIZE UNLIMITED;

PROMPT ============================================================
PROMPT DML DEMONSTRATION - INSERT, UPDATE AND DELETE
PROMPT ============================================================

DECLARE
    v_existing_count NUMBER;
    v_status         student.status%TYPE;
    v_semester       student.semester%TYPE;
BEGIN
    -- Guard: do not overwrite an unrelated or unfinished record.
    SELECT COUNT(*)
      INTO v_existing_count
      FROM student
     WHERE student_id = 2999
        OR reg_no = 'DEMO-DML-2999'
        OR email = 'dml.demo2999@student.demo.edu';

    IF v_existing_count > 0 THEN
        RAISE_APPLICATION_ERROR(
            -20081,
            'DML demo identity already exists. Inspect STUDENT_ID 2999 before rerunning.'
        );
    END IF;

    -- 1. INSERT: omit STATUS to demonstrate its DEFAULT value ('ACTIVE').
    INSERT INTO student (
        student_id, reg_no, student_name, email, semester, dept_id
    ) VALUES (
        2999,
        'DEMO-DML-2999',
        'DML Demonstration Student',
        'dml.demo2999@student.demo.edu',
        1,
        1
    );

    DBMS_OUTPUT.PUT_LINE('INSERT: ' || SQL%ROWCOUNT || ' student row inserted.');

    SELECT status, semester
      INTO v_status, v_semester
      FROM student
     WHERE student_id = 2999;

    DBMS_OUTPUT.PUT_LINE('After INSERT: status=' || v_status ||
                         ', semester=' || v_semester ||
                         ' (STATUS default applied).');
    COMMIT;

    -- 2. UPDATE: change the demo student's semester and status.
    UPDATE student
       SET semester = 2,
           status = 'INACTIVE'
     WHERE student_id = 2999;

    DBMS_OUTPUT.PUT_LINE('UPDATE: ' || SQL%ROWCOUNT || ' student row updated.');

    SELECT status, semester
      INTO v_status, v_semester
      FROM student
     WHERE student_id = 2999;

    DBMS_OUTPUT.PUT_LINE('After UPDATE: status=' || v_status ||
                         ', semester=' || v_semester || '.');
    COMMIT;

    -- 3. DELETE: remove only the isolated demonstration student.
    -- No ENROLLMENT or RESULT rows are created for this demo student.
    DELETE FROM student
     WHERE student_id = 2999;

    DBMS_OUTPUT.PUT_LINE('DELETE: ' || SQL%ROWCOUNT || ' student row deleted.');
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('DML demonstration completed successfully.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('DML demonstration stopped: ' || SQLERRM);
        RAISE;
END;
/

PROMPT ============================================================
PROMPT FINAL CHECK: DEMONSTRATION STUDENT SHOULD NO LONGER EXIST
PROMPT ============================================================

SELECT COUNT(*) AS remaining_demo_student_rows
  FROM student
 WHERE student_id = 2999;

PROMPT Expected final count: 0.
PROMPT The original sample records remain unchanged.
PROMPT ============================================================
