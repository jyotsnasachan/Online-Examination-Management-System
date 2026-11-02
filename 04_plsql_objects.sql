-- ============================================================
-- BCSE302L - DATABASE SYSTEMS
-- Online Examination Management System
-- 04_plsql_objects.sql
-- Oracle Database 26ai Free
--
-- PURPOSE:
--   Implements the Review II PL/SQL requirements using the
--   existing eight-table DBMS_PROJECT schema.
--
-- OBJECTS CREATED:
--   Sequences : SEQ_ENROLLMENT_ID, SEQ_RESULT_ID
--   Procedures: PR_ENROLL_STUDENT, PR_SUBMIT_EXAM,
--               PR_PRINT_EXAM_ROSTER (contains an explicit cursor)
--   Functions : FN_IS_STUDENT_ELIGIBLE,
--               FN_STUDENT_EXAM_PERCENTAGE
--   Triggers  : TRG_ENROLLMENT_BI, TRG_RESULT_BIU,
--               TRG_QUESTION_GUARD_BIUD,
--               TRG_EXAM_COMPLETION_BU
--
-- IMPORTANT:
--   1. Connect as DBMS_PROJECT to service FREEPDB1.
--   2. Run after 01_create_tables.sql and sample-data scripts.
--   3. This script creates/replaces PL/SQL objects only. It does
--      not delete or overwrite your existing project records.
--   4. It assumes sample IDs currently reach ENROLL_ID 4020 and
--      RESULT_ID 6020, as in 02_insert_sample_data.sql.
--   5. Do not run as SYS or SYSTEM.
-- ============================================================

SET DEFINE OFF;
SET SERVEROUTPUT ON SIZE UNLIMITED;

PROMPT ============================================================
PROMPT 1. CREATE SEQUENCES FOR NEW ENROLLMENTS AND RESULTS
PROMPT ============================================================

DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM user_sequences
    WHERE sequence_name = 'SEQ_ENROLLMENT_ID';

    IF v_count = 0 THEN
        EXECUTE IMMEDIATE
            'CREATE SEQUENCE seq_enrollment_id START WITH 4021 INCREMENT BY 1 NOCACHE';
        DBMS_OUTPUT.PUT_LINE('Created SEQ_ENROLLMENT_ID (starts at 4021).');
    ELSE
        DBMS_OUTPUT.PUT_LINE('SEQ_ENROLLMENT_ID already exists; kept it.');
    END IF;

    SELECT COUNT(*) INTO v_count
    FROM user_sequences
    WHERE sequence_name = 'SEQ_RESULT_ID';

    IF v_count = 0 THEN
        EXECUTE IMMEDIATE
            'CREATE SEQUENCE seq_result_id START WITH 6021 INCREMENT BY 1 NOCACHE';
        DBMS_OUTPUT.PUT_LINE('Created SEQ_RESULT_ID (starts at 6021).');
    ELSE
        DBMS_OUTPUT.PUT_LINE('SEQ_RESULT_ID already exists; kept it.');
    END IF;
END;
/

PROMPT ============================================================
PROMPT 2. FUNCTION: CHECK STUDENT EXAM ELIGIBILITY
PROMPT ============================================================

CREATE OR REPLACE FUNCTION fn_is_student_eligible (
    p_student_id IN student.student_id%TYPE,
    p_exam_id    IN exam.exam_id%TYPE
) RETURN VARCHAR2
IS
    v_match_count PLS_INTEGER;
BEGIN
    SELECT COUNT(*)
      INTO v_match_count
      FROM student s
      JOIN exam e
        ON e.exam_id = p_exam_id
      JOIN enrollment en
        ON en.student_id = s.student_id
       AND en.course_id = e.course_id
     WHERE s.student_id = p_student_id
       AND s.status = 'ACTIVE'
       AND e.status IN ('SCHEDULED', 'ONGOING');

    IF v_match_count > 0 THEN
        RETURN 'Y';
    ELSE
        RETURN 'N';
    END IF;
END;
/

PROMPT ============================================================
PROMPT 3. FUNCTION: GET STUDENT EXAM PERCENTAGE
PROMPT ============================================================

CREATE OR REPLACE FUNCTION fn_student_exam_percentage (
    p_student_id IN result.student_id%TYPE,
    p_exam_id    IN result.exam_id%TYPE
) RETURN NUMBER
IS
    v_percentage result.percentage%TYPE;
BEGIN
    SELECT percentage
      INTO v_percentage
      FROM result
     WHERE student_id = p_student_id
       AND exam_id = p_exam_id;

    RETURN v_percentage;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END;
/

PROMPT ============================================================
PROMPT 4. TRIGGER: AUTO-GENERATE ENROLLMENT ID AND VALIDATE STUDENT
PROMPT ============================================================

CREATE OR REPLACE TRIGGER trg_enrollment_bi
BEFORE INSERT ON enrollment
FOR EACH ROW
DECLARE
    v_student_status student.status%TYPE;
BEGIN
    IF :NEW.enroll_id IS NULL THEN
        :NEW.enroll_id := seq_enrollment_id.NEXTVAL;
    END IF;

    IF :NEW.enroll_date IS NULL THEN
        :NEW.enroll_date := SYSDATE;
    END IF;

    BEGIN
        SELECT status
          INTO v_student_status
          FROM student
         WHERE student_id = :NEW.student_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20031,
                'Enrollment rejected: student does not exist.');
    END;

    IF v_student_status <> 'ACTIVE' THEN
        RAISE_APPLICATION_ERROR(-20032,
            'Enrollment rejected: student is not ACTIVE.');
    END IF;
END;
/

PROMPT ============================================================
PROMPT 5. TRIGGER: AUTO-GENERATE RESULT ID, PERCENTAGE AND GRADE
PROMPT Grade bands: A >= 90, B >= 80, C >= 70,
PROMPT              D >= 60, E >= 50, otherwise F.
PROMPT ============================================================

CREATE OR REPLACE TRIGGER trg_result_biu
BEFORE INSERT OR UPDATE ON result
FOR EACH ROW
DECLARE
    v_total_marks exam.total_marks%TYPE;
BEGIN
    IF INSERTING AND :NEW.result_id IS NULL THEN
        :NEW.result_id := seq_result_id.NEXTVAL;
    END IF;

    IF :NEW.attempt_date IS NULL THEN
        :NEW.attempt_date := SYSDATE;
    END IF;

    BEGIN
        SELECT total_marks
          INTO v_total_marks
          FROM exam
         WHERE exam_id = :NEW.exam_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20051,
                'Result rejected: examination does not exist.');
    END;

    IF :NEW.score IS NULL OR :NEW.score < 0 THEN
        RAISE_APPLICATION_ERROR(-20052,
            'Result score must be zero or a positive value.');
    END IF;

    IF :NEW.score > v_total_marks THEN
        RAISE_APPLICATION_ERROR(-20053,
            'Result score cannot exceed the examination total marks.');
    END IF;

    :NEW.percentage := ROUND((:NEW.score / v_total_marks) * 100, 2);

    IF :NEW.percentage >= 90 THEN
        :NEW.grade := 'A';
    ELSIF :NEW.percentage >= 80 THEN
        :NEW.grade := 'B';
    ELSIF :NEW.percentage >= 70 THEN
        :NEW.grade := 'C';
    ELSIF :NEW.percentage >= 60 THEN
        :NEW.grade := 'D';
    ELSIF :NEW.percentage >= 50 THEN
        :NEW.grade := 'E';
    ELSE
        :NEW.grade := 'F';
    END IF;
END;
/

PROMPT ============================================================
PROMPT 6. TRIGGER: LOCK QUESTION BANK AFTER EXAM LEAVES SCHEDULED
PROMPT ============================================================

CREATE OR REPLACE TRIGGER trg_question_guard_biud
BEFORE INSERT OR UPDATE OR DELETE ON question
FOR EACH ROW
DECLARE
    v_exam_id     question.exam_id%TYPE;
    v_exam_status exam.status%TYPE;
BEGIN
    IF DELETING THEN
        v_exam_id := :OLD.exam_id;
    ELSE
        v_exam_id := :NEW.exam_id;
    END IF;

    BEGIN
        SELECT status
          INTO v_exam_status
          FROM exam
         WHERE exam_id = v_exam_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20041,
                'Question change rejected: examination does not exist.');
    END;

    IF v_exam_status <> 'SCHEDULED' THEN
        RAISE_APPLICATION_ERROR(-20042,
            'Question bank can be changed only while the exam is SCHEDULED.');
    END IF;
END;
/

PROMPT ============================================================
PROMPT 7. TRIGGER: VALIDATE QUESTION BANK BEFORE COMPLETING EXAM
PROMPT ============================================================

CREATE OR REPLACE TRIGGER trg_exam_completion_bu
BEFORE UPDATE OF status ON exam
FOR EACH ROW
DECLARE
    v_question_count PLS_INTEGER;
    v_question_marks NUMBER(10,2);
BEGIN
    IF :NEW.status = 'COMPLETED'
       AND NVL(:OLD.status, 'X') <> 'COMPLETED' THEN

        SELECT COUNT(*), NVL(SUM(marks), 0)
          INTO v_question_count, v_question_marks
          FROM question
         WHERE exam_id = :NEW.exam_id;

        IF v_question_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20061,
                'Exam cannot be completed without questions.');
        END IF;

        IF v_question_marks <> :NEW.total_marks THEN
            RAISE_APPLICATION_ERROR(-20062,
                'Exam cannot be completed: question marks do not equal total marks.');
        END IF;
    END IF;
END;
/

PROMPT ============================================================
PROMPT 8. PROCEDURE: ENROLL A STUDENT IN A COURSE
PROMPT ============================================================

CREATE OR REPLACE PROCEDURE pr_enroll_student (
    p_student_id IN student.student_id%TYPE,
    p_course_id  IN course.course_id%TYPE
)
IS
    v_student_status student.status%TYPE;
    v_count          PLS_INTEGER;
BEGIN
    SELECT status
      INTO v_student_status
      FROM student
     WHERE student_id = p_student_id;

    IF v_student_status <> 'ACTIVE' THEN
        RAISE_APPLICATION_ERROR(-20011,
            'Cannot enroll an inactive student.');
    END IF;

    SELECT COUNT(*)
      INTO v_count
      FROM course
     WHERE course_id = p_course_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20012,
            'Course does not exist.');
    END IF;

    SELECT COUNT(*)
      INTO v_count
      FROM enrollment
     WHERE student_id = p_student_id
       AND course_id = p_course_id;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20013,
            'Student is already enrolled in this course.');
    END IF;

    INSERT INTO enrollment (student_id, course_id, enroll_date)
    VALUES (p_student_id, p_course_id, SYSDATE);

    DBMS_OUTPUT.PUT_LINE('Enrollment successful. Student ID: '
                         || p_student_id || ', Course ID: ' || p_course_id);
    DBMS_OUTPUT.PUT_LINE('Enrollment ID is generated automatically by a trigger.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20014,
            'Cannot enroll: student does not exist.');
END;
/

PROMPT ============================================================
PROMPT 9. PROCEDURE: SUBMIT MCQ ANSWERS AND GENERATE RESULT
PROMPT Answer format: question_id:option,question_id:option
PROMPT Example: 1101:B,1102:A,1103:C
PROMPT ============================================================

CREATE OR REPLACE PROCEDURE pr_submit_exam (
    p_student_id IN student.student_id%TYPE,
    p_exam_id    IN exam.exam_id%TYPE,
    p_answers    IN VARCHAR2
)
IS
    TYPE t_answer_map IS TABLE OF VARCHAR2(1) INDEX BY PLS_INTEGER;
    v_answers          t_answer_map;
    v_exam_status      exam.status%TYPE;
    v_token            VARCHAR2(200);
    v_question_id      PLS_INTEGER;
    v_choice           VARCHAR2(1);
    v_colon_position   PLS_INTEGER;
    v_token_index      PLS_INTEGER := 1;
    v_expected_count   PLS_INTEGER;
    v_valid_count      PLS_INTEGER;
    v_score            NUMBER(7,2) := 0;
    v_percentage       NUMBER(5,2);
    v_grade            VARCHAR2(5);
BEGIN
    SELECT status
      INTO v_exam_status
      FROM exam
     WHERE exam_id = p_exam_id;

    IF v_exam_status <> 'ONGOING' THEN
        RAISE_APPLICATION_ERROR(-20021,
            'Exam submission is allowed only when exam status is ONGOING.');
    END IF;

    IF fn_is_student_eligible(p_student_id, p_exam_id) <> 'Y' THEN
        RAISE_APPLICATION_ERROR(-20022,
            'Student is not eligible: check active status and course enrollment.');
    END IF;

    SELECT COUNT(*)
      INTO v_valid_count
      FROM result
     WHERE student_id = p_student_id
       AND exam_id = p_exam_id;

    IF v_valid_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20023,
            'A result already exists. Duplicate exam attempts are not allowed.');
    END IF;

    SELECT COUNT(*)
      INTO v_expected_count
      FROM question
     WHERE exam_id = p_exam_id;

    IF v_expected_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20024,
            'This examination does not have any questions.');
    END IF;

    IF p_answers IS NULL THEN
        RAISE_APPLICATION_ERROR(-20025,
            'Submitted answers cannot be empty.');
    END IF;

    -- Parse comma-separated question_id:option pairs into an associative array.
    LOOP
        v_token := TRIM(REGEXP_SUBSTR(p_answers, '[^,]+', 1, v_token_index));
        EXIT WHEN v_token IS NULL;

        v_colon_position := INSTR(v_token, ':');
        IF v_colon_position < 2 THEN
            RAISE_APPLICATION_ERROR(-20026,
                'Invalid answer format. Use question_id:option.');
        END IF;

        IF NOT REGEXP_LIKE(TRIM(SUBSTR(v_token, 1, v_colon_position - 1)), '^[0-9]+$') THEN
            RAISE_APPLICATION_ERROR(-20027,
                'Question ID must contain digits only.');
        END IF;

        v_question_id := TO_NUMBER(TRIM(SUBSTR(v_token, 1, v_colon_position - 1)));
        v_choice := UPPER(TRIM(SUBSTR(v_token, v_colon_position + 1)));

        IF v_choice IS NULL OR v_choice NOT IN ('A', 'B', 'C', 'D') OR LENGTH(v_choice) <> 1 THEN
            RAISE_APPLICATION_ERROR(-20028,
                'Answer option must be A, B, C or D.');
        END IF;

        IF v_answers.EXISTS(v_question_id) THEN
            RAISE_APPLICATION_ERROR(-20029,
                'Duplicate answer supplied for question ID ' || v_question_id || '.');
        END IF;

        SELECT COUNT(*)
          INTO v_valid_count
          FROM question
         WHERE question_id = v_question_id
           AND exam_id = p_exam_id;

        IF v_valid_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20030,
                'Question ID ' || v_question_id || ' does not belong to this exam.');
        END IF;

        v_answers(v_question_id) := v_choice;
        v_token_index := v_token_index + 1;
    END LOOP;

    IF v_answers.COUNT <> v_expected_count THEN
        RAISE_APPLICATION_ERROR(-20033,
            'Submit exactly one answer for every question in this examination.');
    END IF;

    -- Calculate marks by comparing each submitted option with the answer key.
    FOR q IN (
        SELECT question_id, correct_option, marks
          FROM question
         WHERE exam_id = p_exam_id
         ORDER BY question_id
    ) LOOP
        IF NOT v_answers.EXISTS(q.question_id) THEN
            RAISE_APPLICATION_ERROR(-20034,
                'Missing answer for question ID ' || q.question_id || '.');
        END IF;

        IF v_answers(q.question_id) = q.correct_option THEN
            v_score := v_score + q.marks;
        END IF;
    END LOOP;

    -- Percentage and grade are recalculated by TRG_RESULT_BIU.
    INSERT INTO result (
        score, percentage, grade, attempt_date, student_id, exam_id
    ) VALUES (
        v_score, 0, 'F', SYSDATE, p_student_id, p_exam_id
    );

    DBMS_OUTPUT.PUT_LINE('Exam submitted successfully.');
    DBMS_OUTPUT.PUT_LINE('Student ID: ' || p_student_id);
    DBMS_OUTPUT.PUT_LINE('Exam ID: ' || p_exam_id);
    DBMS_OUTPUT.PUT_LINE('Calculated score: ' || v_score);
    DBMS_OUTPUT.PUT_LINE('Percentage and grade were calculated by TRG_RESULT_BIU.');
    DBMS_OUTPUT.PUT_LINE('The calling application controls COMMIT or ROLLBACK.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20035,
            'Student or examination record was not found.');
END;
/

PROMPT ============================================================
PROMPT 10. PROCEDURE WITH EXPLICIT CURSOR: PRINT EXAM ROSTER
PROMPT ============================================================

CREATE OR REPLACE PROCEDURE pr_print_exam_roster (
    p_exam_id IN exam.exam_id%TYPE
)
IS
    CURSOR c_exam_roster IS
        SELECT s.reg_no,
               s.student_name,
               r.score,
               r.percentage,
               r.grade
          FROM exam e
          JOIN enrollment en
            ON en.course_id = e.course_id
          JOIN student s
            ON s.student_id = en.student_id
          LEFT JOIN result r
            ON r.student_id = s.student_id
           AND r.exam_id = e.exam_id
         WHERE e.exam_id = p_exam_id
         ORDER BY s.reg_no;

    v_reg_no      student.reg_no%TYPE;
    v_name        student.student_name%TYPE;
    v_score       result.score%TYPE;
    v_percentage  result.percentage%TYPE;
    v_grade       result.grade%TYPE;
    v_rows        PLS_INTEGER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Roster for examination ID: ' || p_exam_id);
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------');

    OPEN c_exam_roster;
    LOOP
        FETCH c_exam_roster
         INTO v_reg_no, v_name, v_score, v_percentage, v_grade;
        EXIT WHEN c_exam_roster%NOTFOUND;

        v_rows := v_rows + 1;
        IF v_score IS NULL THEN
            DBMS_OUTPUT.PUT_LINE(v_reg_no || ' | ' || v_name || ' | NOT ATTEMPTED');
        ELSE
            DBMS_OUTPUT.PUT_LINE(v_reg_no || ' | ' || v_name
                || ' | Score: ' || v_score
                || ' | Percentage: ' || v_percentage
                || '% | Grade: ' || v_grade);
        END IF;
    END LOOP;
    CLOSE c_exam_roster;

    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Students processed by explicit cursor: ' || v_rows);
EXCEPTION
    WHEN OTHERS THEN
        IF c_exam_roster%ISOPEN THEN
            CLOSE c_exam_roster;
        END IF;
        RAISE;
END;
/

PROMPT ============================================================
PROMPT 11. VERIFY PL/SQL OBJECTS
PROMPT ============================================================

SELECT object_type, object_name, status
  FROM user_objects
 WHERE object_name IN (
    'FN_IS_STUDENT_ELIGIBLE',
    'FN_STUDENT_EXAM_PERCENTAGE',
    'PR_ENROLL_STUDENT',
    'PR_SUBMIT_EXAM',
    'PR_PRINT_EXAM_ROSTER',
    'TRG_ENROLLMENT_BI',
    'TRG_RESULT_BIU',
    'TRG_QUESTION_GUARD_BIUD',
    'TRG_EXAM_COMPLETION_BU'
 )
 ORDER BY object_type, object_name;

PROMPT ============================================================
PROMPT PL/SQL OBJECT SCRIPT FINISHED.
PROMPT Confirm all listed objects have STATUS = VALID.
PROMPT ============================================================
