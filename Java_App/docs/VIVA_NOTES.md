# Viva Notes - Online Examination Management System

## Project purpose
The system stores students, departments, faculty, courses,
enrollments, examinations, questions and examination results.

## Database
Oracle AI Database 26ai Free is used as the relational database.
Primary keys uniquely identify rows. Foreign keys maintain
relationships and referential integrity.

## Java connectivity
JDBC connects the Java application to Oracle.
DriverManager obtains a Connection.
PreparedStatement executes parameterized SQL.
ResultSet reads query results.
CallableStatement calls stored procedures.

## PL/SQL
PR_SUBMIT_EXAM validates submitted answers and calculates marks.
TRG_RESULT_BIU generates result IDs and calculates percentage and grade.
FN_IS_STUDENT_ELIGIBLE checks student eligibility.
PR_PRINT_EXAM_ROSTER demonstrates an explicit cursor.

## User interface
Java Swing provides the desktop interface.
JTabbedPane separates Dashboard, Students, Examinations,
Results, Take Examination and Administration.

## Examination workflow
1. Select an eligible student.
2. Select an ongoing examination.
3. Load the MCQ questions.
4. Select answers.
5. Submit the attempt.
6. Java calls PR_SUBMIT_EXAM through JDBC.
7. Oracle stores the result.
8. The application displays score, percentage and grade.

## Integrity and validation
The schema uses primary keys, foreign keys, unique constraints,
NOT NULL constraints and CHECK constraints.
The question trigger prevents changes after an exam starts.
The completion trigger validates question-bank marks.

## Limitations to acknowledge
The current version is a desktop demonstration.
It does not yet have production-grade user authentication,
a web deployment, server-enforced timing or concurrent-user
security controls.
