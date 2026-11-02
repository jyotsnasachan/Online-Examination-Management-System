-- ============================================================
-- BCSE302L - DATABASE SYSTEMS
-- Online Examination Management System
-- 02_insert_sample_data.sql
-- Oracle Database 26ai Free / SQL Developer
--
-- IMPORTANT:
-- 1. Connect as DBMS_PROJECT to FREEPDB1.
-- 2. Run this script ONCE, after 01_create_tables.sql succeeds.
-- 3. This script assumes all eight project tables are empty.
-- 4. Sample names/emails are fictional academic demo data.
-- 5. It inserts at least 10 rows in every table.
-- ============================================================

SET DEFINE OFF;
SET SERVEROUTPUT ON;

PROMPT ============================================================
PROMPT 1. DEPARTMENT - 10 sample departments
PROMPT ============================================================
INSERT ALL
  INTO department (dept_id, dept_name, hod_name) VALUES (1, 'Computer Science Engineering', 'Dr. Meera Nair')
  INTO department (dept_id, dept_name, hod_name) VALUES (2, 'Information Technology', 'Dr. Arvind Rao')
  INTO department (dept_id, dept_name, hod_name) VALUES (3, 'Electronics and Communication', 'Dr. Kavita Shah')
  INTO department (dept_id, dept_name, hod_name) VALUES (4, 'Electrical and Electronics', 'Dr. R. Menon')
  INTO department (dept_id, dept_name, hod_name) VALUES (5, 'Mechanical Engineering', 'Dr. P. Iyer')
  INTO department (dept_id, dept_name, hod_name) VALUES (6, 'Civil Engineering', 'Dr. S. Kulkarni')
  INTO department (dept_id, dept_name, hod_name) VALUES (7, 'Biotechnology', 'Dr. T. Das')
  INTO department (dept_id, dept_name, hod_name) VALUES (8, 'Chemical Engineering', 'Dr. N. Kapoor')
  INTO department (dept_id, dept_name, hod_name) VALUES (9, 'Mathematics', 'Dr. L. Fernandes')
  INTO department (dept_id, dept_name, hod_name) VALUES (10, 'Data Science', 'Dr. A. Thomas')
SELECT 1 FROM dual;

PROMPT ============================================================
PROMPT 2. FACULTY - 10 sample faculty members
PROMPT ============================================================
INSERT ALL
  INTO faculty (faculty_id, faculty_name, email, designation, dept_id) VALUES (101, 'Ananya Sharma', 'ananya.sharma@demo-university.edu', 'Assistant Professor', 1)
  INTO faculty (faculty_id, faculty_name, email, designation, dept_id) VALUES (102, 'Rahul Verma', 'rahul.verma@demo-university.edu', 'Associate Professor', 2)
  INTO faculty (faculty_id, faculty_name, email, designation, dept_id) VALUES (103, 'Priya Nair', 'priya.nair@demo-university.edu', 'Assistant Professor', 3)
  INTO faculty (faculty_id, faculty_name, email, designation, dept_id) VALUES (104, 'Karan Mehta', 'karan.mehta@demo-university.edu', 'Assistant Professor', 4)
  INTO faculty (faculty_id, faculty_name, email, designation, dept_id) VALUES (105, 'Divya Iyer', 'divya.iyer@demo-university.edu', 'Professor', 5)
  INTO faculty (faculty_id, faculty_name, email, designation, dept_id) VALUES (106, 'Amit Kulkarni', 'amit.kulkarni@demo-university.edu', 'Assistant Professor', 6)
  INTO faculty (faculty_id, faculty_name, email, designation, dept_id) VALUES (107, 'Sneha Das', 'sneha.das@demo-university.edu', 'Associate Professor', 7)
  INTO faculty (faculty_id, faculty_name, email, designation, dept_id) VALUES (108, 'Vivek Kapoor', 'vivek.kapoor@demo-university.edu', 'Assistant Professor', 8)
  INTO faculty (faculty_id, faculty_name, email, designation, dept_id) VALUES (109, 'Neha Thomas', 'neha.thomas@demo-university.edu', 'Assistant Professor', 9)
  INTO faculty (faculty_id, faculty_name, email, designation, dept_id) VALUES (110, 'Luis Fernandes', 'luis.fernandes@demo-university.edu', 'Professor', 10)
SELECT 1 FROM dual;

PROMPT ============================================================
PROMPT 3. STUDENT - 10 sample students
PROMPT ============================================================
INSERT ALL
  INTO student (student_id, reg_no, student_name, email, semester, status, dept_id) VALUES (2001, '24CSE1001', 'Aarav Gupta', 'aarav.gupta@student.demo.edu', 4, 'ACTIVE', 1)
  INTO student (student_id, reg_no, student_name, email, semester, status, dept_id) VALUES (2002, '24IT1002', 'Isha Patel', 'isha.patel@student.demo.edu', 4, 'ACTIVE', 2)
  INTO student (student_id, reg_no, student_name, email, semester, status, dept_id) VALUES (2003, '24ECE1003', 'Reyansh Shah', 'reyansh.shah@student.demo.edu', 5, 'ACTIVE', 3)
  INTO student (student_id, reg_no, student_name, email, semester, status, dept_id) VALUES (2004, '24EEE1004', 'Anaya Reddy', 'anaya.reddy@student.demo.edu', 4, 'ACTIVE', 4)
  INTO student (student_id, reg_no, student_name, email, semester, status, dept_id) VALUES (2005, '24MEC1005', 'Vivaan Joshi', 'vivaan.joshi@student.demo.edu', 6, 'ACTIVE', 5)
  INTO student (student_id, reg_no, student_name, email, semester, status, dept_id) VALUES (2006, '24CIV1006', 'Myra Singh', 'myra.singh@student.demo.edu', 5, 'ACTIVE', 6)
  INTO student (student_id, reg_no, student_name, email, semester, status, dept_id) VALUES (2007, '24BIO1007', 'Advik Rao', 'advik.rao@student.demo.edu', 4, 'ACTIVE', 7)
  INTO student (student_id, reg_no, student_name, email, semester, status, dept_id) VALUES (2008, '24CHE1008', 'Sara Khan', 'sara.khan@student.demo.edu', 6, 'ACTIVE', 8)
  INTO student (student_id, reg_no, student_name, email, semester, status, dept_id) VALUES (2009, '24MAT1009', 'Kabir Menon', 'kabir.menon@student.demo.edu', 4, 'ACTIVE', 9)
  INTO student (student_id, reg_no, student_name, email, semester, status, dept_id) VALUES (2010, '24DS10010', 'Diya Fernandes', 'diya.fernandes@student.demo.edu', 5, 'ACTIVE', 10)
SELECT 1 FROM dual;

PROMPT ============================================================
PROMPT 4. COURSE - 10 sample courses
PROMPT ============================================================
INSERT ALL
  INTO course (course_id, course_code, course_name, credits, dept_id, faculty_id) VALUES (301, 'BCSE302L', 'Database Systems', 4, 1, 101)
  INTO course (course_id, course_code, course_name, credits, dept_id, faculty_id) VALUES (302, 'BCSE303L', 'Data Structures and Algorithms', 4, 1, 101)
  INTO course (course_id, course_code, course_name, credits, dept_id, faculty_id) VALUES (303, 'BCSE304L', 'Operating Systems', 4, 1, 101)
  INTO course (course_id, course_code, course_name, credits, dept_id, faculty_id) VALUES (304, 'BITE201L', 'Computer Networks', 3, 2, 102)
  INTO course (course_id, course_code, course_name, credits, dept_id, faculty_id) VALUES (305, 'BITE202L', 'Software Engineering', 3, 2, 102)
  INTO course (course_id, course_code, course_name, credits, dept_id, faculty_id) VALUES (306, 'BECE203L', 'Digital Logic Design', 3, 3, 103)
  INTO course (course_id, course_code, course_name, credits, dept_id, faculty_id) VALUES (307, 'BEEE204L', 'Electrical Circuits', 3, 4, 104)
  INTO course (course_id, course_code, course_name, credits, dept_id, faculty_id) VALUES (308, 'BMEC205L', 'Engineering Mechanics', 3, 5, 105)
  INTO course (course_id, course_code, course_name, credits, dept_id, faculty_id) VALUES (309, 'BMAT206L', 'Engineering Mathematics', 4, 9, 109)
  INTO course (course_id, course_code, course_name, credits, dept_id, faculty_id) VALUES (310, 'BDSC207L', 'Introduction to Data Analytics', 3, 10, 110)
SELECT 1 FROM dual;

PROMPT ============================================================
PROMPT 5. ENROLLMENT - 20 registrations (2 per student)
PROMPT ============================================================
INSERT ALL
  INTO enrollment (enroll_id, enroll_date, student_id, course_id) VALUES (4001, TRUNC(SYSDATE) - 60, 2001, 301)
  INTO enrollment (enroll_id, enroll_date, student_id, course_id) VALUES (4002, TRUNC(SYSDATE) - 60, 2001, 302)
  INTO enrollment (enroll_id, enroll_date, student_id, course_id) VALUES (4003, TRUNC(SYSDATE) - 60, 2002, 302)
  INTO enrollment (enroll_id, enroll_date, student_id, course_id) VALUES (4004, TRUNC(SYSDATE) - 60, 2002, 303)
  INTO enrollment (enroll_id, enroll_date, student_id, course_id) VALUES (4005, TRUNC(SYSDATE) - 60, 2003, 303)
  INTO enrollment (enroll_id, enroll_date, student_id, course_id) VALUES (4006, TRUNC(SYSDATE) - 60, 2003, 304)
  INTO enrollment (enroll_id, enroll_date, student_id, course_id) VALUES (4007, TRUNC(SYSDATE) - 60, 2004, 304)
  INTO enrollment (enroll_id, enroll_date, student_id, course_id) VALUES (4008, TRUNC(SYSDATE) - 60, 2004, 305)
  INTO enrollment (enroll_id, enroll_date, student_id, course_id) VALUES (4009, TRUNC(SYSDATE) - 60, 2005, 305)
  INTO enrollment (enroll_id, enroll_date, student_id, course_id) VALUES (4010, TRUNC(SYSDATE) - 60, 2005, 306)
  INTO enrollment (enroll_id, enroll_date, student_id, course_id) VALUES (4011, TRUNC(SYSDATE) - 60, 2006, 306)
  INTO enrollment (enroll_id, enroll_date, student_id, course_id) VALUES (4012, TRUNC(SYSDATE) - 60, 2006, 307)
  INTO enrollment (enroll_id, enroll_date, student_id, course_id) VALUES (4013, TRUNC(SYSDATE) - 60, 2007, 307)
  INTO enrollment (enroll_id, enroll_date, student_id, course_id) VALUES (4014, TRUNC(SYSDATE) - 60, 2007, 308)
  INTO enrollment (enroll_id, enroll_date, student_id, course_id) VALUES (4015, TRUNC(SYSDATE) - 60, 2008, 308)
  INTO enrollment (enroll_id, enroll_date, student_id, course_id) VALUES (4016, TRUNC(SYSDATE) - 60, 2008, 309)
  INTO enrollment (enroll_id, enroll_date, student_id, course_id) VALUES (4017, TRUNC(SYSDATE) - 60, 2009, 309)
  INTO enrollment (enroll_id, enroll_date, student_id, course_id) VALUES (4018, TRUNC(SYSDATE) - 60, 2009, 310)
  INTO enrollment (enroll_id, enroll_date, student_id, course_id) VALUES (4019, TRUNC(SYSDATE) - 60, 2010, 310)
  INTO enrollment (enroll_id, enroll_date, student_id, course_id) VALUES (4020, TRUNC(SYSDATE) - 60, 2010, 301)
SELECT 1 FROM dual;

PROMPT ============================================================
PROMPT 6. EXAM - 10 completed examinations (one per course)
PROMPT ============================================================
INSERT ALL
  INTO exam (exam_id, exam_title, exam_date, duration_min, total_marks, pass_marks, status, course_id) VALUES (501, 'Database Systems - Mid-Semester MCQ', TRUNC(SYSDATE) - 14, 30, 30, 12, 'COMPLETED', 301)
  INTO exam (exam_id, exam_title, exam_date, duration_min, total_marks, pass_marks, status, course_id) VALUES (502, 'Data Structures and Algorithms - Mid-Semester MCQ', TRUNC(SYSDATE) - 14, 30, 30, 12, 'COMPLETED', 302)
  INTO exam (exam_id, exam_title, exam_date, duration_min, total_marks, pass_marks, status, course_id) VALUES (503, 'Operating Systems - Mid-Semester MCQ', TRUNC(SYSDATE) - 14, 30, 30, 12, 'COMPLETED', 303)
  INTO exam (exam_id, exam_title, exam_date, duration_min, total_marks, pass_marks, status, course_id) VALUES (504, 'Computer Networks - Mid-Semester MCQ', TRUNC(SYSDATE) - 14, 30, 30, 12, 'COMPLETED', 304)
  INTO exam (exam_id, exam_title, exam_date, duration_min, total_marks, pass_marks, status, course_id) VALUES (505, 'Software Engineering - Mid-Semester MCQ', TRUNC(SYSDATE) - 14, 30, 30, 12, 'COMPLETED', 305)
  INTO exam (exam_id, exam_title, exam_date, duration_min, total_marks, pass_marks, status, course_id) VALUES (506, 'Digital Logic Design - Mid-Semester MCQ', TRUNC(SYSDATE) - 14, 30, 30, 12, 'COMPLETED', 306)
  INTO exam (exam_id, exam_title, exam_date, duration_min, total_marks, pass_marks, status, course_id) VALUES (507, 'Electrical Circuits - Mid-Semester MCQ', TRUNC(SYSDATE) - 14, 30, 30, 12, 'COMPLETED', 307)
  INTO exam (exam_id, exam_title, exam_date, duration_min, total_marks, pass_marks, status, course_id) VALUES (508, 'Engineering Mechanics - Mid-Semester MCQ', TRUNC(SYSDATE) - 14, 30, 30, 12, 'COMPLETED', 308)
  INTO exam (exam_id, exam_title, exam_date, duration_min, total_marks, pass_marks, status, course_id) VALUES (509, 'Engineering Mathematics - Mid-Semester MCQ', TRUNC(SYSDATE) - 14, 30, 30, 12, 'COMPLETED', 309)
  INTO exam (exam_id, exam_title, exam_date, duration_min, total_marks, pass_marks, status, course_id) VALUES (510, 'Introduction to Data Analytics - Mid-Semester MCQ', TRUNC(SYSDATE) - 14, 30, 30, 12, 'COMPLETED', 310)
SELECT 1 FROM dual;

PROMPT ============================================================
PROMPT 7. QUESTION - 30 meaningful MCQs (3 per exam, 10 marks each)
PROMPT ============================================================
INSERT ALL
  INTO question (question_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks, exam_id) VALUES (101, 'Which SQL statement is used to retrieve rows from a table?', 'INSERT', 'SELECT', 'UPDATE', 'DELETE', 'B', 10, 501)
  INTO question (question_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks, exam_id) VALUES (102, 'Which constraint uniquely identifies each row in a table?', 'PRIMARY KEY', 'CHECK', 'DEFAULT', 'NOT NULL', 'A', 10, 501)
  INTO question (question_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks, exam_id) VALUES (103, 'Which SQL operation combines rows from related tables?', 'ORDER BY', 'GROUP BY', 'JOIN', 'DISTINCT', 'C', 10, 501)
  INTO question (question_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks, exam_id) VALUES (201, 'Which data structure follows the LIFO principle?', 'Queue', 'Stack', 'Tree', 'Graph', 'B', 10, 502)
  INTO question (question_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks, exam_id) VALUES (202, 'What is the time complexity of binary search on a sorted array?', 'O(n)', 'O(n log n)', 'O(log n)', 'O(1)', 'C', 10, 502)
  INTO question (question_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks, exam_id) VALUES (203, 'Which data structure is commonly used for breadth-first search?', 'Stack', 'Queue', 'Heap', 'Hash table', 'B', 10, 502)
  INTO question (question_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks, exam_id) VALUES (301, 'Which operating system component schedules processes on the CPU?', 'Compiler', 'Scheduler', 'Loader', 'Linker', 'B', 10, 503)
  INTO question (question_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks, exam_id) VALUES (302, 'Which state describes a process waiting for an event?', 'Running', 'Ready', 'Blocked', 'Terminated', 'C', 10, 503)
  INTO question (question_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks, exam_id) VALUES (303, 'Which memory technique divides memory into fixed-size blocks?', 'Paging', 'Spooling', 'Parsing', 'Caching', 'A', 10, 503)
  INTO question (question_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks, exam_id) VALUES (401, 'Which protocol provides reliable, connection-oriented transport?', 'UDP', 'IP', 'TCP', 'ARP', 'C', 10, 504)
  INTO question (question_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks, exam_id) VALUES (402, 'Which service translates domain names into IP addresses?', 'DHCP', 'DNS', 'FTP', 'SMTP', 'B', 10, 504)
  INTO question (question_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks, exam_id) VALUES (403, 'How many bits are in an IPv4 address?', '16', '32', '64', '128', 'B', 10, 504)
  INTO question (question_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks, exam_id) VALUES (501, 'Which activity identifies what a software system must do?', 'Requirement analysis', 'Deployment', 'Maintenance', 'Coding only', 'A', 10, 505)
  INTO question (question_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks, exam_id) VALUES (502, 'Which testing level checks individual program units?', 'System testing', 'Acceptance testing', 'Unit testing', 'Regression testing', 'C', 10, 505)
  INTO question (question_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks, exam_id) VALUES (503, 'Which model performs development in sequential phases?', 'Agile', 'Waterfall', 'Spiral only', 'Prototype only', 'B', 10, 505)
  INTO question (question_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks, exam_id) VALUES (601, 'What is the output of an AND gate when both inputs are 1?', '0', '1', 'Undefined', 'High impedance', 'B', 10, 506)
  INTO question (question_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks, exam_id) VALUES (602, 'How many bits are in a standard binary digit?', '1', '2', '4', '8', 'A', 10, 506)
  INTO question (question_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks, exam_id) VALUES (603, 'Which circuit stores one bit of information?', 'Multiplexer', 'Encoder', 'Flip-flop', 'Adder', 'C', 10, 506)
  INTO question (question_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks, exam_id) VALUES (701, 'What is the SI unit of electrical resistance?', 'Volt', 'Ampere', 'Ohm', 'Watt', 'C', 10, 507)
  INTO question (question_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks, exam_id) VALUES (702, 'Which law states V = I × R?', 'Faraday law', 'Ohm law', 'Kirchhoff current law', 'Lenz law', 'B', 10, 507)
  INTO question (question_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks, exam_id) VALUES (703, 'What happens to total resistance in a series circuit?', 'It is the sum of resistances', 'It is always zero', 'It is the smallest resistance', 'It is always one ohm', 'A', 10, 507)
  INTO question (question_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks, exam_id) VALUES (801, 'What is the SI unit of force?', 'Joule', 'Newton', 'Pascal', 'Watt', 'B', 10, 508)
  INTO question (question_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks, exam_id) VALUES (802, 'Newton's second law is commonly expressed as which equation?', 'F = ma', 'P = IV', 'V = IR', 'E = mc', 'A', 10, 508)
  INTO question (question_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks, exam_id) VALUES (803, 'Work is equal to force multiplied by which quantity in the force direction?', 'Time', 'Mass', 'Displacement', 'Acceleration', 'C', 10, 508)
  INTO question (question_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks, exam_id) VALUES (901, 'What is the derivative of x squared with respect to x?', 'x', '2x', 'x squared', '2', 'B', 10, 509)
  INTO question (question_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks, exam_id) VALUES (902, 'What is the probability of getting heads on a fair coin toss?', '0', '0.25', '0.5', '1', 'C', 10, 509)
  INTO question (question_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks, exam_id) VALUES (903, 'What is the determinant of [[1, 0], [0, 1]]?', '0', '1', '2', '-1', 'B', 10, 509)
  INTO question (question_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks, exam_id) VALUES (1001, 'Which measure represents the arithmetic average?', 'Median', 'Mode', 'Mean', 'Range', 'C', 10, 510)
  INTO question (question_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks, exam_id) VALUES (1002, 'Which learning approach uses labelled examples?', 'Unsupervised learning', 'Supervised learning', 'Reinforcement only', 'Clustering only', 'B', 10, 510)
  INTO question (question_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks, exam_id) VALUES (1003, 'Which SQL function counts rows?', 'SUM', 'AVG', 'COUNT', 'MAX', 'C', 10, 510)
SELECT 1 FROM dual;

PROMPT ============================================================
PROMPT 8. RESULT - 20 completed attempts (2 per student)
PROMPT Scores are out of 30; percentages and grades match the scores.
PROMPT ============================================================
INSERT ALL
  INTO result (result_id, score, percentage, grade, attempt_date, student_id, exam_id) VALUES (6001, 27, 90.00, 'A', TRUNC(SYSDATE) - 12, 2001, 501)
  INTO result (result_id, score, percentage, grade, attempt_date, student_id, exam_id) VALUES (6002, 22, 73.33, 'C', TRUNC(SYSDATE) - 12, 2001, 502)
  INTO result (result_id, score, percentage, grade, attempt_date, student_id, exam_id) VALUES (6003, 24, 80.00, 'B', TRUNC(SYSDATE) - 12, 2002, 502)
  INTO result (result_id, score, percentage, grade, attempt_date, student_id, exam_id) VALUES (6004, 26, 86.67, 'B', TRUNC(SYSDATE) - 12, 2002, 503)
  INTO result (result_id, score, percentage, grade, attempt_date, student_id, exam_id) VALUES (6005, 21, 70.00, 'C', TRUNC(SYSDATE) - 12, 2003, 503)
  INTO result (result_id, score, percentage, grade, attempt_date, student_id, exam_id) VALUES (6006, 17, 56.67, 'E', TRUNC(SYSDATE) - 12, 2003, 504)
  INTO result (result_id, score, percentage, grade, attempt_date, student_id, exam_id) VALUES (6007, 18, 60.00, 'D', TRUNC(SYSDATE) - 12, 2004, 504)
  INTO result (result_id, score, percentage, grade, attempt_date, student_id, exam_id) VALUES (6008, 28, 93.33, 'A', TRUNC(SYSDATE) - 12, 2004, 505)
  INTO result (result_id, score, percentage, grade, attempt_date, student_id, exam_id) VALUES (6009, 15, 50.00, 'E', TRUNC(SYSDATE) - 12, 2005, 505)
  INTO result (result_id, score, percentage, grade, attempt_date, student_id, exam_id) VALUES (6010, 14, 46.67, 'F', TRUNC(SYSDATE) - 12, 2005, 506)
  INTO result (result_id, score, percentage, grade, attempt_date, student_id, exam_id) VALUES (6011, 12, 40.00, 'F', TRUNC(SYSDATE) - 12, 2006, 506)
  INTO result (result_id, score, percentage, grade, attempt_date, student_id, exam_id) VALUES (6012, 19, 63.33, 'D', TRUNC(SYSDATE) - 12, 2006, 507)
  INTO result (result_id, score, percentage, grade, attempt_date, student_id, exam_id) VALUES (6013, 9, 30.00, 'F', TRUNC(SYSDATE) - 12, 2007, 507)
  INTO result (result_id, score, percentage, grade, attempt_date, student_id, exam_id) VALUES (6014, 29, 96.67, 'A', TRUNC(SYSDATE) - 12, 2007, 508)
  INTO result (result_id, score, percentage, grade, attempt_date, student_id, exam_id) VALUES (6015, 30, 100.00, 'A', TRUNC(SYSDATE) - 12, 2008, 508)
  INTO result (result_id, score, percentage, grade, attempt_date, student_id, exam_id) VALUES (6016, 16, 53.33, 'E', TRUNC(SYSDATE) - 12, 2008, 509)
  INTO result (result_id, score, percentage, grade, attempt_date, student_id, exam_id) VALUES (6017, 25, 83.33, 'B', TRUNC(SYSDATE) - 12, 2009, 509)
  INTO result (result_id, score, percentage, grade, attempt_date, student_id, exam_id) VALUES (6018, 23, 76.67, 'C', TRUNC(SYSDATE) - 12, 2009, 510)
  INTO result (result_id, score, percentage, grade, attempt_date, student_id, exam_id) VALUES (6019, 20, 66.67, 'D', TRUNC(SYSDATE) - 12, 2010, 510)
  INTO result (result_id, score, percentage, grade, attempt_date, student_id, exam_id) VALUES (6020, 11, 36.67, 'F', TRUNC(SYSDATE) - 12, 2010, 501)
SELECT 1 FROM dual;

COMMIT;

PROMPT ============================================================
PROMPT 9. VERIFY ROW COUNTS - EACH TABLE MUST HAVE AT LEAST 10
PROMPT ============================================================
SELECT 'DEPARTMENT' AS table_name, COUNT(*) AS row_count FROM department
UNION ALL SELECT 'FACULTY', COUNT(*) FROM faculty
UNION ALL SELECT 'STUDENT', COUNT(*) FROM student
UNION ALL SELECT 'COURSE', COUNT(*) FROM course
UNION ALL SELECT 'ENROLLMENT', COUNT(*) FROM enrollment
UNION ALL SELECT 'EXAM', COUNT(*) FROM exam
UNION ALL SELECT 'QUESTION', COUNT(*) FROM question
UNION ALL SELECT 'RESULT', COUNT(*) FROM result
ORDER BY table_name;

PROMPT ============================================================
PROMPT SAMPLE DATA INSERTION COMPLETE.
PROMPT Expected counts: DEPARTMENT 10, FACULTY 10, STUDENT 10, COURSE 10,
PROMPT ENROLLMENT 20, EXAM 10, QUESTION 30, RESULT 20.
PROMPT ============================================================
