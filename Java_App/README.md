# Online Examination Management System

## Technology
- Oracle AI Database 26ai Free
- Java 21
- Java Swing
- JDBC (Oracle ojdbc17 driver)
- PL/SQL

## Database
Oracle service: FREEPDB1
Schema: DBMS_PROJECT
Tables:
DEPARTMENT, FACULTY, STUDENT, COURSE,
ENROLLMENT, EXAM, QUESTION, RESULT

## Application Features
1. Dashboard showing database record counts.
2. Student records.
3. Examination catalogue.
4. Student examination results.
5. MCQ examination interface.
6. Automatic score, percentage and grade calculation.
7. Examination countdown and timeout submission.
8. Administrator examination creation.
9. Administrator question creation.
10. Examination publication after question-mark validation.

## Run on macOS
1. Start Docker Desktop.
2. Ensure the oracle26ai container is running.
3. Open Terminal in this folder.
4. Run: ./run.command
5. Enter the DBMS_PROJECT password in the application prompt.

## Important
The JDBC driver is stored in lib/ojdbc17.jar.
Do not publish database passwords.
The administrator tab is a demonstration interface and does not
currently implement separate role-based authentication.
The countdown is enforced by the desktop application.

## Main source files
src/Main.java
src/TakeExamPanel.java
src/AdminPanel.java
lib/ojdbc17.jar
