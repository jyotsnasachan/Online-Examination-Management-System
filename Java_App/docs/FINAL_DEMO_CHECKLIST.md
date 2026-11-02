# Final Demonstration Checklist

## Database
- [ ] Start Oracle Docker container.
- [ ] Connect to DBMS_PROJECT / FREEPDB1.
- [ ] Verify all eight project tables.
- [ ] Verify procedures, functions and triggers are VALID.

## Application
- [ ] Launch using ./run.command.
- [ ] Verify dashboard counts.
- [ ] Open Students and verify sample data.
- [ ] Open Examinations and verify exam records.
- [ ] Open Results and verify stored marks and grades.
- [ ] Open Take Examination.
- [ ] Load an eligible ongoing examination.
- [ ] Submit an MCQ attempt and verify its result.
- [ ] Verify a timeout submission.
- [ ] Open Administration.
- [ ] Create a scheduled examination.
- [ ] Add questions whose marks equal the exam total.
- [ ] Publish the examination.
- [ ] Verify that the published examination appears for eligible students.

## Evidence
- [ ] Dashboard screenshot.
- [ ] Student list screenshot.
- [ ] Examination list screenshot.
- [ ] MCQ question screen.
- [ ] Result popup screenshot.
- [ ] Admin create / add question / publish screenshots.
- [ ] SQL script output and PL/SQL object validation output.

## Submission
- [ ] Keep SQL scripts and Java source files together.
- [ ] Include README.md and this checklist.
- [ ] Never include database passwords.
