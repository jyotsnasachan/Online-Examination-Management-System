import javax.swing.*;
import javax.swing.border.*;
import java.awt.*;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TakeExamPanel extends JPanel {

    private final JComboBox<StudentItem> studentBox = new JComboBox<>();
    private final JComboBox<ExamItem> examBox = new JComboBox<>();
    private final JPanel questionPanel = new JPanel();
    private final JLabel statusLabel = new JLabel("Select a student and examination.");
    private final JButton loadButton = new JButton("Load Questions");
    private final JButton submitButton = new JButton("Submit Examination");
    private final List<QuestionEntry> questions = new ArrayList<>();

    private Timer countdownTimer;
    private int secondsLeft;
    private boolean loading;
    private boolean attemptStarted;
    private boolean attemptFinished;
    private boolean timeoutReached;
    private boolean submitting;

    public TakeExamPanel() {
        setLayout(new BorderLayout(12, 12));
        setBorder(new EmptyBorder(18, 18, 18, 18));

        JPanel controls = new JPanel(new GridLayout(2, 3, 10, 8));
        controls.add(new JLabel("Select Student"));
        controls.add(new JLabel("Available Examination"));
        controls.add(new JLabel("Action"));
        controls.add(studentBox);
        controls.add(examBox);

        JPanel actions = new JPanel(new FlowLayout(FlowLayout.LEFT, 4, 0));
        actions.add(loadButton);
        controls.add(actions);
        add(controls, BorderLayout.NORTH);

        questionPanel.setLayout(new BoxLayout(questionPanel, BoxLayout.Y_AXIS));
        JScrollPane scroll = new JScrollPane(questionPanel);
        scroll.getVerticalScrollBar().setUnitIncrement(16);
        add(scroll, BorderLayout.CENTER);

        JPanel bottom = new JPanel(new BorderLayout());
        bottom.add(statusLabel, BorderLayout.CENTER);
        bottom.add(submitButton, BorderLayout.EAST);
        add(bottom, BorderLayout.SOUTH);

        submitButton.setEnabled(false);

        studentBox.addActionListener(e -> {
            if (!loading && !attemptStarted && !attemptFinished) {
                loadEligibleExams();
            }
        });

        loadButton.addActionListener(e -> loadQuestions());
        submitButton.addActionListener(e -> submitExam(timeoutReached));

        loadStudents();
    }

    private void loadStudents() {
        loading = true;
        studentBox.removeAllItems();

        try (Connection conn = Main.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT student_id, reg_no, student_name " +
                 "FROM student WHERE status='ACTIVE' ORDER BY reg_no");
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                studentBox.addItem(new StudentItem(
                    rs.getInt("student_id"),
                    rs.getString("reg_no"),
                    rs.getString("student_name")
                ));
            }
        } catch (SQLException e) {
            showError(e);
        }

        loading = false;
        if (studentBox.getItemCount() > 0) loadEligibleExams();
    }

    private void loadEligibleExams() {
        examBox.removeAllItems();
        clearQuestions();

        StudentItem student = (StudentItem) studentBox.getSelectedItem();
        if (student == null) return;

        String sql =
            "SELECT e.exam_id, e.exam_title, e.total_marks, e.duration_min " +
            "FROM exam e WHERE e.status='ONGOING' " +
            "AND EXISTS (SELECT 1 FROM enrollment en " +
            "WHERE en.course_id=e.course_id AND en.student_id=?) " +
            "AND NOT EXISTS (SELECT 1 FROM result r " +
            "WHERE r.student_id=? AND r.exam_id=e.exam_id) " +
            "ORDER BY e.exam_id";

        try (Connection conn = Main.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, student.id);
            ps.setInt(2, student.id);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    examBox.addItem(new ExamItem(
                        rs.getInt("exam_id"),
                        rs.getString("exam_title"),
                        rs.getInt("total_marks"),
                        rs.getInt("duration_min")
                    ));
                }
            }

            statusLabel.setText(examBox.getItemCount() == 0
                ? "No unattempted ongoing eligible examinations."
                : examBox.getItemCount() + " eligible examination(s) found.");

        } catch (SQLException e) {
            showError(e);
        }
    }

    private void loadQuestions() {
        if (attemptStarted || attemptFinished) return;

        ExamItem exam = (ExamItem) examBox.getSelectedItem();
        if (exam == null) {
            JOptionPane.showMessageDialog(this, "No eligible exam selected.");
            return;
        }

        clearQuestions();

        String sql =
            "SELECT question_id, question_text, option_a, option_b, " +
            "option_c, option_d, marks FROM question " +
            "WHERE exam_id=? ORDER BY question_id";

        try (Connection conn = Main.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, exam.id);

            try (ResultSet rs = ps.executeQuery()) {
                int number = 1;

                while (rs.next()) {
                    JPanel card = new JPanel(new BorderLayout(8, 8));
                    card.setBorder(new CompoundBorder(
                        new LineBorder(Color.LIGHT_GRAY),
                        new EmptyBorder(12, 12, 12, 12)
                    ));
                    card.setMaximumSize(new Dimension(Integer.MAX_VALUE, 190));

                    JLabel title = new JLabel(
                        number + ". " + rs.getString("question_text") +
                        "    [" + rs.getInt("marks") + " marks]"
                    );
                    title.setFont(new Font("Arial", Font.BOLD, 14));
                    card.add(title, BorderLayout.NORTH);

                    JPanel options = new JPanel(new GridLayout(2, 2, 8, 5));
                    String[] values = {
                        rs.getString("option_a"), rs.getString("option_b"),
                        rs.getString("option_c"), rs.getString("option_d")
                    };

                    JRadioButton[] buttons = new JRadioButton[4];
                    ButtonGroup group = new ButtonGroup();

                    for (int i = 0; i < 4; i++) {
                        buttons[i] = new JRadioButton(
                            (char) ('A' + i) + ". " + values[i]
                        );
                        group.add(buttons[i]);
                        options.add(buttons[i]);
                    }

                    card.add(options, BorderLayout.CENTER);
                    card.setAlignmentX(Component.LEFT_ALIGNMENT);
                    questionPanel.add(card);
                    questionPanel.add(Box.createVerticalStrut(10));

                    questions.add(new QuestionEntry(
                        rs.getInt("question_id"), buttons
                    ));
                    number++;
                }
            }

            questionPanel.revalidate();
            questionPanel.repaint();

            if (questions.isEmpty()) {
                statusLabel.setText("No questions available.");
                return;
            }

            attemptStarted = true;
            studentBox.setEnabled(false);
            examBox.setEnabled(false);
            loadButton.setEnabled(false);
            submitButton.setEnabled(true);

            secondsLeft = exam.duration * 60;
            updateCountdown();

            countdownTimer = new Timer(1000, e -> {
                secondsLeft--;

                if (secondsLeft <= 0) {
                    secondsLeft = 0;
                    timeoutReached = true;
                    countdownTimer.stop();
                    submitExam(true);
                } else {
                    updateCountdown();
                }
            });

            countdownTimer.start();

        } catch (SQLException e) {
            showError(e);
        }
    }

    private void updateCountdown() {
        int minutes = secondsLeft / 60;
        int seconds = secondsLeft % 60;

        statusLabel.setText(String.format(
            "TIME LEFT: %02d:%02d | %d questions | Timer running",
            minutes, seconds, questions.size()
        ));

        statusLabel.setForeground(
            secondsLeft <= 30 ? Color.RED : new Color(35, 90, 55)
        );
    }

    private void submitExam(boolean automatic) {
        if (submitting || attemptFinished || questions.isEmpty()) return;

        StudentItem student = (StudentItem) studentBox.getSelectedItem();
        ExamItem exam = (ExamItem) examBox.getSelectedItem();
        if (student == null || exam == null) return;

        StringBuilder answers = new StringBuilder();

        for (QuestionEntry q : questions) {
            int selected = -1;

            for (int i = 0; i < 4; i++) {
                if (q.buttons[i].isSelected()) {
                    selected = i;
                    break;
                }
            }

            if (selected == -1 && !automatic) {
                JOptionPane.showMessageDialog(this,
                    "Please answer every question before submitting.",
                    "Incomplete Examination",
                    JOptionPane.WARNING_MESSAGE);
                return;
            }

            if (answers.length() > 0) answers.append(",");
            answers.append(q.id).append(":")
                   .append(selected == -1 ? "N" : String.valueOf((char) ('A' + selected)));
        }

        if (!automatic) {
            int confirm = JOptionPane.showConfirmDialog(this,
                "Are you sure you want to submit your examination?",
                "Confirm Submission", JOptionPane.YES_NO_OPTION);

            if (confirm != JOptionPane.YES_OPTION) return;
        }

        if (countdownTimer != null) countdownTimer.stop();

        submitting = true;
        submitButton.setEnabled(false);
        statusLabel.setText(automatic
            ? "Time expired. Submitting your answers..."
            : "Submitting examination...");

        try (Connection conn = Main.getConnection()) {
            conn.setAutoCommit(false);

            try {
                try (CallableStatement cs =
                    conn.prepareCall("{call pr_submit_exam(?, ?, ?)}")) {
                    cs.setInt(1, student.id);
                    cs.setInt(2, exam.id);
                    cs.setString(3, answers.toString());
                    cs.execute();
                }

                conn.commit();
                attemptFinished = true;

                for (QuestionEntry q : questions) {
                    for (JRadioButton b : q.buttons) b.setEnabled(false);
                }

                try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT score, percentage, grade FROM result " +
                    "WHERE student_id=? AND exam_id=?")) {

                    ps.setInt(1, student.id);
                    ps.setInt(2, exam.id);

                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            String result =
                                "Score: " + rs.getString("score") +
                                " / " + exam.totalMarks +
                                "\nPercentage: " + rs.getString("percentage") +
                                "%\nGrade: " + rs.getString("grade") +
                                (automatic
                                    ? "\n\nTime expired. Unanswered questions received zero marks."
                                    : "");

                            statusLabel.setText("Examination submitted successfully.");
                            JOptionPane.showMessageDialog(this, result,
                                "Examination Result",
                                JOptionPane.INFORMATION_MESSAGE);
                        }
                    }
                }

            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }

        } catch (SQLException e) {
            statusLabel.setForeground(Color.RED);
            statusLabel.setText("Submission failed. You can retry.");
            submitButton.setText(timeoutReached
                ? "Retry Auto-Submission" : "Retry Submission");
            submitButton.setEnabled(true);

            // The timer has stopped; a retry submits the same saved selections.
            showError(e);

        } finally {
            submitting = false;
        }
    }

    private void clearQuestions() {
        questions.clear();
        questionPanel.removeAll();
        questionPanel.revalidate();
        questionPanel.repaint();
        submitButton.setEnabled(false);
    }

    private void showError(Exception e) {
        JOptionPane.showMessageDialog(this, e.getMessage(),
            "Database Error", JOptionPane.ERROR_MESSAGE);
    }

    private static class StudentItem {
        int id;
        String regNo, name;

        StudentItem(int id, String regNo, String name) {
            this.id = id;
            this.regNo = regNo;
            this.name = name;
        }

        public String toString() {
            return regNo + " - " + name;
        }
    }

    private static class ExamItem {
        int id, totalMarks, duration;
        String title;

        ExamItem(int id, String title, int totalMarks, int duration) {
            this.id = id;
            this.title = title;
            this.totalMarks = totalMarks;
            this.duration = duration;
        }

        public String toString() {
            return id + " - " + title;
        }
    }

    private static class QuestionEntry {
        int id;
        JRadioButton[] buttons;

        QuestionEntry(int id, JRadioButton[] buttons) {
            this.id = id;
            this.buttons = buttons;
        }
    }
}
