-- ============================================================
-- BCSE302L - DATABASE SYSTEMS
-- Online Examination Management System
-- Recovery script for the sample-data insertion
-- Oracle Database 26ai Free / SQL Developer
--
-- PURPOSE:
-- The original sample-data script inserted the first six table
-- groups, but the QUESTION section contained an unescaped
-- apostrophe in "Newton's second law". This script safely adds
-- any missing QUESTION and RESULT rows only.
--
-- SAFE TO RUN MORE THAN ONCE: MERGE avoids duplicate question IDs
-- and duplicate student/exam results.
-- Connect as DBMS_PROJECT to FREEPDB1 and run with F5.
-- ============================================================

SET DEFINE OFF;
SET SERVEROUTPUT ON;

PROMPT ============================================================
PROMPT REPAIR 1. Insert any missing QUESTION rows (30 total expected)
PROMPT ============================================================

MERGE INTO question q
USING (
    SELECT 101 question_id, 'Which SQL statement is used to retrieve rows from a table?' question_text, 'INSERT' option_a, 'SELECT' option_b, 'UPDATE' option_c, 'DELETE' option_d, 'B' correct_option, 10 marks, 501 exam_id FROM dual
    UNION ALL SELECT 102, 'Which constraint uniquely identifies each row in a table?', 'PRIMARY KEY', 'CHECK', 'DEFAULT', 'NOT NULL', 'A', 10, 501 FROM dual
    UNION ALL SELECT 103, 'Which SQL operation combines rows from related tables?', 'ORDER BY', 'GROUP BY', 'JOIN', 'DISTINCT', 'C', 10, 501 FROM dual
    UNION ALL SELECT 201, 'Which data structure follows the LIFO principle?', 'Queue', 'Stack', 'Tree', 'Graph', 'B', 10, 502 FROM dual
    UNION ALL SELECT 202, 'What is the time complexity of binary search on a sorted array?', 'O(n)', 'O(n log n)', 'O(log n)', 'O(1)', 'C', 10, 502 FROM dual
    UNION ALL SELECT 203, 'Which data structure is commonly used for breadth-first search?', 'Stack', 'Queue', 'Heap', 'Hash table', 'B', 10, 502 FROM dual
    UNION ALL SELECT 301, 'Which operating system component schedules processes on the CPU?', 'Compiler', 'Scheduler', 'Loader', 'Linker', 'B', 10, 503 FROM dual
    UNION ALL SELECT 302, 'Which state describes a process waiting for an event?', 'Running', 'Ready', 'Blocked', 'Terminated', 'C', 10, 503 FROM dual
    UNION ALL SELECT 303, 'Which memory technique divides memory into fixed-size blocks?', 'Paging', 'Spooling', 'Parsing', 'Caching', 'A', 10, 503 FROM dual
    UNION ALL SELECT 401, 'Which protocol provides reliable, connection-oriented transport?', 'UDP', 'IP', 'TCP', 'ARP', 'C', 10, 504 FROM dual
    UNION ALL SELECT 402, 'Which service translates domain names into IP addresses?', 'DHCP', 'DNS', 'FTP', 'SMTP', 'B', 10, 504 FROM dual
    UNION ALL SELECT 403, 'How many bits are in an IPv4 address?', '16', '32', '64', '128', 'B', 10, 504 FROM dual
    UNION ALL SELECT 501, 'Which activity identifies what a software system must do?', 'Requirement analysis', 'Deployment', 'Maintenance', 'Coding only', 'A', 10, 505 FROM dual
    UNION ALL SELECT 502, 'Which testing level checks individual program units?', 'System testing', 'Acceptance testing', 'Unit testing', 'Regression testing', 'C', 10, 505 FROM dual
    UNION ALL SELECT 503, 'Which model performs development in sequential phases?', 'Agile', 'Waterfall', 'Spiral only', 'Prototype only', 'B', 10, 505 FROM dual
    UNION ALL SELECT 601, 'What is the output of an AND gate when both inputs are 1?', '0', '1', 'Undefined', 'High impedance', 'B', 10, 506 FROM dual
    UNION ALL SELECT 602, 'How many bits are in a standard binary digit?', '1', '2', '4', '8', 'A', 10, 506 FROM dual
    UNION ALL SELECT 603, 'Which circuit stores one bit of information?', 'Multiplexer', 'Encoder', 'Flip-flop', 'Adder', 'C', 10, 506 FROM dual
    UNION ALL SELECT 701, 'What is the SI unit of electrical resistance?', 'Volt', 'Ampere', 'Ohm', 'Watt', 'C', 10, 507 FROM dual
    UNION ALL SELECT 702, 'Which law states V = I times R?', 'Faraday law', 'Ohm law', 'Kirchhoff current law', 'Lenz law', 'B', 10, 507 FROM dual
    UNION ALL SELECT 703, 'What happens to total resistance in a series circuit?', 'It is the sum of resistances', 'It is always zero', 'It is the smallest resistance', 'It is always one ohm', 'A', 10, 507 FROM dual
    UNION ALL SELECT 801, 'What is the SI unit of force?', 'Joule', 'Newton', 'Pascal', 'Watt', 'B', 10, 508 FROM dual
    UNION ALL SELECT 802, 'Newton''s second law is commonly expressed as which equation?', 'F = ma', 'P = IV', 'V = IR', 'E = mc', 'A', 10, 508 FROM dual
    UNION ALL SELECT 803, 'Work is equal to force multiplied by which quantity in the force direction?', 'Time', 'Mass', 'Displacement', 'Acceleration', 'C', 10, 508 FROM dual
    UNION ALL SELECT 901, 'What is the derivative of x squared with respect to x?', 'x', '2x', 'x squared', '2', 'B', 10, 509 FROM dual
    UNION ALL SELECT 902, 'What is the probability of getting heads on a fair coin toss?', '0', '0.25', '0.5', '1', 'C', 10, 509 FROM dual
    UNION ALL SELECT 903, 'What is the determinant of the 2 by 2 identity matrix?', '0', '1', '2', '-1', 'B', 10, 509 FROM dual
    UNION ALL SELECT 1001, 'Which measure represents the arithmetic average?', 'Median', 'Mode', 'Mean', 'Range', 'C', 10, 510 FROM dual
    UNION ALL SELECT 1002, 'Which learning approach uses labelled examples?', 'Unsupervised learning', 'Supervised learning', 'Reinforcement only', 'Clustering only', 'B', 10, 510 FROM dual
    UNION ALL SELECT 1003, 'Which SQL function counts rows?', 'SUM', 'AVG', 'COUNT', 'MAX', 'C', 10, 510 FROM dual
) s
ON (q.question_id = s.question_id)
WHEN NOT MATCHED THEN
    INSERT (question_id, question_text, option_a, option_b, option_c,
            option_d, correct_option, marks, exam_id)
    VALUES (s.question_id, s.question_text, s.option_a, s.option_b, s.option_c,
            s.option_d, s.correct_option, s.marks, s.exam_id);

PROMPT ============================================================
PROMPT REPAIR 2. Insert any missing RESULT rows (20 total expected)
PROMPT ============================================================

MERGE INTO result r
USING (
    SELECT 6001 result_id, 27 score, 90.00 percentage, 'A' grade, TRUNC(SYSDATE)-12 attempt_date, 2001 student_id, 501 exam_id FROM dual
    UNION ALL SELECT 6002, 22, 73.33, 'C', TRUNC(SYSDATE)-12, 2001, 502 FROM dual
    UNION ALL SELECT 6003, 24, 80.00, 'B', TRUNC(SYSDATE)-12, 2002, 502 FROM dual
    UNION ALL SELECT 6004, 26, 86.67, 'B', TRUNC(SYSDATE)-12, 2002, 503 FROM dual
    UNION ALL SELECT 6005, 21, 70.00, 'C', TRUNC(SYSDATE)-12, 2003, 503 FROM dual
    UNION ALL SELECT 6006, 17, 56.67, 'E', TRUNC(SYSDATE)-12, 2003, 504 FROM dual
    UNION ALL SELECT 6007, 18, 60.00, 'D', TRUNC(SYSDATE)-12, 2004, 504 FROM dual
    UNION ALL SELECT 6008, 28, 93.33, 'A', TRUNC(SYSDATE)-12, 2004, 505 FROM dual
    UNION ALL SELECT 6009, 15, 50.00, 'E', TRUNC(SYSDATE)-12, 2005, 505 FROM dual
    UNION ALL SELECT 6010, 14, 46.67, 'F', TRUNC(SYSDATE)-12, 2005, 506 FROM dual
    UNION ALL SELECT 6011, 12, 40.00, 'F', TRUNC(SYSDATE)-12, 2006, 506 FROM dual
    UNION ALL SELECT 6012, 19, 63.33, 'D', TRUNC(SYSDATE)-12, 2006, 507 FROM dual
    UNION ALL SELECT 6013, 9, 30.00, 'F', TRUNC(SYSDATE)-12, 2007, 507 FROM dual
    UNION ALL SELECT 6014, 29, 96.67, 'A', TRUNC(SYSDATE)-12, 2007, 508 FROM dual
    UNION ALL SELECT 6015, 30, 100.00, 'A', TRUNC(SYSDATE)-12, 2008, 508 FROM dual
    UNION ALL SELECT 6016, 16, 53.33, 'E', TRUNC(SYSDATE)-12, 2008, 509 FROM dual
    UNION ALL SELECT 6017, 25, 83.33, 'B', TRUNC(SYSDATE)-12, 2009, 509 FROM dual
    UNION ALL SELECT 6018, 23, 76.67, 'C', TRUNC(SYSDATE)-12, 2009, 510 FROM dual
    UNION ALL SELECT 6019, 20, 66.67, 'D', TRUNC(SYSDATE)-12, 2010, 510 FROM dual
    UNION ALL SELECT 6020, 11, 36.67, 'F', TRUNC(SYSDATE)-12, 2010, 501 FROM dual
) s
ON (r.student_id = s.student_id AND r.exam_id = s.exam_id)
WHEN NOT MATCHED THEN
    INSERT (result_id, score, percentage, grade, attempt_date, student_id, exam_id)
    VALUES (s.result_id, s.score, s.percentage, s.grade, s.attempt_date, s.student_id, s.exam_id);

-- Keep the sample grades consistent with pass_marks = 12/30 (40%).
-- Scores of 12 and 14 meet the passing threshold and receive grade E.
UPDATE result SET grade = 'E' WHERE result_id IN (6010, 6011) AND score >= 12;

COMMIT;

PROMPT ============================================================
PROMPT VERIFY ALL EIGHT TABLE COUNTS
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
PROMPT Expected minimums: 10, 10, 10, 10, 10, 10, 10, 10.
PROMPT Target demo counts: 10, 10, 10, 10, 20, 10, 30, 20.
PROMPT Repair script completed. Confirm every table has at least 10 rows.
PROMPT ============================================================
