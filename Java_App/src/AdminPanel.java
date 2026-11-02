import javax.swing.*;
import javax.swing.border.EmptyBorder;
import java.awt.*;
import java.sql.*;
import java.time.LocalDate;

public class AdminPanel extends JPanel {

    private final JTextField id = new JTextField();
    private final JTextField title = new JTextField();
    private final JTextField date = new JTextField(LocalDate.now().toString());
    private final JTextField duration = new JTextField("30");
    private final JTextField total = new JTextField("30");
    private final JTextField pass = new JTextField("12");

    private final JComboBox<Course> courses = new JComboBox<>();
    private final JComboBox<Exam> questionExams = new JComboBox<>();
    private final JComboBox<Exam> publishExams = new JComboBox<>();

    private final JTextField qid = new JTextField();
    private final JTextArea question = new JTextArea(3, 25);
    private final JTextField[] options = {
        new JTextField(), new JTextField(),
        new JTextField(), new JTextField()
    };
    private final JTextField marks = new JTextField("10");
    private final JComboBox<String> correct =
        new JComboBox<>(new String[]{"A", "B", "C", "D"});

    public AdminPanel() {
        setLayout(new BorderLayout());
        setBorder(new EmptyBorder(15, 15, 15, 15));

        JTabbedPane tabs = new JTabbedPane();
        tabs.addTab("Create Examination", examForm());
        tabs.addTab("Add Questions", questionForm());
        tabs.addTab("Publish Examination", publishForm());

        add(tabs, BorderLayout.CENTER);
        loadCourses();
        refreshExams();
    }

    private void field(JPanel p, String label, Component c) {
        p.add(new JLabel(label));
        p.add(c);
    }

    private JPanel examForm() {
        JPanel p = new JPanel(new GridLayout(0, 2, 10, 12));
        p.setBorder(new EmptyBorder(20, 25, 20, 25));

        field(p, "Exam ID (unique)", id);
        field(p, "Exam title", title);
        field(p, "Course", courses);
        field(p, "Exam date (YYYY-MM-DD)", date);
        field(p, "Duration in minutes", duration);
        field(p, "Total marks", total);
        field(p, "Passing marks", pass);

        JButton create = new JButton("Create Examination");
        create.addActionListener(e -> createExam());
        field(p, "Action", create);

        p.add(new JLabel("New exams start as SCHEDULED."));
        p.add(new JLabel(""));

        return p;
    }

    private JPanel questionForm() {
        JPanel p = new JPanel(new GridLayout(0, 2, 9, 9));
        p.setBorder(new EmptyBorder(15, 20, 15, 20));

        field(p, "Scheduled examination", questionExams);
        field(p, "Question ID (unique)", qid);
        field(p, "Question text", new JScrollPane(question));

        field(p, "Option A", options[0]);
        field(p, "Option B", options[1]);
        field(p, "Option C", options[2]);
        field(p, "Option D", options[3]);
        field(p, "Correct option", correct);
        field(p, "Marks", marks);

        JButton add = new JButton("Add Question");
        add.addActionListener(e -> addQuestion());

        JButton refresh = new JButton("Refresh Exams");
        refresh.addActionListener(e -> refreshExams());

        JPanel buttons = new JPanel();
        buttons.add(add);
        buttons.add(refresh);
        field(p, "Action", buttons);

        return p;
    }

    private JPanel publishForm() {
        JPanel p = new JPanel(new GridLayout(0, 2, 12, 15));
        p.setBorder(new EmptyBorder(35, 40, 35, 40));

        field(p, "Scheduled examination", publishExams);

        JButton refresh = new JButton("Refresh List");
        refresh.addActionListener(e -> refreshExams());
        field(p, "Refresh", refresh);

        JButton publish = new JButton("Start / Publish Examination");
        publish.addActionListener(e -> publishExam());
        field(p, "Action", publish);

        p.add(new JLabel(
            "Publication requires questions to total the configured marks."
        ));
        p.add(new JLabel(""));

        return p;
    }

    private void loadCourses() {
        courses.removeAllItems();

        String sql = "SELECT course_id, course_code, course_name " +
                     "FROM course ORDER BY course_code";

        try (Connection c = Main.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                courses.addItem(new Course(
                    rs.getInt(1), rs.getString(2), rs.getString(3)
                ));
            }
        } catch (SQLException e) {
            error(e);
        }
    }

    private void refreshExams() {
        questionExams.removeAllItems();
        publishExams.removeAllItems();

        String sql = "SELECT exam_id, exam_title, total_marks " +
                     "FROM exam WHERE status='SCHEDULED' ORDER BY exam_id";

        try (Connection c = Main.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                int examId = rs.getInt(1);
                String examTitle = rs.getString(2);
                double examMarks = rs.getDouble(3);

                questionExams.addItem(
                    new Exam(examId, examTitle, examMarks)
                );
                publishExams.addItem(
                    new Exam(examId, examTitle, examMarks)
                );
            }
        } catch (SQLException e) {
            error(e);
        }
    }

    private void createExam() {
        try {
            int examId = Integer.parseInt(id.getText().trim());
            int minutes = Integer.parseInt(duration.getText().trim());
            double totalMarks = Double.parseDouble(total.getText().trim());
            double passMarks = Double.parseDouble(pass.getText().trim());

            String examTitle = title.getText().trim();
            Course course = (Course) courses.getSelectedItem();

            if (examId <= 0 || examTitle.isEmpty() || course == null ||
                minutes < 1 || minutes > 600 || totalMarks <= 0 ||
                passMarks < 0 || passMarks > totalMarks) {
                throw new IllegalArgumentException(
                    "Enter valid exam details."
                );
            }

            String sql = "INSERT INTO exam " +
                "(exam_id, exam_title, exam_date, duration_min, " +
                "total_marks, pass_marks, status, course_id) " +
                "VALUES (?, ?, ?, ?, ?, ?, 'SCHEDULED', ?)";

            try (Connection c = Main.getConnection();
                 PreparedStatement ps = c.prepareStatement(sql)) {

                ps.setInt(1, examId);
                ps.setString(2, examTitle);
                ps.setDate(3, Date.valueOf(date.getText().trim()));
                ps.setInt(4, minutes);
                ps.setDouble(5, totalMarks);
                ps.setDouble(6, passMarks);
                ps.setInt(7, course.id);
                ps.executeUpdate();
            }

            JOptionPane.showMessageDialog(this,
                "Examination created successfully.\nStatus: SCHEDULED");

            id.setText("");
            title.setText("");
            refreshExams();

        } catch (Exception e) {
            error(e);
        }
    }

    private void addQuestion() {
        Exam exam = (Exam) questionExams.getSelectedItem();

        if (exam == null) {
            error(new Exception("Select a scheduled examination."));
            return;
        }

        try {
            int questionId = Integer.parseInt(qid.getText().trim());
            double questionMarks = Double.parseDouble(marks.getText().trim());
            String text = question.getText().trim();

            if (questionId <= 0 || questionMarks <= 0 || text.isEmpty()) {
                throw new IllegalArgumentException(
                    "Enter a valid question ID, text and marks."
                );
            }

            for (JTextField option : options) {
                if (option.getText().trim().isEmpty()) {
                    throw new IllegalArgumentException(
                        "All four options are required."
                    );
                }
            }

            String sql = "INSERT INTO question " +
                "(question_id, question_text, option_a, option_b, " +
                "option_c, option_d, correct_option, marks, exam_id) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

            try (Connection c = Main.getConnection();
                 PreparedStatement ps = c.prepareStatement(sql)) {

                ps.setInt(1, questionId);
                ps.setString(2, text);

                for (int i = 0; i < 4; i++) {
                    ps.setString(3 + i, options[i].getText().trim());
                }

                ps.setString(7, (String) correct.getSelectedItem());
                ps.setDouble(8, questionMarks);
                ps.setInt(9, exam.id);
                ps.executeUpdate();
            }

            JOptionPane.showMessageDialog(this,
                "Question added to examination " + exam.id);

            qid.setText("");
            question.setText("");
            for (JTextField option : options) option.setText("");

        } catch (Exception e) {
            error(e);
        }
    }

    private void publishExam() {
        Exam exam = (Exam) publishExams.getSelectedItem();

        if (exam == null) {
            error(new Exception("Select a scheduled examination."));
            return;
        }

        String sql = "SELECT COUNT(*), NVL(SUM(marks), 0) " +
                     "FROM question WHERE exam_id=?";

        try (Connection c = Main.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, exam.id);

            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                int count = rs.getInt(1);
                double questionMarks = rs.getDouble(2);

                if (count == 0 ||
                    Math.abs(questionMarks - exam.totalMarks) > 0.001) {
                    throw new IllegalArgumentException(
                        "Cannot publish examination.\nQuestions: " + count +
                        "\nQuestion marks: " + questionMarks +
                        "\nRequired marks: " + exam.totalMarks
                    );
                }
            }

            int choice = JOptionPane.showConfirmDialog(
                this, "Start " + exam.title + "?",
                "Confirm Publication", JOptionPane.YES_NO_OPTION
            );

            if (choice != JOptionPane.YES_OPTION) return;

            try (PreparedStatement update = c.prepareStatement(
                "UPDATE exam SET status='ONGOING' " +
                "WHERE exam_id=? AND status='SCHEDULED'")) {

                update.setInt(1, exam.id);
                if (update.executeUpdate() != 1) {
                    throw new SQLException("Refresh and retry.");
                }
            }

            JOptionPane.showMessageDialog(this,
                "Examination published and available to eligible students.");
            refreshExams();

        } catch (Exception e) {
            error(e);
        }
    }

    private void error(Exception e) {
        JOptionPane.showMessageDialog(this, e.getMessage(),
            "Administration Message", JOptionPane.ERROR_MESSAGE);
    }

    private static class Course {
        int id;
        String code, name;

        Course(int id, String code, String name) {
            this.id = id;
            this.code = code;
            this.name = name;
        }

        public String toString() {
            return code + " - " + name;
        }
    }

    private static class Exam {
        int id;
        String title;
        double totalMarks;

        Exam(int id, String title, double totalMarks) {
            this.id = id;
            this.title = title;
            this.totalMarks = totalMarks;
        }

        public String toString() {
            return id + " - " + title;
        }
    }
}
