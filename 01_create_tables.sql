-- Online Examination Management System
-- BCSE302L - Database Systems
-- Oracle Database 26ai Free
-- Review II / Final Project: DDL and integrity constraints
--
-- IMPORTANT:
-- 1. Connect to the DBMS_PROJECT schema in FREEPDB1 before running this file.
-- 2. Run this script ONCE in a fresh project schema using SQL Developer -> F5 (Run Script).
-- 3. This file creates exactly the eight approved project tables. It does not insert data.
-- 4. Do not run as SYS or SYSTEM.

SET DEFINE OFF;

PROMPT ============================================================
PROMPT Creating DEPARTMENT
PROMPT ============================================================

CREATE TABLE department (
    dept_id   NUMBER(5)       CONSTRAINT pk_department PRIMARY KEY,
    dept_name VARCHAR2(100)   CONSTRAINT nn_department_name NOT NULL,
    hod_name  VARCHAR2(100)   CONSTRAINT nn_department_hod NOT NULL,
    CONSTRAINT uq_department_name UNIQUE (dept_name)
);

PROMPT ============================================================
PROMPT Creating FACULTY
PROMPT ============================================================

CREATE TABLE faculty (
    faculty_id   NUMBER(6)       CONSTRAINT pk_faculty PRIMARY KEY,
    faculty_name VARCHAR2(120)   CONSTRAINT nn_faculty_name NOT NULL,
    email        VARCHAR2(150)   CONSTRAINT nn_faculty_email NOT NULL,
    designation  VARCHAR2(80)    CONSTRAINT nn_faculty_designation NOT NULL,
    dept_id      NUMBER(5)       CONSTRAINT nn_faculty_dept NOT NULL,
    CONSTRAINT uq_faculty_email UNIQUE (email),
    CONSTRAINT fk_faculty_department
        FOREIGN KEY (dept_id) REFERENCES department (dept_id)
);

PROMPT ============================================================
PROMPT Creating STUDENT
PROMPT ============================================================

CREATE TABLE student (
    student_id   NUMBER(8)       CONSTRAINT pk_student PRIMARY KEY,
    reg_no       VARCHAR2(30)    CONSTRAINT nn_student_reg_no NOT NULL,
    student_name VARCHAR2(120)   CONSTRAINT nn_student_name NOT NULL,
    email        VARCHAR2(150)   CONSTRAINT nn_student_email NOT NULL,
    semester     NUMBER(2)       CONSTRAINT nn_student_semester NOT NULL,
    status       VARCHAR2(12)    DEFAULT 'ACTIVE' CONSTRAINT nn_student_status NOT NULL,
    dept_id      NUMBER(5)       CONSTRAINT nn_student_dept NOT NULL,
    CONSTRAINT uq_student_reg_no UNIQUE (reg_no),
    CONSTRAINT uq_student_email UNIQUE (email),
    CONSTRAINT ck_student_semester CHECK (semester BETWEEN 1 AND 8),
    CONSTRAINT ck_student_status CHECK (status IN ('ACTIVE', 'INACTIVE')),
    CONSTRAINT fk_student_department
        FOREIGN KEY (dept_id) REFERENCES department (dept_id)
);

PROMPT ============================================================
PROMPT Creating COURSE
PROMPT ============================================================

CREATE TABLE course (
    course_id   NUMBER(6)       CONSTRAINT pk_course PRIMARY KEY,
    course_code VARCHAR2(20)    CONSTRAINT nn_course_code NOT NULL,
    course_name VARCHAR2(150)   CONSTRAINT nn_course_name NOT NULL,
    credits     NUMBER(2)       CONSTRAINT nn_course_credits NOT NULL,
    dept_id     NUMBER(5)       CONSTRAINT nn_course_dept NOT NULL,
    faculty_id  NUMBER(6)       CONSTRAINT nn_course_faculty NOT NULL,
    CONSTRAINT uq_course_code UNIQUE (course_code),
    CONSTRAINT ck_course_credits CHECK (credits > 0),
    CONSTRAINT fk_course_department
        FOREIGN KEY (dept_id) REFERENCES department (dept_id),
    CONSTRAINT fk_course_faculty
        FOREIGN KEY (faculty_id) REFERENCES faculty (faculty_id)
);

PROMPT ============================================================
PROMPT Creating ENROLLMENT
PROMPT ============================================================

CREATE TABLE enrollment (
    enroll_id   NUMBER(10)      CONSTRAINT pk_enrollment PRIMARY KEY,
    enroll_date DATE            DEFAULT SYSDATE CONSTRAINT nn_enrollment_date NOT NULL,
    student_id  NUMBER(8)       CONSTRAINT nn_enrollment_student NOT NULL,
    course_id   NUMBER(6)       CONSTRAINT nn_enrollment_course NOT NULL,
    CONSTRAINT uq_enrollment_student_course UNIQUE (student_id, course_id),
    CONSTRAINT fk_enrollment_student
        FOREIGN KEY (student_id) REFERENCES student (student_id),
    CONSTRAINT fk_enrollment_course
        FOREIGN KEY (course_id) REFERENCES course (course_id)
);

PROMPT ============================================================
PROMPT Creating EXAM
PROMPT ============================================================

CREATE TABLE exam (
    exam_id      NUMBER(8)       CONSTRAINT pk_exam PRIMARY KEY,
    exam_title   VARCHAR2(150)   CONSTRAINT nn_exam_title NOT NULL,
    exam_date    DATE            CONSTRAINT nn_exam_date NOT NULL,
    duration_min NUMBER(4)       CONSTRAINT nn_exam_duration NOT NULL,
    total_marks  NUMBER(7,2)     CONSTRAINT nn_exam_total_marks NOT NULL,
    pass_marks   NUMBER(7,2)     CONSTRAINT nn_exam_pass_marks NOT NULL,
    status       VARCHAR2(12)    DEFAULT 'SCHEDULED' CONSTRAINT nn_exam_status NOT NULL,
    course_id    NUMBER(6)       CONSTRAINT nn_exam_course NOT NULL,
    CONSTRAINT ck_exam_duration CHECK (duration_min BETWEEN 1 AND 600),
    CONSTRAINT ck_exam_total_marks CHECK (total_marks > 0),
    CONSTRAINT ck_exam_pass_marks CHECK (pass_marks >= 0 AND pass_marks <= total_marks),
    CONSTRAINT ck_exam_status CHECK (status IN ('SCHEDULED', 'ONGOING', 'COMPLETED', 'CANCELLED')),
    CONSTRAINT fk_exam_course
        FOREIGN KEY (course_id) REFERENCES course (course_id)
);

PROMPT ============================================================
PROMPT Creating QUESTION
PROMPT ============================================================

CREATE TABLE question (
    question_id   NUMBER(10)      CONSTRAINT pk_question PRIMARY KEY,
    question_text VARCHAR2(1000)  CONSTRAINT nn_question_text NOT NULL,
    option_a      VARCHAR2(500)   CONSTRAINT nn_question_option_a NOT NULL,
    option_b      VARCHAR2(500)   CONSTRAINT nn_question_option_b NOT NULL,
    option_c      VARCHAR2(500)   CONSTRAINT nn_question_option_c NOT NULL,
    option_d      VARCHAR2(500)   CONSTRAINT nn_question_option_d NOT NULL,
    correct_option CHAR(1)        CONSTRAINT nn_question_correct_option NOT NULL,
    marks         NUMBER(6,2)     CONSTRAINT nn_question_marks NOT NULL,
    exam_id       NUMBER(8)       CONSTRAINT nn_question_exam NOT NULL,
    CONSTRAINT ck_question_correct_option CHECK (correct_option IN ('A', 'B', 'C', 'D')),
    CONSTRAINT ck_question_marks CHECK (marks > 0),
    CONSTRAINT fk_question_exam
        FOREIGN KEY (exam_id) REFERENCES exam (exam_id)
);

PROMPT ============================================================
PROMPT Creating RESULT
PROMPT ============================================================

CREATE TABLE result (
    result_id   NUMBER(10)      CONSTRAINT pk_result PRIMARY KEY,
    score       NUMBER(7,2)     CONSTRAINT nn_result_score NOT NULL,
    percentage  NUMBER(5,2)     CONSTRAINT nn_result_percentage NOT NULL,
    grade       VARCHAR2(5)     CONSTRAINT nn_result_grade NOT NULL,
    attempt_date DATE           DEFAULT SYSDATE CONSTRAINT nn_result_attempt_date NOT NULL,
    student_id  NUMBER(8)       CONSTRAINT nn_result_student NOT NULL,
    exam_id     NUMBER(8)       CONSTRAINT nn_result_exam NOT NULL,
    CONSTRAINT uq_result_student_exam UNIQUE (student_id, exam_id),
    CONSTRAINT ck_result_score CHECK (score >= 0),
    CONSTRAINT ck_result_percentage CHECK (percentage BETWEEN 0 AND 100),
    CONSTRAINT fk_result_student
        FOREIGN KEY (student_id) REFERENCES student (student_id),
    CONSTRAINT fk_result_exam
        FOREIGN KEY (exam_id) REFERENCES exam (exam_id)
);

PROMPT ============================================================
PROMPT Verifying the eight project tables
PROMPT ============================================================

SELECT table_name
FROM user_tables
WHERE table_name IN (
    'DEPARTMENT', 'STUDENT', 'FACULTY', 'COURSE',
    'ENROLLMENT', 'EXAM', 'QUESTION', 'RESULT'
)
ORDER BY table_name;

PROMPT ============================================================
PROMPT DDL script completed. Verify that exactly 8 rows are listed above.
PROMPT ============================================================
